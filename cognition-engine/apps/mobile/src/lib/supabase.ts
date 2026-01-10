/**
 * Supabase client configuration.
 *
 * Configures Supabase with secure token storage via expo-secure-store.
 * Provides auth state management and session handling.
 */

import { createClient, Session, AuthChangeEvent } from '@supabase/supabase-js';
import { AppState, AppStateStatus } from 'react-native';

import { env } from '@/config/env';
import { supabaseStorageAdapter, STORAGE_KEYS } from './secure-store';

/**
 * Supabase client singleton.
 * Configured with:
 * - Custom secure storage adapter for tokens
 * - Auto refresh enabled
 * - Persist session enabled
 * - URL detection disabled (mobile app)
 */
export const supabase = createClient(
  env.EXPO_PUBLIC_SUPABASE_URL,
  env.EXPO_PUBLIC_SUPABASE_ANON_KEY,
  {
    auth: {
      storage: supabaseStorageAdapter,
      autoRefreshToken: true,
      persistSession: true,
      detectSessionInUrl: false,
      storageKey: STORAGE_KEYS.AUTH_SESSION,
    },
  }
);

/**
 * Handle app state changes for token refresh.
 * Refreshes the session when app comes to foreground.
 */
let appStateSubscription: { remove: () => void } | null = null;

export function setupAppStateListener(): void {
  if (appStateSubscription) {
    return; // Already set up
  }

  appStateSubscription = AppState.addEventListener(
    'change',
    async (state: AppStateStatus) => {
      if (state === 'active') {
        // App came to foreground, refresh session if needed
        try {
          const { data, error } = await supabase.auth.getSession();
          if (error) {
            console.warn('Session refresh failed:', error.message);
          } else if (data.session) {
            // Check if token needs refresh (within 60 seconds of expiry)
            const expiresAt = data.session.expires_at;
            if (expiresAt) {
              const now = Math.floor(Date.now() / 1000);
              const timeUntilExpiry = expiresAt - now;
              if (timeUntilExpiry < 60) {
                await supabase.auth.refreshSession();
              }
            }
          }
        } catch (error) {
          console.error('Error handling app state change:', error);
        }
      }
    }
  );
}

export function cleanupAppStateListener(): void {
  if (appStateSubscription) {
    appStateSubscription.remove();
    appStateSubscription = null;
  }
}

/**
 * Subscribe to auth state changes.
 * Returns unsubscribe function.
 */
export function onAuthStateChange(
  callback: (event: AuthChangeEvent, session: Session | null) => void
): { unsubscribe: () => void } {
  const { data } = supabase.auth.onAuthStateChange(callback);
  return { unsubscribe: () => data.subscription.unsubscribe() };
}

/**
 * Get current session.
 * Returns null if not authenticated.
 */
export async function getSession(): Promise<Session | null> {
  const { data, error } = await supabase.auth.getSession();
  if (error) {
    console.error('getSession error:', error.message);
    return null;
  }
  return data.session;
}

/**
 * Get current access token.
 * Returns null if not authenticated.
 */
export async function getAccessToken(): Promise<string | null> {
  const session = await getSession();
  return session?.access_token ?? null;
}

/**
 * Sign in with email and password.
 */
export async function signInWithEmail(
  email: string,
  password: string
): Promise<{ session: Session | null; error: Error | null }> {
  const { data, error } = await supabase.auth.signInWithPassword({
    email,
    password,
  });

  if (error) {
    return { session: null, error };
  }

  return { session: data.session, error: null };
}

/**
 * Sign up with email and password.
 */
export async function signUpWithEmail(
  email: string,
  password: string
): Promise<{
  session: Session | null;
  user: { id: string; email?: string } | null;
  error: Error | null;
  needsEmailConfirmation: boolean;
}> {
  const { data, error } = await supabase.auth.signUp({
    email,
    password,
  });

  if (error) {
    return { session: null, user: null, error, needsEmailConfirmation: false };
  }

  // Check if email confirmation is required
  const needsEmailConfirmation =
    data.user?.identities?.length === 0 ||
    (data.user && !data.session);

  return {
    session: data.session,
    user: data.user
      ? { id: data.user.id, email: data.user.email }
      : null,
    error: null,
    needsEmailConfirmation,
  };
}

/**
 * Sign out the current user.
 */
export async function signOut(): Promise<{ error: Error | null }> {
  const { error } = await supabase.auth.signOut();
  return { error };
}

/**
 * Refresh the current session.
 */
export async function refreshSession(): Promise<{
  session: Session | null;
  error: Error | null;
}> {
  const { data, error } = await supabase.auth.refreshSession();
  return { session: data.session, error };
}
