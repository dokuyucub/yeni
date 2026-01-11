/**
 * Normalization functions for decision intake data.
 */

import type {
  DecisionIntake,
  DecisionOption,
  ObjectiveWeight,
  ObjectiveKey,
  RiskTolerance,
  OBJECTIVE_KEYS,
} from '@cognition-engine/shared';

/**
 * Default objective weights based on risk tolerance.
 */
const DEFAULT_WEIGHTS_BY_RISK: Record<RiskTolerance, Record<ObjectiveKey, number>> = {
  low: {
    money: 25,
    time: 15,
    freedom: 15,
    learning: 10,
    status: 5,
    impact: 10,
    health: 10,
    relationships: 10,
    other: 0,
  },
  medium: {
    money: 20,
    time: 10,
    freedom: 20,
    learning: 30,
    status: 5,
    impact: 10,
    health: 0,
    relationships: 5,
    other: 0,
  },
  high: {
    money: 30,
    time: 5,
    freedom: 10,
    learning: 20,
    status: 10,
    impact: 20,
    health: 0,
    relationships: 5,
    other: 0,
  },
};

/**
 * Normalize objective weights to sum to 100.
 */
export function normalizeObjectiveWeights(
  objectives: ObjectiveWeight[],
  targetSum: number = 100
): ObjectiveWeight[] {
  if (objectives.length === 0) return [];

  const currentSum = objectives.reduce((sum, obj) => sum + obj.weight, 0);

  if (currentSum === 0) {
    // Distribute evenly
    const evenWeight = Math.floor(targetSum / objectives.length);
    const remainder = targetSum - evenWeight * objectives.length;

    return objectives.map((obj, index) => ({
      ...obj,
      weight: evenWeight + (index === 0 ? remainder : 0),
    }));
  }

  if (currentSum === targetSum) {
    return objectives;
  }

  // Scale proportionally
  const scale = targetSum / currentSum;
  const scaled = objectives.map((obj) => ({
    ...obj,
    weight: Math.round(obj.weight * scale),
  }));

  // Adjust for rounding errors
  const newSum = scaled.reduce((sum, obj) => sum + obj.weight, 0);
  const diff = targetSum - newSum;

  if (diff !== 0 && scaled.length > 0) {
    // Add/subtract from the largest weight
    const maxIndex = scaled.reduce(
      (maxIdx, obj, idx) => (obj.weight > scaled[maxIdx].weight ? idx : maxIdx),
      0
    );
    scaled[maxIndex].weight += diff;
  }

  return scaled;
}

/**
 * Get default objective weights for a given risk tolerance.
 */
export function getDefaultObjectives(tolerance: RiskTolerance): ObjectiveWeight[] {
  const weights = DEFAULT_WEIGHTS_BY_RISK[tolerance];

  return Object.entries(weights)
    .filter(([_, weight]) => weight > 0)
    .map(([key, weight]) => ({
      key: key as ObjectiveKey,
      weight,
    }));
}

/**
 * Ensure all objective keys are present with at least 0 weight.
 */
export function ensureAllObjectiveKeys(
  objectives: ObjectiveWeight[],
  allKeys: readonly ObjectiveKey[]
): ObjectiveWeight[] {
  const existingKeys = new Set(objectives.map((obj) => obj.key));
  const result = [...objectives];

  for (const key of allKeys) {
    if (!existingKeys.has(key)) {
      result.push({ key, weight: 0 });
    }
  }

  return result;
}

/**
 * Normalize option labels to O1, O2, O3, etc.
 */
export function normalizeOptionLabels(options: DecisionOption[]): DecisionOption[] {
  return options.map((option, index) => ({
    ...option,
    label: `O${index + 1}`,
  }));
}

/**
 * Add a new option with the next label.
 */
export function addOption(options: DecisionOption[]): DecisionOption[] {
  const newOption: DecisionOption = {
    label: `O${options.length + 1}`,
    name: '',
    description: '',
  };
  return [...options, newOption];
}

/**
 * Remove an option and renumber labels.
 */
export function removeOption(
  options: DecisionOption[],
  index: number
): DecisionOption[] {
  const filtered = options.filter((_, i) => i !== index);
  return normalizeOptionLabels(filtered);
}

/**
 * Validate that we have at least 2 options.
 */
export function hasMinimumOptions(options: DecisionOption[]): boolean {
  return options.length >= 2;
}

/**
 * Validate that options have required fields.
 */
export function validateOptions(options: DecisionOption[]): {
  valid: boolean;
  errors: string[];
} {
  const errors: string[] = [];

  if (options.length < 2) {
    errors.push('At least 2 options are required');
  }

  options.forEach((option, index) => {
    if (!option.name.trim()) {
      errors.push(`Option ${index + 1}: Name is required`);
    }
    if (option.description.length < 10) {
      errors.push(`Option ${index + 1}: Description must be at least 10 characters`);
    }
  });

  return { valid: errors.length === 0, errors };
}

/**
 * Normalize a complete intake for submission.
 */
export function normalizeIntake(intake: Partial<DecisionIntake>): Partial<DecisionIntake> {
  const normalized = { ...intake };

  // Normalize options
  if (normalized.options) {
    normalized.options = normalizeOptionLabels(normalized.options);
  }

  // Normalize objectives
  if (normalized.objectives && normalized.objectives.length > 0) {
    normalized.objectives = normalizeObjectiveWeights(normalized.objectives);
  } else if (normalized.risk?.tolerance) {
    // Apply defaults if no objectives set
    normalized.objectives = getDefaultObjectives(normalized.risk.tolerance);
  }

  // Ensure at least empty arrays
  normalized.dealbreakers = normalized.dealbreakers ?? [];
  normalized.knownUncertainties = normalized.knownUncertainties ?? [];

  return normalized;
}

/**
 * Check if a draft is complete enough for submission.
 */
export function isDraftComplete(intake: Partial<DecisionIntake>): {
  complete: boolean;
  missingFields: string[];
} {
  const missingFields: string[] = [];

  // Required fields
  if (!intake.title?.trim()) missingFields.push('Title');
  if (!intake.statement?.trim() || intake.statement.length < 20) {
    missingFields.push('Decision statement');
  }

  // Options
  if (!intake.options || intake.options.length < 2) {
    missingFields.push('At least 2 options');
  } else {
    const optionValidation = validateOptions(intake.options);
    if (!optionValidation.valid) {
      missingFields.push('Complete option details');
    }
  }

  // Time horizons
  const horizons = intake.timeHorizons;
  if (!horizons || (!horizons.short && !horizons.mid && !horizons.long && !horizons.custom)) {
    missingFields.push('Time horizon');
  }

  // Objectives
  if (!intake.objectives || intake.objectives.length === 0) {
    missingFields.push('Objectives');
  } else {
    const sum = intake.objectives.reduce((s, o) => s + o.weight, 0);
    if (sum !== 100) {
      missingFields.push('Objective weights (must sum to 100)');
    }
  }

  // Baseline
  if (!intake.baselineDoNothing?.trim() || intake.baselineDoNothing.length < 10) {
    missingFields.push('Baseline (do nothing) scenario');
  }

  // Success/Failure
  if (!intake.successDefinition?.trim() || intake.successDefinition.length < 10) {
    missingFields.push('Success definition');
  }
  if (!intake.failureDefinition?.trim() || intake.failureDefinition.length < 10) {
    missingFields.push('Failure definition');
  }

  // Risk
  if (!intake.risk?.tolerance) {
    missingFields.push('Risk tolerance');
  }

  return {
    complete: missingFields.length === 0,
    missingFields,
  };
}
