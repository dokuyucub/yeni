/**
 * Reusable input component.
 */

import { useState } from 'react';
import {
  TextInput,
  StyleSheet,
  Text,
  View,
  Pressable,
  TextInputProps,
  ViewStyle,
} from 'react-native';

interface InputProps extends Omit<TextInputProps, 'style'> {
  label?: string;
  error?: string;
  hint?: string;
  containerStyle?: ViewStyle;
  showPasswordToggle?: boolean;
}

export function Input({
  label,
  error,
  hint,
  containerStyle,
  showPasswordToggle = false,
  secureTextEntry,
  ...props
}: InputProps) {
  const [isPasswordVisible, setIsPasswordVisible] = useState(false);
  const shouldHidePassword = secureTextEntry && !isPasswordVisible;

  return (
    <View style={[styles.container, containerStyle]}>
      {label && <Text style={styles.label}>{label}</Text>}
      <View style={styles.inputWrapper}>
        <TextInput
          style={[
            styles.input,
            error && styles.inputError,
            showPasswordToggle && styles.inputWithToggle,
          ]}
          placeholderTextColor="#6a6a8a"
          secureTextEntry={shouldHidePassword}
          autoCapitalize="none"
          autoCorrect={false}
          {...props}
        />
        {showPasswordToggle && secureTextEntry && (
          <Pressable
            style={styles.toggleButton}
            onPress={() => setIsPasswordVisible(!isPasswordVisible)}
            hitSlop={8}
          >
            <Text style={styles.toggleText}>
              {isPasswordVisible ? 'Hide' : 'Show'}
            </Text>
          </Pressable>
        )}
      </View>
      {error && <Text style={styles.error}>{error}</Text>}
      {hint && !error && <Text style={styles.hint}>{hint}</Text>}
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    marginBottom: 16,
  },
  label: {
    color: '#ffffff',
    fontSize: 14,
    fontWeight: '600',
    marginBottom: 8,
  },
  inputWrapper: {
    position: 'relative',
    flexDirection: 'row',
    alignItems: 'center',
  },
  input: {
    flex: 1,
    backgroundColor: '#1a1a2e',
    borderWidth: 1,
    borderColor: '#2a2a4e',
    borderRadius: 8,
    paddingVertical: 12,
    paddingHorizontal: 16,
    color: '#ffffff',
    fontSize: 16,
  },
  inputWithToggle: {
    paddingRight: 60,
  },
  inputError: {
    borderColor: '#ef4444',
  },
  toggleButton: {
    position: 'absolute',
    right: 16,
  },
  toggleText: {
    color: '#e94560',
    fontSize: 14,
    fontWeight: '600',
  },
  error: {
    color: '#ef4444',
    fontSize: 12,
    marginTop: 4,
  },
  hint: {
    color: '#6a6a8a',
    fontSize: 12,
    marginTop: 4,
  },
});
