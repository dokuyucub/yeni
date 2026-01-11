/**
 * App stack layout (authenticated screens).
 */

import { Stack } from 'expo-router';

export default function AppLayout() {
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
        name="index"
        options={{
          title: 'Cognition Engine',
        }}
      />
      <Stack.Screen
        name="profile"
        options={{
          title: 'Profile',
          headerBackTitle: 'Back',
        }}
      />
      <Stack.Screen
        name="decisions/index"
        options={{
          title: 'My Decisions',
          headerBackTitle: 'Home',
        }}
      />
      <Stack.Screen
        name="decisions/wizard/[draftId]"
        options={{
          headerShown: false,
        }}
      />
    </Stack>
  );
}
