/**
 * Decision domain types.
 * Core data models for the Decision Studio feature.
 */

/**
 * Decision urgency levels.
 */
export type DecisionUrgency = 'immediate' | 'this_week' | 'this_month' | 'flexible';

/**
 * Decision importance levels.
 */
export type DecisionImportance = 'critical' | 'high' | 'medium' | 'low';

/**
 * Decision status throughout the lifecycle.
 */
export type DecisionStatus =
  | 'draft'
  | 'intake_complete'
  | 'modeling'
  | 'simulating'
  | 'recommended'
  | 'decided'
  | 'tracking'
  | 'archived';

/**
 * Initial decision intake data from the wizard.
 */
export interface DecisionIntake {
  title: string;
  context: string;
  desired_outcome: string;
  constraints: string[];
  urgency: DecisionUrgency;
  importance: DecisionImportance;
  stakeholders?: string[];
  initial_options?: string[];
}

/**
 * Full decision entity after creation.
 */
export interface Decision {
  id: string;
  user_id: string;
  title: string;
  context: string;
  desired_outcome: string;
  constraints: string[];
  urgency: DecisionUrgency;
  importance: DecisionImportance;
  stakeholders: string[];
  status: DecisionStatus;
  created_at: string;
  updated_at: string;
}

/**
 * Decision option (alternative choice).
 */
export interface DecisionOption {
  id: string;
  decision_id: string;
  name: string;
  description: string;
  pros: string[];
  cons: string[];
  estimated_cost?: number;
  estimated_time_days?: number;
  risk_level: 'low' | 'medium' | 'high';
  created_at: string;
}

/**
 * Evaluation criterion for comparing options.
 */
export interface DecisionCriterion {
  id: string;
  decision_id: string;
  name: string;
  description: string;
  weight: number; // 0-100, total should sum to 100
  created_at: string;
}

/**
 * Assumption that affects the decision model.
 */
export interface DecisionAssumption {
  id: string;
  decision_id: string;
  statement: string;
  confidence: number; // 0-100
  impact_if_wrong: 'low' | 'medium' | 'high';
  created_at: string;
}

/**
 * Decision graph node representing a decision point or outcome.
 */
export interface GraphNode {
  id: string;
  type: 'decision' | 'chance' | 'outcome';
  label: string;
  probability?: number; // For chance nodes
  value?: number; // For outcome nodes (expected value)
  position: { x: number; y: number };
}

/**
 * Decision graph edge connecting nodes.
 */
export interface GraphEdge {
  id: string;
  source: string;
  target: string;
  label?: string;
}

/**
 * Complete decision graph structure.
 */
export interface DecisionGraph {
  id: string;
  decision_id: string;
  nodes: GraphNode[];
  edges: GraphEdge[];
  created_at: string;
  updated_at: string;
}

/**
 * Simulation scenario result.
 */
export interface SimulationScenario {
  id: string;
  name: 'optimistic' | 'baseline' | 'pessimistic';
  description: string;
  assumptions_modified: Record<string, number>; // assumption_id -> modified confidence
  expected_value: number;
  variance: number;
  ruin_risk: number; // 0-100 probability of catastrophic outcome
  top_option_id: string;
}

/**
 * Complete simulation results.
 */
export interface SimulationResult {
  id: string;
  decision_id: string;
  scenarios: SimulationScenario[];
  monte_carlo_iterations: number;
  created_at: string;
}

/**
 * AI-generated recommendation.
 */
export interface Recommendation {
  id: string;
  decision_id: string;
  recommended_option_id: string;
  confidence: number;
  reasoning: string;
  risks: string[];
  mitigations: string[];
  next_7_days_plan: string[];
  consultant_report: string; // Human-readable final report
  created_at: string;
}

/**
 * Post-decision tracking check-in.
 */
export interface DecisionCheckIn {
  id: string;
  decision_id: string;
  check_in_date: string;
  actual_outcome: string;
  variance_from_expected: string;
  lessons_learned: string[];
  created_at: string;
}
