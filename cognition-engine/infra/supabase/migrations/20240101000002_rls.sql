-- Cognition Engine Row Level Security Policies
-- Migration: 20240101000002_rls.sql
-- Description: Enable RLS and create policies for all tables

-- ============================================================================
-- ENABLE RLS ON ALL TABLES
-- ============================================================================

ALTER TABLE decisions ENABLE ROW LEVEL SECURITY;
ALTER TABLE options ENABLE ROW LEVEL SECURITY;
ALTER TABLE criteria ENABLE ROW LEVEL SECURITY;
ALTER TABLE assumptions ENABLE ROW LEVEL SECURITY;
ALTER TABLE decision_graphs ENABLE ROW LEVEL SECURITY;
ALTER TABLE simulations ENABLE ROW LEVEL SECURITY;
ALTER TABLE recommendations ENABLE ROW LEVEL SECURITY;
ALTER TABLE checkins ENABLE ROW LEVEL SECURITY;

-- ============================================================================
-- HELPER FUNCTION: Check if user owns a decision
-- ============================================================================

CREATE OR REPLACE FUNCTION auth.user_owns_decision(decision_uuid UUID)
RETURNS BOOLEAN AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1 FROM decisions
        WHERE id = decision_uuid
        AND user_id = auth.uid()
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER STABLE;

-- ============================================================================
-- POLICIES: decisions
-- User can only access their own decisions
-- ============================================================================

-- SELECT: Users can view their own decisions
CREATE POLICY "Users can view own decisions"
    ON decisions FOR SELECT
    TO authenticated
    USING (user_id = auth.uid());

-- INSERT: Users can create decisions for themselves
CREATE POLICY "Users can create own decisions"
    ON decisions FOR INSERT
    TO authenticated
    WITH CHECK (user_id = auth.uid());

-- UPDATE: Users can update their own decisions
CREATE POLICY "Users can update own decisions"
    ON decisions FOR UPDATE
    TO authenticated
    USING (user_id = auth.uid())
    WITH CHECK (user_id = auth.uid());

-- DELETE: Users can delete their own decisions
CREATE POLICY "Users can delete own decisions"
    ON decisions FOR DELETE
    TO authenticated
    USING (user_id = auth.uid());

-- ============================================================================
-- POLICIES: options
-- User can access options belonging to their own decisions
-- ============================================================================

-- SELECT: Users can view options of their own decisions
CREATE POLICY "Users can view options of own decisions"
    ON options FOR SELECT
    TO authenticated
    USING (
        EXISTS (
            SELECT 1 FROM decisions
            WHERE decisions.id = options.decision_id
            AND decisions.user_id = auth.uid()
        )
    );

-- INSERT: Users can create options for their own decisions
CREATE POLICY "Users can create options for own decisions"
    ON options FOR INSERT
    TO authenticated
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM decisions
            WHERE decisions.id = options.decision_id
            AND decisions.user_id = auth.uid()
        )
    );

-- UPDATE: Users can update options of their own decisions
CREATE POLICY "Users can update options of own decisions"
    ON options FOR UPDATE
    TO authenticated
    USING (
        EXISTS (
            SELECT 1 FROM decisions
            WHERE decisions.id = options.decision_id
            AND decisions.user_id = auth.uid()
        )
    )
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM decisions
            WHERE decisions.id = options.decision_id
            AND decisions.user_id = auth.uid()
        )
    );

-- DELETE: Users can delete options of their own decisions
CREATE POLICY "Users can delete options of own decisions"
    ON options FOR DELETE
    TO authenticated
    USING (
        EXISTS (
            SELECT 1 FROM decisions
            WHERE decisions.id = options.decision_id
            AND decisions.user_id = auth.uid()
        )
    );

-- ============================================================================
-- POLICIES: criteria
-- User can access criteria belonging to their own decisions
-- ============================================================================

-- SELECT
CREATE POLICY "Users can view criteria of own decisions"
    ON criteria FOR SELECT
    TO authenticated
    USING (
        EXISTS (
            SELECT 1 FROM decisions
            WHERE decisions.id = criteria.decision_id
            AND decisions.user_id = auth.uid()
        )
    );

-- INSERT
CREATE POLICY "Users can create criteria for own decisions"
    ON criteria FOR INSERT
    TO authenticated
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM decisions
            WHERE decisions.id = criteria.decision_id
            AND decisions.user_id = auth.uid()
        )
    );

