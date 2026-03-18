---
title: Examples Reference
description: Triage examples for the triage-ci-failure skill.
---

# Examples Reference

Use command: `/triage-ci-failure`.

## Example 1: Test Failure

**CI Log:**
```
FAIL src/auth/__tests__/login.test.ts
  ● Login flow › should return refresh token

    expect(received).toHaveProperty(expected)

    Expected: "refreshToken"
    Received: {"accessToken": "..."}

      at Object.<anonymous> (src/auth/__tests__/login.test.ts:42:23)
```

**Diagnosis:** TEST_FAILURE — Login endpoint response changed to not include `refreshToken`
**Fix:** Added `refreshToken` to the response object in `src/auth/login.ts:28`
**Verification:** `npm test -- --testPathPattern=login.test` → PASS

## Example 2: Build Error

**CI Log:**
```
error TS2307: Cannot find module '@/components/Button' or its corresponding type declarations.
  src/pages/Home.tsx:3:28
```

**Diagnosis:** BUILD_ERROR — Component was moved but import path not updated
**Fix:** Updated import in `src/pages/Home.tsx:3` from `@/components/Button` to `@/components/ui/Button`
**Verification:** `npm run build` → Success

## Example 3: Infrastructure (No Fix)

**CI Log:**
```
npm ERR! code ECONNREFUSED
npm ERR! syscall connect
npm ERR! errno ECONNREFUSED
npm ERR! FetchError: request to https://registry.npmjs.org/react failed
```

**Diagnosis:** INFRA — npm registry connection refused (transient network issue)
**Fix:** None — infrastructure issue, recommend re-running the CI job
**Verification:** N/A
