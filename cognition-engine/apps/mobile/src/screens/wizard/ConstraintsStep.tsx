/**
 * Step 4: Constraints, Resources & Stakeholders
 *
 * Captures practical limitations and people involved.
 */

import { useState } from 'react';
import { StyleSheet, Text, TextInput, View } from 'react-native';

import type {
  DecisionConstraints,
  DecisionResources,
  DecisionStakeholders,
} from '@cognition-engine/shared';
import { useDraftStore, useDraftData } from '@/store/draft-store';
import { Button } from '@/components';

interface ConstraintsStepProps {
  onNext: () => void;
  onBack: () => void;
}

export function ConstraintsStep({ onNext, onBack }: ConstraintsStepProps) {
  const data = useDraftData();
  const updateConstraints = useDraftStore((s) => s.updateConstraints);
  const updateResources = useDraftStore((s) => s.updateResources);
  const updateStakeholders = useDraftStore((s) => s.updateStakeholders);
  const saveDraft = useDraftStore((s) => s.saveDraft);

  const [constraints, setConstraints] = useState<DecisionConstraints>(
    data?.constraints ?? {
      budgetMin: undefined,
      budgetMax: undefined,
      mustHaves: '',
      cantDo: '',
    }
  );

  const [resources, setResources] = useState<DecisionResources>(
    data?.resources ?? {
      available: '',
      needed: '',
    }
  );

  const [stakeholders, setStakeholders] = useState<DecisionStakeholders>(
    data?.stakeholders ?? {
      decisionMaker: '',
      influencers: '',
      affected: '',
    }
  );

  const handleConstraintChange = (
    field: keyof DecisionConstraints,
    value: string | number | undefined
  ) => {
    const updated = { ...constraints, [field]: value };
    setConstraints(updated);
    updateConstraints(updated);
  };

  const handleResourceChange = (field: keyof DecisionResources, value: string) => {
    const updated = { ...resources, [field]: value };
    setResources(updated);
    updateResources(updated);
  };

  const handleStakeholderChange = (
    field: keyof DecisionStakeholders,
    value: string
  ) => {
    const updated = { ...stakeholders, [field]: value };
    setStakeholders(updated);
    updateStakeholders(updated);
  };

  const handleNext = async () => {
    await saveDraft();
    onNext();
  };

  return (
    <View style={styles.container}>
      {/* Constraints */}
      <Text style={styles.sectionTitle}>Constraints</Text>
      <Text style={styles.sectionHint}>
        What are the hard limits on this decision?
      </Text>

      <View style={styles.budgetRow}>
        <View style={styles.budgetField}>
          <Text style={styles.label}>Budget Min ($)</Text>
          <TextInput
            style={styles.input}
            value={constraints.budgetMin?.toString() ?? ''}
            onChangeText={(v) =>
              handleConstraintChange('budgetMin', v ? parseInt(v, 10) : undefined)
            }
            placeholder="0"
            placeholderTextColor="#4a4a6a"
            keyboardType="number-pad"
          />
        </View>
        <View style={styles.budgetField}>
          <Text style={styles.label}>Budget Max ($)</Text>
          <TextInput
            style={styles.input}
            value={constraints.budgetMax?.toString() ?? ''}
            onChangeText={(v) =>
              handleConstraintChange('budgetMax', v ? parseInt(v, 10) : undefined)
            }
            placeholder="∞"
            placeholderTextColor="#4a4a6a"
            keyboardType="number-pad"
          />
        </View>
      </View>

      <View style={styles.field}>
        <Text style={styles.label}>Must-haves</Text>
        <TextInput
          style={styles.textArea}
          value={constraints.mustHaves}
          onChangeText={(v) => handleConstraintChange('mustHaves', v)}
          placeholder="Non-negotiable requirements..."
          placeholderTextColor="#4a4a6a"
          multiline
          numberOfLines={2}
          textAlignVertical="top"
        />
      </View>

      <View style={styles.field}>
        <Text style={styles.label}>Can't do / Off-limits</Text>
        <TextInput
          style={styles.textArea}
          value={constraints.cantDo}
          onChangeText={(v) => handleConstraintChange('cantDo', v)}
          placeholder="Things you absolutely cannot or will not do..."
          placeholderTextColor="#4a4a6a"
          multiline
          numberOfLines={2}
          textAlignVertical="top"
        />
      </View>

      <View style={styles.divider} />

      {/* Resources */}
      <Text style={styles.sectionTitle}>Resources</Text>
      <Text style={styles.sectionHint}>
        What do you have and what do you need?
      </Text>

      <View style={styles.field}>
        <Text style={styles.label}>Currently Available</Text>
        <TextInput
          style={styles.textArea}
          value={resources.available}
          onChangeText={(v) => handleResourceChange('available', v)}
          placeholder="Time, money, skills, connections..."
          placeholderTextColor="#4a4a6a"
          multiline
          numberOfLines={2}
          textAlignVertical="top"
        />
      </View>

      <View style={styles.field}>
        <Text style={styles.label}>Still Needed</Text>
        <TextInput
          style={styles.textArea}
          value={resources.needed}
          onChangeText={(v) => handleResourceChange('needed', v)}
          placeholder="What gaps need to be filled?"
          placeholderTextColor="#4a4a6a"
          multiline
          numberOfLines={2}
          textAlignVertical="top"
        />
      </View>

      <View style={styles.divider} />

      {/* Stakeholders */}
      <Text style={styles.sectionTitle}>Stakeholders</Text>
      <Text style={styles.sectionHint}>Who is involved in or affected by this?</Text>

      <View style={styles.field}>
        <Text style={styles.label}>Decision Maker(s)</Text>
        <TextInput
          style={styles.input}
          value={stakeholders.decisionMaker}
          onChangeText={(v) => handleStakeholderChange('decisionMaker', v)}
          placeholder="Who has final say?"
          placeholderTextColor="#4a4a6a"
        />
      </View>

      <View style={styles.field}>
        <Text style={styles.label}>Key Influencers</Text>
        <TextInput
          style={styles.input}
          value={stakeholders.influencers}
          onChangeText={(v) => handleStakeholderChange('influencers', v)}
          placeholder="Who can sway the decision?"
          placeholderTextColor="#4a4a6a"
        />
      </View>

      <View style={styles.field}>
        <Text style={styles.label}>Affected Parties</Text>
        <TextInput
          style={styles.input}
          value={stakeholders.affected}
          onChangeText={(v) => handleStakeholderChange('affected', v)}
          placeholder="Who will be impacted?"
          placeholderTextColor="#4a4a6a"
        />
      </View>

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
  textArea: {
    backgroundColor: '#1a1a2e',
    borderWidth: 1,
    borderColor: '#2a2a4e',
    borderRadius: 10,
    paddingVertical: 12,
    paddingHorizontal: 16,
    color: '#ffffff',
    fontSize: 15,
    minHeight: 70,
  },
  budgetRow: {
    flexDirection: 'row',
    gap: 12,
    marginBottom: 16,
  },
  budgetField: {
    flex: 1,
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
