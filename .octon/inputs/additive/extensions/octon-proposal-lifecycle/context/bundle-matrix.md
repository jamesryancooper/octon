# Bundle Matrix

## Packet Lifecycle Routes

| Route | Prompt set | Command | Skill |
| --- | --- | --- | --- |
| `create-packet` | `octon-proposal-lifecycle-create-packet` | `octon-proposal-create-packet` | `octon-proposal-lifecycle-create-packet` |
| `explain-packet` | `octon-proposal-lifecycle-explain-packet` | `octon-proposal-explain-packet` | `octon-proposal-lifecycle-explain-packet` |
| `review-packet` | `octon-proposal-lifecycle-review-packet` | `octon-proposal-review-packet` | `octon-proposal-lifecycle-review-packet` |
| `revise-packet` | `octon-proposal-lifecycle-revise-packet` | `octon-proposal-revise-packet` | `octon-proposal-lifecycle-revise-packet` |
| `generate-packet-implementation-prompt` | `octon-proposal-lifecycle-generate-packet-implementation-prompt` | `octon-proposal-generate-packet-implementation-prompt` | `octon-proposal-lifecycle-generate-packet-implementation-prompt` |
| `run-packet-implementation` | `octon-proposal-lifecycle-run-packet-implementation` | `octon-proposal-run-packet-implementation` | `octon-proposal-lifecycle-run-packet-implementation` |
| `generate-packet-verification-prompt` | `octon-proposal-lifecycle-generate-packet-verification-prompt` | `octon-proposal-generate-packet-verification-prompt` | `octon-proposal-lifecycle-generate-packet-verification-prompt` |
| `generate-packet-correction-prompt` | `octon-proposal-lifecycle-generate-packet-correction-prompt` | `octon-proposal-generate-packet-correction-prompt` | `octon-proposal-lifecycle-generate-packet-correction-prompt` |
| `run-packet-verification-and-correction-loop` | `octon-proposal-lifecycle-run-packet-verification-and-correction-loop` | `octon-proposal-run-packet-verification-and-correction-loop` | `octon-proposal-lifecycle-run-packet-verification-and-correction-loop` |
| `generate-packet-closeout-prompt` | `octon-proposal-lifecycle-generate-packet-closeout-prompt` | `octon-proposal-generate-packet-closeout-prompt` | `octon-proposal-lifecycle-generate-packet-closeout-prompt` |
| `closeout-packet` | `octon-proposal-lifecycle-closeout-packet` | `octon-proposal-closeout-packet` | `octon-proposal-lifecycle-closeout-packet` |

## Workflow-Backed Packet Terminal Routes

| Route | Workflow | Command | Skill |
| --- | --- | --- | --- |
| `proposal-packet-terminal-closeout` | `proposal-packet-terminal-closeout` | `proposal-packet-terminal-closeout` | `proposal-packet-terminal-closeout` |

`proposal-packet-terminal-closeout` is a workflow-backed route, not a prompt
bundle. It emits `support/proposal-terminal-closeout.yml` with an
`archive-ready` or `blocked` verdict and never moves the packet to archive.
Archive relocation remains the separate `archive-proposal` workflow route.

## Workflow-Backed Program Delivery Routes

| Route | Workflow | Command | Skill |
| --- | --- | --- | --- |
| `proposal-program-delivery` | `proposal-program-delivery` | `proposal-program-delivery` | `proposal-program-delivery` |

`proposal-program-delivery` is a workflow-backed route, not a prompt bundle. It
emits an aggregate `proposal-program-delivery-receipt-v1` receipt that cites
target-owned child receipts without replacing them. Packet closeout, archive
relocation, Change closeout, branch cleanup, repo hygiene cleanup, and generated
publication freshness remain owned by their canonical lifecycles and publisher
scripts.

## Program Coordination Routes

| Route | Prompt set | Command | Skill |
| --- | --- | --- | --- |
| `create-program` | `octon-proposal-lifecycle-create-program` | `octon-proposal-create-program` | `octon-proposal-lifecycle-create-program` |
| `explain-program` | `octon-proposal-lifecycle-explain-program` | `octon-proposal-explain-program` | `octon-proposal-lifecycle-explain-program` |
| `review-program` | `octon-proposal-lifecycle-review-program` | `octon-proposal-review-program` | `octon-proposal-lifecycle-review-program` |
| `revise-program` | `octon-proposal-lifecycle-revise-program` | `octon-proposal-revise-program` | `octon-proposal-lifecycle-revise-program` |
| `generate-program-implementation-orchestration-prompt` | `octon-proposal-lifecycle-generate-program-implementation-orchestration-prompt` | `octon-proposal-generate-program-orchestration-prompt` | `octon-proposal-lifecycle-generate-program-orchestration-prompt` |
| `generate-program-verification-prompt` | `octon-proposal-lifecycle-generate-program-verification-prompt` | `octon-proposal-generate-program-verification-prompt` | `octon-proposal-lifecycle-generate-program-verification-prompt` |
| `generate-program-correction-prompt` | `octon-proposal-lifecycle-generate-program-correction-prompt` | `octon-proposal-generate-program-correction-prompt` | `octon-proposal-lifecycle-generate-program-correction-prompt` |
| `cleanup-lifecycle-residue` | `octon-proposal-lifecycle-cleanup-lifecycle-residue` | `octon-proposal-cleanup-lifecycle-residue` | `octon-proposal-lifecycle-cleanup-lifecycle-residue` |
| `run-program-verification-and-correction-loop` | `octon-proposal-lifecycle-run-program-verification-and-correction-loop` | `octon-proposal-run-program-verification-and-correction-loop` | `octon-proposal-lifecycle-run-program-verification-and-correction-loop` |
| `generate-program-closeout-prompt` | `octon-proposal-lifecycle-generate-program-closeout-prompt` | `octon-proposal-generate-program-closeout-prompt` | `octon-proposal-lifecycle-generate-program-closeout-prompt` |
| `closeout-program` | `octon-proposal-lifecycle-closeout-program` | `octon-proposal-closeout-program` | `octon-proposal-lifecycle-closeout-program` |

## Generic Runner Surface

`octon-proposal-run-packet-lifecycle` and
`octon-proposal-lifecycle-run-packet-lifecycle` wrap the shared
`octon lifecycle run --lifecycle proposal-packet --target <packet-path>` CLI.
They are orchestration surfaces, not a prompt bundle route.
The proposal packet lifecycle uses `execution_strategy: route-progression`;
the proposal program lifecycle uses
`execution_strategy: orchestrated-replan-loop`.

`octon-proposal-run-program-lifecycle` and
`octon-proposal-lifecycle-run-program-lifecycle` wrap
`octon lifecycle run --lifecycle proposal-program --target
<program-packet-path>`. They are orchestration surfaces, not dispatcher routes
or prompt bundles. Without `--execute-routes`, they stop at a planned
`program-route-handoff`; with `--execute-routes`, selected parent or child
routes run through a bounded plan-execute-replan loop. One step is one parent
route dispatch or one runnable child batch dispatch; one child batch remains
one step regardless of `--max-child-concurrency`. Execution remains bounded by
dependency gates, child receipts, write-scope checks, approval gates, and
`--max-steps`.