-- UPDATE
CREATE POLICY "Users can update criteria of own decisions"
    ON criteria FOR UPDATE
    TO authenticated
    USING (
        EXISTS (
            SELECT 1 FROM decisions
            WHERE decisions.id = criteria.decision_id
            AND decisions.user_id = auth.uid()
        )
    )
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM decisions
            WHERE decisions.id = criteria.decision_id
            AND decisions.user_id = auth.uid()
        )
    );

-- DELETE
CREATE POLICY "Users can delete criteria of own decisions"
    ON criteria FOR DELETE
    TO authenticated
    USING (
        EXISTS (
            SELECT 1 FROM decisions
            WHERE decisions.id = criteria.decision_id
            AND decisions.user_id = auth.uid()
        )
    );

-- ============================================================================
-- POLICIES: assumptions
-- User can access assumptions belonging to their own decisions
-- ============================================================================

-- SELECT
CREATE POLICY "Users can view assumptions of own decisions"
    ON assumptions FOR SELECT
    TO authenticated
    USING (
        EXISTS (
            SELECT 1 FROM decisions
            WHERE decisions.id = assumptions.decision_id
            AND decisions.user_id = auth.uid()
        )
    );

-- INSERT
CREATE POLICY "Users can create assumptions for own decisions"
    ON assumptions FOR INSERT
    TO authenticated
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM decisions
            WHERE decisions.id = assumptions.decision_id
            AND decisions.user_id = auth.uid()
        )
    );

-- UPDATE
CREATE POLICY "Users can update assumptions of own decisions"
    ON assumptions FOR UPDATE
    TO authenticated
    USING (
        EXISTS (
            SELECT 1 FROM decisions
            WHERE decisions.id = assumptions.decision_id
            AND decisions.user_id = auth.uid()
        )
    )
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM decisions
            WHERE decisions.id = assumptions.decision_id
            AND decisions.user_id = auth.uid()
        )
    );

-- DELETE
CREATE POLICY "Users can delete assumptions of own decisions"
    ON assumptions FOR DELETE
    TO authenticated
    USING (
        EXISTS (
            SELECT 1 FROM decisions
            WHERE decisions.id = assumptions.decision_id
            AND decisions.user_id = auth.uid()
        )
    );

-- ============================================================================
-- POLICIES: decision_graphs
-- User can access graphs belonging to their own decisions
-- ============================================================================

-- SELECT
CREATE POLICY "Users can view graphs of own decisions"
    ON decision_graphs FOR SELECT
    TO authenticated
    USING (
        EXISTS (
            SELECT 1 FROM decisions
            WHERE decisions.id = decision_graphs.decision_id
            AND decisions.user_id = auth.uid()
        )
    );

-- INSERT
CREATE POLICY "Users can create graphs for own decisions"
    ON decision_graphs FOR INSERT
    TO authenticated
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM decisions
            WHERE decisions.id = decision_graphs.decision_id
            AND decisions.user_id = auth.uid()
        )
    );

-- UPDATE
CREATE POLICY "Users can update graphs of own decisions"
    ON decision_graphs FOR UPDATE
    TO authenticated
    USING (
        EXISTS (
            SELECT 1 FROM decisions
            WHERE decisions.id = decision_graphs.decision_id
            AND decisions.user_id = auth.uid()
        )
    )
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM decisions
            WHERE decisions.id = decision_graphs.decision_id
            AND decisions.user_id = auth.uid()
        )
    );

-- DELETE
CREATE POLICY "Users can delete graphs of own decisions"
    ON decision_graphs FOR DELETE
    TO authenticated
    USING (
        EXISTS (
            SELECT 1 FROM decisions
            WHERE decisions.id = decision_graphs.decision_id
            AND decisions.user_id = auth.uid()
        )
    );

-- ============================================================================
-- POLICIES: simulations
-- User can access simulations belonging to their own decisions
-- ============================================================================

-- SELECT
CREATE POLICY "Users can view simulations of own decisions"
    ON simulations FOR SELECT
    TO authenticated
    USING (
        EXISTS (
            SELECT 1 FROM decisions
            WHERE decisions.id = simulations.decision_id
            AND decisions.user_id = auth.uid()
        )
    );

-- INSERT
CREATE POLICY "Users can create simulations for own decisions"
    ON simulations FOR INSERT
    TO authenticated
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM decisions
            WHERE decisions.id = simulations.decision_id
            AND decisions.user_id = auth.uid()
        )
    );

