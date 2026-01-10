/**
 * Signup screen.
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

import { signupSchema, type SignupFormData } from '@cognition-engine/shared';
import { Button, Input, ErrorBanner } from '@/components';
import { useAuthStore } from '@/store/auth-store';

export default function SignupScreen() {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [confirmPassword, setConfirmPassword] = useState('');
  const [errors, setErrors] = useState<Partial<SignupFormData>>({});
  const [showConfirmation, setShowConfirmation] = useState(false);

  const { signUp, isLoading, error, clearError } = useAuthStore();

  const validate = (): boolean => {
    const result = signupSchema.safeParse({ email, password, confirmPassword });

    if (!result.success) {
      const fieldErrors: Partial<SignupFormData> = {};
      result.error.errors.forEach((err) => {
        const field = err.path[0] as keyof SignupFormData;
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

  const handleSignup = async () => {
    if (!validate()) return;

    clearError();
    const result = await signUp(email, password);

    if (result.success) {
      if (result.needsConfirmation) {
        setShowConfirmation(true);
      } else {
        router.replace('/(app)');
      }
    }
  };

  if (showConfirmation) {
    return (
      <SafeAreaView style={styles.container}>
        <View style={styles.confirmationContainer}>
          <View style={styles.iconContainer}>
            <Text style={styles.icon}>✓</Text>
          </View>
          <Text style={styles.confirmationTitle}>Check Your Email</Text>
          <Text style={styles.confirmationText}>
            We've sent a confirmation link to{'\n'}
            <Text style={styles.emailText}>{email}</Text>
          </Text>
          <Text style={styles.confirmationHint}>
            Click the link in your email to verify your account, then come back
            to sign in.
          </Text>
          <Link href="/(auth)/login" asChild>
            <Pressable style={styles.backButton}>
              <Text style={styles.backButtonText}>Back to Sign In</Text>
            </Pressable>
          </Link>
        </View>
      </SafeAreaView>
    );
  }

  return (
    <SafeAreaView style={styles.container} edges={['bottom']}>
      <KeyboardAvoidingView
        behavior={Platform.OS === 'ios' ? 'padding' : 'height'}
        style={styles.keyboardView}
      >
        <ScrollView
          contentContainerStyle={styles.scrollContent}
          keyboardShouldPersistTaps="handled"
        >
          <View style={styles.header}>
            <Text style={styles.title}>Create Account</Text>
            <Text style={styles.subtitle}>
              Join Cognition Engine to make better decisions
            </Text>
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
              placeholder="Create a password"
              value={password}
              onChangeText={setPassword}
              secureTextEntry
              showPasswordToggle
              autoComplete="new-password"
              error={errors.password}
              hint="At least 8 characters"
            />

            <Input
              label="Confirm Password"
              placeholder="Confirm your password"
              value={confirmPassword}
              onChangeText={setConfirmPassword}
              secureTextEntry
              showPasswordToggle
              autoComplete="new-password"
              error={errors.confirmPassword}
            />

            <Button
              title="Create Account"
              onPress={handleSignup}
              loading={isLoading}
              disabled={isLoading}
              fullWidth
              size="large"
              style={styles.button}
            />
          </View>

          <View style={styles.footer}>
            <Text style={styles.footerText}>Already have an account?</Text>
            <Link href="/(auth)/login" asChild>
              <Pressable>
                <Text style={styles.linkText}>Sign In</Text>
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
    marginBottom: 32,
  },
  title: {
    fontSize: 28,
    fontWeight: 'bold',
    color: '#ffffff',
    marginBottom: 8,
  },
  subtitle: {
    fontSize: 14,
    color: '#a0a0a0',
    textAlign: 'center',
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
  // Confirmation screen styles
  confirmationContainer: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    paddingHorizontal: 24,
  },
  iconContainer: {
    width: 64,
    height: 64,
    borderRadius: 32,
    backgroundColor: 'rgba(74, 222, 128, 0.2)',
    alignItems: 'center',
    justifyContent: 'center',
    marginBottom: 24,
  },
  icon: {
    color: '#4ade80',
    fontSize: 32,
    fontWeight: 'bold',
  },
  confirmationTitle: {
    fontSize: 24,
    fontWeight: 'bold',
    color: '#ffffff',
    marginBottom: 16,
  },
  confirmationText: {
    fontSize: 16,
    color: '#a0a0a0',
    textAlign: 'center',
    marginBottom: 8,
  },
  emailText: {
    color: '#e94560',
    fontWeight: '600',
  },
  confirmationHint: {
    fontSize: 14,
    color: '#6a6a8a',
    textAlign: 'center',
    marginBottom: 32,
    paddingHorizontal: 16,
  },
  backButton: {
    paddingVertical: 12,
    paddingHorizontal: 24,
  },
  backButtonText: {
    color: '#e94560',
    fontSize: 16,
    fontWeight: '600',
  },
});
