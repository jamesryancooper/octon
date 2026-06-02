# Implementation Plan

1. Define controller-owned aggregate blocker receipt schema.
2. Emit the receipt when required children are not terminal under the active
   closeout policy.
3. Include all blocked terminal children in one receipt rather than cycling one
   child at a time.
4. Teach parent closeout/archive planning to consume the aggregate evidence
   without treating it as child receipt authority.
5. Add tests for multiple blocked children and mixed archived/rejected/deferred
   policy outcomes.
