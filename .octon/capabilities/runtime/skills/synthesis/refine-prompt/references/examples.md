---
examples:
  - input: "add caching to the api"
    invocation: "/refine-prompt 'add caching to the api'"
    output: ".octon/scaffolding/practices/prompts/20250114-120000-refined.md"
    description: "Context-aware refinement with persona, anti-patterns, and self-critique"
  - input: "refactor the auth module"
    invocation: "/refine-prompt 'refactor the auth module' --context_depth=deep"
    output: ".octon/scaffolding/practices/prompts/20250114-120100-refined.md"
    description: "Deep analysis refactoring with comprehensive risk assessment"
---

# Examples Reference

Full examples demonstrating refine-prompt skill usage.

## Example 1: API Caching (Full Refinement)

### Input

```text
/refine-prompt "add caching to the api"
```

### Refined Output

```markdown
# Refined Prompt

**Original:** "add caching to the api"
**Refined:** 2025-01-14T12:00:00Z
**Context Depth:** standard
**Status:** confirmed

---

## Execution Persona

**Role:** Senior Backend Engineer
**Expertise Level:** Senior
**Perspective:** Focus on performance, cache consistency, and maintainability
**Style:** Thorough, well-documented, follows existing patterns exactly

---

## Repository Context

**Tech Stack:** Node.js, Express, TypeScript, Redis (already configured)
**Relevant Modules:** `packages/api/src/`

### Files in Scope

| File | Role | Action |
|------|------|--------|
| `packages/api/src/middleware/cache.ts` | Existing cache middleware | Reference pattern |
| `packages/api/src/routes/users.ts` | User endpoints | Modify (add caching) |
| `packages/api/src/routes/products.ts` | Product endpoints | Modify (add caching) |
| `packages/api/src/config/redis.ts` | Redis configuration | Reference |

### Existing Patterns to Follow

- **Pattern:** Response caching in `packages/api/src/middleware/cache.ts:15`
  - Uses Redis with TTL, cache key based on route + query params
  - Includes cache invalidation on mutations

### Project Constraints

- All middleware must have unit tests
- Cache TTLs must be configurable via environment variables

---

## Intent

Add response caching to API endpoints to improve performance and reduce database load.

## Requirements

1. Implement caching for GET endpoints on users and products routes
2. Use existing Redis configuration and cache middleware pattern
3. Make TTL configurable per endpoint via environment variables
4. Implement cache invalidation on POST/PUT/DELETE

## Assumptions Made

- Using existing Redis instance (already configured in codebase)
- Following existing cache middleware pattern exactly
- Cache keys include user context for personalized responses
- Only GET endpoints should be cached (mutations always hit DB)

---

## Negative Constraints (What NOT To Do)

### Anti-Patterns to Avoid

- **Don't:** Implement a new caching mechanism
  - Why: Existing pattern in `cache.ts` is proven and consistent
- **Don't:** Cache POST/PUT/DELETE responses
  - Why: Mutations must always reflect current state
- **Don't:** Use hardcoded TTL values
  - Why: Project constraint requires env var configuration

### Forbidden Approaches

- Creating a new Redis connection — use existing `config/redis.ts`
- Caching user-specific data without user ID in cache key — causes data leaks
- Skipping cache invalidation — causes stale data bugs

### Out of Scope

- Caching at the CDN/edge level (future work)
- Cache warming strategies (not needed for initial implementation)
- Metrics/monitoring for cache hit rates (separate task)

---

## Sub-Tasks

### Task 1: Extend cache middleware

**Files:** `packages/api/src/middleware/cache.ts`
**Depends on:** None
**Description:** Add configurable TTL support and user-context cache keys

### Task 2: Add caching to user routes

**Files:** `packages/api/src/routes/users.ts`
**Depends on:** Task 1
**Description:** Apply cache middleware to GET /users and GET /users/:id

### Task 3: Add caching to product routes

**Files:** `packages/api/src/routes/products.ts`
**Depends on:** Task 1
**Description:** Apply cache middleware to GET /products and GET /products/:id

### Task 4: Add cache invalidation

**Files:** `packages/api/src/routes/users.ts`, `packages/api/src/routes/products.ts`
**Depends on:** Task 2, Task 3
**Description:** Invalidate relevant cache entries on mutations

### Task 5: Add tests

**Files:** `packages/api/src/middleware/__tests__/cache.test.ts`
**Depends on:** Task 1
**Description:** Unit tests for new cache middleware features

---

## Risks & Edge Cases

| Risk | Severity | Mitigation |
|------|----------|------------|
| Stale data after mutations | High | Implement cache invalidation in Task 4 |
| Cache key collisions | Medium | Include user ID in cache key |
| Redis connection failures | Low | Existing fallback returns uncached response |

### Edge Cases to Handle

- [ ] Paginated endpoints need page/limit in cache key
- [ ] Filtered queries need filter params in cache key
- [ ] Admin users may need separate cache or bypass

---

## Success Criteria

- [ ] Cache middleware supports configurable TTL via env vars
- [ ] GET endpoints return cached responses on subsequent calls
- [ ] Mutations invalidate relevant cache entries
- [ ] All new code has test coverage (>80%)
- [ ] No performance regression (response time <= before + 10ms)
- [ ] No stale data observed after mutations

---

## Self-Critique Results

| Check | Status | Notes |
|-------|--------|-------|
| Completeness | Pass | All necessary context included |
| Ambiguity | Pass | Requirements are specific and measurable |
| Feasibility | Pass | All referenced files exist, pattern is applicable |
| Quality | Pass | Persona appropriate, anti-patterns comprehensive |

**Issues Found & Fixed:**
- Added explicit note about user ID in cache key to prevent data leaks
- Clarified that only GET endpoints should be cached

---

## Intent Confirmation

**Summary:** Add Redis-based response caching to user and product GET endpoints, following the existing cache middleware pattern, with proper invalidation on mutations.

**Key Decisions:**
1. Using existing cache pattern (not creating new) — consistency
2. Cache keys will include user ID — prevents data leaks
3. TTLs via env vars — meets project constraint

**User Response:** Confirmed

---

## Refined Prompt

**Persona:** Act as a Senior Backend Engineer focused on performance and cache consistency. Be thorough and well-documented. Follow existing patterns exactly.

**Task:** Implement response caching for the API using the existing Redis configuration and cache middleware pattern.

**Context:**
- Redis config: `packages/api/src/config/redis.ts`
- Cache pattern: `packages/api/src/middleware/cache.ts:15`

**Requirements:**

1. Extend `packages/api/src/middleware/cache.ts`:
   - Add configurable TTL parameter (read from env vars)
   - Include user ID in cache key for personalized responses
   - Add cache invalidation helper function

2. Apply caching to routes:
   - `packages/api/src/routes/users.ts`: Cache GET /users (TTL: 5min), GET /users/:id (TTL: 10min)
   - `packages/api/src/routes/products.ts`: Cache GET /products (TTL: 15min), GET /products/:id (TTL: 30min)

3. Implement cache invalidation:
   - POST/PUT/DELETE on /users invalidates user cache
   - POST/PUT/DELETE on /products invalidates product cache

4. Add tests in `packages/api/src/middleware/__tests__/cache.test.ts`

**Do NOT:**
- Create a new caching mechanism (use existing pattern)
- Cache POST/PUT/DELETE responses
- Use hardcoded TTL values (must be env vars)
- Create new Redis connections (use existing config)
- Cache without user ID in key (causes data leaks)

**Success Criteria:**
- [ ] TTLs configurable via env vars
- [ ] Cached responses on repeated GET calls
- [ ] Cache invalidated on mutations
- [ ] Test coverage >80%
- [ ] No performance regression
```

## Example 2: Auth Module Refactoring (Deep Analysis)

### Input

```text
/refine-prompt "refactor the auth module" --context_depth=deep
```

### Expected Behavior

With `--context_depth=deep`, the skill performs:

1. **Full dependency mapping** - traces all imports/exports of auth module
2. **Impact analysis** - identifies all files that depend on auth
3. **Interface audit** - documents current public API
4. **Test coverage review** - identifies existing test patterns
5. **Risk assessment** - flags breaking change potential

The refined prompt would include comprehensive file lists, interface documentation, and detailed sub-tasks for safe migration.
