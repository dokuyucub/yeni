/**
 * Option card for decision options.
 */

import { Pressable, StyleSheet, Text, TextInput, View } from 'react-native';
import type { DecisionOption } from '@cognition-engine/shared';

interface OptionCardProps {
  option: DecisionOption;
  index: number;
  onChange: (option: Partial<DecisionOption>) => void;
  onRemove: () => void;
  canRemove: boolean;
}

export function OptionCard({
  option,
  index,
  onChange,
  onRemove,
  canRemove,
}: OptionCardProps) {
  return (
    <View style={styles.container}>
      <View style={styles.header}>
        <View style={styles.labelBadge}>
          <Text style={styles.labelText}>{option.label}</Text>
        </View>
        <Text style={styles.headerTitle}>Option {index + 1}</Text>
        {canRemove && (
          <Pressable style={styles.removeButton} onPress={onRemove}>
            <Text style={styles.removeText}>Remove</Text>
          </Pressable>
        )}
      </View>

      <View style={styles.content}>
        <View style={styles.field}>
          <Text style={styles.fieldLabel}>Name *</Text>
          <TextInput
            style={styles.input}
            value={option.name}
            onChangeText={(name) => onChange({ name })}
            placeholder="e.g., Accept the job offer"
            placeholderTextColor="#4a4a6a"
          />
        </View>

        <View style={styles.field}>
          <Text style={styles.fieldLabel}>Description</Text>
          <TextInput
            style={[styles.input, styles.textArea]}
            value={option.description}
            onChangeText={(description) => onChange({ description })}
            placeholder="Brief description of this option..."
            placeholderTextColor="#4a4a6a"
            multiline
            numberOfLines={3}
            textAlignVertical="top"
          />
        </View>
      </View>
    </View>
  );
}

interface OptionCardReadOnlyProps {
  option: DecisionOption;
}

export function OptionCardReadOnly({ option }: OptionCardReadOnlyProps) {
  return (
    <View style={styles.readOnlyCard}>
      <View style={styles.readOnlyHeader}>
        <View style={styles.labelBadge}>
          <Text style={styles.labelText}>{option.label}</Text>
        </View>
        <Text style={styles.readOnlyName}>{option.name || 'Unnamed option'}</Text>
      </View>
      {option.description && (
        <Text style={styles.readOnlyDescription}>{option.description}</Text>
      )}
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    backgroundColor: '#1a1a2e',
    borderRadius: 12,
    marginBottom: 16,
    overflow: 'hidden',
    borderWidth: 1,
    borderColor: '#2a2a4e',
  },
  header: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: '#2a2a4e',
    paddingVertical: 10,
    paddingHorizontal: 12,
    gap: 10,
  },
  labelBadge: {
    width: 28,
    height: 28,
    borderRadius: 6,
    backgroundColor: '#e94560',
    alignItems: 'center',
    justifyContent: 'center',
  },
  labelText: {
    color: '#ffffff',
    fontSize: 12,
    fontWeight: 'bold',
  },
  headerTitle: {
    flex: 1,
    color: '#ffffff',
    fontSize: 14,
    fontWeight: '600',
  },
  removeButton: {
    paddingVertical: 4,
    paddingHorizontal: 10,
    borderRadius: 6,
    backgroundColor: 'rgba(239, 68, 68, 0.2)',
  },
  removeText: {
    color: '#ef4444',
    fontSize: 12,
    fontWeight: '600',
  },
  content: {
    padding: 16,
  },
  field: {
    marginBottom: 16,
  },
  fieldLabel: {
    color: '#c0c0c0',
    fontSize: 13,
    fontWeight: '500',
    marginBottom: 6,
  },
  input: {
    backgroundColor: '#0f0f1a',
    borderWidth: 1,
    borderColor: '#2a2a4e',
    borderRadius: 8,
    paddingVertical: 10,
    paddingHorizontal: 12,
    color: '#ffffff',
    fontSize: 14,
  },
  textArea: {
    minHeight: 80,
    paddingTop: 10,
  },
  // Read-only styles
  readOnlyCard: {
    backgroundColor: '#1a1a2e',
    borderRadius: 10,
    padding: 12,
    marginBottom: 10,
    borderWidth: 1,
    borderColor: '#2a2a4e',
  },
  readOnlyHeader: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 10,
  },
  readOnlyName: {
    flex: 1,
    color: '#ffffff',
    fontSize: 14,
    fontWeight: '600',
  },
  readOnlyDescription: {
    color: '#6a6a8a',
    fontSize: 13,
    marginTop: 8,
    paddingLeft: 38,
    lineHeight: 18,
  },
});
