---
title: Examples Reference
description: Resolution examples for the resolve-pr-comments skill.
---

# Examples Reference

Use command: `/resolve-pr-comments`.

## Example 1: Simple Style Fix

**Comment:** "@reviewer: This should use camelCase per our conventions"

```
File: src/utils/helpers.ts:42
Type: STYLE
Resolution: APPLIED
Change: Renamed `get_user_name` → `getUserName` and updated all references
```

## Example 2: Bug Fix with Test

**Comment:** "@reviewer: This will throw if `items` is null"

```
File: src/components/List.tsx:15
Type: BUG
Resolution: APPLIED
Change: Added null check: `if (!items) return null;` before the `.map()` call
```

## Example 3: Design Decision Deferred

**Comment:** "@reviewer: Should we use React Context or Zustand for this state?"

```
File: src/store/auth.ts:1
Type: DESIGN
Resolution: DEFERRED
Note: Two valid approaches — Context (simpler, fewer deps) vs Zustand (more scalable).
      Presenting both options for author decision.
```

## Example 4: Question Answered

**Comment:** "@reviewer: Why are we using `useMemo` here instead of `useCallback`?"

```
File: src/hooks/useData.ts:28
Type: QUESTION
Resolution: ANSWERED
Response: "useMemo is correct here because we're memoizing a computed value (the filtered list),
           not a function reference. useCallback would be appropriate if we were passing a
           callback to a child component."
```
