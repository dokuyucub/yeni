/**
 * Step 5: Risk & Dealbreakers
 *
 * Captures risk tolerance, max loss, dealbreakers, and uncertainties.
 */

import { useState } from 'react';
import { Pressable, StyleSheet, Text, TextInput, View } from 'react-native';

import type { DecisionRisk, RiskTolerance } from '@cognition-engine/shared';
import { useDraftStore, useDraftData } from '@/store/draft-store';
import { Button, ChipInput } from '@/components';

interface RiskStepProps {
  onNext: () => void;
  onBack: () => void;
}

const RISK_OPTIONS: { value: RiskTolerance; label: string; description: string }[] = [
  {
    value: 'conservative',
    label: 'Conservative',
    description: 'Prefer stability and certainty',
  },
  {
    value: 'moderate',
    label: 'Moderate',
    description: 'Balanced approach to risk',
  },
  {
    value: 'aggressive',
    label: 'Aggressive',
    description: 'Willing to take bigger risks for bigger rewards',
  },
];

export function RiskStep({ onNext, onBack }: RiskStepProps) {
  const data = useDraftData();
  const updateRisk = useDraftStore((s) => s.updateRisk);
  const updateDealbreakers = useDraftStore((s) => s.updateDealbreakers);
  const updateUncertainties = useDraftStore((s) => s.updateUncertainties);
  const saveDraft = useDraftStore((s) => s.saveDraft);

  const [risk, setRisk] = useState<DecisionRisk>(
    data?.risk ?? {
      tolerance: 'moderate',
      maxAcceptableLoss: '',
    }
  );

  const dealbreakers = data?.dealbreakers ?? [];
  const uncertainties = data?.knownUncertainties ?? [];

  const handleRiskChange = (field: keyof DecisionRisk, value: string) => {
    const updated = { ...risk, [field]: value };
    setRisk(updated);
    updateRisk(updated);
  };

  const selectTolerance = (tolerance: RiskTolerance) => {
    const updated = { ...risk, tolerance };
    setRisk(updated);
    updateRisk(updated);
  };

  const handleNext = async () => {
    await saveDraft();
    onNext();
  };

  return (
    <View style={styles.container}>
      {/* Risk Tolerance */}
      <Text style={styles.sectionTitle}>Risk Tolerance</Text>
      <Text style={styles.sectionHint}>
        How much risk are you comfortable with?
      </Text>

      <View style={styles.toleranceOptions}>
        {RISK_OPTIONS.map((option) => (
          <Pressable
            key={option.value}
            style={[
              styles.toleranceOption,
              risk.tolerance === option.value && styles.toleranceSelected,
            ]}
            onPress={() => selectTolerance(option.value)}
          >
            <View style={styles.toleranceRadio}>
              {risk.tolerance === option.value && (
                <View style={styles.toleranceRadioInner} />
              )}
            </View>
            <View style={styles.toleranceText}>
              <Text
                style={[
                  styles.toleranceLabel,
                  risk.tolerance === option.value && styles.toleranceLabelSelected,
                ]}
              >
                {option.label}
              </Text>
              <Text style={styles.toleranceDescription}>{option.description}</Text>
            </View>
          </Pressable>
        ))}
      </View>

      {/* Max Acceptable Loss */}
      <View style={styles.field}>
        <Text style={styles.label}>Maximum Acceptable Loss</Text>
        <Text style={styles.hint}>
          What's the worst-case outcome you could accept?
        </Text>
        <TextInput
          style={styles.textArea}
          value={risk.maxAcceptableLoss}
          onChangeText={(v) => handleRiskChange('maxAcceptableLoss', v)}
          placeholder="e.g., Up to 6 months of savings, current job security..."
          placeholderTextColor="#4a4a6a"
          multiline
          numberOfLines={3}
          textAlignVertical="top"
        />
      </View>

      <View style={styles.divider} />

      {/* Dealbreakers */}
      <Text style={styles.sectionTitle}>Dealbreakers</Text>
      <Text style={styles.sectionHint}>
        Conditions that would immediately eliminate an option
      </Text>

      <ChipInput
        items={dealbreakers}
        onChange={updateDealbreakers}
        placeholder="Add a dealbreaker..."
        maxItems={10}
      />

      <View style={styles.divider} />

      {/* Known Uncertainties */}
      <Text style={styles.sectionTitle}>Known Uncertainties</Text>
      <Text style={styles.sectionHint}>
        Things you don't know that could affect the outcome
      </Text>

      <ChipInput
        items={uncertainties}
        onChange={updateUncertainties}
        placeholder="Add an uncertainty..."
        maxItems={10}
      />

      <View style={styles.buttonRow}>
        <Button
          title="Back"
          variant="secondary"
          onPress={onBack}
          style={styles.backButton}
        />
        <Button title="Continue" onPress={handleNext} style={styles.nextButton} />
      </View>
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
    marginBottom: 4,
  },
  sectionHint: {
    color: '#6a6a8a',
    fontSize: 13,
    marginBottom: 16,
  },
  toleranceOptions: {
    marginBottom: 24,
  },
  toleranceOption: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: '#1a1a2e',
    borderRadius: 10,
    borderWidth: 1,
    borderColor: '#2a2a4e',
    padding: 16,
    marginBottom: 10,
  },
  toleranceSelected: {
    borderColor: '#e94560',
    backgroundColor: 'rgba(233, 69, 96, 0.1)',
  },
  toleranceRadio: {
    width: 20,
    height: 20,
    borderRadius: 10,
    borderWidth: 2,
    borderColor: '#4a4a6a',
    alignItems: 'center',
    justifyContent: 'center',
    marginRight: 12,
  },
  toleranceRadioInner: {
    width: 10,
    height: 10,
    borderRadius: 5,
    backgroundColor: '#e94560',
  },
  toleranceText: {
    flex: 1,
  },
  toleranceLabel: {
    color: '#c0c0c0',
    fontSize: 15,
    fontWeight: '600',
    marginBottom: 2,
  },
  toleranceLabelSelected: {
    color: '#ffffff',
  },
  toleranceDescription: {
    color: '#6a6a8a',
    fontSize: 13,
  },
  field: {
    marginBottom: 16,
  },
  label: {
    color: '#ffffff',
    fontSize: 14,
    fontWeight: '600',
    marginBottom: 4,
  },
  hint: {
    color: '#6a6a8a',
    fontSize: 13,
    marginBottom: 8,
  },
  textArea: {
    backgroundColor: '#1a1a2e',
    borderWidth: 1,
    borderColor: '#2a2a4e',
    borderRadius: 10,
    paddingVertical: 12,
    paddingHorizontal: 16,
    color: '#ffffff',
    fontSize: 15,
    minHeight: 90,
  },
  divider: {
    height: 1,
    backgroundColor: '#2a2a4e',
    marginVertical: 24,
  },
  buttonRow: {
    flexDirection: 'row',
    gap: 12,
    marginTop: 24,
  },
  backButton: {
    flex: 1,
  },
  nextButton: {
    flex: 2,
  },
});
