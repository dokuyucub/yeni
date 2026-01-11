/**
 * Review section component for wizard summary.
 */

import { Pressable, StyleSheet, Text, View } from 'react-native';

interface ReviewSectionProps {
  title: string;
  stepIndex: number;
  children: React.ReactNode;
  onEdit?: () => void;
}

export function ReviewSection({ title, stepIndex, children, onEdit }: ReviewSectionProps) {
  return (
    <View style={styles.container}>
      <View style={styles.header}>
        <View style={styles.titleRow}>
          <Text style={styles.stepNumber}>{stepIndex + 1}</Text>
          <Text style={styles.title}>{title}</Text>
        </View>
        {onEdit && (
          <Pressable style={styles.editButton} onPress={onEdit}>
            <Text style={styles.editText}>Edit</Text>
          </Pressable>
        )}
      </View>
      <View style={styles.content}>{children}</View>
    </View>
  );
}

interface ReviewFieldProps {
  label: string;
  value: string | number | undefined | null;
  placeholder?: string;
}

export function ReviewField({ label, value, placeholder = 'Not set' }: ReviewFieldProps) {
  const displayValue = value === undefined || value === null || value === ''
    ? placeholder
    : String(value);
  const isEmpty = value === undefined || value === null || value === '';

  return (
    <View style={styles.field}>
      <Text style={styles.fieldLabel}>{label}</Text>
      <Text style={[styles.fieldValue, isEmpty && styles.fieldEmpty]}>
        {displayValue}
      </Text>
    </View>
  );
}

interface ReviewListProps {
  label: string;
  items: string[];
  placeholder?: string;
}

export function ReviewList({ label, items, placeholder = 'None' }: ReviewListProps) {
  return (
    <View style={styles.field}>
      <Text style={styles.fieldLabel}>{label}</Text>
      {items.length > 0 ? (
        items.map((item, index) => (
          <Text key={index} style={styles.listItem}>
            • {item}
          </Text>
        ))
      ) : (
        <Text style={[styles.fieldValue, styles.fieldEmpty]}>{placeholder}</Text>
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
  },
  header: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    backgroundColor: '#2a2a4e',
    paddingVertical: 12,
    paddingHorizontal: 16,
  },
  titleRow: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 12,
  },
  stepNumber: {
    width: 24,
    height: 24,
    borderRadius: 12,
    backgroundColor: '#e94560',
    color: '#ffffff',
    fontSize: 12,
    fontWeight: 'bold',
    textAlign: 'center',
    lineHeight: 24,
  },
  title: {
    color: '#ffffff',
    fontSize: 16,
    fontWeight: '600',
  },
  editButton: {
    paddingVertical: 4,
    paddingHorizontal: 12,
    borderRadius: 6,
    backgroundColor: 'rgba(233, 69, 96, 0.2)',
  },
  editText: {
    color: '#e94560',
    fontSize: 13,
    fontWeight: '600',
  },
  content: {
    padding: 16,
  },
  field: {
    marginBottom: 12,
  },
  fieldLabel: {
    color: '#6a6a8a',
    fontSize: 12,
    fontWeight: '500',
    marginBottom: 4,
  },
  fieldValue: {
    color: '#c0c0c0',
    fontSize: 14,
    lineHeight: 20,
  },
  fieldEmpty: {
    color: '#4a4a6a',
    fontStyle: 'italic',
  },
  listItem: {
    color: '#c0c0c0',
    fontSize: 14,
    lineHeight: 22,
    paddingLeft: 4,
  },
});