-- UPDATE
CREATE POLICY "Users can update simulations of own decisions"
    ON simulations FOR UPDATE
    TO authenticated
    USING (
        EXISTS (
            SELECT 1 FROM decisions
            WHERE decisions.id = simulations.decision_id
            AND decisions.user_id = auth.uid()
        )
    )
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM decisions
            WHERE decisions.id = simulations.decision_id
            AND decisions.user_id = auth.uid()
        )
    );

-- DELETE
CREATE POLICY "Users can delete simulations of own decisions"
    ON simulations FOR DELETE
    TO authenticated
    USING (
        EXISTS (
            SELECT 1 FROM decisions
            WHERE decisions.id = simulations.decision_id
            AND decisions.user_id = auth.uid()
        )
    );

-- ============================================================================
-- POLICIES: recommendations
-- User can access recommendations belonging to their own decisions
-- ============================================================================

-- SELECT
CREATE POLICY "Users can view recommendations of own decisions"
    ON recommendations FOR SELECT
    TO authenticated
    USING (
        EXISTS (
            SELECT 1 FROM decisions
            WHERE decisions.id = recommendations.decision_id
            AND decisions.user_id = auth.uid()
        )
    );

-- INSERT
CREATE POLICY "Users can create recommendations for own decisions"
    ON recommendations FOR INSERT
    TO authenticated
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM decisions
            WHERE decisions.id = recommendations.decision_id
            AND decisions.user_id = auth.uid()
        )
    );

-- UPDATE
CREATE POLICY "Users can update recommendations of own decisions"
    ON recommendations FOR UPDATE
    TO authenticated
    USING (
        EXISTS (
            SELECT 1 FROM decisions
            WHERE decisions.id = recommendations.decision_id
            AND decisions.user_id = auth.uid()
        )
    )
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM decisions
            WHERE decisions.id = recommendations.decision_id
            AND decisions.user_id = auth.uid()
        )
    );

-- DELETE
CREATE POLICY "Users can delete recommendations of own decisions"
    ON recommendations FOR DELETE
    TO authenticated
    USING (
        EXISTS (
            SELECT 1 FROM decisions
            WHERE decisions.id = recommendations.decision_id
            AND decisions.user_id = auth.uid()
        )
    );

-- ============================================================================
-- POLICIES: checkins
-- User can access checkins for their own decisions AND that they created
-- ============================================================================

-- SELECT: Must own the decision AND be the checkin author
CREATE POLICY "Users can view own checkins"
    ON checkins FOR SELECT
    TO authenticated
    USING (
        user_id = auth.uid()
        AND EXISTS (
            SELECT 1 FROM decisions
            WHERE decisions.id = checkins.decision_id
            AND decisions.user_id = auth.uid()
        )
    );

-- INSERT: Must own the decision AND set themselves as author
CREATE POLICY "Users can create checkins for own decisions"
    ON checkins FOR INSERT
    TO authenticated
    WITH CHECK (
        user_id = auth.uid()
        AND EXISTS (
            SELECT 1 FROM decisions
            WHERE decisions.id = checkins.decision_id
            AND decisions.user_id = auth.uid()
        )
    );

-- UPDATE: Must own the decision AND be the checkin author
CREATE POLICY "Users can update own checkins"
    ON checkins FOR UPDATE
    TO authenticated
    USING (
        user_id = auth.uid()
        AND EXISTS (
            SELECT 1 FROM decisions
            WHERE decisions.id = checkins.decision_id
            AND decisions.user_id = auth.uid()
        )
    )
    WITH CHECK (
        user_id = auth.uid()
        AND EXISTS (
            SELECT 1 FROM decisions
            WHERE decisions.id = checkins.decision_id
            AND decisions.user_id = auth.uid()
        )
    );

-- DELETE: Must own the decision AND be the checkin author
CREATE POLICY "Users can delete own checkins"
    ON checkins FOR DELETE
    TO authenticated
    USING (
        user_id = auth.uid()
        AND EXISTS (
            SELECT 1 FROM decisions
            WHERE decisions.id = checkins.decision_id
            AND decisions.user_id = auth.uid()
        )
    );

-- ============================================================================
-- SERVICE ROLE BYPASS
-- Note: Service role automatically bypasses RLS
-- This is used by the backend for admin operations if needed
-- ============================================================================

-- Grant necessary permissions to authenticated users
GRANT USAGE ON SCHEMA public TO authenticated;
GRANT ALL ON ALL TABLES IN SCHEMA public TO authenticated;
GRANT ALL ON ALL SEQUENCES IN SCHEMA public TO authenticated;

-- Ensure anon role has minimal access (only through RLS)
GRANT USAGE ON SCHEMA public TO anon;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO anon;
