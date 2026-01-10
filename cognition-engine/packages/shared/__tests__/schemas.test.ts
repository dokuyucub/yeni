/**
 * Tests for shared schemas.
 */

import { decisionIntakeSchema, decisionOptionSchema } from '../src/schemas/decision';
import { healthResponseSchema } from '../src/schemas/api';

describe('healthResponseSchema', () => {
  it('should validate a valid health response', () => {
    const validResponse = {
      status: 'healthy',
      version: '0.1.0',
      timestamp: '2024-01-01T00:00:00Z',
    };

    const result = healthResponseSchema.safeParse(validResponse);
    expect(result.success).toBe(true);
  });

  it('should reject invalid status', () => {
    const invalidResponse = {
      status: 'invalid_status',
      version: '0.1.0',
      timestamp: '2024-01-01T00:00:00Z',
    };

    const result = healthResponseSchema.safeParse(invalidResponse);
    expect(result.success).toBe(false);
  });
});

describe('decisionIntakeSchema', () => {
  it('should validate a valid decision intake', () => {
    const validIntake = {
      title: 'Should I accept the new job offer?',
      context:
        'I have been offered a new position at a different company with higher salary but requires relocation.',
      desired_outcome: 'Make an informed decision that maximizes long-term career growth',
      constraints: ['Cannot move before June', 'Need to maintain current income level'],
      urgency: 'this_week',
      importance: 'critical',
    };

    const result = decisionIntakeSchema.safeParse(validIntake);
    expect(result.success).toBe(true);
  });

  it('should reject title that is too short', () => {
    const invalidIntake = {
      title: 'Job',
      context:
        'I have been offered a new position at a different company with higher salary but requires relocation.',
      desired_outcome: 'Make an informed decision',
      constraints: [],
      urgency: 'this_week',
      importance: 'critical',
    };

    const result = decisionIntakeSchema.safeParse(invalidIntake);
    expect(result.success).toBe(false);
    if (!result.success) {
      expect(result.error.issues[0].path).toContain('title');
    }
  });

  it('should reject context that is too short', () => {
    const invalidIntake = {
      title: 'Should I accept the job?',
      context: 'Short context',
      desired_outcome: 'Make an informed decision',
      constraints: [],
      urgency: 'this_week',
      importance: 'critical',
    };

    const result = decisionIntakeSchema.safeParse(invalidIntake);
    expect(result.success).toBe(false);
  });

  it('should reject invalid urgency', () => {
    const invalidIntake = {
      title: 'Should I accept the job offer?',
      context:
        'I have been offered a new position at a different company with higher salary but requires relocation.',
      desired_outcome: 'Make an informed decision',
      constraints: [],
      urgency: 'tomorrow',
      importance: 'critical',
    };

    const result = decisionIntakeSchema.safeParse(invalidIntake);
    expect(result.success).toBe(false);
  });
});

describe('decisionOptionSchema', () => {
  it('should validate a valid decision option', () => {
    const validOption = {
      name: 'Accept the offer',
      description: 'Accept the new job offer and relocate to the new city for better opportunities.',
      pros: ['Higher salary', 'Career growth', 'New experiences'],
      cons: ['Relocation stress', 'Distance from family'],
      estimated_cost: 5000,
      estimated_time_days: 30,
      risk_level: 'medium',
    };

    const result = decisionOptionSchema.safeParse(validOption);
    expect(result.success).toBe(true);
  });

  it('should validate option without optional fields', () => {
    const validOption = {
      name: 'Accept the offer',
      description: 'Accept the new job offer and relocate.',
      pros: ['Higher salary'],
      cons: ['Relocation stress'],
      risk_level: 'low',
    };

    const result = decisionOptionSchema.safeParse(validOption);
    expect(result.success).toBe(true);
  });
});
