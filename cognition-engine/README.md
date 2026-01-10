# Cognition Engine

AI Decision & Simulation Consultant - A production-grade mobile application for making better decisions through structured analysis, simulation, and AI-powered recommendations.

## Features (Planned)

- **Decision Studio**: Complete decision workflow from intake to recommendation
- **Model Builder**: Generate options, criteria, and assumptions with AI assistance
- **Decision Graphs**: Visual representation of decision trees and probability flows
- **Simulations**: Monte Carlo simulations with optimistic/baseline/pessimistic scenarios
- **Recommendations**: AI-powered recommendations with risk analysis
- **Tracking**: Post-decision check-ins and learning loops

## Tech Stack

- **Mobile**: React Native (Expo) + TypeScript
- **Backend**: FastAPI (Python) + Pydantic
- **Database/Auth**: Supabase (Postgres)
- **AI**: Claude API (via backend only)
- **State Management**: TanStack Query + Zustand
- **Validation**: Zod (client) + Pydantic (server)

## Repository Structure

```
cognition-engine/
├── apps/
│   └── mobile/          # Expo React Native app
├── services/
│   └── api/             # FastAPI backend service
├── packages/
│   └── shared/          # Shared TypeScript types & schemas
├── infra/
│   └── supabase/        # Supabase local dev + migrations
├── docs/                # Documentation
└── .github/workflows/   # CI/CD pipelines
```

## Prerequisites

### macOS Setup

1. **Node.js 20+**
   ```bash
   # Using nvm
   nvm install 20
   nvm use 20
   ```

2. **pnpm 9+**
   ```bash
   npm install -g pnpm@9
   ```

3. **Python 3.11+**
   ```bash
   # Using pyenv
   pyenv install 3.11
   pyenv local 3.11
   ```

4. **uv (Python package manager)**
   ```bash
   curl -LsSf https://astral.sh/uv/install.sh | sh
   ```

5. **Docker Desktop** (for local Supabase)
   ```bash
   brew install --cask docker
   ```

6. **Supabase CLI**
   ```bash
   brew install supabase/tap/supabase
   ```

7. **Expo Go app** on your iOS/Android device (for mobile testing)

## Getting Started

### 1. Clone and Install Dependencies

```bash
# Clone the repository
git clone <repository-url>
cd cognition-engine

# Install Node.js dependencies
pnpm install

# Set up Python environment
pnpm setup:api
```

### 2. Start Local Supabase

```bash
# Start Supabase (first time takes a few minutes for Docker images)
cd infra/supabase
supabase start

# View connection info
supabase status
```

You'll see output like:
```
         API URL: http://127.0.0.1:54321
     GraphQL URL: http://127.0.0.1:54321/graphql/v1
          DB URL: postgresql://postgres:postgres@127.0.0.1:54322/postgres
      Studio URL: http://127.0.0.1:54323
        anon key: eyJhbGci...
service_role key: eyJhbGci...
      JWT secret: super-secret-jwt-token-with-at-least-32-characters-long
```

### 3. Configure Environment

```bash
# Copy environment templates
cp apps/mobile/.env.example apps/mobile/.env
cp services/api/.env.example services/api/.env
```

The `.env.example` files contain local Supabase defaults. For production, update with your hosted Supabase credentials.

### 4. Start Development Servers

**Terminal 1 - Supabase** (if not already running):
```bash
cd infra/supabase && supabase start
```

**Terminal 2 - API Server:**
```bash
pnpm dev:api
```

**Terminal 3 - Mobile App:**
```bash
pnpm dev:mobile
```

### 5. Access the App

| Service | URL |
|---------|-----|
| API | http://localhost:8000 |
| API Docs | http://localhost:8000/docs |
| Supabase Studio | http://127.0.0.1:54323 |
| Mobile | Scan QR code with Expo Go |

## Development Commands

### Root Commands

```bash
# Start services
pnpm dev:mobile          # Start Expo dev server
pnpm dev:api             # Start FastAPI server

# Code quality
pnpm lint                # Run all linters
pnpm lint:fix            # Fix lint issues
pnpm typecheck           # TypeScript type check

# Testing
pnpm test                # Run all tests
pnpm test:ts             # TypeScript tests only
pnpm test:py             # Python tests only

# Setup
pnpm setup:api           # Set up Python environment
pnpm clean               # Clean all dependencies
```

### Supabase Commands

