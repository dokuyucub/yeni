/**
 * Root layout with auth initialization and navigation.
 */

import { useEffect } from 'react';
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { Slot, useRouter, useSegments } from 'expo-router';
import { StatusBar } from 'expo-status-bar';
import { SafeAreaProvider } from 'react-native-safe-area-context';

import { Loading } from '@/components';
import { useAuthStore } from '@/store/auth-store';

const queryClient = new QueryClient({
  defaultOptions: {
    queries: {
      staleTime: 1000 * 60 * 5, // 5 minutes
      retry: 2,
    },
  },
});

/**
 * Auth-aware navigation guard.
 * Redirects to appropriate screen based on auth state.
 */
function AuthNavigator() {
  const router = useRouter();
  const segments = useSegments();
  const { isInitialized, isAuthenticated, initialize } = useAuthStore();

  // Initialize auth on mount
  useEffect(() => {
    initialize();
  }, [initialize]);

  // Handle navigation based on auth state
  useEffect(() => {
    if (!isInitialized) return;

    const inAuthGroup = segments[0] === '(auth)';
    const inAppGroup = segments[0] === '(app)';

    if (isAuthenticated) {
      // User is signed in
      if (inAuthGroup || (!inAppGroup && segments.length === 0)) {
        // Redirect to app if in auth group or at root
        router.replace('/(app)');
      }
    } else {
      // User is not signed in
      if (inAppGroup || (!inAuthGroup && segments.length === 0)) {
        // Redirect to login if in app group or at root
        router.replace('/(auth)/login');
      }
    }
  }, [isInitialized, isAuthenticated, segments, router]);

  // Show loading while initializing
  if (!isInitialized) {
    return <Loading fullScreen message="Starting up..." />;
  }

  return <Slot />;
}

export default function RootLayout() {
  return (
    <QueryClientProvider client={queryClient}>
      <SafeAreaProvider>
        <StatusBar style="light" />
        <AuthNavigator />
      </SafeAreaProvider>
    </QueryClientProvider>
  );
}
