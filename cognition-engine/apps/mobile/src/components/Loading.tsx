/**
 * Loading spinner component.
 */

import { ActivityIndicator, StyleSheet, Text, View } from 'react-native';

interface LoadingProps {
  message?: string;
  size?: 'small' | 'large';
  fullScreen?: boolean;
}

export function Loading({
  message,
  size = 'large',
  fullScreen = false,
}: LoadingProps) {
  const content = (
    <>
      <ActivityIndicator size={size} color="#e94560" />
      {message && <Text style={styles.message}>{message}</Text>}
    </>
  );

  if (fullScreen) {
    return <View style={styles.fullScreen}>{content}</View>;
  }

  return <View style={styles.container}>{content}</View>;
}

const styles = StyleSheet.create({
  container: {
    padding: 20,
    alignItems: 'center',
    justifyContent: 'center',
  },
  fullScreen: {
    flex: 1,
    backgroundColor: '#16213e',
    alignItems: 'center',
    justifyContent: 'center',
  },
  message: {
    marginTop: 16,
    color: '#a0a0a0',
    fontSize: 14,
    textAlign: 'center',
  },
});
