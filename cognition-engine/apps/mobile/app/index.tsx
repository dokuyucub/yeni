import { useEffect, useState } from 'react';
import { Pressable, StyleSheet, Text, View } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';

import { apiClient } from '@/lib/api-client';

export default function HomeScreen() {
  const [apiStatus, setApiStatus] = useState<'checking' | 'online' | 'offline'>('checking');

  useEffect(() => {
    checkApiHealth();
  }, []);

  const checkApiHealth = async () => {
    setApiStatus('checking');
    try {
      const response = await apiClient.health();
      if (response.status === 'healthy') {
        setApiStatus('online');
      } else {
        setApiStatus('offline');
      }
    } catch {
      setApiStatus('offline');
    }
  };

  return (
    <SafeAreaView style={styles.container}>
      <View style={styles.content}>
        <Text style={styles.title}>Cognition Engine</Text>
        <Text style={styles.subtitle}>AI Decision & Simulation Consultant</Text>

        <View style={styles.statusCard}>
          <Text style={styles.statusLabel}>API Status</Text>
          <View style={styles.statusRow}>
            <View
              style={[
                styles.statusIndicator,
                apiStatus === 'online' && styles.statusOnline,
                apiStatus === 'offline' && styles.statusOffline,
                apiStatus === 'checking' && styles.statusChecking,
              ]}
            />
            <Text style={styles.statusText}>
              {apiStatus === 'checking' && 'Checking...'}
              {apiStatus === 'online' && 'Connected'}
              {apiStatus === 'offline' && 'Disconnected'}
            </Text>
          </View>
          {apiStatus === 'offline' && (
            <Pressable style={styles.retryButton} onPress={checkApiHealth}>
              <Text style={styles.retryButtonText}>Retry</Text>
            </Pressable>
          )}
        </View>

        <View style={styles.featuresCard}>
          <Text style={styles.featuresTitle}>Coming Soon</Text>
          <View style={styles.featureItem}>
            <Text style={styles.featureBullet}>•</Text>
            <Text style={styles.featureText}>Decision Studio</Text>
          </View>
          <View style={styles.featureItem}>
            <Text style={styles.featureBullet}>•</Text>
            <Text style={styles.featureText}>Budget Calculator</Text>
          </View>
          <View style={styles.featureItem}>
            <Text style={styles.featureBullet}>•</Text>
            <Text style={styles.featureText}>Risk Analysis</Text>
          </View>
          <View style={styles.featureItem}>
            <Text style={styles.featureBullet}>•</Text>
            <Text style={styles.featureText}>Negotiation Drafts</Text>
          </View>
        </View>
      </View>

      <Text style={styles.version}>v0.1.0 • Step 1 Complete</Text>
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
    alignItems: 'center',
    justifyContent: 'center',
    paddingHorizontal: 24,
  },
  title: {
    fontSize: 32,
    fontWeight: 'bold',
    color: '#e94560',
    marginBottom: 8,
  },
  subtitle: {
    fontSize: 16,
    color: '#a0a0a0',
    marginBottom: 48,
    textAlign: 'center',
  },
  statusCard: {
    backgroundColor: '#1a1a2e',
    borderRadius: 16,
    padding: 24,
    width: '100%',
    marginBottom: 24,
    borderWidth: 1,
    borderColor: '#2a2a4e',
  },
  statusLabel: {
    fontSize: 14,
    color: '#808080',
    marginBottom: 12,
    textTransform: 'uppercase',
    letterSpacing: 1,
  },
  statusRow: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  statusIndicator: {
    width: 12,
    height: 12,
    borderRadius: 6,
    marginRight: 12,
  },
  statusOnline: {
    backgroundColor: '#4ade80',
  },
  statusOffline: {
    backgroundColor: '#ef4444',
  },
  statusChecking: {
    backgroundColor: '#fbbf24',
  },
  statusText: {
    fontSize: 18,
    color: '#ffffff',
    fontWeight: '600',
  },
  retryButton: {
    marginTop: 16,
    paddingVertical: 8,
    paddingHorizontal: 16,
    backgroundColor: '#e94560',
    borderRadius: 8,
    alignSelf: 'flex-start',
  },
  retryButtonText: {
    color: '#ffffff',
    fontWeight: '600',
  },
  featuresCard: {
    backgroundColor: '#1a1a2e',
    borderRadius: 16,
    padding: 24,
    width: '100%',
    borderWidth: 1,
    borderColor: '#2a2a4e',
  },
  featuresTitle: {
    fontSize: 18,
    fontWeight: 'bold',
    color: '#ffffff',
    marginBottom: 16,
  },
  featureItem: {
    flexDirection: 'row',
    alignItems: 'center',
    marginBottom: 12,
  },
  featureBullet: {
    color: '#e94560',
    fontSize: 16,
    marginRight: 12,
  },
  featureText: {
    color: '#c0c0c0',
    fontSize: 16,
  },
  version: {
    color: '#606080',
    fontSize: 12,
    textAlign: 'center',
    paddingBottom: 24,
  },
});
