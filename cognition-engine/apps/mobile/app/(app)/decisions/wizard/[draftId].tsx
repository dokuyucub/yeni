/**
 * Decision wizard screen.
 *
 * Multi-step wizard for decision intake.
 */

import { useEffect, useCallback, useRef } from 'react';
import { Alert, BackHandler, ScrollView, StyleSheet, Text } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { router, useLocalSearchParams, Stack } from 'expo-router';

import { WIZARD_STEPS } from '@cognition-engine/shared';
import { useDraftStore, useCurrentDraft, useIsDraftLoading } from '@/store/draft-store';
import { Loading, ProgressHeader } from '@/components';

// Step components
import { BasicsStep } from '@/screens/wizard/BasicsStep';
import { OptionsStep } from '@/screens/wizard/OptionsStep';
import { HorizonsStep } from '@/screens/wizard/HorizonsStep';
import { ConstraintsStep } from '@/screens/wizard/ConstraintsStep';
import { RiskStep } from '@/screens/wizard/RiskStep';
import { BaselineStep } from '@/screens/wizard/BaselineStep';
import { ReviewStep } from '@/screens/wizard/ReviewStep';

export default function WizardScreen() {
  const { draftId } = useLocalSearchParams<{ draftId: string }>();
  const draft = useCurrentDraft();
  const isLoading = useIsDraftLoading();
  const loadDraft = useDraftStore((s) => s.loadDraft);
  const saveDraft = useDraftStore((s) => s.saveDraft);
  const setCurrentStep = useDraftStore((s) => s.setCurrentStep);
  const clearCurrentDraft = useDraftStore((s) => s.clearCurrentDraft);

  const scrollRef = useRef<ScrollView>(null);

  // Load draft on mount if not already loaded
  useEffect(() => {
    if (draftId && (!draft || draft.id !== draftId)) {
      loadDraft(draftId);
    }
  }, [draftId, draft, loadDraft]);

  // Auto-save on step change
  const currentStep = draft?.currentStepIndex ?? 0;

  // Handle back button
  useEffect(() => {
    const onBackPress = () => {
      handleBack();
      return true;
    };

    const subscription = BackHandler.addEventListener('hardwareBackPress', onBackPress);
    return () => subscription.remove();
  }, [currentStep]);

  const handleBack = useCallback(() => {
    if (currentStep > 0) {
      setCurrentStep(currentStep - 1);
      scrollRef.current?.scrollTo({ y: 0, animated: true });
    } else {
      // Confirm exit on first step
      Alert.alert(
        'Save Draft?',
        'Your progress will be saved and you can continue later.',
        [
          { text: 'Cancel', style: 'cancel' },
          {
            text: 'Save & Exit',
            onPress: async () => {
              await saveDraft();
              clearCurrentDraft();
              router.back();
            },
          },
        ]
      );
    }
  }, [currentStep, setCurrentStep, saveDraft, clearCurrentDraft]);

  const handleNext = useCallback(() => {
    if (currentStep < WIZARD_STEPS.length - 1) {
      setCurrentStep(currentStep + 1);
      scrollRef.current?.scrollTo({ y: 0, animated: true });
    }
  }, [currentStep, setCurrentStep]);

  const goToStep = useCallback(
    (stepIndex: number) => {
      if (stepIndex >= 0 && stepIndex < WIZARD_STEPS.length) {
        setCurrentStep(stepIndex);
        scrollRef.current?.scrollTo({ y: 0, animated: true });
      }
    },
    [setCurrentStep]
  );

  const handleSubmit = useCallback(async () => {
    Alert.alert(
      'Create Decision',
      'Ready to create this decision? You can still edit it afterwards.',
      [
        { text: 'Cancel', style: 'cancel' },
        {
          text: 'Create',
          onPress: async () => {
            // TODO: Call API to submit decision
            Alert.alert(
              'Coming Soon',
              'Decision submission will be available in the next update.',
              [
                {
                  text: 'OK',
                  onPress: () => {
                    clearCurrentDraft();
                    router.replace('/(app)/decisions');
                  },
                },
              ]
            );
          },
        },
      ]
    );
  }, [clearCurrentDraft]);

  if (isLoading || !draft) {
    return <Loading />;
  }

  const stepInfo = WIZARD_STEPS[currentStep];

  const renderStep = () => {
    switch (currentStep) {
      case 0:
        return <BasicsStep onNext={handleNext} />;
      case 1:
        return <OptionsStep onNext={handleNext} onBack={handleBack} />;
      case 2:
        return <HorizonsStep onNext={handleNext} onBack={handleBack} />;
      case 3:
        return <ConstraintsStep onNext={handleNext} onBack={handleBack} />;
      case 4:
        return <RiskStep onNext={handleNext} onBack={handleBack} />;
      case 5:
        return <BaselineStep onNext={handleNext} onBack={handleBack} />;
      case 6:
        return <ReviewStep onBack={handleBack} onSubmit={handleSubmit} goToStep={goToStep} />;
      default:
        return null;
    }
  };

  return (
    <>
      <Stack.Screen
        options={{
          title: stepInfo?.title ?? 'Decision Wizard',
          headerShown: false,
        }}
      />
      <SafeAreaView style={styles.container} edges={['top']}>
        <ProgressHeader
          currentStep={currentStep}
          onBack={handleBack}
        />
        <ScrollView
          ref={scrollRef}
          style={styles.scrollView}
          contentContainerStyle={styles.scrollContent}
          keyboardShouldPersistTaps="handled"
          showsVerticalScrollIndicator={false}
        >
          <Text style={styles.stepDescription}>{stepInfo?.description}</Text>
          {renderStep()}
        </ScrollView>
      </SafeAreaView>
    </>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#16213e',
  },
  scrollView: {
    flex: 1,
  },
  scrollContent: {
    paddingHorizontal: 20,
    paddingTop: 8,
    paddingBottom: 40,
  },
  stepDescription: {
    color: '#808080',
    fontSize: 14,
    lineHeight: 20,
    marginBottom: 24,
  },
});
