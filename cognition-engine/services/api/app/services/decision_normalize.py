"""
Decision intake normalization service.

Provides deterministic normalization and validation for decision intake data.
"""

import re
from typing import TypeVar

from app.models.decision_intake import (
    DecisionConstraints,
    DecisionIntakeRequest,
    DecisionOption,
    DecisionResources,
    DecisionRisk,
    DecisionStakeholders,
    GutPreference,
    NormalizedIntake,
    ObjectiveKey,
    ObjectiveWeight,
    RiskTolerance,
    TimeHorizons,
)

T = TypeVar("T")


# ============================================================================
# DEFAULT OBJECTIVE WEIGHTS
# ============================================================================

DEFAULT_OBJECTIVE_WEIGHTS: list[ObjectiveWeight] = [
    ObjectiveWeight(key=ObjectiveKey.LEARNING, weight=30),
    ObjectiveWeight(key=ObjectiveKey.FREEDOM, weight=20),
    ObjectiveWeight(key=ObjectiveKey.MONEY, weight=20),
    ObjectiveWeight(key=ObjectiveKey.TIME, weight=10),
    ObjectiveWeight(key=ObjectiveKey.IMPACT, weight=10),
    ObjectiveWeight(key=ObjectiveKey.STATUS, weight=5),
    ObjectiveWeight(key=ObjectiveKey.RELATIONSHIPS, weight=5),
]


# ============================================================================
# TEXT NORMALIZATION
# ============================================================================


def normalize_text(s: str | None) -> str:
    """
    Normalize text by trimming and collapsing internal whitespace.

    - Strips leading/trailing whitespace
    - Collapses multiple spaces/tabs to single space
    - Preserves unicode characters

    Args:
        s: Input string or None

    Returns:
        Normalized string
    """
    if s is None:
        return ""
    # Strip leading/trailing
    s = s.strip()
    # Collapse internal whitespace (spaces, tabs) to single space
    # Preserves newlines for multi-line text
    s = re.sub(r"[ \t]+", " ", s)
    return s


def normalize_multiline(s: str | None) -> str:
    """
    Normalize multi-line text.

    - Strips leading/trailing whitespace
    - Collapses multiple blank lines to single blank line
    - Trims each line

    Args:
        s: Input string or None

    Returns:
        Normalized string
    """
    if s is None:
        return ""
    # Split into lines, strip each, filter empty
    lines = s.split("\n")
    lines = [line.strip() for line in lines]
    # Collapse multiple empty lines
    result_lines: list[str] = []
    prev_empty = False
    for line in lines:
        if not line:
            if not prev_empty:
                result_lines.append("")
            prev_empty = True
        else:
            result_lines.append(line)
            prev_empty = False
    # Strip trailing empty lines
    while result_lines and not result_lines[-1]:
        result_lines.pop()
    return "\n".join(result_lines)


# ============================================================================
# OPTIONS NORMALIZATION
# ============================================================================


def normalize_options(
    options: list[DecisionOption],
    warnings: list[str],
) -> list[DecisionOption]:
    """
    Normalize decision options.

    - Trims names and descriptions
    - Relabels sequentially as O1, O2, O3, etc.
    - Filters out options with empty names

    Args:
        options: List of options
        warnings: List to append warnings to

    Returns:
        Normalized list of options
    """
    normalized: list[DecisionOption] = []
    original_labels: list[str] = []

    for opt in options:
        name = normalize_text(opt.name)
        description = normalize_multiline(opt.description)

        # Skip options with empty names
        if not name:
            continue

        original_labels.append(opt.label)
        normalized.append(
            DecisionOption(
                label=f"O{len(normalized) + 1}",
                name=name,
                description=description,
            )
        )

    # Check if relabeling occurred
    new_labels = [opt.label for opt in normalized]
    if original_labels and original_labels != new_labels:
        warnings.append("options_relabeled")

    return normalized


