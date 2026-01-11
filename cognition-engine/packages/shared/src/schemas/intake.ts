/**
 * Zod schemas for Decision Intake validation.
 */

import { z } from 'zod';

/**
 * Option schema.
 */
export const decisionOptionSchema = z.object({
  label: z.string().min(1, 'Label is required'),
  name: z.string().min(1, 'Name is required').max(100, 'Name too long'),
  description: z.string().min(10, 'Description must be at least 10 characters'),
});

/**
 * Time horizons schema.
 */
export const timeHorizonsSchema = z.object({
  short: z.boolean(),
  mid: z.boolean(),
  long: z.boolean(),
  custom: z.string().optional(),
}).refine(
  (data) => data.short || data.mid || data.long || (data.custom && data.custom.length > 0),
  { message: 'Select at least one time horizon' }
);

/**
 * Objective key enum.
 */
export const objectiveKeySchema = z.enum([
  'money',
  'time',
  'freedom',
  'learning',
  'status',
  'impact',
  'health',
  'relationships',
  'other',
]);

/**
 * Objective weight schema.
 */
export const objectiveWeightSchema = z.object({
  key: objectiveKeySchema,
  weight: z.number().min(0).max(100),
});

/**
 * Objectives array schema with sum validation.
 */
export const objectivesArraySchema = z
  .array(objectiveWeightSchema)
  .refine(
    (objectives) => {
      const sum = objectives.reduce((acc, obj) => acc + obj.weight, 0);
      return sum === 100;
    },
    { message: 'Objective weights must sum to 100' }
  );

/**
 * Constraints schema.
 */
export const constraintsSchema = z.object({
  budget: z.number().min(0).optional(),
  budgetCurrency: z.string().optional(),
  location: z.string().optional(),
  legal: z.string().optional(),
  timeline: z.string().optional(),
  skills: z.string().optional(),
  dependencies: z.string().optional(),
});

/**
 * Stakeholders schema.
 */
export const stakeholdersSchema = z.object({
  affected: z.string().optional(),
  deciders: z.string().optional(),
  influencers: z.string().optional(),
});

/**
 * Resources schema.
 */
export const resourcesSchema = z.object({
  money: z.number().min(0).optional(),
  moneyCurrency: z.string().optional(),
  timeHoursPerWeek: z.number().min(0).max(168).optional(),
  network: z.string().optional(),
  tools: z.string().optional(),
  credibility: z.string().optional(),
});

/**
 * Risk tolerance schema.
 */
export const riskToleranceSchema = z.enum(['low', 'medium', 'high']);

/**
 * Max acceptable loss schema.
 */
export const maxAcceptableLossSchema = z.object({
  amount: z.number().min(0),
  unit: z.enum(['money', 'hours']),
  currency: z.string().optional(),
});

/**
 * Risk schema.
 */
export const riskSchema = z.object({
  tolerance: riskToleranceSchema,
  maxAcceptableLoss: maxAcceptableLossSchema.optional(),
});

/**
 * Gut preference schema.
 */
export const gutPreferenceSchema = z.object({
  optionLabel: z.string().optional(),
  reason: z.string().optional(),
});

/**
 * Complete Decision Intake schema.
 */
export const decisionIntakeSchema = z.object({
  title: z.string().min(5, 'Title must be at least 5 characters').max(200, 'Title too long'),
  statement: z.string().min(20, 'Statement must be at least 20 characters'),
  options: z
    .array(decisionOptionSchema)
    .min(2, 'At least 2 options required'),
  timeHorizons: timeHorizonsSchema,
  objectives: objectivesArraySchema,
  constraints: constraintsSchema,
  stakeholders: stakeholdersSchema,
  baselineDoNothing: z.string().min(10, 'Baseline must be at least 10 characters'),
  resources: resourcesSchema,
  risk: riskSchema,
  dealbreakers: z.array(z.string().min(1)),
  knownUncertainties: z.array(z.string().min(1)),
  gutPreference: gutPreferenceSchema.optional(),
  successDefinition: z.string().min(10, 'Success definition must be at least 10 characters'),
  failureDefinition: z.string().min(10, 'Failure definition must be at least 10 characters'),
});

export type DecisionIntakeInput = z.infer<typeof decisionIntakeSchema>;

/**
 * Step-specific validation schemas.
 */

export const basicsStepSchema = z.object({
  title: z.string().min(5, 'Title must be at least 5 characters').max(200, 'Title too long'),
  statement: z.string().min(20, 'Statement must be at least 20 characters'),
});

export const optionsStepSchema = z.object({
  options: z
    .array(decisionOptionSchema)
    .min(2, 'At least 2 options required'),
});

export const horizonsStepSchema = z.object({
  timeHorizons: timeHorizonsSchema,
  objectives: objectivesArraySchema,
});

export const constraintsStepSchema = z.object({
  constraints: constraintsSchema,
  stakeholders: stakeholdersSchema,
  resources: resourcesSchema,
});

export const riskStepSchema = z.object({
  risk: riskSchema,
  dealbreakers: z.array(z.string()),
  knownUncertainties: z.array(z.string()),
});

export const baselineStepSchema = z.object({
  baselineDoNothing: z.string().min(10, 'Baseline must be at least 10 characters'),
  successDefinition: z.string().min(10, 'Success definition must be at least 10 characters'),
  failureDefinition: z.string().min(10, 'Failure definition must be at least 10 characters'),
  gutPreference: gutPreferenceSchema.optional(),
});
