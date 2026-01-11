"""
Decisions repository for Supabase database operations.

Uses service role key to bypass RLS - ownership enforcement is done in code.
"""

from datetime import datetime
from typing import Any
from uuid import UUID

from supabase import Client

from app.core.logging import get_logger
from app.db.supabase_client import get_supabase_client
from app.models.decision_intake import (
    DecisionStatus,
    NormalizedIntake,
)

logger = get_logger(__name__)


class DecisionNotFoundError(Exception):
    """Raised when a decision is not found or user doesn't have access."""

    pass


class DecisionCreateError(Exception):
    """Raised when decision creation fails."""

    pass


class DecisionsRepository:
    """
    Repository for decision CRUD operations.

    All methods enforce ownership by comparing user_id.
    Service role bypasses RLS, so we must check ownership in code.
    """

    def __init__(self, client: Client | None = None):
        """
        Initialize repository.

        Args:
            client: Optional Supabase client (for testing)
        """
        self._client = client

    @property
    def client(self) -> Client:
        """Get or create Supabase client."""
        if self._client is None:
            self._client = get_supabase_client()
        return self._client

    def _intake_to_json(self, intake: NormalizedIntake) -> dict[str, Any]:
        """Convert normalized intake to JSON-serializable dict."""
        return intake.model_dump(mode="json", exclude={"warnings"})

    def _parse_datetime(self, value: str | datetime) -> datetime:
        """Parse datetime from string or return as-is."""
        if isinstance(value, datetime):
            return value
        return datetime.fromisoformat(value.replace("Z", "+00:00"))

    async def create_decision(
        self,
        user_id: UUID,
        intake: NormalizedIntake,
    ) -> dict[str, Any]:
        """
        Create a new decision with intake data.

        Args:
            user_id: The user creating the decision
            intake: Normalized intake data

        Returns:
            Dict with decision_id, status, created_at, updated_at

        Raises:
            DecisionCreateError: If creation fails
        """
        decision_id: UUID | None = None

        try:
            # Create decision row
            decision_data = {
                "user_id": str(user_id),
                "title": intake.title,
                "statement": intake.statement,
                "status": DecisionStatus.DRAFT.value,
                "intake_json": self._intake_to_json(intake),
            }

            result = (
                self.client.table("decisions").insert(decision_data).execute()
            )

            if not result.data:
                raise DecisionCreateError("Failed to create decision")

            decision = result.data[0]
            decision_id = UUID(decision["id"])

            # Create options
            if intake.options:
                options_data = [
                    {
                        "decision_id": str(decision_id),
                        "label": opt.label,
                        "description": f"{opt.name}\n\n{opt.description}".strip(),
                    }
                    for opt in intake.options
                ]

                options_result = (
                    self.client.table("options").insert(options_data).execute()
                )

                if not options_result.data:
                    # Rollback: delete the decision
                    self.client.table("decisions").delete().eq(
                        "id", str(decision_id)
                    ).execute()
                    raise DecisionCreateError("Failed to create options")

            logger.info(
                "Decision created",
                decision_id=str(decision_id),
                options_count=len(intake.options),
            )

            return {
                "decision_id": decision_id,
                "status": DecisionStatus(decision["status"]),
                "created_at": self._parse_datetime(decision["created_at"]),
                "updated_at": self._parse_datetime(decision["updated_at"]),
            }

        except DecisionCreateError:
            raise
        except Exception as e:
            logger.error("Failed to create decision", error=str(e))
            # Attempt rollback if decision was created
            if decision_id:
                try:
                    self.client.table("decisions").delete().eq(
                        "id", str(decision_id)
                    ).execute()
                except Exception:
                    pass
            raise DecisionCreateError(f"Failed to create decision: {e}")

    async def list_decisions(self, user_id: UUID) -> list[dict[str, Any]]:
        """
        List all decisions for a user.

        Args:
            user_id: The user's ID

        Returns:
            List of decision summaries
        """
        result = (
            self.client.table("decisions")
            .select("id, title, status, updated_at")
            .eq("user_id", str(user_id))
            .order("updated_at", desc=True)
            .execute()
        )

        return [
            {
                "decision_id": UUID(d["id"]),
                "title": d["title"],
                "status": DecisionStatus(d["status"]),
                "updated_at": self._parse_datetime(d["updated_at"]),
            }
            for d in (result.data or [])
        ]

    async def get_decision(
        self,
        user_id: UUID,
        decision_id: UUID,
    ) -> dict[str, Any]:
        """
        Get a single decision with full intake data.

        Args:
            user_id: The requesting user's ID
            decision_id: The decision to retrieve

        Returns:
            Full decision data including intake

        Raises:
            DecisionNotFoundError: If not found or unauthorized
        """
        result = (
            self.client.table("decisions")
            .select("*")
            .eq("id", str(decision_id))
            .execute()
        )

        if not result.data:
            raise DecisionNotFoundError("Decision not found")

        decision = result.data[0]

        # Enforce ownership
        if decision["user_id"] != str(user_id):
            # Return 404 to not leak existence
            raise DecisionNotFoundError("Decision not found")

        return {
            "decision_id": UUID(decision["id"]),
            "status": DecisionStatus(decision["status"]),
            "created_at": self._parse_datetime(decision["created_at"]),
            "updated_at": self._parse_datetime(decision["updated_at"]),
            "intake": decision.get("intake_json", {}),
        }

    async def replace_decision(
        self,
        user_id: UUID,
        decision_id: UUID,
        intake: NormalizedIntake,
    ) -> dict[str, Any]:
        """
        Replace a decision's intake data (full replace).

        Args:
            user_id: The requesting user's ID
            decision_id: The decision to update
            intake: New normalized intake data

        Returns:
            Updated decision data

        Raises:
            DecisionNotFoundError: If not found or unauthorized
        """
        # First verify ownership
        existing = (
            self.client.table("decisions")
            .select("id, user_id")
            .eq("id", str(decision_id))
            .execute()
        )

        if not existing.data:
            raise DecisionNotFoundError("Decision not found")

        if existing.data[0]["user_id"] != str(user_id):
            raise DecisionNotFoundError("Decision not found")

        # Update decision
        update_data = {
            "title": intake.title,
            "statement": intake.statement,
            "intake_json": self._intake_to_json(intake),
        }

        result = (
            self.client.table("decisions")
            .update(update_data)
            .eq("id", str(decision_id))
            .execute()
        )

        if not result.data:
            raise DecisionNotFoundError("Failed to update decision")

        decision = result.data[0]

        # Replace options: delete existing, insert new
        self.client.table("options").delete().eq(
            "decision_id", str(decision_id)
        ).execute()

        if intake.options:
            options_data = [
                {
                    "decision_id": str(decision_id),
                    "label": opt.label,
                    "description": f"{opt.name}\n\n{opt.description}".strip(),
                }
                for opt in intake.options
            ]
            self.client.table("options").insert(options_data).execute()

        logger.info(
            "Decision replaced",
            decision_id=str(decision_id),
            options_count=len(intake.options),
        )

        return {
            "decision_id": UUID(decision["id"]),
            "status": DecisionStatus(decision["status"]),
            "created_at": self._parse_datetime(decision["created_at"]),
            "updated_at": self._parse_datetime(decision["updated_at"]),
            "intake": self._intake_to_json(intake),
        }

    async def delete_decision(
        self,
        user_id: UUID,
        decision_id: UUID,
    ) -> bool:
        """
        Delete a decision and all related data.

        Args:
            user_id: The requesting user's ID
            decision_id: The decision to delete

        Returns:
            True if deleted

        Raises:
            DecisionNotFoundError: If not found or unauthorized
        """
        # Verify ownership
        existing = (
            self.client.table("decisions")
            .select("id, user_id")
            .eq("id", str(decision_id))
            .execute()
        )

        if not existing.data:
            raise DecisionNotFoundError("Decision not found")

        if existing.data[0]["user_id"] != str(user_id):
            raise DecisionNotFoundError("Decision not found")

        # Delete (cascades to options, criteria, etc.)
        self.client.table("decisions").delete().eq(
            "id", str(decision_id)
        ).execute()

        logger.info("Decision deleted", decision_id=str(decision_id))

        return True


# Singleton instance for dependency injection
_repo_instance: DecisionsRepository | None = None


def get_decisions_repo() -> DecisionsRepository:
    """Get the decisions repository singleton."""
    global _repo_instance
    if _repo_instance is None:
        _repo_instance = DecisionsRepository()
    return _repo_instance
