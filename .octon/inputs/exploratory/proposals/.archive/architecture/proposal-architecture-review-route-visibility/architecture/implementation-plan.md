# Implementation Plan

1. Identify how the lifecycle planner detects architecture proposal manifests and strict architecture-review receipts.
2. Add route graph fields for architecture-review status and owning route/workflow hints.
3. Preserve existing promote and review completion checks.
4. Add fixtures for missing, stale, failing, passing, and not-applicable states.
5. Add negative controls proving diagnostic visibility cannot satisfy architecture-review gates.
