/**
 * Zod schemas for decision domain validation.
 * Used for form validation and API request validation.
 */

import { z } from 'zod';

/**
 * Decision urgency enum schema.
 */
export const decisionUrgencySchema = z.enum([
  'immediate',
  'this_week',
  'this_month',
  'flexible',
]);

/**
 * Decision importance enum schema.
 */
export const decisionImportanceSchema = z.enum(['critical', 'high', 'medium', 'low']);

/**
 * Decision status enum schema.
 */
export const decisionStatusSchema = z.enum([
  'draft',
  'intake_complete',
  'modeling',
  'simulating',
  'recommended',
  'decided',
  'tracking',
  'archived',
]);

/**
 * Decision intake form schema with validation rules.
 */
export const decisionIntakeSchema = z.object({
  title: z
    .string()
    .min(5, 'Title must be at least 5 characters')
    .max(200, 'Title must be at most 200 characters'),
  context: z
    .string()
    .min(20, 'Context must be at least 20 characters')
    .max(5000, 'Context must be at most 5000 characters'),
  desired_outcome: z
    .string()
    .min(10, 'Desired outcome must be at least 10 characters')
    .max(1000, 'Desired outcome must be at most 1000 characters'),
  constraints: z
    .array(z.string().min(1).max(500))
    .min(0)
    .max(20, 'Maximum 20 constraints allowed'),
  urgency: decisionUrgencySchema,
  importance: decisionImportanceSchema,
  stakeholders: z.array(z.string().min(1).max(100)).max(20).optional(),
  initial_options: z.array(z.string().min(1).max(500)).max(10).optional(),
});

/**
 * Decision option schema.
 */
export const decisionOptionSchema = z.object({
  name: z.string().min(2).max(100),
  description: z.string().min(10).max(2000),
  pros: z.array(z.string().min(1).max(500)).max(20),
  cons: z.array(z.string().min(1).max(500)).max(20),
  estimated_cost: z.number().positive().optional(),
  estimated_time_days: z.number().int().positive().optional(),
  risk_level: z.enum(['low', 'medium', 'high']),
});

/**
 * Decision criterion schema.
 */
export const decisionCriterionSchema = z.object({
  name: z.string().min(2).max(100),
  description: z.string().min(5).max(500),
  weight: z.number().int().min(0).max(100),
});

/**
 * Decision assumption schema.
 */
export const decisionAssumptionSchema = z.object({
  statement: z.string().min(10).max(1000),
  confidence: z.number().int().min(0).max(100),
  impact_if_wrong: z.enum(['low', 'medium', 'high']),
});

/**
 * Graph node schema.
 */
export const graphNodeSchema = z.object({
  id: z.string(),
  type: z.enum(['decision', 'chance', 'outcome']),
  label: z.string().min(1).max(200),
  probability: z.number().min(0).max(1).optional(),
  value: z.number().optional(),
  position: z.object({
    x: z.number(),
    y: z.number(),
  }),
});

/**
 * Graph edge schema.
 */
export const graphEdgeSchema = z.object({
  id: z.string(),
  source: z.string(),
  target: z.string(),
  label: z.string().max(100).optional(),
});

/**
 * Decision graph schema.
 */
export const decisionGraphSchema = z.object({
  nodes: z.array(graphNodeSchema),
  edges: z.array(graphEdgeSchema),
});

/**
 * Check-in schema.
 */
export const decisionCheckInSchema = z.object({
  actual_outcome: z.string().min(10).max(2000),
  variance_from_expected: z.string().min(5).max(1000),
  lessons_learned: z.array(z.string().min(5).max(500)).min(1).max(10),
});

// Type exports from schemas
export type DecisionIntakeInput = z.infer<typeof decisionIntakeSchema>;
export type DecisionOptionInput = z.infer<typeof decisionOptionSchema>;
export type DecisionCriterionInput = z.infer<typeof decisionCriterionSchema>;
export type DecisionAssumptionInput = z.infer<typeof decisionAssumptionSchema>;
export type DecisionGraphInput = z.infer<typeof decisionGraphSchema>;
export type DecisionCheckInInput = z.infer<typeof decisionCheckInSchema>;
