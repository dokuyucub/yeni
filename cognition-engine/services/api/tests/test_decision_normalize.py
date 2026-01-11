"""
Unit tests for decision intake normalization.
"""

import pytest

from app.models.decision_intake import (
    DecisionConstraints,
    DecisionIntakeRequest,
    DecisionOption,
    DecisionResources,
    DecisionRisk,
    DecisionStakeholders,
    GutPreference,
    ObjectiveKey,
    ObjectiveWeight,
    RiskTolerance,
    TimeHorizons,
)
from app.services.decision_normalize import (
    DEFAULT_OBJECTIVE_WEIGHTS,
    normalize_decision_intake,
    normalize_multiline,
    normalize_objectives,
    normalize_options,
    normalize_string_list,
    normalize_text,
)


# ============================================================================
# TEXT NORMALIZATION TESTS
# ============================================================================


class TestNormalizeText:
    """Tests for normalize_text function."""

    def test_none_returns_empty(self):
        assert normalize_text(None) == ""

    def test_strips_whitespace(self):
        assert normalize_text("  hello  ") == "hello"

    def test_collapses_internal_spaces(self):
        assert normalize_text("hello    world") == "hello world"

    def test_collapses_tabs(self):
        assert normalize_text("hello\t\tworld") == "hello world"

    def test_preserves_unicode(self):
        assert normalize_text("  héllo wörld  ") == "héllo wörld"

    def test_mixed_whitespace(self):
        assert normalize_text("  hello \t  world  ") == "hello world"


class TestNormalizeMultiline:
    """Tests for normalize_multiline function."""

    def test_none_returns_empty(self):
        assert normalize_multiline(None) == ""

    def test_strips_lines(self):
        assert normalize_multiline("  line1  \n  line2  ") == "line1\nline2"

    def test_collapses_blank_lines(self):
        assert normalize_multiline("line1\n\n\n\nline2") == "line1\n\nline2"

    def test_removes_trailing_empty_lines(self):
        assert normalize_multiline("line1\n\n\n") == "line1"


# ============================================================================
# OPTIONS NORMALIZATION TESTS
# ============================================================================


class TestNormalizeOptions:
    """Tests for options normalization."""

    def test_relabels_sequentially(self):
        options = [
            DecisionOption(label="X", name="Option A", description="Desc A"),
            DecisionOption(label="Y", name="Option B", description="Desc B"),
        ]
        warnings: list[str] = []
        result = normalize_options(options, warnings)

        assert len(result) == 2
        assert result[0].label == "O1"
        assert result[1].label == "O2"
        assert "options_relabeled" in warnings

    def test_removes_empty_name_options(self):
        options = [
            DecisionOption(label="O1", name="Option A", description="Desc A"),
            DecisionOption(label="O2", name="", description="Desc B"),
            DecisionOption(label="O3", name="Option C", description="Desc C"),
        ]
        warnings: list[str] = []
        result = normalize_options(options, warnings)

        assert len(result) == 2
        assert result[0].name == "Option A"
        assert result[1].name == "Option C"
        assert result[1].label == "O2"

    def test_trims_names_and_descriptions(self):
        options = [
            DecisionOption(
                label="O1", name="  Option A  ", description="  Desc A  "
            ),
            DecisionOption(label="O2", name="Option B", description=""),
        ]
        warnings: list[str] = []
        result = normalize_options(options, warnings)

        assert result[0].name == "Option A"
        assert result[0].description == "Desc A"

    def test_no_relabel_warning_when_correct(self):
        options = [
            DecisionOption(label="O1", name="Option A", description="Desc A"),
            DecisionOption(label="O2", name="Option B", description="Desc B"),
        ]
        warnings: list[str] = []
        normalize_options(options, warnings)

        assert "options_relabeled" not in warnings


# ============================================================================
# OBJECTIVES NORMALIZATION TESTS
# ============================================================================


