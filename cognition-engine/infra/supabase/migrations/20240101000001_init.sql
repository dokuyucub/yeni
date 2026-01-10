-- Cognition Engine Database Schema
-- Migration: 20240101000001_init.sql
-- Description: Initial schema with all core tables, triggers, and indexes

-- ============================================================================
-- EXTENSIONS
-- ============================================================================

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================================================
-- HELPER FUNCTIONS
-- ============================================================================

-- Function to automatically update updated_at timestamp
CREATE OR REPLACE FUNCTION trigger_set_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- ============================================================================
-- TABLE: decisions
-- Core decision entity owned by a user
-- ============================================================================

CREATE TABLE decisions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    title TEXT NOT NULL CHECK (char_length(title) >= 5 AND char_length(title) <= 200),
    statement TEXT NOT NULL CHECK (char_length(statement) >= 20),
    context TEXT NOT NULL DEFAULT '',
    desired_outcome TEXT NOT NULL DEFAULT '',
    urgency TEXT NOT NULL DEFAULT 'flexible' CHECK (urgency IN ('immediate', 'this_week', 'this_month', 'flexible')),
    importance TEXT NOT NULL DEFAULT 'medium' CHECK (importance IN ('critical', 'high', 'medium', 'low')),
    status TEXT NOT NULL DEFAULT 'draft' CHECK (status IN ('draft', 'active', 'executed', 'archived')),
    stakeholders JSONB NOT NULL DEFAULT '[]'::jsonb,
    constraints JSONB NOT NULL DEFAULT '[]'::jsonb,
    metadata JSONB NOT NULL DEFAULT '{}'::jsonb,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Indexes for decisions
CREATE INDEX idx_decisions_user_id ON decisions(user_id);
CREATE INDEX idx_decisions_status ON decisions(status);
CREATE INDEX idx_decisions_user_status ON decisions(user_id, status);
CREATE INDEX idx_decisions_created_at ON decisions(created_at DESC);

-- Trigger for updated_at
CREATE TRIGGER set_decisions_updated_at
    BEFORE UPDATE ON decisions
    FOR EACH ROW
    EXECUTE FUNCTION trigger_set_updated_at();

-- ============================================================================
-- TABLE: options
-- Decision alternatives/choices
-- ============================================================================

