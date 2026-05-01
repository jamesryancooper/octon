# Lifecycle Route Matrix

- proposal: `octon-proposal-packet-lifecycle-automation`

## Routes

| Route | Purpose | Primary output |
| --- | --- | --- |
| `create-proposal-packet` | Normalize source context, classify the scenario, select an existing or custom creation route, create the packet, and validate it. | Manifest-governed proposal packet plus `support/proposal-packet-creation-prompt.md` when generated. |
| `explain-proposal-packet` | Explain purpose, target state, durable promoted outcome, scope boundaries, and follow-on work. | Explanation report under retained evidence or user response. |
| `generate-implementation-prompt` | Convert a packet into a packet-specific executable implementation prompt. | `support/executable-implementation-prompt.md`. |
| `generate-verification-prompt` | Convert packet acceptance criteria and implemented repo state into a verification prompt. | `support/follow-up-verification-prompt.md`. |
| `generate-correction-prompt` | Convert one unresolved verification finding into a targeted correction prompt. | `support/correction-prompts/<finding-id>.md`. |
| `run-verification-and-correction-loop` | Re-run verification and correction until findings resolve or are explicitly deferred. | Verification and correction receipts. |
| `generate-closeout-prompt` | Generate a packet-specific closeout prompt for archival, PR/CI/review, merge, branch cleanup, and sync. | `support/custom-closeout-prompt.md`. |
| `closeout-proposal-packet` | Execute closeout using the generated prompt and existing proposal promote/archive workflows. | Archived packet, registry update, evidence, PR closeout, clean sync. |
| `create-proposal-program` | Create a parent program packet and planned canonical child packet references without nesting child packet directories. | Parent proposal packet plus child packet index and sequence contract. |
| `generate-program-implementation-prompt` | Generate an aggregate implementation prompt that executes child packets in declared sequence or allowed parallel groups. | `support/executable-program-implementation-prompt.md`. |
| `generate-program-verification-prompt` | Generate an aggregate verification prompt across parent gates and child packet acceptance criteria. | `support/follow-up-program-verification-prompt.md`. |
| `generate-program-correction-prompt` | Convert one parent, child, child-group, or cross-packet verification finding into a targeted program correction prompt. | `support/program-correction-prompts/<finding-id>.md`. |
| `run-program-verification-and-correction-loop` | Re-run program-level and child-level verification/correction until clean, blocked, revised, superseded, or explicitly deferred. | Program verification and correction receipts. |
| `generate-program-closeout-prompt` | Generate closeout prompt for coherent child closeout plus parent archival. | `support/custom-program-closeout-prompt.md`. |
| `closeout-proposal-program` | Execute program closeout after child lifecycle states are coherent. | Closed child packets, archived parent, registry update, evidence, clean sync. |

## Scenario Classes

| Scenario | Source | Creation route behavior |
| --- | --- | --- |
| `audit-aligned-packet` | Audit findings or consistency failures | Preserve full audit in `resources/**`, map every finding to remediation and closure proof. |
| `architecture-evaluation-packet` | Architecture score or evaluation | Preserve full evaluation in `resources/**`, produce gap-to-target analysis and implementation plan. |
| `highest-leverage-next-step-packet` | Current repo state plus target thesis | Select one repo-grounded highest-leverage step and prevent broad redesign. |
| `source-to-packet` | User requirements, notes, specs, concept material, or not-yet-classified source input | Classify the target proposal kind, then dispatch to the matching source-to-architecture, source-to-policy, source-to-migration, design, or custom packet route. |
| `source-to-architecture-packet` | Source artifact or concept set | Prefer existing concept-integration source-to-architecture route. |
| `source-to-policy-packet` | Policy source artifact | Prefer existing concept-integration source-to-policy route. |
| `source-to-migration-packet` | Migration source artifact | Prefer existing concept-integration source-to-migration route. |
| `packet-refresh-or-supersession` | Existing packet plus live repo drift | Prefer existing concept-integration refresh/supersession route. |
| `implementation-follow-up` | Existing packet ready to execute | Generate or use packet-specific implementation prompt. |
| `verification-correction` | Verification findings | Generate targeted correction prompts and re-verify. |
| `closeout` | Implemented packet and PR state | Archive, retain evidence, resolve checks/reviews, merge, cleanup, and sync. |
| `proposal-program` | Multi-packet initiative | Create or operate a parent program packet that coordinates child packets at canonical paths. |

## Dispatch Rules

1. Use existing concept-integration and proposal workflow routes when they
   already satisfy the scenario.
2. Generate custom prompts only where the existing route is too generic or the
   user explicitly requests packet-specific prompt artifacts.
3. Keep meta-prompts stable and repo-generic.
4. Keep packet-specific prompts source-grounded, repo-grounded, and scoped to
   the selected packet.
5. Program routes may coordinate only child packets at canonical proposal paths;
   they must reject nested child proposal package directories.
6. Parent program prompts must not override child `proposal.yml`, subtype
   manifests, child acceptance criteria, child validation verdicts, or child
   promotion targets.
7. Fail closed on missing proposal packet authority, ambiguous lifecycle state,
   or unresolved one-way-door execution scope.
