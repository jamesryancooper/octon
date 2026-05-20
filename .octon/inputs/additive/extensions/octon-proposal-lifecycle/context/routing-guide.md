# Routing Guide

Use the composite route when the user provides a lifecycle action, packet path,
source material, finding id, or program packet. The dispatcher
prefers explicit `bundle` values, then `lifecycle_action`, then falls back to
read-only explanation or creation defaults for routeable composite inputs.

Default resolution:

- `packet_path` alone resolves to `explain-packet`.
- `program_packet_path` alone resolves to `explain-program`.
- `source_kind` defaults to `create-packet`.
- `child_packet_paths` without `program_packet_path` defaults to
  `create-program`.

Use `octon lifecycle plan|run|resume` for the generic end-to-end lifecycle
orchestration surface. The proposal pack exposes
`/octon-proposal-run-packet-lifecycle` and
`/octon-proposal-run-program-lifecycle` as user-facing wrappers, while route
dispatch remains responsible for packet- and program-specific leaf bundles. By
default, `octon lifecycle run --executor auto|codex|claude` produces a gated
handoff (`route-ready` for packets or `program-route-handoff` for programs)
instead of invoking extension prompt bundles directly.
Runtime dispatch follows the published contract `execution_strategy`:
`route-progression` selects the packet lifecycle driver, while
`orchestrated-replan-loop` selects the program lifecycle controller. Route
contracts still define eligible work, and program scheduler fields still
define child batching; neither is treated as the execution strategy.
With `--execute-routes`, the runner delegates selected route execution to the
shared lifecycle executor adapter; prompt-bundle and workflow execution remains
outside the lifecycle runner itself. For proposal programs, `--execute-routes`
continues as a bounded plan-execute-replan loop until terminal completion,
blocked state, approval pause, failure, timeout, cancellation, or max-step
exhaustion.
Because non-mock handoffs do not execute the selected route, they also do not
consume bounded lifecycle loop iterations. Executed routes do consume bounded
lifecycle loop attempts, including `auto`, `codex`, and `claude` adapter-backed
execution. For proposal programs, one step is one selected parent route
dispatch or one runnable child batch dispatch; one child batch counts as one
step regardless of `--max-child-concurrency`. Program route execution is
additionally bounded by dependency gates, child receipts, write-scope checks,
authority-zone checks, replay checks, receipt checks, and delegation proof
retention.
`octon lifecycle cancel --run-id <run> --reason <text>` is the shared durable
stop control for packet and program runs. After cancellation, resume, retry, or
execute-routes must report `cancelled` with `route_execution_mode: none` and no
adapter dispatch. `octon lifecycle program cancel` remains accepted as a
program-specific alias.
Human-boundary blocks remain fail-closed. Program child human exception grant
evidence should route operators through `octon lifecycle program approve`, then
program retry or lifecycle resume. Grant consumption records typed
grant-consumption evidence and never substitutes for the route delegation proof.

## Naming Scheme

- Pack ID: `octon-proposal-lifecycle`.
- Composite command: `octon-proposal`.
- Route IDs use packet/program-qualified action names, for example
  `create-packet`, `review-program`, `generate-packet-implementation-prompt`,
  or `run-program-verification-and-correction-loop`.
- Leaf command IDs: `octon-proposal-<route-id>`.
- Skill and prompt set IDs: `octon-proposal-lifecycle-<route-id>`.
- Human labels: `Octon Proposal Lifecycle: <Action> Packet` or
  `Octon Proposal Lifecycle: <Action> Program`.

## Primary Inputs

- `bundle`: explicit route id override.
- `lifecycle_action`: desired lifecycle operation.
- `packet_path`: active or archived proposal packet path.
- `source_kind`: source class such as `audit`, `architecture-evaluation`, or
  `requirements`.
- `finding_id`: stable finding id for correction generation.
- `program_packet_path`: parent proposal program packet path.
- `child_packet_paths`: canonical child proposal packet paths.

## Fail-Closed Rules

- Unsupported explicit route ids deny.
- Missing routeable inputs escalate.
- Valid packet or program lifecycle actions with missing required packet,
  program, or finding inputs escalate instead of resolving.
- Ambiguous lifecycle states escalate to packet revision or operator decision.
- Packet-path-only composite input resolves only to read-only packet
  explanation.
- Program-packet-only composite input resolves only to read-only program
  explanation.
- Program routes reject nested child proposal packet directories.
- Closeout routes refuse failing checks, unresolved reviews, or missing archive
  and evidence posture.
- Packet implementation prompt generation, `run-packet-implementation`, and
  `promote-proposal` routes refuse packets without a fresh accepted
  `support/proposal-review.md` that authorizes implementation.
- The lifecycle runner advances from `run-packet-implementation` to
  `promote-proposal` through `support/implementation-run.md`, and from
  closeout to archive through `support/proposal-closeout.md`; these receipts
  are packet-local loop state, not new proposal statuses.
