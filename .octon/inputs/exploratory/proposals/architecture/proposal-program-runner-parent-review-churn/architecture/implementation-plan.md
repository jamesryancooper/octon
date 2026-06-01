# Implementation Plan

1. Identify parent review digest inputs and volatile evidence paths.
2. Separate parent-authored coordination digest from run-control evidence
   references.
3. Preserve strict review gates before routes that require accepted
   implementation authorization.
4. Avoid requiring accepted-only gates after parent implemented state when the
   lifecycle contract declares implemented-state gates.
5. Add tests for irrelevant evidence churn and meaningful parent-surface
   changes.
