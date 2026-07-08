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
| `proposal-packet-delivery` | `proposal-packet-delivery` | `octon-proposal-run-packet-delivery` | `proposal-packet-delivery` |

`proposal-packet-terminal-closeout` is a workflow-backed route, not a prompt
bundle. It emits `support/proposal-terminal-closeout.yml` with an
`archive-ready` or `blocked` verdict and never moves the packet to archive.
Archive relocation remains the separate `archive-proposal` workflow route.

`proposal-packet-delivery` is a workflow-backed route, not a prompt bundle. Its
operator-facing command is `octon-proposal-run-packet-delivery`. It
emits an aggregate `proposal-packet-delivery-receipt-v1` receipt that cites
target-owned packet receipts without replacing them. Implementation, promotion,
packet closeout, terminal closeout, archive relocation, Change closeout, branch
cleanup, repo hygiene cleanup, and generated publication freshness remain owned
by their canonical lifecycles and publisher scripts.
The command requires `target`, `outcome`, `route=branch-no-pr`, `profile`, and
`run-id` before admission unless a future accepted workflow adds a named
preflight derivation with retained evidence and negative controls.

## Workflow-Backed Program Delivery Routes

| Route | Workflow | Command | Skill |
| --- | --- | --- | --- |
| `proposal-program-delivery` | `proposal-program-delivery` | `proposal-program-delivery`; alias `octon-proposal-run-program-delivery` | `proposal-program-delivery` |
| `proposal-program-clean-delivery` | n/a - runner wrapper | `proposal-program-clean-delivery`; alias `octon-proposal-run-program-clean-delivery` | `octon-proposal-lifecycle-run-program-lifecycle` |

`proposal-program-delivery` is a workflow-backed route, not a prompt bundle. It
emits an aggregate `proposal-program-delivery-receipt-v1` receipt that cites
target-owned child receipts without replacing them. Packet closeout, archive
relocation, Change closeout, branch cleanup, repo hygiene cleanup, and generated
publication freshness remain owned by their canonical lifecycles and publisher
scripts.
The optional operator-facing command alias is
`octon-proposal-run-program-delivery` with display label
`Run Program to Clean Delivery`. It delegates to `proposal-program-delivery`
and does not create an independent workflow, lifecycle mode, closeout, archive,
cleanup, Git mutation, branch cleanup, generated publication, receipt schema,
profile schema, or terminal proof rule.
The workflow requires target program path, target outcome, profile path, and
delivery run id before admission unless a future accepted workflow adds a named
preflight derivation with retained evidence and negative controls.

`proposal-program-clean-delivery` is an operator wrapper around the existing
proposal-program lifecycle runner. It first expands to `octon lifecycle
route-graph --lifecycle proposal-program --target <program> --set
target_outcome=cleaned`, then to `octon lifecycle run --lifecycle
proposal-program --target <program> --execute-routes --set
target_outcome=cleaned`. The route graph is diagnostic-only and the cleaned
target remains a request until owning delivery, closeout, archive, Change
closeout, landing, sync, cleanup, and terminal-proof evidence passes.

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

`octon lifecycle route-graph --lifecycle proposal-program --target
<program-packet-path>` emits a non-authoritative planning read model before
route execution. The graph maps effective route ids to operator labels but does
not rename route ids or satisfy receipts.

## Host Projection Naming Matrix

| Surface | Authority id | Source command | Operator alias | Skill | Codex | Claude | Cursor | Rationale |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Packet lifecycle runner | `proposal-packet` lifecycle | `octon-proposal-run-packet-lifecycle` | none | `octon-proposal-lifecycle-run-packet-lifecycle` | projected | projected | projected | Extension orchestration wrapper; generated host projections remain non-authority. |
| Program lifecycle runner | `proposal-program` lifecycle | `octon-proposal-run-program-lifecycle` | none | `octon-proposal-lifecycle-run-program-lifecycle` | projected | projected | projected | Extension orchestration wrapper for the program replan loop. |
| Program clean-delivery request | `proposal-program-clean-delivery` command | `proposal-program-clean-delivery` | `octon-proposal-run-program-clean-delivery` | `octon-proposal-lifecycle-run-program-lifecycle` | projected | alias projected | projected | Wrapper requests `target_outcome=cleaned`; it does not create delivery authority. |
| Program delivery workflow | `proposal-program-delivery` workflow | `proposal-program-delivery` | `octon-proposal-run-program-delivery` | `proposal-program-delivery` | projected | alias projected | projected | Workflow owns aggregate delivery receipt; alias is operator vocabulary only. |
| Packet delivery workflow | `proposal-packet-delivery` workflow | `proposal-packet-delivery` | `octon-proposal-run-packet-delivery` | `proposal-packet-delivery` | projected | alias projected | alias projected | Workflow owns aggregate packet delivery receipt; source command support is Codex-scoped. |
| Packet terminal closeout | `proposal-packet-terminal-closeout` workflow | `proposal-packet-terminal-closeout` | none | `proposal-packet-terminal-closeout` | projected | omitted | projected | Terminal readiness is workflow-backed; Claude omission follows source host adapter support. |
| Change closeout | `closeout-change` workflow | n/a | n/a | `closeout-change` | projected | projected | projected | Change closeout remains the singular Change route; skills are source-owned. |
| Dirty-worktree closeout | `closeout-worktree` wrapper | n/a | n/a | `closeout-worktree` | projected | projected | projected | Wrapper partitions worktree state and delegates to Change closeout; it is not a separate work unit. |
| Repo hygiene cleanup | `repo-hygiene-cleanup` skill | n/a | n/a | `repo-hygiene-cleanup` | projected | projected | projected | Cleanup deletion requires cleanup authorization; detection alone is not authority. |
| Lifecycle residue cleanup | `cleanup-lifecycle-residue` route | `octon-proposal-cleanup-lifecycle-residue` | none | `octon-proposal-lifecycle-cleanup-lifecycle-residue` | projected | projected | projected | Non-mutating unless a separate cleanup authority explicitly authorizes deletion. |

Projection status is source-manifest-backed. Host files under `.codex`,
`.claude`, `.cursor`, and generated/effective projections are derived outputs;
they may be validated for parity but never become lifecycle, workflow, delivery,
Change closeout, cleanup, archive, or terminal-proof authority.
