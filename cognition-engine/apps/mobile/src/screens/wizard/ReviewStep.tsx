/**
 * Step 7: Review & Submit
 *
 * Read-only summary of all decision data.
 */

import { StyleSheet, Text, View } from 'react-native';

import { WIZARD_STEPS, OBJECTIVE_LABELS } from '@cognition-engine/shared';
import { useDraftData } from '@/store/draft-store';
import {
  Button,
  ReviewSection,
  ReviewField,
  ReviewList,
  OptionCardReadOnly,
} from '@/components';

interface ReviewStepProps {
  onBack: () => void;
  onSubmit: () => void;
  goToStep: (stepIndex: number) => void;
}

export function ReviewStep({ onBack, onSubmit, goToStep }: ReviewStepProps) {
  const data = useDraftData();

  if (!data) {
    return (
      <View style={styles.container}>
        <Text style={styles.error}>No data to review</Text>
      </View>
    );
  }

  const activeObjectives = (data.objectives ?? []).filter((o) => o.weight > 0);

  return (
    <View style={styles.container}>
      <Text style={styles.intro}>
        Review your decision before creating it. You can go back to edit any
        section.
      </Text>

      {/* Step 1: Basics */}
      <ReviewSection
        title={WIZARD_STEPS[0].title}
        stepIndex={0}
        onEdit={() => goToStep(0)}
      >
        <ReviewField label="Title" value={data.title} />
        <ReviewField label="Problem Statement" value={data.statement} />
      </ReviewSection>

      {/* Step 2: Options */}
      <ReviewSection
        title={WIZARD_STEPS[1].title}
        stepIndex={1}
        onEdit={() => goToStep(1)}
      >
        {data.options && data.options.length > 0 ? (
          data.options.map((option) => (
            <OptionCardReadOnly key={option.label} option={option} />
          ))
        ) : (
          <Text style={styles.emptyText}>No options defined</Text>
        )}
      </ReviewSection>

      {/* Step 3: Horizons & Objectives */}
      <ReviewSection
        title={WIZARD_STEPS[2].title}
        stepIndex={2}
        onEdit={() => goToStep(2)}
      >
        <ReviewField
          label="Decision Deadline"
          value={data.timeHorizons?.decisionDeadline}
        />
        <ReviewField
          label="Implementation Period"
          value={data.timeHorizons?.implementationPeriod}
        />
        <ReviewField
          label="Impact Horizon"
          value={data.timeHorizons?.impactHorizon}
        />

        <Text style={styles.subheading}>Objective Weights</Text>
        {activeObjectives.length > 0 ? (
          activeObjectives.map((obj) => (
            <View key={obj.key} style={styles.objectiveRow}>
              <Text style={styles.objectiveLabel}>{OBJECTIVE_LABELS[obj.key]}</Text>
              <Text style={styles.objectiveWeight}>{obj.weight}%</Text>
            </View>
          ))
        ) : (
          <Text style={styles.emptyText}>No objectives weighted</Text>
        )}
      </ReviewSection>

      {/* Step 4: Constraints & Resources */}
      <ReviewSection
        title={WIZARD_STEPS[3].title}
        stepIndex={3}
        onEdit={() => goToStep(3)}
      >
        {(data.constraints?.budgetMin || data.constraints?.budgetMax) && (
          <ReviewField
            label="Budget Range"
            value={`$${data.constraints.budgetMin ?? 0} - $${data.constraints.budgetMax ?? '∞'}`}
          />
        )}
        <ReviewField label="Must-haves" value={data.constraints?.mustHaves} />
        <ReviewField label="Can't do" value={data.constraints?.cantDo} />
        <ReviewField label="Available Resources" value={data.resources?.available} />
        <ReviewField label="Needed Resources" value={data.resources?.needed} />
        <ReviewField label="Decision Maker" value={data.stakeholders?.decisionMaker} />
        <ReviewField label="Influencers" value={data.stakeholders?.influencers} />
        <ReviewField label="Affected Parties" value={data.stakeholders?.affected} />
      </ReviewSection>

      {/* Step 5: Risk & Dealbreakers */}
      <ReviewSection
        title={WIZARD_STEPS[4].title}
        stepIndex={4}
        onEdit={() => goToStep(4)}
      >
        <ReviewField
          label="Risk Tolerance"
          value={
            data.risk?.tolerance
              ? data.risk.tolerance.charAt(0).toUpperCase() +
                data.risk.tolerance.slice(1)
              : undefined
          }
        />
        <ReviewField
          label="Maximum Acceptable Loss"
          value={data.risk?.maxAcceptableLoss}
        />
        <ReviewList label="Dealbreakers" items={data.dealbreakers ?? []} />
        <ReviewList
          label="Known Uncertainties"
          items={data.knownUncertainties ?? []}
        />
      </ReviewSection>

      {/* Step 6: Baseline & Success/Failure */}
      <ReviewSection
        title={WIZARD_STEPS[5].title}
        stepIndex={5}
        onEdit={() => goToStep(5)}
      >
        <ReviewField label="Do-Nothing Baseline" value={data.baselineDoNothing} />
        <ReviewField label="Success Definition" value={data.successDefinition} />
        <ReviewField label="Failure Definition" value={data.failureDefinition} />
        {data.gutPreference && (
          <>
            <ReviewField
              label="Gut Feeling"
              value={`${data.gutPreference.optionLabel} (${data.gutPreference.confidence}% confident)`}
            />
            <ReviewField label="Intuition Reason" value={data.gutPreference.reason} />
          </>
        )}
      </ReviewSection>

      <View style={styles.buttonRow}>
        <Button
          title="Back"
          variant="secondary"
          onPress={onBack}
          style={styles.backButton}
        />
        <Button
          title="Create Decision"
          onPress={onSubmit}
          style={styles.submitButton}
        />
      </View>

      <Text style={styles.disclaimer}>
        Creating this decision will save it to your account and enable AI
        analysis features.
      </Text>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
  },
  intro: {
    color: '#c0c0c0',
    fontSize: 14,
    lineHeight: 20,
    marginBottom: 20,
  },
  error: {
    color: '#ef4444',
    fontSize: 16,
    textAlign: 'center',
  },
  emptyText: {
    color: '#4a4a6a',
    fontSize: 14,
    fontStyle: 'italic',
  },
  subheading: {
    color: '#ffffff',
    fontSize: 14,
    fontWeight: '600',
    marginTop: 12,
    marginBottom: 8,
  },
  objectiveRow: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    paddingVertical: 4,
  },
  objectiveLabel: {
    color: '#c0c0c0',
    fontSize: 14,
  },
  objectiveWeight: {
    color: '#e94560',
    fontSize: 14,
    fontWeight: '600',
  },
  buttonRow: {
    flexDirection: 'row',
    gap: 12,
    marginTop: 8,
  },
  backButton: {
    flex: 1,
  },
  submitButton: {
    flex: 2,
  },
  disclaimer: {
    color: '#6a6a8a',
    fontSize: 12,
    textAlign: 'center',
    marginTop: 16,
    lineHeight: 18,
  },
});