CREATE TABLE options (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    decision_id UUID NOT NULL REFERENCES decisions(id) ON DELETE CASCADE,
    label TEXT NOT NULL CHECK (char_length(label) >= 1 AND char_length(label) <= 50),
    description TEXT NOT NULL CHECK (char_length(description) >= 10),
    actions_json JSONB NOT NULL DEFAULT '[]'::jsonb,
    dependencies_json JSONB NOT NULL DEFAULT '[]'::jsonb,
    costs_json JSONB NOT NULL DEFAULT '{}'::jsonb,
    time_to_first_results_days INTEGER NOT NULL DEFAULT 0 CHECK (time_to_first_results_days >= 0),
    reversibility_score INTEGER NOT NULL DEFAULT 5 CHECK (reversibility_score >= 0 AND reversibility_score <= 10),
    optionality_score INTEGER NOT NULL DEFAULT 5 CHECK (optionality_score >= 0 AND optionality_score <= 10),
    complexity_score INTEGER NOT NULL DEFAULT 5 CHECK (complexity_score >= 0 AND complexity_score <= 10),
    hidden_costs_json JSONB NOT NULL DEFAULT '[]'::jsonb,
    pros JSONB NOT NULL DEFAULT '[]'::jsonb,
    cons JSONB NOT NULL DEFAULT '[]'::jsonb,
    risk_level TEXT NOT NULL DEFAULT 'medium' CHECK (risk_level IN ('low', 'medium', 'high')),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Indexes for options
CREATE INDEX idx_options_decision_id ON options(decision_id);

-- Trigger for updated_at
CREATE TRIGGER set_options_updated_at
    BEFORE UPDATE ON options
    FOR EACH ROW
    EXECUTE FUNCTION trigger_set_updated_at();

-- ============================================================================
-- TABLE: criteria
-- Evaluation criteria for comparing options
-- ============================================================================

CREATE TABLE criteria (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    decision_id UUID NOT NULL REFERENCES decisions(id) ON DELETE CASCADE,
    name TEXT NOT NULL CHECK (char_length(name) >= 2 AND char_length(name) <= 100),
    description TEXT NOT NULL DEFAULT '',
    weight INTEGER NOT NULL DEFAULT 50 CHECK (weight >= 0 AND weight <= 100),
    rubric_json JSONB NOT NULL DEFAULT '{}'::jsonb,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Indexes for criteria
CREATE INDEX idx_criteria_decision_id ON criteria(decision_id);

-- Trigger for updated_at
CREATE TRIGGER set_criteria_updated_at
    BEFORE UPDATE ON criteria
    FOR EACH ROW
    EXECUTE FUNCTION trigger_set_updated_at();

-- ============================================================================
-- TABLE: assumptions
-- Key assumptions that affect decision modeling
-- ============================================================================

CREATE TABLE assumptions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    decision_id UUID NOT NULL REFERENCES decisions(id) ON DELETE CASCADE,
    assumption TEXT NOT NULL CHECK (char_length(assumption) >= 10),
    default_value TEXT NOT NULL DEFAULT '',
    confidence NUMERIC(3,2) NOT NULL DEFAULT 0.50 CHECK (confidence >= 0 AND confidence <= 1),
    why_it_matters TEXT NOT NULL DEFAULT '',
    validation_method TEXT NOT NULL DEFAULT '',
    status TEXT NOT NULL DEFAULT 'unvalidated' CHECK (status IN ('unvalidated', 'validated', 'invalidated')),
    impact_if_wrong TEXT NOT NULL DEFAULT 'medium' CHECK (impact_if_wrong IN ('low', 'medium', 'high')),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Indexes for assumptions
CREATE INDEX idx_assumptions_decision_id ON assumptions(decision_id);
CREATE INDEX idx_assumptions_status ON assumptions(status);

-- Trigger for updated_at
CREATE TRIGGER set_assumptions_updated_at
    BEFORE UPDATE ON assumptions
    FOR EACH ROW
    EXECUTE FUNCTION trigger_set_updated_at();

-- ============================================================================
-- TABLE: decision_graphs
-- Versioned decision tree/graph structures
-- ============================================================================

CREATE TABLE decision_graphs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    decision_id UUID NOT NULL REFERENCES decisions(id) ON DELETE CASCADE,
    version INTEGER NOT NULL DEFAULT 1 CHECK (version >= 1),
    graph_json JSONB NOT NULL DEFAULT '{
        "nodes": [],
        "edges": [],
        "metadata": {}
    }'::jsonb,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE(decision_id, version)
);

-- Indexes for decision_graphs
CREATE INDEX idx_decision_graphs_decision_id ON decision_graphs(decision_id);
CREATE INDEX idx_decision_graphs_decision_version ON decision_graphs(decision_id, version DESC);

-- ============================================================================
-- TABLE: simulations
-- Monte Carlo and scenario simulation results
-- ============================================================================

CREATE TABLE simulations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    decision_id UUID NOT NULL REFERENCES decisions(id) ON DELETE CASCADE,
    option_id UUID NOT NULL REFERENCES options(id) ON DELETE CASCADE,
    scenario TEXT NOT NULL CHECK (scenario IN ('bear', 'base', 'bull')),
    priors_json JSONB NOT NULL DEFAULT '{}'::jsonb,
    outcomes_json JSONB NOT NULL DEFAULT '{
        "expected_value": 0,
        "variance": 0,
        "confidence_interval": {"low": 0, "high": 0},
        "ruin_risk": 0
    }'::jsonb,
    events_sequence_json JSONB NOT NULL DEFAULT '[]'::jsonb,
    monte_carlo_iterations INTEGER NOT NULL DEFAULT 1000,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Indexes for simulations
CREATE INDEX idx_simulations_decision_id ON simulations(decision_id);
CREATE INDEX idx_simulations_option_id ON simulations(option_id);
CREATE INDEX idx_simulations_scenario ON simulations(scenario);
CREATE INDEX idx_simulations_decision_option ON simulations(decision_id, option_id);

