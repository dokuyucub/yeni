/**
 * Step 3: Time Horizons & Objectives
 *
 * Captures decision timeline and objective weights.
 */

import { useState } from 'react';
import { StyleSheet, Text, TextInput, View } from 'react-native';

import type { TimeHorizons } from '@cognition-engine/shared';
import { useDraftStore, useDraftData } from '@/store/draft-store';
import { Button, WeightInput } from '@/components';
import { getDefaultObjectives, ensureAllObjectiveKeys } from '@/lib/drafts';

interface HorizonsStepProps {
  onNext: () => void;
  onBack: () => void;
}

export function HorizonsStep({ onNext, onBack }: HorizonsStepProps) {
  const data = useDraftData();
  const updateTimeHorizons = useDraftStore((s) => s.updateTimeHorizons);
  const updateObjectives = useDraftStore((s) => s.updateObjectives);
  const saveDraft = useDraftStore((s) => s.saveDraft);

  const [horizons, setHorizons] = useState<TimeHorizons>(
    data?.timeHorizons ?? {
      decisionDeadline: '',
      implementationPeriod: '',
      impactHorizon: '',
    }
  );

  // Ensure we have all objective keys with current values or defaults
  const currentObjectives = ensureAllObjectiveKeys(
    data?.objectives ?? getDefaultObjectives('moderate')
  );

  const totalWeight = currentObjectives.reduce((sum, o) => sum + o.weight, 0);
  const isWeightValid = totalWeight === 100;

  const handleHorizonChange = (field: keyof TimeHorizons, value: string) => {
    const updated = { ...horizons, [field]: value };
    setHorizons(updated);
    updateTimeHorizons(updated);
  };

  const handleNext = async () => {
    if (!isWeightValid) return;
    await saveDraft();
    onNext();
  };

  return (
    <View style={styles.container}>
      <Text style={styles.sectionTitle}>Time Horizons</Text>
      <Text style={styles.sectionHint}>
        When do you need to decide, implement, and see results?
      </Text>

      <View style={styles.field}>
        <Text style={styles.label}>Decision Deadline</Text>
        <TextInput
          style={styles.input}
          value={horizons.decisionDeadline}
          onChangeText={(v) => handleHorizonChange('decisionDeadline', v)}
          placeholder="e.g., End of this month"
          placeholderTextColor="#4a4a6a"
        />
      </View>

      <View style={styles.field}>
        <Text style={styles.label}>Implementation Period</Text>
        <TextInput
          style={styles.input}
          value={horizons.implementationPeriod}
          onChangeText={(v) => handleHorizonChange('implementationPeriod', v)}
          placeholder="e.g., 3-6 months"
          placeholderTextColor="#4a4a6a"
        />
      </View>

      <View style={styles.field}>
        <Text style={styles.label}>Impact Horizon</Text>
        <TextInput
          style={styles.input}
          value={horizons.impactHorizon}
          onChangeText={(v) => handleHorizonChange('impactHorizon', v)}
          placeholder="e.g., 2-3 years"
          placeholderTextColor="#4a4a6a"
        />
      </View>

      <View style={styles.divider} />

      <WeightInput objectives={currentObjectives} onChange={updateObjectives} />

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
          disabled={!isWeightValid}
          style={styles.nextButton}
        />
      </View>

      {!isWeightValid && (
        <Text style={styles.validation}>
          Objective weights must total 100 to continue
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
    marginBottom: 4,
  },
  sectionHint: {
    color: '#6a6a8a',
    fontSize: 13,
    marginBottom: 16,
  },
  field: {
    marginBottom: 16,
  },
  label: {
    color: '#c0c0c0',
    fontSize: 14,
    fontWeight: '500',
    marginBottom: 6,
  },
  input: {
    backgroundColor: '#1a1a2e',
    borderWidth: 1,
    borderColor: '#2a2a4e',
    borderRadius: 10,
    paddingVertical: 12,
    paddingHorizontal: 16,
    color: '#ffffff',
    fontSize: 15,
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
  validation: {
    color: '#ef4444',
    fontSize: 12,
    textAlign: 'center',
    marginTop: 12,
  },
});
