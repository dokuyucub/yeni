/**
 * Decision Intake types for the wizard flow.
 */

/**
 * Option definition for a decision.
 */
export interface DecisionOption {
  label: string; // O1, O2, etc.
  name: string; // Short name
  description: string; // Detailed description
}

/**
 * Time horizons for decision impact.
 */
export interface TimeHorizons {
  decisionDeadline: string;
  implementationPeriod: string;
  impactHorizon: string;
}

/**
 * Objective with weight.
 */
export interface ObjectiveWeight {
  key: ObjectiveKey;
  weight: number; // 0-100, sum must equal 100
}

/**
 * Available objective keys.
 */
export type ObjectiveKey =
  | 'money'
  | 'time'
  | 'freedom'
  | 'learning'
  | 'status'
  | 'impact'
  | 'health'
  | 'relationships'
  | 'other';

/**
 * Constraints on the decision.
 */
export interface DecisionConstraints {
  budgetMin?: number;
  budgetMax?: number;
  mustHaves: string;
  cantDo: string;
}

/**
 * Stakeholders affected by the decision.
 */
export interface DecisionStakeholders {
  decisionMaker: string;
  influencers: string;
  affected: string;
}

/**
 * Available resources.
 */
export interface DecisionResources {
  available: string;
  needed: string;
}

/**
 * Risk tolerance level.
 */
export type RiskTolerance = 'conservative' | 'moderate' | 'aggressive';

/**
 * Risk configuration.
 */
export interface DecisionRisk {
  tolerance: RiskTolerance;
  maxAcceptableLoss: string;
}

/**
 * Gut preference (optional).
 */
export interface GutPreference {
  optionLabel: string;
  confidence: number;
  reason: string;
}

/**
 * Complete Decision Intake request DTO.
 */
export interface DecisionIntake {
  title: string;
  statement: string;
  options: DecisionOption[];
  timeHorizons: TimeHorizons;
  objectives: ObjectiveWeight[];
  constraints: DecisionConstraints;
  stakeholders: DecisionStakeholders;
  baselineDoNothing: string;
  resources: DecisionResources;
  risk: DecisionRisk;
  dealbreakers: string[];
  knownUncertainties: string[];
  gutPreference?: GutPreference;
  successDefinition: string;
  failureDefinition: string;
}

/**
 * Response from creating a decision intake.
 */
export interface DecisionIntakeResponse {
  id: string;
  status: 'draft' | 'active';
  createdAt: string;
  message?: string;
}

/**
 * Local draft state (extends intake with metadata).
 */
export interface DraftDecision {
  id: string;
  currentStepIndex: number;
  updatedAt: string;
  createdAt: string;
  data: Partial<DecisionIntake>;
}

/**
 * Draft list item for display.
 */
export interface DraftListItem {
  id: string;
  title: string;
  currentStepIndex: number;
  updatedAt: string;
  optionCount: number;
}

/**
 * Wizard step definition.
 */
export interface WizardStep {
  index: number;
  key: string;
  title: string;
  description: string;
  route: string;
}

/**
 * All objective keys for iteration.
 */
export const OBJECTIVE_KEYS: ObjectiveKey[] = [
  'money',
  'time',
  'freedom',
  'learning',
  'status',
  'impact',
  'health',
  'relationships',
  'other',
];

/**
 * Human-readable labels for objectives.
 */
export const OBJECTIVE_LABELS: Record<ObjectiveKey, string> = {
  money: 'Money',
  time: 'Time',
  freedom: 'Freedom',
  learning: 'Learning',
  status: 'Status',
  impact: 'Impact',
  health: 'Health',
  relationships: 'Relationships',
  other: 'Other',
};

/**
 * Wizard steps configuration.
 */
export const WIZARD_STEPS: WizardStep[] = [
  { index: 0, key: 'basics', title: 'Basics', description: 'Define your decision title and problem statement.', route: 'basics' },
  { index: 1, key: 'options', title: 'Options', description: 'List the options you are considering.', route: 'options' },
  { index: 2, key: 'horizons', title: 'Horizons & Goals', description: 'Set time horizons and prioritize your objectives.', route: 'horizons' },
  { index: 3, key: 'constraints', title: 'Constraints', description: 'Define constraints, resources, and stakeholders.', route: 'constraints' },
  { index: 4, key: 'risk', title: 'Risk', description: 'Set your risk tolerance and identify dealbreakers.', route: 'risk' },
  { index: 5, key: 'baseline', title: 'Outcomes', description: 'Define success, failure, and your baseline scenario.', route: 'baseline' },
  { index: 6, key: 'review', title: 'Review', description: 'Review and submit your decision for analysis.', route: 'review' },
];
