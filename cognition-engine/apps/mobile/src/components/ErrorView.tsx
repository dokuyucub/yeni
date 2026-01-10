/**
 * Error display component.
 */

import { Pressable, StyleSheet, Text, View } from 'react-native';

interface ErrorViewProps {
  message: string;
  details?: string;
  onRetry?: () => void;
  onDismiss?: () => void;
}

export function ErrorView({
  message,
  details,
  onRetry,
  onDismiss,
}: ErrorViewProps) {
  return (
    <View style={styles.container}>
      <View style={styles.iconContainer}>
        <Text style={styles.icon}>!</Text>
      </View>
      <Text style={styles.message}>{message}</Text>
      {details && <Text style={styles.details}>{details}</Text>}
      <View style={styles.actions}>
        {onRetry && (
          <Pressable style={styles.retryButton} onPress={onRetry}>
            <Text style={styles.retryText}>Try Again</Text>
          </Pressable>
        )}
        {onDismiss && (
          <Pressable style={styles.dismissButton} onPress={onDismiss}>
            <Text style={styles.dismissText}>Dismiss</Text>
          </Pressable>
        )}
      </View>
    </View>
  );
}

/**
 * Inline error message for forms.
 */
export function ErrorMessage({ message }: { message: string }) {
  return <Text style={styles.errorMessage}>{message}</Text>;
}

/**
 * Error banner at top of screen.
 */
export function ErrorBanner({
  message,
  onDismiss,
}: {
  message: string;
  onDismiss?: () => void;
}) {
  return (
    <View style={styles.banner}>
      <Text style={styles.bannerText}>{message}</Text>
      {onDismiss && (
        <Pressable onPress={onDismiss} hitSlop={8}>
          <Text style={styles.bannerDismiss}>×</Text>
        </Pressable>
      )}
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    padding: 24,
    alignItems: 'center',
    justifyContent: 'center',
  },
  iconContainer: {
    width: 48,
    height: 48,
    borderRadius: 24,
    backgroundColor: 'rgba(239, 68, 68, 0.2)',
    alignItems: 'center',
    justifyContent: 'center',
    marginBottom: 16,
  },
  icon: {
    color: '#ef4444',
    fontSize: 24,
    fontWeight: 'bold',
  },
  message: {
    color: '#ffffff',
    fontSize: 16,
    fontWeight: '600',
    textAlign: 'center',
    marginBottom: 8,
  },
  details: {
    color: '#a0a0a0',
    fontSize: 14,
    textAlign: 'center',
    marginBottom: 16,
  },
  actions: {
    flexDirection: 'row',
    gap: 12,
  },
  retryButton: {
    backgroundColor: '#e94560',
    paddingVertical: 10,
    paddingHorizontal: 20,
    borderRadius: 8,
  },
  retryText: {
    color: '#ffffff',
    fontWeight: '600',
  },
  dismissButton: {
    backgroundColor: 'transparent',
    borderWidth: 1,
    borderColor: '#4a4a6a',
    paddingVertical: 10,
    paddingHorizontal: 20,
    borderRadius: 8,
  },
  dismissText: {
    color: '#a0a0a0',
    fontWeight: '600',
  },
  errorMessage: {
    color: '#ef4444',
    fontSize: 12,
    marginTop: 4,
  },
  banner: {
    backgroundColor: 'rgba(239, 68, 68, 0.15)',
    borderColor: '#ef4444',
    borderWidth: 1,
    borderRadius: 8,
    padding: 12,
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    marginBottom: 16,
  },
  bannerText: {
    color: '#ef4444',
    fontSize: 14,
    flex: 1,
  },
  bannerDismiss: {
    color: '#ef4444',
    fontSize: 20,
    fontWeight: 'bold',
    marginLeft: 12,
  },
});
