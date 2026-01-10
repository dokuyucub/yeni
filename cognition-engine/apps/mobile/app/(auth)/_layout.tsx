/**
 * Auth stack layout.
 * Contains login and signup screens.
 */

import { Stack } from 'expo-router';

export default function AuthLayout() {
  return (
    <Stack
      screenOptions={{
        headerStyle: {
          backgroundColor: '#1a1a2e',
        },
        headerTintColor: '#ffffff',
        headerTitleStyle: {
          fontWeight: 'bold',
        },
        contentStyle: {
          backgroundColor: '#16213e',
        },
        headerShadowVisible: false,
      }}
    >
      <Stack.Screen
        name="login"
        options={{
          title: 'Sign In',
          headerShown: false,
        }}
      />
      <Stack.Screen
        name="signup"
        options={{
          title: 'Create Account',
          headerBackTitle: 'Back',
        }}
      />
    </Stack>
  );
}
