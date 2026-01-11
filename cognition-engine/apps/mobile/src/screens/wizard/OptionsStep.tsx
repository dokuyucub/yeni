/**
 * Step 2: Decision Options
 *
 * Captures the options being considered.
 */

import { StyleSheet, Text, View } from 'react-native';

import { useDraftStore, useDraftData } from '@/store/draft-store';
import { Button, OptionCard } from '@/components';
import { hasMinimumOptions } from '@/lib/drafts';

interface OptionsStepProps {
  onNext: () => void;
  onBack: () => void;
}

export function OptionsStep({ onNext, onBack }: OptionsStepProps) {
  const data = useDraftData();
  const addOption = useDraftStore((s) => s.addOption);
  const removeOption = useDraftStore((s) => s.removeOption);
  const updateOption = useDraftStore((s) => s.updateOption);
  const saveDraft = useDraftStore((s) => s.saveDraft);

  const options = data?.options ?? [];
  const canProceed = hasMinimumOptions(options);

  const handleAddOption = () => {
    addOption();
  };

  const handleRemoveOption = (index: number) => {
    removeOption(index);
  };

  const handleNext = async () => {
    if (!canProceed) return;
    await saveDraft();
    onNext();
  };

  return (
    <View style={styles.container}>
      <Text style={styles.sectionTitle}>
        What options are you considering? (minimum 2)
      </Text>

      {options.map((option, index) => (
        <OptionCard
          key={`${option.label}-${index}`}
          option={option}
          index={index}
          onChange={(update) => updateOption(index, update)}
          onRemove={() => handleRemoveOption(index)}
          canRemove={options.length > 2}
        />
      ))}

      {options.length < 6 && (
        <Button
          title="+ Add Another Option"
          variant="secondary"
          onPress={handleAddOption}
          style={styles.addButton}
        />
      )}

      {options.length >= 6 && (
        <Text style={styles.maxWarning}>
          Maximum 6 options. Focus on your most viable choices.
        </Text>
      )}

      <View style={styles.tips}>
        <Text style={styles.tipsTitle}>Option Ideas:</Text>
        <Text style={styles.tipItem}>• Status quo (do nothing)</Text>
        <Text style={styles.tipItem}>• Most ambitious choice</Text>
        <Text style={styles.tipItem}>• Safe/conservative choice</Text>
        <Text style={styles.tipItem}>• Creative alternatives</Text>
      </View>

      <View style={styles.buttonRow}>
        <Button
          title="Back"
          variant="secondary"
          onPress={onBack}
          style={styles.backButton}
        />
        <Button
          title="Continue"
          onPress={handleNext}
          disabled={!canProceed}
          style={styles.nextButton}
        />
      </View>

      {!canProceed && (
        <Text style={styles.validation}>
          Add at least 2 options with names to continue
        </Text>
      )}
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
  },
  sectionTitle: {
    color: '#ffffff',
    fontSize: 16,
    fontWeight: '600',
    marginBottom: 16,
  },
  addButton: {
    marginVertical: 8,
  },
  maxWarning: {
    color: '#fbbf24',
    fontSize: 13,
    textAlign: 'center',
    marginVertical: 8,
  },
  tips: {
    backgroundColor: '#1a1a2e',
    borderRadius: 10,
    padding: 16,
    marginTop: 16,
    marginBottom: 24,
    borderLeftWidth: 3,
    borderLeftColor: '#e94560',
  },
  tipsTitle: {
    color: '#ffffff',
    fontSize: 14,
    fontWeight: '600',
    marginBottom: 8,
  },
  tipItem: {
    color: '#a0a0a0',
    fontSize: 13,
    lineHeight: 22,
  },
  buttonRow: {
    flexDirection: 'row',
    gap: 12,
  },
  backButton: {
    flex: 1,
  },
  nextButton: {
    flex: 2,
  },
  validation: {
    color: '#ef4444',
    fontSize: 12,
    textAlign: 'center',
    marginTop: 12,
  },
});
