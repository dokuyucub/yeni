/**
 * Zod schemas for API validation.
 * Client-side validation before sending requests.
 */

import { z } from 'zod';

/**
 * Health response schema.
 */
export const healthResponseSchema = z.object({
  status: z.enum(['healthy', 'degraded', 'unhealthy']),
  version: z.string(),
  timestamp: z.string(),
});

/**
 * API error schema.
 */
export const apiErrorSchema = z.object({
  error: z.string(),
  message: z.string(),
  status_code: z.number().int(),
  request_id: z.string().optional(),
});

/**
 * Paginated response schema factory.
 */
export const paginatedResponseSchema = <T extends z.ZodTypeAny>(itemSchema: T) =>
  z.object({
    data: z.array(itemSchema),
    total: z.number().int(),
    page: z.number().int(),
    page_size: z.number().int(),
    has_more: z.boolean(),
  });

/**
 * Generic API response schema factory.
 */
export const apiResponseSchema = <T extends z.ZodTypeAny>(dataSchema: T) =>
  z.object({
    data: dataSchema,
    message: z.string().optional(),
  });

// Type exports from schemas
export type HealthResponseSchema = z.infer<typeof healthResponseSchema>;
export type ApiErrorSchema = z.infer<typeof apiErrorSchema>;
