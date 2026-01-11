-- Cognition Engine Decision Intake JSON Storage
-- Migration: 20240101000003_intake_json.sql
-- Description: Add intake_json column for storing full wizard intake data

-- ============================================================================
-- ADD intake_json COLUMN TO decisions TABLE
-- ============================================================================

-- Add intake_json column to store the full decision intake payload
ALTER TABLE public.decisions
    ADD COLUMN IF NOT EXISTS intake_json JSONB NOT NULL DEFAULT '{}'::jsonb;

-- ============================================================================
-- RELAX CONSTRAINTS FOR WIZARD DRAFTS
-- ============================================================================

-- The original schema had strict constraints that don't work well with
-- incremental wizard saves. We need to relax title and statement constraints.

-- Drop existing constraints
ALTER TABLE public.decisions
    DROP CONSTRAINT IF EXISTS decisions_title_check;
ALTER TABLE public.decisions
    DROP CONSTRAINT IF EXISTS decisions_statement_check;

-- Add more lenient constraints that allow drafts
ALTER TABLE public.decisions
    ADD CONSTRAINT decisions_title_check
    CHECK (char_length(title) >= 1 AND char_length(title) <= 500);
ALTER TABLE public.decisions
    ADD CONSTRAINT decisions_statement_check
    CHECK (char_length(statement) >= 1 OR status = 'draft');

-- ============================================================================
-- INDEXES
-- ============================================================================

-- Index for user + updated_at for efficient list queries
CREATE INDEX IF NOT EXISTS idx_decisions_user_updated
    ON public.decisions(user_id, updated_at DESC);

-- GIN index on intake_json for efficient JSON queries
CREATE INDEX IF NOT EXISTS idx_decisions_intake_json
    ON public.decisions USING GIN (intake_json);

-- ============================================================================
-- COMMENTS
-- ============================================================================

COMMENT ON COLUMN public.decisions.intake_json IS 'Full decision intake payload from wizard (JSONB)';