```bash
cd infra/supabase

# Lifecycle
supabase start           # Start local Supabase
supabase stop            # Stop local Supabase
supabase status          # View connection info

# Database
supabase db reset        # Reset DB (apply migrations + seed)
supabase migration list  # View migration status
supabase migration new <name>  # Create new migration

# Generate types
supabase gen types typescript --local > ../../packages/shared/src/types/database.ts
```

### Mobile App (apps/mobile)

```bash
cd apps/mobile

pnpm dev          # Start Expo dev server
pnpm ios          # Run on iOS simulator
pnpm android      # Run on Android emulator
pnpm typecheck    # TypeScript type check
pnpm test         # Run Jest tests
```

### API Service (services/api)

```bash
cd services/api

# Using uv (recommended)
uv run uvicorn app.main:app --reload
uv run pytest
uv run ruff check .

# Or activate venv first
source .venv/bin/activate
uvicorn app.main:app --reload
pytest
```

## API Endpoints

### Public Endpoints

```bash
# Health check
curl http://localhost:8000/health
```

### Protected Endpoints

```bash
# Get current user (requires Supabase JWT)
curl -H "Authorization: Bearer <your-jwt-token>" \
     http://localhost:8000/users/me
```

### Response Examples

**Health Check:**
```json
{
  "status": "healthy",
  "version": "0.1.0",
  "timestamp": "2024-01-01T00:00:00Z"
}
```

**User Me:**
```json
{
  "id": "uuid-here",
  "email": "user@example.com",
  "role": "authenticated"
}
```

## Database Schema

See [docs/SUPABASE.md](docs/SUPABASE.md) for full schema documentation.

### Tables

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

### Row Level Security

All tables have RLS enabled:
- Users can only access their own decisions
- Child tables (options, criteria, etc.) inherit access via decision ownership
- Service role key bypasses RLS (backend only)

## Environment Variables

### Mobile App (.env)

| Variable | Description |
|----------|-------------|
| `EXPO_PUBLIC_API_URL` | Backend API URL |
| `EXPO_PUBLIC_SUPABASE_URL` | Supabase project URL |
| `EXPO_PUBLIC_SUPABASE_ANON_KEY` | Supabase anonymous key (public) |
| `EXPO_PUBLIC_ENV` | Environment (development/production) |

### API Service (.env)

| Variable | Description |
|----------|-------------|
| `SUPABASE_URL` | Supabase project URL |
| `SUPABASE_ANON_KEY` | Supabase anonymous key |
| `SUPABASE_SERVICE_ROLE_KEY` | Supabase service role key (secret!) |
| `SUPABASE_JWT_SECRET` | JWT secret for offline verification |
| `ANTHROPIC_API_KEY` | Anthropic (Claude) API key |
| `CORS_ORIGINS` | Allowed CORS origins |

## Testing

### TypeScript Tests

```bash
pnpm test:ts

# Specific packages
pnpm --filter @cognition-engine/mobile test
pnpm --filter @cognition-engine/shared test
```

### Python Tests

```bash
cd services/api
uv run pytest

# With coverage
uv run pytest --cov=app --cov-report=html
```

### RLS Policy Tests

```sql
-- In Supabase Studio SQL Editor
SET request.jwt.claims = '{"sub": "user-uuid", "role": "authenticated"}';
SET role TO authenticated;
SELECT * FROM decisions;  -- Should only return user's decisions
RESET role;
```

## Project Roadmap

- [x] **Step 1**: Monorepo scaffold + tooling
- [x] **Step 2**: Supabase setup (schema, RLS, auth)
- [ ] **Step 3**: Mobile auth + navigation
- [ ] **Step 4**: Decision Wizard UI
- [ ] **Step 5**: Backend intake endpoints
- [ ] **Step 6**: AI Orchestrator v1
- [ ] **Step 7**: Model Builder
- [ ] **Step 8**: Decision Graph
- [ ] **Step 9**: Simulation + Recommendation
- [ ] **Step 10**: Tracking + polish

## Troubleshooting

### Supabase Issues

```bash
# Reset everything
cd infra/supabase
supabase stop --no-backup
supabase start

# Check Docker
docker ps | grep supabase
```

### API Issues

```bash
# Verify JWT secret matches
cd infra/supabase && supabase status | grep JWT
# Compare with services/api/.env SUPABASE_JWT_SECRET
```

### Mobile Issues

```bash
# Clear Expo cache
cd apps/mobile
pnpm start --clear
```

## License

Private - All rights reserved.
