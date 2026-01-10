/**
 * Auth state management with Zustand.
 *
 * Manages authentication state, session handling, and auth actions.
 * Integrates with Supabase client for persistence.
 */

import { create } from 'zustand';
import { Session, AuthChangeEvent } from '@supabase/supabase-js';

import type { AuthUser, AuthError } from '@cognition-engine/shared';
import {
  getSession,
  signInWithEmail,
  signUpWithEmail,
  signOut as supabaseSignOut,
  onAuthStateChange,
  setupAppStateListener,
  cleanupAppStateListener,
  refreshSession,
} from '@/lib/supabase';
import { clearAuthStorage } from '@/lib/secure-store';

/**
 * Auth store state shape.
 */
interface AuthState {
  // State
  isInitialized: boolean;
  isLoading: boolean;
  isAuthenticated: boolean;
  user: AuthUser | null;
  session: Session | null;
  error: AuthError | null;

  // Actions
  initialize: () => Promise<void>;
  signIn: (email: string, password: string) => Promise<{ success: boolean; error?: AuthError }>;
  signUp: (
    email: string,
    password: string
  ) => Promise<{ success: boolean; needsConfirmation?: boolean; error?: AuthError }>;
  signOut: () => Promise<void>;
  clearError: () => void;
  refresh: () => Promise<boolean>;
}

/**
 * Convert Supabase session to auth user.
 */
function sessionToUser(session: Session | null): AuthUser | null {
  if (!session?.user) return null;

  return {
    id: session.user.id,
    email: session.user.email,
    phone: session.user.phone,
    created_at: session.user.created_at,
    updated_at: session.user.updated_at,
    app_metadata: session.user.app_metadata,
    user_metadata: session.user.user_metadata,
  };
}

/**
 * Auth store singleton.
 */
export const useAuthStore = create<AuthState>((set, get) => ({
  // Initial state
  isInitialized: false,
  isLoading: true,
  isAuthenticated: false,
  user: null,
  session: null,
  error: null,

  /**
   * Initialize auth state from persisted session.
   * Call this on app startup.
   */
  initialize: async () => {
    if (get().isInitialized) {
      return;
    }

    set({ isLoading: true, error: null });

    try {
      // Set up app state listener for token refresh
      setupAppStateListener();

      // Get initial session
      const session = await getSession();

      set({
        isInitialized: true,
        isLoading: false,
        isAuthenticated: !!session,
        user: sessionToUser(session),
        session,
      });

      // Subscribe to auth state changes
      onAuthStateChange((event: AuthChangeEvent, session: Session | null) => {
        console.log('Auth state changed:', event);

        switch (event) {
          case 'SIGNED_IN':
          case 'TOKEN_REFRESHED':
            set({
              isAuthenticated: true,
              user: sessionToUser(session),
              session,
              error: null,
            });
            break;

          case 'SIGNED_OUT':
            set({
              isAuthenticated: false,
              user: null,
              session: null,
            });
            break;

          case 'USER_UPDATED':
            if (session) {
              set({
                user: sessionToUser(session),
                session,
              });
            }
            break;

          case 'PASSWORD_RECOVERY':
            // Handle password recovery if needed
            break;
        }
      });
    } catch (error) {
      console.error('Auth initialization error:', error);
      set({
        isInitialized: true,
        isLoading: false,
        isAuthenticated: false,
        error: {
          message: 'Failed to initialize authentication',
          code: 'INIT_ERROR',
        },
      });
    }
  },

  /**
   * Sign in with email and password.
   */
  signIn: async (email: string, password: string) => {
    set({ isLoading: true, error: null });

    try {
      const { session, error } = await signInWithEmail(email, password);

      if (error) {
        const authError: AuthError = {
          message: error.message,
          code: (error as any).code,
        };
        set({ isLoading: false, error: authError });
        return { success: false, error: authError };
      }

      set({
        isLoading: false,
        isAuthenticated: true,
        user: sessionToUser(session),
        session,
      });

      return { success: true };
    } catch (error) {
      const authError: AuthError = {
        message: error instanceof Error ? error.message : 'Sign in failed',
        code: 'UNKNOWN_ERROR',
      };
      set({ isLoading: false, error: authError });
      return { success: false, error: authError };
    }
  },

  /**
   * Sign up with email and password.
   */
  signUp: async (email: string, password: string) => {
    set({ isLoading: true, error: null });

    try {
      const { session, user, error, needsEmailConfirmation } = await signUpWithEmail(
        email,
        password
      );

      if (error) {
        const authError: AuthError = {
          message: error.message,
          code: (error as any).code,
        };
        set({ isLoading: false, error: authError });
        return { success: false, error: authError };
      }

      if (needsEmailConfirmation) {
        set({ isLoading: false });
        return { success: true, needsConfirmation: true };
      }

      set({
        isLoading: false,
        isAuthenticated: !!session,
        user: session ? sessionToUser(session) : user ? { id: user.id, email: user.email } : null,
        session,
      });

      return { success: true, needsConfirmation: false };
    } catch (error) {
      const authError: AuthError = {
        message: error instanceof Error ? error.message : 'Sign up failed',
        code: 'UNKNOWN_ERROR',
      };
      set({ isLoading: false, error: authError });
      return { success: false, error: authError };
    }
  },

  /**
   * Sign out current user.
   */
  signOut: async () => {
    set({ isLoading: true, error: null });

    try {
      await supabaseSignOut();
      await clearAuthStorage();
      cleanupAppStateListener();

      set({
        isLoading: false,
        isAuthenticated: false,
        user: null,
        session: null,
      });
    } catch (error) {
      console.error('Sign out error:', error);
      // Still clear local state even if remote sign out fails
      set({
        isLoading: false,
        isAuthenticated: false,
        user: null,
        session: null,
      });
    }
  },

  /**
   * Clear current error.
   */
  clearError: () => {
    set({ error: null });
  },

  /**
   * Refresh the session.
   * Returns true if refresh successful.
   */
  refresh: async () => {
    try {
      const { session, error } = await refreshSession();

      if (error || !session) {
        return false;
      }

      set({
        session,
        user: sessionToUser(session),
      });

      return true;
    } catch {
      return false;
    }
  },
}));

/**
 * Selector hooks for common auth state.
 */
export const useIsAuthenticated = () => useAuthStore((state) => state.isAuthenticated);
export const useIsAuthLoading = () => useAuthStore((state) => state.isLoading);
export const useAuthUser = () => useAuthStore((state) => state.user);
export const useAuthError = () => useAuthStore((state) => state.error);
export const useAuthSession = () => useAuthStore((state) => state.session);
