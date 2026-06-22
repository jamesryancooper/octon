# Implementation Plan

Implementation is not authorized by this packet creation route. A later accepted implementation route should:

1. Add a profile identifier for proposal-program delivery evaluation to the lifecycle postmortem evaluator input and validator contract.
2. Extend retained evidence mapping so completed proposal-program postmortems can locate parent, child, retained index, planner, delivery, terminal local evidence, validator, and git proof refs when present.
3. Add structured output fields for blocker taxonomy, autonomy analysis, efficiency diagnostics, delivery proof-chain audit, and recommendation backlog.
4. Preserve the existing eighteen-section postmortem contract and add proposal-program profile fields as a compatible extension.
5. Add fixtures for:
   - completed proposal-program lifecycle with branch-no-PR delivery evidence;
   - completed proposal-program lifecycle without delivery evidence;
   - blocker-heavy lifecycle with low-risk governed recovery opportunities;
   - negative controls proving postmortem output is not authority.
6. Update runtime docs and proposal-program lifecycle context to describe the profile and non-authority boundary.
7. Run the lifecycle postmortem validator and test suite.

## Out Of Scope

- Implementing planner recovery behavior.
- Editing historical child receipts.
- Changing delivery wrapper behavior.
- Authorizing or performing material side effects.
