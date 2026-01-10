/**
 * Authentication types for Supabase auth integration.
 */

/**
 * User session from Supabase Auth.
 */
export interface AuthSession {
  access_token: string;
  refresh_token: string;
  expires_at?: number;
  expires_in?: number;
  token_type: string;
  user: AuthUser;
}

/**
 * User object from Supabase Auth.
 */
export interface AuthUser {
  id: string;
  email?: string;
  phone?: string;
  created_at?: string;
  updated_at?: string;
  app_metadata?: Record<string, unknown>;
  user_metadata?: Record<string, unknown>;
}

/**
 * Response from /users/me endpoint.
 */
export interface UserMeResponse {
  id: string;
  email: string | null;
  role: string;
  app_metadata: Record<string, unknown> | null;
  user_metadata: Record<string, unknown> | null;
}

/**
 * Auth state for the application.
 */
export interface AuthState {
  isAuthenticated: boolean;
  isLoading: boolean;
  user: AuthUser | null;
  accessToken: string | null;
}

/**
 * Login request payload.
 */
export interface LoginRequest {
  email: string;
  password: string;
}

/**
 * Signup request payload.
 */
export interface SignupRequest {
  email: string;
  password: string;
  metadata?: Record<string, unknown>;
}

/**
 * Auth error response.
 */
export interface AuthError {
  message: string;
  status?: number;
  code?: string;
}
