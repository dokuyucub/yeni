/**
 * Step 1: Decision Basics
 *
 * Captures title and problem statement.
 */

import { useState } from 'react';
import { StyleSheet, Text, TextInput, View } from 'react-native';

import { useDraftStore, useDraftData } from '@/store/draft-store';
import { Button } from '@/components';

interface BasicsStepProps {
  onNext: () => void;
}

export function BasicsStep({ onNext }: BasicsStepProps) {
  const data = useDraftData();
  const updateBasics = useDraftStore((s) => s.updateBasics);
  const saveDraft = useDraftStore((s) => s.saveDraft);

  const [title, setTitle] = useState(data?.title ?? '');
  const [statement, setStatement] = useState(data?.statement ?? '');
  const [errors, setErrors] = useState<{ title?: string; statement?: string }>({});

  const validate = () => {
    const newErrors: typeof errors = {};

    if (!title.trim()) {
      newErrors.title = 'Title is required';
    } else if (title.length < 3) {
      newErrors.title = 'Title must be at least 3 characters';
    }

    if (!statement.trim()) {
      newErrors.statement = 'Problem statement is required';
    } else if (statement.length < 10) {
      newErrors.statement = 'Please provide more detail (at least 10 characters)';
    }

    setErrors(newErrors);
    return Object.keys(newErrors).length === 0;
  };

  const handleNext = async () => {
    if (!validate()) return;

    updateBasics(title.trim(), statement.trim());
    await saveDraft();
    onNext();
  };

  return (
    <View style={styles.container}>
      <View style={styles.field}>
        <Text style={styles.label}>Decision Title *</Text>
        <Text style={styles.hint}>
          A short, memorable name for this decision
        </Text>
        <TextInput
          style={[styles.input, errors.title && styles.inputError]}
          value={title}
          onChangeText={setTitle}
          placeholder="e.g., Career change to tech"
          placeholderTextColor="#4a4a6a"
          maxLength={100}
        />
        {errors.title && <Text style={styles.error}>{errors.title}</Text>}
        <Text style={styles.charCount}>{title.length}/100</Text>
      </View>

      <View style={styles.field}>
        <Text style={styles.label}>Problem Statement *</Text>
        <Text style={styles.hint}>
          What decision are you facing? Be specific about the situation and what
          you need to decide.
        </Text>
        <TextInput
          style={[styles.textArea, errors.statement && styles.inputError]}
          value={statement}
          onChangeText={setStatement}
          placeholder="e.g., I've been offered a senior developer position at a startup with higher pay but less stability. I need to decide whether to leave my current stable corporate job..."
          placeholderTextColor="#4a4a6a"
          multiline
          numberOfLines={6}
          textAlignVertical="top"
          maxLength={2000}
        />
        {errors.statement && <Text style={styles.error}>{errors.statement}</Text>}
        <Text style={styles.charCount}>{statement.length}/2000</Text>
      </View>

      <View style={styles.tips}>
        <Text style={styles.tipsTitle}>Tips for a good problem statement:</Text>
        <Text style={styles.tipItem}>• Be specific about the context</Text>
        <Text style={styles.tipItem}>• Include relevant constraints</Text>
        <Text style={styles.tipItem}>• Mention the timeline if applicable</Text>
        <Text style={styles.tipItem}>• Describe what makes this decision difficult</Text>
      </View>

      <Button title="Continue" onPress={handleNext} style={styles.button} />
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
  },
  field: {
    marginBottom: 24,
  },
  label: {
    color: '#ffffff',
    fontSize: 16,
    fontWeight: '600',
    marginBottom: 4,
  },
  hint: {
    color: '#6a6a8a',
    fontSize: 13,
    marginBottom: 8,
    lineHeight: 18,
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
    minHeight: 140,
    textAlignVertical: 'top',
  },
  inputError: {
    borderColor: '#ef4444',
  },
  error: {
    color: '#ef4444',
    fontSize: 12,
    marginTop: 4,
  },
  charCount: {
    color: '#4a4a6a',
    fontSize: 11,
    textAlign: 'right',
    marginTop: 4,
  },
  tips: {
    backgroundColor: '#1a1a2e',
    borderRadius: 10,
    padding: 16,
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
  button: {
    marginTop: 8,
  },
});