def validate_options(options: list[DecisionOption], warnings: list[str]) -> None:
    """
    Validate options meet minimum requirements.

    Args:
        options: List of options to validate
        warnings: List to append warnings to

    Raises:
        ValueError: If validation fails
    """
    if len(options) < 2:
        raise ValueError("At least 2 options are required")

    for i, opt in enumerate(options):
        if len(opt.name) < 2:
            raise ValueError(f"Option {i + 1}: name must be at least 2 characters")


# ============================================================================
# OBJECTIVES NORMALIZATION
# ============================================================================


def normalize_objectives(
    objectives: list[ObjectiveWeight],
    warnings: list[str],
) -> list[ObjectiveWeight]:
    """
    Normalize objective weights.

    - If empty, applies default weights
    - If sum != 100, renormalizes proportionally
    - Rounds to integers and fixes rounding drift

    Args:
        objectives: List of objective weights
        warnings: List to append warnings to

    Returns:
        Normalized list of objective weights summing to 100
    """
    # If empty, use defaults
    if not objectives:
        warnings.append("objectives_defaulted")
        return DEFAULT_OBJECTIVE_WEIGHTS.copy()

    # Filter out zero weights and invalid keys
    valid_keys = {k.value for k in ObjectiveKey}
    filtered = [
        obj for obj in objectives if obj.weight > 0 and obj.key.value in valid_keys
    ]

    if not filtered:
        warnings.append("objectives_defaulted")
        return DEFAULT_OBJECTIVE_WEIGHTS.copy()

    # Calculate current sum
    current_sum = sum(obj.weight for obj in filtered)

    if current_sum == 100:
        return filtered

    # Need to renormalize
    warnings.append("weights_renormalized")

    if current_sum == 0:
        # Distribute evenly
        even_weight = 100 // len(filtered)
        remainder = 100 - (even_weight * len(filtered))
        return [
            ObjectiveWeight(
                key=obj.key,
                weight=even_weight + (1 if i < remainder else 0),
            )
            for i, obj in enumerate(filtered)
        ]

    # Scale proportionally
    scale = 100.0 / current_sum
    scaled = [
        ObjectiveWeight(key=obj.key, weight=round(obj.weight * scale))
        for obj in filtered
    ]

    # Fix rounding drift
    new_sum = sum(obj.weight for obj in scaled)
    diff = 100 - new_sum

    if diff != 0 and scaled:
        # Adjust the largest weight
        max_idx = max(range(len(scaled)), key=lambda i: scaled[i].weight)
        scaled[max_idx] = ObjectiveWeight(
            key=scaled[max_idx].key,
            weight=scaled[max_idx].weight + diff,
        )

    return scaled


# ============================================================================
# ARRAY NORMALIZATION
# ============================================================================


def normalize_string_list(
    items: list[str],
    max_items: int,
    field_name: str,
    warnings: list[str],
) -> list[str]:
    """
    Normalize a list of strings.

    - Trims each item
    - Removes empty items
    - Caps at max_items

    Args:
        items: List of strings
        max_items: Maximum allowed items
        field_name: Name of field for warning messages
        warnings: List to append warnings to

    Returns:
        Normalized list
    """
    normalized = [normalize_text(item) for item in items]
    normalized = [item for item in normalized if item]

    if len(normalized) > max_items:
        warnings.append(f"{field_name}_truncated")
        normalized = normalized[:max_items]

    if len(items) != len(normalized):
        warnings.append(f"removed_empty_{field_name}")

    return normalized


# ============================================================================
# SUB-MODEL NORMALIZATION
# ============================================================================


def normalize_time_horizons(horizons: TimeHorizons) -> TimeHorizons:
    """Normalize time horizons."""
    return TimeHorizons(
        decisionDeadline=normalize_text(horizons.decisionDeadline),
        implementationPeriod=normalize_text(horizons.implementationPeriod),
        impactHorizon=normalize_text(horizons.impactHorizon),
    )


def normalize_constraints(constraints: DecisionConstraints) -> DecisionConstraints:
    """Normalize constraints."""
    return DecisionConstraints(
        budgetMin=constraints.budgetMin,
        budgetMax=constraints.budgetMax,
        mustHaves=normalize_multiline(constraints.mustHaves),
        cantDo=normalize_multiline(constraints.cantDo),
    )


