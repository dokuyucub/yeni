/**
 * Progress header for wizard steps.
 */

import { Pressable, StyleSheet, Text, View } from 'react-native';
import { WIZARD_STEPS } from '@cognition-engine/shared';

interface ProgressHeaderProps {
  currentStep: number;
  onBack?: () => void;
  showBack?: boolean;
}

export function ProgressHeader({
  currentStep,
  onBack,
  showBack = true,
}: ProgressHeaderProps) {
  const totalSteps = WIZARD_STEPS.length;
  const currentStepData = WIZARD_STEPS[currentStep];
  const progress = ((currentStep + 1) / totalSteps) * 100;

  return (
    <View style={styles.container}>
      <View style={styles.header}>
        {showBack && onBack ? (
          <Pressable onPress={onBack} style={styles.backButton} hitSlop={8}>
            <Text style={styles.backText}>← Back</Text>
          </Pressable>
        ) : (
          <View style={styles.backPlaceholder} />
        )}

        <Text style={styles.stepText}>
          Step {currentStep + 1} of {totalSteps}
        </Text>

        <View style={styles.backPlaceholder} />
      </View>

      <View style={styles.progressBarContainer}>
        <View style={[styles.progressBar, { width: `${progress}%` }]} />
      </View>

      <Text style={styles.stepTitle}>{currentStepData?.title ?? ''}</Text>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    paddingHorizontal: 16,
    paddingTop: 8,
    paddingBottom: 16,
    backgroundColor: '#1a1a2e',
    borderBottomWidth: 1,
    borderBottomColor: '#2a2a4e',
  },
  header: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    marginBottom: 12,
  },
  backButton: {
    paddingVertical: 4,
    paddingHorizontal: 8,
  },
  backText: {
    color: '#e94560',
    fontSize: 14,
    fontWeight: '600',
  },
  backPlaceholder: {
    width: 60,
  },
  stepText: {
    color: '#a0a0a0',
    fontSize: 14,
  },
  progressBarContainer: {
    height: 4,
    backgroundColor: '#2a2a4e',
    borderRadius: 2,
    marginBottom: 12,
    overflow: 'hidden',
  },
  progressBar: {
    height: '100%',
    backgroundColor: '#e94560',
    borderRadius: 2,
  },
  stepTitle: {
    color: '#ffffff',
    fontSize: 20,
    fontWeight: 'bold',
    textAlign: 'center',
  },
});
