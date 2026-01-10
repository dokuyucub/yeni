/**
 * Profile screen.
 * Displays user information and allows sign out.
 */

import { useEffect, useState } from 'react';
import { Alert, StyleSheet, Text, View } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { router } from 'expo-router';

import type { UserMeResponse } from '@cognition-engine/shared';
import { Button, Loading, ErrorView } from '@/components';
import { useAuthStore, useAuthUser } from '@/store/auth-store';
import { apiClient } from '@/lib/api-client';

export default function ProfileScreen() {
  const user = useAuthUser();
  const { signOut, isLoading: isAuthLoading } = useAuthStore();

  const [profileData, setProfileData] = useState<UserMeResponse | null>(null);
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    loadProfile();
  }, []);

  const loadProfile = async () => {
    setIsLoading(true);
    setError(null);

    try {
      const data = await apiClient.me();
      setProfileData(data);
    } catch (err) {
      const message = err instanceof Error ? err.message : 'Failed to load profile';
      setError(message);
    } finally {
      setIsLoading(false);
    }
  };

  const handleSignOut = () => {
    Alert.alert('Sign Out', 'Are you sure you want to sign out?', [
      {
        text: 'Cancel',
        style: 'cancel',
      },
      {
        text: 'Sign Out',
        style: 'destructive',
        onPress: async () => {
          await signOut();
          router.replace('/(auth)/login');
        },
      },
    ]);
  };

  if (isLoading) {
    return <Loading fullScreen message="Loading profile..." />;
  }

  return (
    <SafeAreaView style={styles.container} edges={['bottom']}>
      <View style={styles.content}>
        {error ? (
          <ErrorView
            message="Failed to load profile"
            details={error}
            onRetry={loadProfile}
          />
        ) : (
          <>
            <View style={styles.avatarContainer}>
              <View style={styles.avatar}>
                <Text style={styles.avatarText}>
                  {(user?.email?.[0] ?? 'U').toUpperCase()}
                </Text>
              </View>
            </View>

            <View style={styles.infoCard}>
              <Text style={styles.sectionTitle}>Account Information</Text>

              <View style={styles.infoRow}>
                <Text style={styles.infoLabel}>User ID</Text>
                <Text style={styles.infoValue} numberOfLines={1}>
                  {profileData?.id ?? user?.id ?? 'Unknown'}
                </Text>
              </View>

              <View style={styles.divider} />

              <View style={styles.infoRow}>
                <Text style={styles.infoLabel}>Email</Text>
                <Text style={styles.infoValue}>
                  {profileData?.email ?? user?.email ?? 'Not set'}
                </Text>
              </View>

              <View style={styles.divider} />

              <View style={styles.infoRow}>
                <Text style={styles.infoLabel}>Role</Text>
                <Text style={styles.infoValue}>
                  {profileData?.role ?? 'authenticated'}
                </Text>
              </View>

              <View style={styles.divider} />

              <View style={styles.infoRow}>
                <Text style={styles.infoLabel}>API Status</Text>
                <View style={styles.statusContainer}>
                  <View
                    style={[
                      styles.statusDot,
                      profileData ? styles.statusOnline : styles.statusOffline,
                    ]}
                  />
                  <Text style={styles.infoValue}>
                    {profileData ? 'Verified' : 'Not Verified'}
                  </Text>
                </View>
              </View>
            </View>

            <View style={styles.actions}>
              <Button
                title="Sign Out"
                onPress={handleSignOut}
                variant="outline"
                fullWidth
                loading={isAuthLoading}
              />
            </View>
          </>
        )}
      </View>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#16213e',
  },
  content: {
    flex: 1,
    paddingHorizontal: 24,
    paddingTop: 24,
  },
  avatarContainer: {
    alignItems: 'center',
    marginBottom: 32,
  },
  avatar: {
    width: 80,
    height: 80,
    borderRadius: 40,
    backgroundColor: '#e94560',
    alignItems: 'center',
    justifyContent: 'center',
  },
  avatarText: {
    color: '#ffffff',
    fontSize: 32,
    fontWeight: 'bold',
  },
  infoCard: {
    backgroundColor: '#1a1a2e',
    borderRadius: 16,
    padding: 20,
    borderWidth: 1,
    borderColor: '#2a2a4e',
    marginBottom: 24,
  },
  sectionTitle: {
    fontSize: 14,
    color: '#808080',
    marginBottom: 16,
    textTransform: 'uppercase',
    letterSpacing: 1,
  },
  infoRow: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    paddingVertical: 8,
  },
  infoLabel: {
    color: '#a0a0a0',
    fontSize: 14,
  },
  infoValue: {
    color: '#ffffff',
    fontSize: 14,
    fontWeight: '500',
    maxWidth: '60%',
    textAlign: 'right',
  },
  divider: {
    height: 1,
    backgroundColor: '#2a2a4e',
    marginVertical: 4,
  },
  statusContainer: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  statusDot: {
    width: 8,
    height: 8,
    borderRadius: 4,
    marginRight: 8,
  },
  statusOnline: {
    backgroundColor: '#4ade80',
  },
  statusOffline: {
    backgroundColor: '#ef4444',
  },
  actions: {
    marginTop: 'auto',
    paddingBottom: 24,
  },
});
