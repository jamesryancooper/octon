# Implementation Plan

1. Resolve selected child id, target path, and expected receipt lineage.
2. Validate every supplied `promotion_evidence` path is repo-relative,
   existing, child-bound, and not parent-owned.
3. Add pre-dispatch blocker evidence for missing, stale, or wrong-child
   promotion evidence.
4. Keep final status mutation workflow-owned.
5. Add negative tests for wrong-child and stale evidence.
