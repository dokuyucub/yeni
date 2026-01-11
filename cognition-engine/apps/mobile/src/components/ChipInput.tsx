/**
 * Chip input for adding/removing string items.
 */

import { useState } from 'react';
import { Pressable, StyleSheet, Text, TextInput, View } from 'react-native';

interface ChipInputProps {
  label: string;
  items: string[];
  onChange: (items: string[]) => void;
  placeholder?: string;
  maxItems?: number;
}

export function ChipInput({
  label,
  items,
  onChange,
  placeholder = 'Type and press Add',
  maxItems = 10,
}: ChipInputProps) {
  const [inputValue, setInputValue] = useState('');

  const handleAdd = () => {
    const trimmed = inputValue.trim();
    if (trimmed && !items.includes(trimmed) && items.length < maxItems) {
      onChange([...items, trimmed]);
      setInputValue('');
    }
  };

  const handleRemove = (index: number) => {
    const newItems = items.filter((_, i) => i !== index);
    onChange(newItems);
  };

  return (
    <View style={styles.container}>
      <Text style={styles.label}>{label}</Text>

      <View style={styles.inputRow}>
        <TextInput
          style={styles.input}
          value={inputValue}
          onChangeText={setInputValue}
          placeholder={placeholder}
          placeholderTextColor="#6a6a8a"
          onSubmitEditing={handleAdd}
          returnKeyType="done"
        />
        <Pressable
          style={[styles.addButton, !inputValue.trim() && styles.addButtonDisabled]}
          onPress={handleAdd}
          disabled={!inputValue.trim()}
        >
          <Text style={styles.addButtonText}>Add</Text>
        </Pressable>
      </View>

      {items.length > 0 && (
        <View style={styles.chipsContainer}>
          {items.map((item, index) => (
            <View key={`${item}-${index}`} style={styles.chip}>
              <Text style={styles.chipText} numberOfLines={1}>
                {item}
              </Text>
              <Pressable
                onPress={() => handleRemove(index)}
                style={styles.removeButton}
                hitSlop={8}
              >
                <Text style={styles.removeText}>×</Text>
              </Pressable>
            </View>
          ))}
        </View>
      )}

      {items.length === 0 && (
        <Text style={styles.emptyText}>No items added yet</Text>
      )}
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    marginBottom: 20,
  },
  label: {
    color: '#ffffff',
    fontSize: 14,
    fontWeight: '600',
    marginBottom: 8,
  },
  inputRow: {
    flexDirection: 'row',
    gap: 8,
  },
  input: {
    flex: 1,
    backgroundColor: '#1a1a2e',
    borderWidth: 1,
    borderColor: '#2a2a4e',
    borderRadius: 8,
    paddingVertical: 10,
    paddingHorizontal: 12,
    color: '#ffffff',
    fontSize: 14,
  },
  addButton: {
    backgroundColor: '#e94560',
    paddingHorizontal: 16,
    borderRadius: 8,
    justifyContent: 'center',
  },
  addButtonDisabled: {
    opacity: 0.5,
  },
  addButtonText: {
    color: '#ffffff',
    fontWeight: '600',
  },
  chipsContainer: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    gap: 8,
    marginTop: 12,
  },
  chip: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: '#2a2a4e',
    paddingVertical: 6,
    paddingLeft: 12,
    paddingRight: 8,
    borderRadius: 16,
    maxWidth: '90%',
  },
  chipText: {
    color: '#ffffff',
    fontSize: 13,
    marginRight: 4,
    flexShrink: 1,
  },
  removeButton: {
    width: 20,
    height: 20,
    alignItems: 'center',
    justifyContent: 'center',
  },
  removeText: {
    color: '#a0a0a0',
    fontSize: 18,
    fontWeight: 'bold',
  },
  emptyText: {
    color: '#6a6a8a',
    fontSize: 13,
    marginTop: 8,
    fontStyle: 'italic',
  },
});
