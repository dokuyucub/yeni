# Architecture Overview

## System Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                        Mobile App (Expo)                        │
│  ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────────────┐   │
│  │  Screens │ │Components│ │  Hooks   │ │   State (Zustand) │   │
│  └────┬─────┘ └────┬─────┘ └────┬─────┘ └────────┬─────────┘   │
│       └────────────┴────────────┴────────────────┘             │
│                           │                                     │
│                    ┌──────▼──────┐                              │
│                    │  API Client │                              │
│                    └──────┬──────┘                              │
└───────────────────────────┼─────────────────────────────────────┘
                            │ HTTPS
┌───────────────────────────▼─────────────────────────────────────┐
│                     FastAPI Backend                             │
│  ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────────────┐   │
│  │  Routers │ │ Services │ │  Models  │ │   AI Orchestrator │   │
│  └────┬─────┘ └────┬─────┘ └────┬─────┘ └────────┬─────────┘   │
│       └────────────┴────────────┴────────────────┘             │
│                           │                                     │
│              ┌────────────┴────────────┐                        │
│              │                         │                        │
│       ┌──────▼──────┐          ┌───────▼───────┐               │
│       │   Supabase  │          │  Claude API   │               │
│       │  (Postgres) │          │  (Anthropic)  │               │
│       └─────────────┘          └───────────────┘               │
└─────────────────────────────────────────────────────────────────┘
```

## Data Flow

### Decision Creation Flow

```
1. User opens Decision Wizard
2. User fills intake form (validated with Zod)
3. Draft saved locally (Zustand)
4. On submit: API call to POST /decisions/intake
5. Backend normalizes and validates (Pydantic)
6. Decision saved to Supabase
7. AI Orchestrator triggered for model generation
8. Options/Criteria/Assumptions generated
9. User reviews and modifies
10. Graph generation triggered
11. Simulations run
12. Recommendations generated
13. User makes decision
14. Tracking begins
```

## Security Model

### Authentication
- Supabase Auth (JWT tokens)
- Tokens stored in Expo SecureStore
- Auto-refresh on expiry

### Authorization
- Row Level Security (RLS) in Supabase
- User can only access their own data
- Service role key for backend operations

### Data Privacy
- No PII in logs
- Request IDs for tracing (no user data)
- Claude API calls stripped of identifying info

## Rate Limiting

| Endpoint Type | Limit |
|---------------|-------|
| Standard API | 60 req/min |
| AI Endpoints | 10 req/min |

## Error Handling

### Client Side
- Error boundaries for crash protection
- Toast notifications for user feedback
- Retry logic with exponential backoff

### Server Side
- Structured error responses
- Request ID tracking
- Structured logging (JSON in prod)

## Caching Strategy

| Data Type | Cache Duration | Invalidation |
|-----------|---------------|--------------|
| Decisions list | 5 min | On create/update |
| Decision detail | 5 min | On update |
| AI responses | 1 hour | Manual |
| User profile | 15 min | On update |
