/**
 * Zod schemas for auth validation.
 */

import { z } from 'zod';

/**
 * Email validation schema.
 */
export const emailSchema = z
  .string()
  .min(1, 'Email is required')
  .email('Please enter a valid email address');

/**
 * Password validation schema.
 * Minimum 8 characters for security.
 */
export const passwordSchema = z
  .string()
  .min(1, 'Password is required')
  .min(8, 'Password must be at least 8 characters');

/**
 * Login form validation schema.
 */
export const loginSchema = z.object({
  email: emailSchema,
  password: z.string().min(1, 'Password is required'),
});

export type LoginFormData = z.infer<typeof loginSchema>;

/**
 * Signup form validation schema.
 */
export const signupSchema = z
  .object({
    email: emailSchema,
    password: passwordSchema,
    confirmPassword: z.string().min(1, 'Please confirm your password'),
  })
  .refine((data) => data.password === data.confirmPassword, {
    message: 'Passwords do not match',
    path: ['confirmPassword'],
  });

export type SignupFormData = z.infer<typeof signupSchema>;

/**
 * User me response schema.
 */
export const userMeResponseSchema = z.object({
  id: z.string().uuid(),
  email: z.string().email().nullable(),
  role: z.string(),
  app_metadata: z.record(z.unknown()).nullable(),
  user_metadata: z.record(z.unknown()).nullable(),
});
