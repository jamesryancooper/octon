# Implementation Plan

1. Identify the existing plan result data that already carries selected routes, blockers, gate results, child states, and run inputs.
2. Add a route graph projection that reads from current plan state.
3. Include explicit non-authority classification in output.
4. Add fixtures for parent-only, child-batch, review-loop, architecture-review, delivery-handoff, and blocked states.
5. Ensure route graph output does not consume execution steps or mutate lifecycle state beyond retained diagnostic evidence when requested.
