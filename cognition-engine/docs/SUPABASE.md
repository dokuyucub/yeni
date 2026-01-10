# Supabase Setup Guide

This document covers local Supabase development setup, database schema, and security policies.

## Prerequisites

1. **Docker Desktop** - Required for local Supabase
   ```bash
   # macOS
   brew install --cask docker
   ```

2. **Supabase CLI**
   ```bash
   # macOS
   brew install supabase/tap/supabase

   # Or via npm
   npm install -g supabase
   ```

## Quick Start

```bash
# Navigate to Supabase directory
cd cognition-engine/infra/supabase

# Start local Supabase (first time takes a few minutes)
supabase start

# View status and connection info
supabase status

# Apply migrations (automatic on start, manual if needed)
supabase db reset

# Stop Supabase
supabase stop
```

## Connection Details (Local)

After running `supabase start`, you'll see:

| Service | URL |
|---------|-----|
| API URL | http://127.0.0.1:54321 |
| Studio | http://127.0.0.1:54323 |
| Inbucket (Email) | http://127.0.0.1:54324 |
| Database | postgresql://postgres:postgres@127.0.0.1:54322/postgres |

**Keys** (local development only):
- `anon key`: For client-side (mobile app) - respects RLS
- `service_role key`: For server-side (API) - bypasses RLS
- `JWT secret`: For offline JWT verification

Get these values with:
```bash
supabase status
```

## Database Schema

### Tables Overview

| Table | Description |
|-------|-------------|
| `decisions` | Core decision entities |
| `options` | Decision alternatives |
| `criteria` | Evaluation criteria |
| `assumptions` | Key assumptions |
| `decision_graphs` | Versioned graph structures |
| `simulations` | Monte Carlo results |
| `recommendations` | AI recommendations |
| `checkins` | Post-decision tracking |

### Entity Relationship

```
decisions (1) ←──→ (N) options
decisions (1) ←──→ (N) criteria
decisions (1) ←──→ (N) assumptions
decisions (1) ←──→ (N) decision_graphs
decisions (1) ←──→ (N) simulations
decisions (1) ←──→ (N) recommendations
decisions (1) ←──→ (N) checkins

options (1) ←──→ (N) simulations
```

### Key Fields

**decisions**
- `id` (UUID) - Primary key
- `user_id` (UUID) - Owner reference to auth.users
- `title` (TEXT) - Decision title
- `statement` (TEXT) - Full decision statement
- `status` (TEXT) - draft | active | executed | archived
- `urgency` (TEXT) - immediate | this_week | this_month | flexible
- `importance` (TEXT) - critical | high | medium | low

**options**
- `reversibility_score` (0-10) - Higher = more reversible
- `optionality_score` (0-10) - Higher = preserves more options
- `complexity_score` (0-10) - Higher = more complex

**simulations**
- `scenario` (TEXT) - bear | base | bull
- `outcomes_json` - Contains expected_value, variance, ruin_risk

## Row Level Security (RLS)

All tables have RLS enabled with the following rules:

### Ownership Model

```sql
-- decisions: Direct ownership
decisions.user_id = auth.uid()

-- Child tables: Ownership via decisions join
EXISTS (
    SELECT 1 FROM decisions
    WHERE decisions.id = child_table.decision_id
    AND decisions.user_id = auth.uid()
)

-- checkins: Dual ownership check
checkins.user_id = auth.uid()
AND EXISTS (SELECT 1 FROM decisions WHERE ...)
```

### Policy Operations

| Operation | decisions | Child Tables | checkins |
|-----------|-----------|--------------|----------|
| SELECT | user_id = auth.uid() | Via decision join | user_id + decision join |
| INSERT | user_id = auth.uid() | Via decision join | user_id + decision join |
| UPDATE | user_id = auth.uid() | Via decision join | user_id + decision join |
| DELETE | user_id = auth.uid() | Via decision join | user_id + decision join |

## Common Commands

```bash
# Start/Stop
supabase start
supabase stop

# Reset database (applies all migrations + seed)
supabase db reset

# View migration status
supabase migration list

# Create new migration
supabase migration new <name>

# Generate types (TypeScript)
supabase gen types typescript --local > types/database.ts

# View logs
supabase logs

# Access database directly
psql postgresql://postgres:postgres@127.0.0.1:54322/postgres
```

## Testing RLS Policies

```sql
-- In Supabase Studio SQL Editor or psql

-- Set role to authenticated user
SET request.jwt.claims = '{"sub": "user-uuid-here", "role": "authenticated"}';
SET role TO authenticated;

-- Try to select (should only see own data)
SELECT * FROM decisions;

-- Reset
RESET role;
```

## Seed Data

The seed file creates:
- Test user: `test@cognitionengine.local` / `testpassword123`
- Sample decision with options, criteria, and assumptions

To re-seed:
```bash
supabase db reset
```

## Production Setup

1. Create project at [supabase.com](https://supabase.com)
2. Get connection details from Settings > API
3. Run migrations:
   ```bash
   supabase link --project-ref <project-id>
   supabase db push
   ```
4. Update environment variables with production values

## Troubleshooting

### Docker Issues
```bash
# Restart Docker
docker restart $(docker ps -q)

# Clean up Supabase containers
supabase stop --no-backup
docker system prune -f
```

### Migration Issues
```bash
# Check migration status
supabase migration list

# Repair migration history
supabase migration repair --status applied <version>
```

### Connection Issues
```bash
# Verify Supabase is running
supabase status

# Check Docker containers
docker ps | grep supabase
```