class TestNormalizeObjectives:
    """Tests for objectives normalization."""

    def test_empty_returns_defaults(self):
        warnings: list[str] = []
        result = normalize_objectives([], warnings)

        assert result == DEFAULT_OBJECTIVE_WEIGHTS
        assert "objectives_defaulted" in warnings

    def test_all_zero_returns_defaults(self):
        objectives = [
            ObjectiveWeight(key=ObjectiveKey.MONEY, weight=0),
            ObjectiveWeight(key=ObjectiveKey.TIME, weight=0),
        ]
        warnings: list[str] = []
        result = normalize_objectives(objectives, warnings)

        assert result == DEFAULT_OBJECTIVE_WEIGHTS
        assert "objectives_defaulted" in warnings

    def test_sum_100_unchanged(self):
        objectives = [
            ObjectiveWeight(key=ObjectiveKey.MONEY, weight=60),
            ObjectiveWeight(key=ObjectiveKey.TIME, weight=40),
        ]
        warnings: list[str] = []
        result = normalize_objectives(objectives, warnings)

        assert len(result) == 2
        assert sum(o.weight for o in result) == 100
        assert "weights_renormalized" not in warnings

    def test_renormalizes_when_sum_not_100(self):
        objectives = [
            ObjectiveWeight(key=ObjectiveKey.MONEY, weight=30),
            ObjectiveWeight(key=ObjectiveKey.TIME, weight=20),
        ]
        warnings: list[str] = []
        result = normalize_objectives(objectives, warnings)

        assert sum(o.weight for o in result) == 100
        assert "weights_renormalized" in warnings

    def test_renormalize_proportionally(self):
        # 60% money, 40% time -> should stay 60/40
        objectives = [
            ObjectiveWeight(key=ObjectiveKey.MONEY, weight=30),
            ObjectiveWeight(key=ObjectiveKey.TIME, weight=20),
        ]
        warnings: list[str] = []
        result = normalize_objectives(objectives, warnings)

        money = next(o for o in result if o.key == ObjectiveKey.MONEY)
        time = next(o for o in result if o.key == ObjectiveKey.TIME)

        assert money.weight == 60
        assert time.weight == 40

    def test_filters_zero_weights(self):
        objectives = [
            ObjectiveWeight(key=ObjectiveKey.MONEY, weight=50),
            ObjectiveWeight(key=ObjectiveKey.TIME, weight=50),
            ObjectiveWeight(key=ObjectiveKey.LEARNING, weight=0),
        ]
        warnings: list[str] = []
        result = normalize_objectives(objectives, warnings)

        assert len(result) == 2
        assert all(o.weight > 0 for o in result)


# ============================================================================
# STRING LIST NORMALIZATION TESTS
# ============================================================================


class TestNormalizeStringList:
    """Tests for string list normalization."""

    def test_removes_empty_strings(self):
        items = ["item1", "", "  ", "item2"]
        warnings: list[str] = []
        result = normalize_string_list(items, 10, "test", warnings)

        assert result == ["item1", "item2"]
        assert "removed_empty_test" in warnings

    def test_trims_items(self):
        items = ["  item1  ", "item2  "]
        warnings: list[str] = []
        result = normalize_string_list(items, 10, "test", warnings)

        assert result == ["item1", "item2"]

    def test_truncates_at_max(self):
        items = ["a", "b", "c", "d", "e"]
        warnings: list[str] = []
        result = normalize_string_list(items, 3, "test", warnings)

        assert result == ["a", "b", "c"]
        assert "test_truncated" in warnings

    def test_no_warning_when_unchanged(self):
        items = ["item1", "item2"]
        warnings: list[str] = []
        normalize_string_list(items, 10, "test", warnings)

        assert len(warnings) == 0


# ============================================================================
# FULL INTAKE NORMALIZATION TESTS
# ============================================================================


