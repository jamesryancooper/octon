---
title: React Rules - Testing
description: Testing-oriented checks for high-risk performance and correctness changes.
version: "1.0.1"
---

# Testing Rules

## Focus Areas

- Add regression tests for waterfalls removed via parallelization
- Add render-count tests when memoization or dependency changes are introduced
- Add integration tests for server/client boundary changes
- Verify hydration behavior in SSR/streaming paths
