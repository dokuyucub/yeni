/**
 * Step 6: Baseline, Success & Failure Definitions
 *
 * Captures do-nothing baseline and success/failure criteria.
 */

import { useState } from 'react';
import { Pressable, StyleSheet, Text, TextInput, View } from 'react-native';

import type { GutPreference } from '@cognition-engine/shared';
import { useDraftStore, useDraftData } from '@/store/draft-store';
import { Button } from '@/components';

interface BaselineStepProps {
  onNext: () => void;
  onBack: () => void;
}

export function BaselineStep({ onNext, onBack }: BaselineStepProps) {
  const data = useDraftData();
  const updateBaseline = useDraftStore((s) => s.updateBaseline);
  const updateSuccessDefinition = useDraftStore((s) => s.updateSuccessDefinition);
  const updateFailureDefinition = useDraftStore((s) => s.updateFailureDefinition);
  const updateGutPreference = useDraftStore((s) => s.updateGutPreference);
  const saveDraft = useDraftStore((s) => s.saveDraft);

  const [baseline, setBaseline] = useState(data?.baselineDoNothing ?? '');
  const [success, setSuccess] = useState(data?.successDefinition ?? '');
  const [failure, setFailure] = useState(data?.failureDefinition ?? '');
  const [gut, setGut] = useState<GutPreference | undefined>(data?.gutPreference);

  const options = data?.options ?? [];

  const handleBaselineChange = (value: string) => {
    setBaseline(value);
    updateBaseline(value);
  };

  const handleSuccessChange = (value: string) => {
    setSuccess(value);
    updateSuccessDefinition(value);
  };

  const handleFailureChange = (value: string) => {
    setFailure(value);
    updateFailureDefinition(value);
  };

  const handleGutChange = (optionLabel: string | undefined) => {
    if (optionLabel) {
      const newGut: GutPreference = {
        optionLabel,
        confidence: gut?.confidence ?? 50,
        reason: gut?.reason ?? '',
      };
      setGut(newGut);
      updateGutPreference(newGut);
    } else {
      setGut(undefined);
      updateGutPreference(undefined);
    }
  };

  const handleConfidenceChange = (value: string) => {
    if (!gut) return;
    const confidence = Math.max(0, Math.min(100, parseInt(value, 10) || 0));
    const newGut = { ...gut, confidence };
    setGut(newGut);
    updateGutPreference(newGut);
  };

  const handleReasonChange = (value: string) => {
    if (!gut) return;
    const newGut = { ...gut, reason: value };
    setGut(newGut);
    updateGutPreference(newGut);
  };

  const handleNext = async () => {
    await saveDraft();
    onNext();
  };

  return (
    <View style={styles.container}>
      {/* Baseline */}
      <Text style={styles.sectionTitle}>Do-Nothing Baseline</Text>
      <Text style={styles.sectionHint}>
        What happens if you don't make a decision or take no action?
      </Text>

      <TextInput
        style={styles.textArea}
        value={baseline}
        onChangeText={handleBaselineChange}
        placeholder="Describe the status quo and what would happen if you did nothing..."
        placeholderTextColor="#4a4a6a"
        multiline
        numberOfLines={4}
        textAlignVertical="top"
      />

      <View style={styles.divider} />

      {/* Success Definition */}
      <Text style={styles.sectionTitle}>What Does Success Look Like?</Text>
      <Text style={styles.sectionHint}>
        How will you know if you made the right choice?
      </Text>

      <TextInput
        style={styles.textArea}
        value={success}
        onChangeText={handleSuccessChange}
        placeholder="Describe concrete indicators of a successful outcome..."
        placeholderTextColor="#4a4a6a"
        multiline
        numberOfLines={4}
        textAlignVertical="top"
      />

      <View style={styles.divider} />

      {/* Failure Definition */}
      <Text style={styles.sectionTitle}>What Does Failure Look Like?</Text>
      <Text style={styles.sectionHint}>
        What outcomes would you consider a failure?
      </Text>

      <TextInput
        style={styles.textArea}
        value={failure}
        onChangeText={handleFailureChange}
        placeholder="Describe what would make you regret this decision..."
        placeholderTextColor="#4a4a6a"
        multiline
        numberOfLines={4}
        textAlignVertical="top"
      />

      <View style={styles.divider} />

      {/* Gut Feeling */}
      <Text style={styles.sectionTitle}>Gut Feeling (Optional)</Text>
      <Text style={styles.sectionHint}>
        What does your intuition tell you? This helps identify biases.
      </Text>

      <Text style={styles.label}>Which option feels right?</Text>
      <View style={styles.gutOptions}>
        <Pressable
          style={[styles.gutOption, !gut && styles.gutOptionSelected]}
          onPress={() => handleGutChange(undefined)}
        >
          <Text style={[styles.gutOptionText, !gut && styles.gutOptionTextSelected]}>
            Not sure
          </Text>
        </Pressable>
        {options.map((option) => (
          <Pressable
            key={option.label}
            style={[
              styles.gutOption,
              gut?.optionLabel === option.label && styles.gutOptionSelected,
            ]}
            onPress={() => handleGutChange(option.label)}
          >
            <Text
              style={[
                styles.gutOptionText,
                gut?.optionLabel === option.label && styles.gutOptionTextSelected,
              ]}
            >
              {option.label}: {option.name || 'Unnamed'}
            </Text>
          </Pressable>
        ))}
      </View>

      {gut && (
        <>
          <View style={styles.confidenceRow}>
            <Text style={styles.label}>Confidence Level</Text>
            <View style={styles.confidenceInput}>
              <TextInput
                style={styles.confidenceTextInput}
                value={String(gut.confidence)}
                onChangeText={handleConfidenceChange}
                keyboardType="number-pad"
                maxLength={3}
              />
              <Text style={styles.confidencePercent}>%</Text>
            </View>
          </View>

          <View style={styles.field}>
            <Text style={styles.label}>Why does this feel right?</Text>
            <TextInput
              style={styles.input}
              value={gut.reason}
              onChangeText={handleReasonChange}
              placeholder="What's driving this intuition?"
              placeholderTextColor="#4a4a6a"
            />
          </View>
        </>
      )}

      <View style={styles.buttonRow}>
        <Button
          title="Back"
          variant="secondary"
          onPress={onBack}
          style={styles.backButton}
        />
        <Button title="Review" onPress={handleNext} style={styles.nextButton} />
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
    marginBottom: 12,
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
    minHeight: 100,
  },
  divider: {
    height: 1,
    backgroundColor: '#2a2a4e',
    marginVertical: 24,
  },
  field: {
    marginBottom: 16,
  },
  label: {
    color: '#c0c0c0',
    fontSize: 14,
    fontWeight: '500',
    marginBottom: 8,
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
  gutOptions: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    gap: 8,
    marginBottom: 16,
  },
  gutOption: {
    paddingVertical: 8,
    paddingHorizontal: 14,
    backgroundColor: '#1a1a2e',
    borderRadius: 20,
    borderWidth: 1,
    borderColor: '#2a2a4e',
  },
  gutOptionSelected: {
    borderColor: '#e94560',
    backgroundColor: 'rgba(233, 69, 96, 0.15)',
  },
  gutOptionText: {
    color: '#808080',
    fontSize: 13,
  },
  gutOptionTextSelected: {
    color: '#e94560',
    fontWeight: '600',
  },
  confidenceRow: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    marginBottom: 16,
  },
  confidenceInput: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  confidenceTextInput: {
    width: 60,
    backgroundColor: '#1a1a2e',
    borderWidth: 1,
    borderColor: '#2a2a4e',
    borderRadius: 8,
    paddingVertical: 8,
    paddingHorizontal: 12,
    color: '#ffffff',
    fontSize: 16,
    textAlign: 'center',
  },
  confidencePercent: {
    color: '#808080',
    fontSize: 16,
    marginLeft: 6,
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
