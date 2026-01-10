-- Cognition Engine Seed Data
-- File: seed.sql
-- Description: Optional seed data for local development
--
-- NOTE: Since RLS is enabled, this seed file uses the service role context
-- which bypasses RLS. In production, data is created through the API
-- with proper user authentication.
--
-- To run this seed manually with service role:
--   psql -h localhost -p 54322 -U postgres -d postgres -f seed.sql
-- Or through Supabase CLI:
--   supabase db reset (applies migrations + seed)

-- ============================================================================
-- SEED: Create a test user (only works in local dev)
-- ============================================================================

-- First, we need a test user in auth.users
-- This is done through Supabase Auth, not direct SQL in production
-- For local development, you can create a user via:
--   1. Supabase Studio UI (http://localhost:54323)
--   2. API call to /auth/v1/signup
--   3. Direct SQL below (local dev only)

-- Create test user if not exists (LOCAL DEV ONLY)
-- The password below is 'testpassword123' hashed
DO $$
DECLARE
    test_user_id UUID;
    test_decision_id UUID;
    test_option_1_id UUID;
    test_option_2_id UUID;
BEGIN
    -- Check if test user already exists
    SELECT id INTO test_user_id
    FROM auth.users
    WHERE email = 'test@cognitionengine.local';

    -- If no test user, create one
    IF test_user_id IS NULL THEN
        INSERT INTO auth.users (
            id,
            instance_id,
            email,
            encrypted_password,
            email_confirmed_at,
            raw_app_meta_data,
            raw_user_meta_data,
            created_at,
            updated_at,
            role,
            aud,
            confirmation_token
        ) VALUES (
            gen_random_uuid(),
            '00000000-0000-0000-0000-000000000000',
            'test@cognitionengine.local',
            crypt('testpassword123', gen_salt('bf')),
            NOW(),
            '{"provider":"email","providers":["email"]}',
            '{"name":"Test User"}',
            NOW(),
            NOW(),
            'authenticated',
            'authenticated',
            ''
        )
        RETURNING id INTO test_user_id;

        RAISE NOTICE 'Created test user with ID: %', test_user_id;
    ELSE
        RAISE NOTICE 'Test user already exists with ID: %', test_user_id;
    END IF;

    -- Check if sample decision already exists
    IF NOT EXISTS (
        SELECT 1 FROM decisions
        WHERE user_id = test_user_id
        AND title = 'Sample: Should I switch careers to AI/ML?'
    ) THEN
        -- Create a sample decision
        INSERT INTO decisions (
            id,
            user_id,
            title,
            statement,
            context,
            desired_outcome,
            urgency,
            importance,
            status,
            stakeholders,
            constraints
        ) VALUES (
            gen_random_uuid(),
            test_user_id,
            'Sample: Should I switch careers to AI/ML?',
            'I am considering whether to transition from my current software engineering role to a specialized AI/ML position. This would require significant upskilling and potentially a temporary pay cut.',
            'I have 5 years of experience as a backend developer. The AI/ML field is growing rapidly but is also becoming more competitive. I have some basic ML knowledge from online courses.',
            'Make a well-informed decision that optimizes for long-term career growth and financial stability while maintaining work-life balance.',
            'this_month',
            'high',
            'draft',
            '["Family", "Current employer", "Future self"]',
            '["Cannot take more than 20% pay cut", "Need to maintain health insurance", "Maximum 6-month transition period"]'
        )
        RETURNING id INTO test_decision_id;

        -- Create sample options
        INSERT INTO options (
            id,
            decision_id,
            label,
            description,
            pros,
            cons,
            risk_level,
            reversibility_score,
            optionality_score,
            complexity_score,
            time_to_first_results_days
        ) VALUES (
            gen_random_uuid(),
            test_decision_id,
            'O1',
            'Full transition: Leave current job and pursue AI/ML bootcamp or masters degree',
            '["Complete focus on learning", "Faster skill acquisition", "Clean break from current role", "Networking opportunities in new field"]',
            '["Financial risk during transition", "Loss of current income", "No guarantee of job placement", "Opportunity cost of time"]',
            'high',
            3,
            4,
            8,
            180
        )
        RETURNING id INTO test_option_1_id;

        INSERT INTO options (
            id,
            decision_id,
            label,
            description,
            pros,
            cons,
            risk_level,
            reversibility_score,
            optionality_score,
            complexity_score,
            time_to_first_results_days
        ) VALUES (
            gen_random_uuid(),
            test_decision_id,
            'O2',
            'Gradual transition: Stay employed while upskilling through part-time learning and internal ML projects',
            '["Maintains income stability", "Lower financial risk", "Can test interest before committing", "Potential internal transfer opportunities"]',
            '["Slower progress", "Burnout risk from double workload", "May take 2-3 years", "Less immersive learning experience"]',
            'medium',
            8,
            7,
            6,
            365
        )
        RETURNING id INTO test_option_2_id;

        -- Create sample criteria
        INSERT INTO criteria (decision_id, name, description, weight) VALUES
            (test_decision_id, 'Financial Impact', 'Short and long-term financial implications', 30),
            (test_decision_id, 'Career Growth Potential', 'Long-term career trajectory and opportunities', 25),
            (test_decision_id, 'Work-Life Balance', 'Impact on personal time and relationships', 20),
            (test_decision_id, 'Risk Level', 'Probability and magnitude of negative outcomes', 15),
            (test_decision_id, 'Learning Effectiveness', 'Quality and depth of skill acquisition', 10);

        -- Create sample assumptions
        INSERT INTO assumptions (decision_id, assumption, default_value, confidence, why_it_matters, validation_method, status, impact_if_wrong) VALUES
            (test_decision_id, 'AI/ML job market will remain strong for the next 5 years', 'true', 0.75, 'Core premise of the career switch value', 'Industry reports and job market data', 'unvalidated', 'high'),
            (test_decision_id, 'I can complete sufficient upskilling within 12 months', 'true', 0.60, 'Affects timeline and financial planning', 'Talk to people who made similar transitions', 'unvalidated', 'medium'),
            (test_decision_id, 'My current employer would support internal transition', 'uncertain', 0.40, 'Could enable low-risk gradual transition', 'Direct conversation with manager/HR', 'unvalidated', 'medium');

        RAISE NOTICE 'Created sample decision with ID: %', test_decision_id;
        RAISE NOTICE 'Created 2 options, 5 criteria, and 3 assumptions';
    ELSE
        RAISE NOTICE 'Sample decision already exists, skipping seed';
    END IF;
END $$;

-- ============================================================================
-- VERIFICATION QUERIES (run these to verify seed worked)
-- ============================================================================

-- Uncomment to verify:
-- SELECT id, email FROM auth.users WHERE email = 'test@cognitionengine.local';
-- SELECT id, title, status FROM decisions;
-- SELECT id, label, description FROM options;
-- SELECT id, name, weight FROM criteria;
-- SELECT id, assumption, confidence FROM assumptions;
