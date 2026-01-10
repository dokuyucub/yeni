/**
 * Environment configuration with Zod validation.
 *
 * This module validates all required environment variables at startup
 * and provides typed access throughout the application.
 */

import { z } from 'zod';

/**
 * Environment variable schema.
 * All EXPO_PUBLIC_ prefixed vars are available at runtime.
 */
const envSchema = z.object({
  EXPO_PUBLIC_SUPABASE_URL: z
    .string()
    .min(1, 'EXPO_PUBLIC_SUPABASE_URL is required')
    .url('EXPO_PUBLIC_SUPABASE_URL must be a valid URL'),

  EXPO_PUBLIC_SUPABASE_ANON_KEY: z
    .string()
    .min(1, 'EXPO_PUBLIC_SUPABASE_ANON_KEY is required')
    .min(20, 'EXPO_PUBLIC_SUPABASE_ANON_KEY appears invalid'),

  EXPO_PUBLIC_API_URL: z
    .string()
    .min(1, 'EXPO_PUBLIC_API_URL is required')
    .url('EXPO_PUBLIC_API_URL must be a valid URL'),

  EXPO_PUBLIC_ENV: z
    .enum(['development', 'staging', 'production'])
    .default('development'),
});

type EnvConfig = z.infer<typeof envSchema>;

/**
 * Load and validate environment variables.
 * Throws descriptive error if validation fails.
 */
function loadEnv(): EnvConfig {
  const rawEnv = {
    EXPO_PUBLIC_SUPABASE_URL: process.env.EXPO_PUBLIC_SUPABASE_URL,
    EXPO_PUBLIC_SUPABASE_ANON_KEY: process.env.EXPO_PUBLIC_SUPABASE_ANON_KEY,
    EXPO_PUBLIC_API_URL: process.env.EXPO_PUBLIC_API_URL,
    EXPO_PUBLIC_ENV: process.env.EXPO_PUBLIC_ENV,
  };

  const result = envSchema.safeParse(rawEnv);

  if (!result.success) {
    const errors = result.error.errors
      .map((e) => `  - ${e.path.join('.')}: ${e.message}`)
      .join('\n');

    console.error(
      `\n❌ Environment validation failed:\n${errors}\n\n` +
        'Make sure you have copied .env.example to .env and filled in the values.\n' +
        'For local development, run: cd infra/supabase && supabase status\n'
    );

    // In development, provide fallbacks for easier debugging
    if (__DEV__) {
      console.warn('Using fallback development values...');
      return {
        EXPO_PUBLIC_SUPABASE_URL: 'http://127.0.0.1:54321',
        EXPO_PUBLIC_SUPABASE_ANON_KEY:
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6ImFub24iLCJleHAiOjE5ODM4MTI5OTZ9.CRXP1A7WOeoJeXxjNni43kdQwgnWNReilDMblYTn_I0',
        EXPO_PUBLIC_API_URL: 'http://localhost:8000',
        EXPO_PUBLIC_ENV: 'development',
      };
    }

    throw new Error(`Environment validation failed:\n${errors}`);
  }

  return result.data;
}

/**
 * Validated environment configuration.
 * Access environment variables through this object.
 */
export const env = loadEnv();

/**
 * Check if running in development mode.
 */
export const isDev = env.EXPO_PUBLIC_ENV === 'development';

/**
 * Check if running in production mode.
 */
export const isProd = env.EXPO_PUBLIC_ENV === 'production';
