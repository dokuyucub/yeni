/**
 * Login screen.
 */

import { useState } from 'react';
import {
  KeyboardAvoidingView,
  Platform,
  ScrollView,
  StyleSheet,
  Text,
  View,
  Pressable,
} from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { Link, router } from 'expo-router';

import { loginSchema, type LoginFormData } from '@cognition-engine/shared';
import { Button, Input, ErrorBanner } from '@/components';
import { useAuthStore } from '@/store/auth-store';

export default function LoginScreen() {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [errors, setErrors] = useState<Partial<LoginFormData>>({});

  const { signIn, isLoading, error, clearError } = useAuthStore();

  const validate = (): boolean => {
    const result = loginSchema.safeParse({ email, password });

    if (!result.success) {
      const fieldErrors: Partial<LoginFormData> = {};
      result.error.errors.forEach((err) => {
        const field = err.path[0] as keyof LoginFormData;
        if (!fieldErrors[field]) {
          fieldErrors[field] = err.message;
        }
      });
      setErrors(fieldErrors);
      return false;
    }

    setErrors({});
    return true;
  };

  const handleLogin = async () => {
    if (!validate()) return;

    clearError();
    const result = await signIn(email, password);

    if (result.success) {
      router.replace('/(app)');
    }
  };

  return (
    <SafeAreaView style={styles.container}>
      <KeyboardAvoidingView
        behavior={Platform.OS === 'ios' ? 'padding' : 'height'}
        style={styles.keyboardView}
      >
        <ScrollView
          contentContainerStyle={styles.scrollContent}
          keyboardShouldPersistTaps="handled"
        >
          <View style={styles.header}>
            <Text style={styles.title}>Cognition Engine</Text>
            <Text style={styles.subtitle}>Sign in to continue</Text>
          </View>

          <View style={styles.form}>
            {error && (
              <ErrorBanner message={error.message} onDismiss={clearError} />
            )}

            <Input
              label="Email"
              placeholder="Enter your email"
              value={email}
              onChangeText={setEmail}
              keyboardType="email-address"
              autoComplete="email"
              error={errors.email}
            />

            <Input
              label="Password"
              placeholder="Enter your password"
              value={password}
              onChangeText={setPassword}
              secureTextEntry
              showPasswordToggle
              autoComplete="password"
              error={errors.password}
            />

            <Button
              title="Sign In"
              onPress={handleLogin}
              loading={isLoading}
              disabled={isLoading}
              fullWidth
              size="large"
              style={styles.button}
            />
          </View>

          <View style={styles.footer}>
            <Text style={styles.footerText}>Don't have an account?</Text>
            <Link href="/(auth)/signup" asChild>
              <Pressable>
                <Text style={styles.linkText}>Create Account</Text>
              </Pressable>
            </Link>
          </View>
        </ScrollView>
      </KeyboardAvoidingView>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#16213e',
  },
  keyboardView: {
    flex: 1,
  },
  scrollContent: {
    flexGrow: 1,
    justifyContent: 'center',
    paddingHorizontal: 24,
    paddingVertical: 32,
  },
  header: {
    alignItems: 'center',
    marginBottom: 48,
  },
  title: {
    fontSize: 32,
    fontWeight: 'bold',
    color: '#e94560',
    marginBottom: 8,
  },
  subtitle: {
    fontSize: 16,
    color: '#a0a0a0',
  },
  form: {
    marginBottom: 32,
  },
  button: {
    marginTop: 8,
  },
  footer: {
    flexDirection: 'row',
    justifyContent: 'center',
    alignItems: 'center',
    gap: 8,
  },
  footerText: {
    color: '#a0a0a0',
    fontSize: 14,
  },
  linkText: {
    color: '#e94560',
    fontSize: 14,
    fontWeight: '600',
  },
});
