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
├── infra/               # Infrastructure configs (coming soon)
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

5. **Expo CLI**
   ```bash
   pnpm add -g expo-cli
   ```

6. **Expo Go app** on your iOS/Android device (for mobile testing)

## Getting Started

### 1. Clone and Install Dependencies

```bash
# Clone the repository
git clone <repository-url>
cd cognition-engine

# Install Node.js dependencies
pnpm install

# Set up Python environment
cd services/api
uv venv
uv sync --dev
cd ../..
```

### 2. Configure Environment

```bash
# Copy environment templates
cp apps/mobile/.env.example apps/mobile/.env
cp services/api/.env.example services/api/.env

# Edit the .env files with your configuration
# - Supabase credentials
# - Anthropic API key
# - etc.
```

### 3. Start Development Servers

**Terminal 1 - API Server:**
```bash
pnpm dev:api
# Or directly:
cd services/api
source .venv/bin/activate
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

**Terminal 2 - Mobile App:**
```bash
pnpm dev:mobile
# Or directly:
cd apps/mobile
pnpm dev
```

### 4. Access the App

- **API**: http://localhost:8000
- **API Docs**: http://localhost:8000/docs
- **Mobile**: Scan QR code with Expo Go app, or press `i` for iOS simulator / `a` for Android emulator

## Development Commands

### Root Commands

```bash
# Start mobile app
pnpm dev:mobile

# Start API server
pnpm dev:api

# Run all linters
pnpm lint

# Fix lint issues
pnpm lint:fix

# Run type checking
pnpm typecheck

# Run all tests
pnpm test

# Clean all dependencies
pnpm clean
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
source .venv/bin/activate

uvicorn app.main:app --reload    # Start dev server
pytest                            # Run tests
pytest --cov=app                  # Run tests with coverage
ruff check .                      # Lint Python code
ruff format .                     # Format Python code
```

### Shared Package (packages/shared)

```bash
cd packages/shared

pnpm typecheck    # TypeScript type check
pnpm test         # Run Jest tests
pnpm build        # Build package
```

## API Endpoints

### Health Check

```bash
curl http://localhost:8000/health
```

Response:
```json
{
  "status": "healthy",
  "version": "0.1.0",
  "timestamp": "2024-01-01T00:00:00Z"
}
```

## Testing

### TypeScript Tests

```bash
# Run all TS tests
pnpm test:ts

# Run specific package tests
pnpm --filter @cognition-engine/mobile test
pnpm --filter @cognition-engine/shared test
```

### Python Tests

```bash
cd services/api
source .venv/bin/activate

# Run all tests
pytest

# Run with coverage
pytest --cov=app --cov-report=html

# Run specific test file
pytest tests/test_health.py
```

## Environment Variables

### Mobile App (.env)

| Variable | Description |
|----------|-------------|
| `EXPO_PUBLIC_API_URL` | Backend API URL |
| `EXPO_PUBLIC_SUPABASE_URL` | Supabase project URL |
| `EXPO_PUBLIC_SUPABASE_ANON_KEY` | Supabase anonymous key |
| `EXPO_PUBLIC_ENV` | Environment (development/production) |

### API Service (.env)

| Variable | Description |
|----------|-------------|
| `HOST` | Server host |
| `PORT` | Server port |
| `ENV` | Environment |
| `DEBUG` | Enable debug mode |
| `LOG_LEVEL` | Logging level |
| `SUPABASE_URL` | Supabase project URL |
| `SUPABASE_ANON_KEY` | Supabase anonymous key |
| `SUPABASE_SERVICE_ROLE_KEY` | Supabase service role key |
| `ANTHROPIC_API_KEY` | Anthropic (Claude) API key |
| `CORS_ORIGINS` | Allowed CORS origins |
| `SECRET_KEY` | Application secret key |

## Project Roadmap

- [x] **Step 1**: Monorepo scaffold + tooling
- [ ] **Step 2**: Supabase setup (schema, RLS, auth)
- [ ] **Step 3**: Mobile auth + navigation
- [ ] **Step 4**: Decision Wizard UI
- [ ] **Step 5**: Backend intake endpoints
- [ ] **Step 6**: AI Orchestrator v1
- [ ] **Step 7**: Model Builder
- [ ] **Step 8**: Decision Graph
- [ ] **Step 9**: Simulation + Recommendation
- [ ] **Step 10**: Tracking + polish

## License

Private - All rights reserved.
