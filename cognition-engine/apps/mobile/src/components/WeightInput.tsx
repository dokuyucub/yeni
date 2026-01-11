/**
 * Weight input for objectives.
 */

import { Pressable, StyleSheet, Text, TextInput, View } from 'react-native';
import type { ObjectiveWeight, ObjectiveKey } from '@cognition-engine/shared';
import { OBJECTIVE_LABELS } from '@cognition-engine/shared';

interface WeightInputProps {
  objectives: ObjectiveWeight[];
  onChange: (objectives: ObjectiveWeight[]) => void;
}

const ALL_KEYS: ObjectiveKey[] = [
  'money',
  'time',
  'freedom',
  'learning',
  'status',
  'impact',
  'health',
  'relationships',
  'other',
];

export function WeightInput({ objectives, onChange }: WeightInputProps) {
  const total = objectives.reduce((sum, obj) => sum + obj.weight, 0);
  const isValid = total === 100;

  // Get weight for a key
  const getWeight = (key: ObjectiveKey): number => {
    return objectives.find((o) => o.key === key)?.weight ?? 0;
  };

  // Update weight for a key
  const updateWeight = (key: ObjectiveKey, value: string) => {
    const numValue = parseInt(value, 10) || 0;
    const clampedValue = Math.max(0, Math.min(100, numValue));

    const existing = objectives.find((o) => o.key === key);
    if (existing) {
      const updated = objectives.map((o) =>
        o.key === key ? { ...o, weight: clampedValue } : o
      );
      onChange(updated);
    } else {
      onChange([...objectives, { key, weight: clampedValue }]);
    }
  };

  // Increment/decrement weight
  const adjustWeight = (key: ObjectiveKey, delta: number) => {
    const current = getWeight(key);
    const newValue = Math.max(0, Math.min(100, current + delta));
    updateWeight(key, String(newValue));
  };

  // Distribute remaining evenly
  const distributeRemaining = () => {
    const remaining = 100 - total;
    if (remaining <= 0) return;

    const activeKeys = objectives.filter((o) => o.weight > 0).map((o) => o.key);
    if (activeKeys.length === 0) return;

    const perKey = Math.floor(remaining / activeKeys.length);
    const extra = remaining % activeKeys.length;

    const updated = objectives.map((o, index) => {
      if (activeKeys.includes(o.key)) {
        return { ...o, weight: o.weight + perKey + (index === 0 ? extra : 0) };
      }
      return o;
    });

    onChange(updated);
  };

  return (
    <View style={styles.container}>
      <View style={styles.header}>
        <Text style={styles.label}>Objective Weights</Text>
        <Text style={[styles.total, isValid ? styles.totalValid : styles.totalInvalid]}>
          Total: {total}/100
        </Text>
      </View>

      <Text style={styles.hint}>
        Distribute 100 points across objectives that matter most
      </Text>

      {ALL_KEYS.map((key) => (
        <View key={key} style={styles.row}>
          <Text style={styles.keyLabel}>{OBJECTIVE_LABELS[key]}</Text>
          <View style={styles.controls}>
            <Pressable
              style={styles.adjustButton}
              onPress={() => adjustWeight(key, -5)}
            >
              <Text style={styles.adjustText}>−</Text>
            </Pressable>
            <TextInput
              style={styles.input}
              value={String(getWeight(key))}
              onChangeText={(v) => updateWeight(key, v)}
              keyboardType="number-pad"
              maxLength={3}
            />
            <Pressable
              style={styles.adjustButton}
              onPress={() => adjustWeight(key, 5)}
            >
              <Text style={styles.adjustText}>+</Text>
            </Pressable>
          </View>
        </View>
      ))}

      {!isValid && total < 100 && (
        <Pressable style={styles.distributeButton} onPress={distributeRemaining}>
          <Text style={styles.distributeText}>
            Distribute remaining {100 - total} points
          </Text>
        </Pressable>
      )}

      {!isValid && (
        <Text style={styles.error}>
          {total < 100
            ? `Add ${100 - total} more points`
            : `Remove ${total - 100} points`}
        </Text>
      )}
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    marginBottom: 20,
  },
  header: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: 4,
  },
  label: {
    color: '#ffffff',
    fontSize: 14,
    fontWeight: '600',
  },
  total: {
    fontSize: 14,
    fontWeight: '600',
  },
  totalValid: {
    color: '#4ade80',
  },
  totalInvalid: {
    color: '#ef4444',
  },
  hint: {
    color: '#6a6a8a',
    fontSize: 12,
    marginBottom: 12,
  },
  row: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    paddingVertical: 8,
    borderBottomWidth: 1,
    borderBottomColor: '#2a2a4e',
  },
  keyLabel: {
    color: '#c0c0c0',
    fontSize: 14,
    flex: 1,
  },
  controls: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 8,
  },
  adjustButton: {
    width: 32,
    height: 32,
    backgroundColor: '#2a2a4e',
    borderRadius: 16,
    alignItems: 'center',
    justifyContent: 'center',
  },
  adjustText: {
    color: '#ffffff',
    fontSize: 18,
    fontWeight: 'bold',
  },
  input: {
    width: 50,
    backgroundColor: '#1a1a2e',
    borderWidth: 1,
    borderColor: '#2a2a4e',
    borderRadius: 6,
    paddingVertical: 4,
    paddingHorizontal: 8,
    color: '#ffffff',
    fontSize: 14,
    textAlign: 'center',
  },
  distributeButton: {
    marginTop: 12,
    paddingVertical: 8,
    paddingHorizontal: 16,
    backgroundColor: '#2a2a4e',
    borderRadius: 8,
    alignSelf: 'center',
  },
  distributeText: {
    color: '#e94560',
    fontSize: 13,
    fontWeight: '600',
  },
  error: {
    color: '#ef4444',
    fontSize: 12,
    marginTop: 8,
    textAlign: 'center',
  },
});