def normalize_stakeholders(stakeholders: DecisionStakeholders) -> DecisionStakeholders:
    """Normalize stakeholders."""
    return DecisionStakeholders(
        decisionMaker=normalize_text(stakeholders.decisionMaker),
        influencers=normalize_text(stakeholders.influencers),
        affected=normalize_text(stakeholders.affected),
    )


def normalize_resources(resources: DecisionResources) -> DecisionResources:
    """Normalize resources."""
    return DecisionResources(
        available=normalize_multiline(resources.available),
        needed=normalize_multiline(resources.needed),
    )


def normalize_risk(risk: DecisionRisk) -> DecisionRisk:
    """Normalize risk configuration."""
    return DecisionRisk(
        tolerance=risk.tolerance,
        maxAcceptableLoss=normalize_multiline(risk.maxAcceptableLoss),
    )


def normalize_gut_preference(
    pref: GutPreference | None,
) -> GutPreference | None:
    """Normalize gut preference."""
    if pref is None:
        return None

    label = normalize_text(pref.optionLabel)
    reason = normalize_text(pref.reason)

    # If no label, return None
    if not label:
        return None

    return GutPreference(
        optionLabel=label,
        confidence=max(0, min(100, pref.confidence)),
        reason=reason,
    )


# ============================================================================
# MAIN NORMALIZATION FUNCTION
# ============================================================================


def normalize_decision_intake(intake: DecisionIntakeRequest) -> NormalizedIntake:
    """
    Normalize a complete decision intake.

    Performs all validation and normalization steps:
    - Text trimming and whitespace collapse
    - Option validation and relabeling
    - Objective weight normalization
    - Array cleanup

    Args:
        intake: The raw intake request

    Returns:
        NormalizedIntake with cleaned data and warnings

    Raises:
        ValueError: If intake fails validation
    """
    warnings: list[str] = []

    # Normalize basic fields
    title = normalize_text(intake.title)
    statement = normalize_multiline(intake.statement)
    baseline = normalize_multiline(intake.baselineDoNothing)
    success = normalize_multiline(intake.successDefinition)
    failure = normalize_multiline(intake.failureDefinition)

    # Validate required text fields
    if len(title) < 3:
        raise ValueError("Title must be at least 3 characters")
    if len(statement) < 10:
        raise ValueError("Statement must be at least 10 characters")
    if len(success) < 10:
        raise ValueError("Success definition must be at least 10 characters")
    if len(failure) < 10:
        raise ValueError("Failure definition must be at least 10 characters")
    if len(baseline) < 5:
        raise ValueError("Baseline must be at least 5 characters")

    # Normalize options
    options = normalize_options(intake.options, warnings)
    validate_options(options, warnings)

    # Normalize objectives
    objectives = normalize_objectives(intake.objectives, warnings)

    # Normalize arrays
    dealbreakers = normalize_string_list(
        intake.dealbreakers, 30, "dealbreakers", warnings
    )
    uncertainties = normalize_string_list(
        intake.knownUncertainties, 30, "uncertainties", warnings
    )

    # Normalize sub-models
    time_horizons = normalize_time_horizons(intake.timeHorizons)
    constraints = normalize_constraints(intake.constraints)
    stakeholders = normalize_stakeholders(intake.stakeholders)
    resources = normalize_resources(intake.resources)
    risk = normalize_risk(intake.risk)
    gut = normalize_gut_preference(intake.gutPreference)

    return NormalizedIntake(
        title=title,
        statement=statement,
        options=options,
        timeHorizons=time_horizons,
        objectives=objectives,
        constraints=constraints,
        stakeholders=stakeholders,
        baselineDoNothing=baseline,
        resources=resources,
        risk=risk,
        dealbreakers=dealbreakers,
        knownUncertainties=uncertainties,
        gutPreference=gut,
        successDefinition=success,
        failureDefinition=failure,
        warnings=warnings,
    )