-- ============================================================================
-- TABLE: recommendations
-- AI-generated versioned recommendations
-- ============================================================================

CREATE TABLE recommendations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    decision_id UUID NOT NULL REFERENCES decisions(id) ON DELETE CASCADE,
    version INTEGER NOT NULL DEFAULT 1 CHECK (version >= 1),
    ranking_json JSONB NOT NULL DEFAULT '[]'::jsonb,
    kill_switches_json JSONB NOT NULL DEFAULT '[]'::jsonb,
    next_7_days_plan_json JSONB NOT NULL DEFAULT '[]'::jsonb,
    instrumentation_json JSONB NOT NULL DEFAULT '[]'::jsonb,
    premortem_json JSONB NOT NULL DEFAULT '[]'::jsonb,
    narrative_text TEXT NOT NULL DEFAULT '',
    confidence NUMERIC(3,2) NOT NULL DEFAULT 0.50 CHECK (confidence >= 0 AND confidence <= 1),
    risks JSONB NOT NULL DEFAULT '[]'::jsonb,
    mitigations JSONB NOT NULL DEFAULT '[]'::jsonb,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE(decision_id, version)
);

-- Indexes for recommendations
CREATE INDEX idx_recommendations_decision_id ON recommendations(decision_id);
CREATE INDEX idx_recommendations_decision_version ON recommendations(decision_id, version DESC);

-- ============================================================================
-- TABLE: checkins
-- Post-decision tracking and learning
-- ============================================================================

CREATE TABLE checkins (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    decision_id UUID NOT NULL REFERENCES decisions(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    checkin_date DATE NOT NULL DEFAULT CURRENT_DATE,
    actual_outcomes_json JSONB NOT NULL DEFAULT '{}'::jsonb,
    notes TEXT NOT NULL DEFAULT '',
    satisfaction_score INTEGER CHECK (satisfaction_score IS NULL OR (satisfaction_score >= 0 AND satisfaction_score <= 10)),
    variance_from_expected TEXT NOT NULL DEFAULT '',
    lessons_learned JSONB NOT NULL DEFAULT '[]'::jsonb,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE(decision_id, user_id, checkin_date)
);

-- Indexes for checkins
CREATE INDEX idx_checkins_decision_id ON checkins(decision_id);
CREATE INDEX idx_checkins_user_id ON checkins(user_id);
CREATE INDEX idx_checkins_date ON checkins(checkin_date DESC);
CREATE INDEX idx_checkins_decision_user ON checkins(decision_id, user_id);

-- ============================================================================
-- COMMENTS FOR DOCUMENTATION
-- ============================================================================

COMMENT ON TABLE decisions IS 'Core decision entities owned by users';
COMMENT ON TABLE options IS 'Decision alternatives/choices linked to a decision';
COMMENT ON TABLE criteria IS 'Evaluation criteria for comparing options';
COMMENT ON TABLE assumptions IS 'Key assumptions affecting decision modeling';
COMMENT ON TABLE decision_graphs IS 'Versioned decision tree structures';
COMMENT ON TABLE simulations IS 'Monte Carlo and scenario simulation results';
COMMENT ON TABLE recommendations IS 'AI-generated versioned recommendations';
COMMENT ON TABLE checkins IS 'Post-decision tracking and learning entries';

COMMENT ON COLUMN decisions.urgency IS 'immediate | this_week | this_month | flexible';
COMMENT ON COLUMN decisions.importance IS 'critical | high | medium | low';
COMMENT ON COLUMN decisions.status IS 'draft | active | executed | archived';
COMMENT ON COLUMN options.reversibility_score IS 'Scale 0-10, higher = more reversible';
COMMENT ON COLUMN options.optionality_score IS 'Scale 0-10, higher = more future options preserved';
COMMENT ON COLUMN options.complexity_score IS 'Scale 0-10, higher = more complex to execute';
COMMENT ON COLUMN assumptions.confidence IS 'Confidence level 0.00-1.00';
COMMENT ON COLUMN assumptions.status IS 'unvalidated | validated | invalidated';
COMMENT ON COLUMN simulations.scenario IS 'bear (pessimistic) | base (expected) | bull (optimistic)';