def make_valid_intake(**kwargs) -> DecisionIntakeRequest:
    """Create a valid intake request with defaults."""
    defaults = {
        "title": "Test Decision Title",
        "statement": "This is a test decision statement that is long enough.",
        "options": [
            DecisionOption(
                label="O1", name="Option One", description="Description of option one"
            ),
            DecisionOption(
                label="O2", name="Option Two", description="Description of option two"
            ),
        ],
        "timeHorizons": TimeHorizons(
            decisionDeadline="End of month",
            implementationPeriod="3 months",
            impactHorizon="1 year",
        ),
        "objectives": [
            ObjectiveWeight(key=ObjectiveKey.MONEY, weight=60),
            ObjectiveWeight(key=ObjectiveKey.TIME, weight=40),
        ],
        "constraints": DecisionConstraints(
            budgetMin=1000, budgetMax=5000, mustHaves="Must work", cantDo="Can't fail"
        ),
        "stakeholders": DecisionStakeholders(
            decisionMaker="Me", influencers="Boss", affected="Team"
        ),
        "baselineDoNothing": "If I do nothing, status quo continues.",
        "resources": DecisionResources(available="Time and money", needed="Help"),
        "risk": DecisionRisk(
            tolerance=RiskTolerance.MODERATE, maxAcceptableLoss="$1000"
        ),
        "dealbreakers": ["Losing job", "Going bankrupt"],
        "knownUncertainties": ["Market conditions", "Health"],
        "gutPreference": GutPreference(
            optionLabel="O1", confidence=70, reason="Feels right"
        ),
        "successDefinition": "Achieve the goal within budget and time.",
        "failureDefinition": "Miss the deadline or exceed budget significantly.",
    }
    defaults.update(kwargs)
    return DecisionIntakeRequest(**defaults)


class TestNormalizeDecisionIntake:
    """Tests for full intake normalization."""

    def test_valid_intake_normalizes(self):
        intake = make_valid_intake()
        result = normalize_decision_intake(intake)

        assert result.title == "Test Decision Title"
        assert len(result.options) == 2
        assert sum(o.weight for o in result.objectives) == 100

    def test_title_too_short_raises(self):
        intake = make_valid_intake(title="Hi")

        with pytest.raises(ValueError, match="Title must be at least 3 characters"):
            normalize_decision_intake(intake)

    def test_statement_too_short_raises(self):
        intake = make_valid_intake(statement="Short")

        with pytest.raises(
            ValueError, match="Statement must be at least 10 characters"
        ):
            normalize_decision_intake(intake)

    def test_success_definition_too_short_raises(self):
        intake = make_valid_intake(successDefinition="Short")

        with pytest.raises(
            ValueError, match="Success definition must be at least 10 characters"
        ):
            normalize_decision_intake(intake)

    def test_failure_definition_too_short_raises(self):
        intake = make_valid_intake(failureDefinition="Short")

        with pytest.raises(
            ValueError, match="Failure definition must be at least 10 characters"
        ):
            normalize_decision_intake(intake)

    def test_baseline_too_short_raises(self):
        intake = make_valid_intake(baselineDoNothing="No")

        with pytest.raises(ValueError, match="Baseline must be at least 5 characters"):
            normalize_decision_intake(intake)

    def test_fewer_than_2_options_raises(self):
        intake = make_valid_intake(
            options=[
                DecisionOption(label="O1", name="Only One", description="Description")
            ]
        )

        with pytest.raises(ValueError, match="At least 2 options are required"):
            normalize_decision_intake(intake)

    def test_option_name_too_short_raises(self):
        intake = make_valid_intake(
            options=[
                DecisionOption(label="O1", name="A", description="Description one"),
                DecisionOption(label="O2", name="Option Two", description="Desc two"),
            ]
        )

        with pytest.raises(
            ValueError, match="Option 1: name must be at least 2 characters"
        ):
            normalize_decision_intake(intake)

    def test_empty_objectives_uses_defaults(self):
        intake = make_valid_intake(objectives=[])
        result = normalize_decision_intake(intake)

        assert len(result.objectives) > 0
        assert sum(o.weight for o in result.objectives) == 100
        assert "objectives_defaulted" in result.warnings

    def test_gut_preference_empty_label_becomes_none(self):
        intake = make_valid_intake(
            gutPreference=GutPreference(optionLabel="", confidence=50, reason="test")
        )
        result = normalize_decision_intake(intake)

        assert result.gutPreference is None

    def test_whitespace_in_text_fields_normalized(self):
        intake = make_valid_intake(
            title="  Test   Decision   Title  ",
            statement="   This   is   a   test   statement.   ",
        )
        result = normalize_decision_intake(intake)

        assert result.title == "Test Decision Title"
        assert "  " not in result.statement

    def test_empty_dealbreakers_filtered(self):
        intake = make_valid_intake(dealbreakers=["valid", "", "  ", "another valid"])
        result = normalize_decision_intake(intake)

        assert result.dealbreakers == ["valid", "another valid"]
        assert "removed_empty_dealbreakers" in result.warnings
