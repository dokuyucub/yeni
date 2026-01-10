/**
 * Secure storage wrapper using expo-secure-store.
 *
 * Provides typed, async storage for sensitive data like auth tokens.
 * Uses device keychain/keystore for secure storage.
 */

import * as SecureStore from 'expo-secure-store';
import { Platform } from 'react-native';

/**
 * Storage keys used throughout the app.
 * Centralized to prevent typos and enable easy refactoring.
 */
export const STORAGE_KEYS = {
  AUTH_SESSION: 'cognition_auth_session',
  ACCESS_TOKEN: 'cognition_access_token',
  REFRESH_TOKEN: 'cognition_refresh_token',
} as const;

type StorageKey = (typeof STORAGE_KEYS)[keyof typeof STORAGE_KEYS];

/**
 * SecureStore options for consistency.
 */
const STORE_OPTIONS: SecureStore.SecureStoreOptions = {
  keychainAccessible: SecureStore.WHEN_UNLOCKED,
};

/**
 * Check if SecureStore is available on this platform.
 * SecureStore is not available on web.
 */
export function isSecureStoreAvailable(): boolean {
  return Platform.OS !== 'web';
}

/**
 * Get a value from secure storage.
 *
 * @param key - The storage key
 * @returns The stored value or null if not found
 */
export async function getSecureItem(key: StorageKey): Promise<string | null> {
  try {
    if (!isSecureStoreAvailable()) {
      // Fallback to localStorage on web (less secure, dev only)
      if (typeof localStorage !== 'undefined') {
        return localStorage.getItem(key);
      }
      return null;
    }
    return await SecureStore.getItemAsync(key, STORE_OPTIONS);
  } catch (error) {
    console.error(`SecureStore.getItem(${key}) failed:`, error);
    return null;
  }
}

/**
 * Set a value in secure storage.
 *
 * @param key - The storage key
 * @param value - The value to store
 */
export async function setSecureItem(key: StorageKey, value: string): Promise<void> {
  try {
    if (!isSecureStoreAvailable()) {
      // Fallback to localStorage on web (less secure, dev only)
      if (typeof localStorage !== 'undefined') {
        localStorage.setItem(key, value);
      }
      return;
    }
    await SecureStore.setItemAsync(key, value, STORE_OPTIONS);
  } catch (error) {
    console.error(`SecureStore.setItem(${key}) failed:`, error);
    throw error;
  }
}

/**
 * Remove a value from secure storage.
 *
 * @param key - The storage key
 */
export async function removeSecureItem(key: StorageKey): Promise<void> {
  try {
    if (!isSecureStoreAvailable()) {
      // Fallback to localStorage on web
      if (typeof localStorage !== 'undefined') {
        localStorage.removeItem(key);
      }
      return;
    }
    await SecureStore.deleteItemAsync(key, STORE_OPTIONS);
  } catch (error) {
    console.error(`SecureStore.removeItem(${key}) failed:`, error);
    // Don't throw on remove failures
  }
}

/**
 * Clear all auth-related items from secure storage.
 */
export async function clearAuthStorage(): Promise<void> {
  await Promise.all([
    removeSecureItem(STORAGE_KEYS.AUTH_SESSION),
    removeSecureItem(STORAGE_KEYS.ACCESS_TOKEN),
    removeSecureItem(STORAGE_KEYS.REFRESH_TOKEN),
  ]);
}

/**
 * Supabase storage adapter interface.
 * Used to configure Supabase client for secure token storage.
 */
export const supabaseStorageAdapter = {
  getItem: async (key: string): Promise<string | null> => {
    return getSecureItem(key as StorageKey);
  },
  setItem: async (key: string, value: string): Promise<void> => {
    await setSecureItem(key as StorageKey, value);
  },
  removeItem: async (key: string): Promise<void> => {
    await removeSecureItem(key as StorageKey);
  },
};
