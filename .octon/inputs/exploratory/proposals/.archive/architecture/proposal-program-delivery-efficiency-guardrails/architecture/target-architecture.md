# Target Architecture

## Decision

Proposal-program delivery should become fail-closed and efficient by construction. The delivery wrapper must prove route readiness before expensive lifecycle continuation and must treat the canonical order as the default execution law:

`child implementation -> child validation -> child closeout -> child archive -> parent/program delivery -> landing/sync/cleanup`

Any requested alternative order must stop at stage 01 unless the run provides a retained, schema-valid override receipt bound to the target, requested order, operator identity or authority source, and risk acknowledgement.

## Components

### Execution Order Policy

`proposal-program-delivery-profile-v1` gains an `execution_order_policy` block:

- `canonical_order_required: true`
- `canonical_order_ref: child-before-parent-delivery`
- `operator_requested_alternative_order: false`
- `requested_order_ref: null`
- `override_required_when_order_differs: true`
- `override_receipt_ref: null`

The profile validator rejects any profile where requested order differs from the canonical reference and no valid override receipt exists.

### Stage 01 Warning And Stop

The delivery workflow stage that binds the profile must evaluate order policy before child lifecycle, parent validation, closeout, Git mutation, or publication checks continue. If order differs and no override exists, it emits a retained blocker receipt and the warning:

> Requested order differs from the canonical efficient proposal-program delivery order. This can cause stale evidence, repeated validation, dirty-worktree recovery, and higher token cost. Proceed only with an explicit retained override receipt.

The warning is advisory only when a valid override receipt is already bound. Without the receipt, it is terminal for the route.

### Consolidated Delivery Readiness Preflight

The delivery wrapper introduces a stage before lifecycle continuation that proves:

- Git metadata write access, including index and ref mutation preflight;
- source branch/worktree cleanliness or explicit clean-worktree route selection;
- parent review digest freshness against the archived parent packet;
- child validation receipt compatibility using shared pass semantics;
- required Bash, Python, and YAML tooling;
- selected route legality, including no-PR and PR fallback constraints;
- generated publication freshness posture without treating generated output as authority.

The preflight emits one retained readiness receipt with pass/fail details and rerun commands. Later stages consume this receipt instead of rediscovering these blockers independently.

### Clean Route-Owned Worktree Default

If the source branch is behind `origin/main`, dirty, or contains unclassified residue, delivery defaults to a clean route-owned worktree from current `origin/main`. The wrapper must require include-path classification before any reconstruction or commit. Broad `stage-all` remains forbidden unless route-owned classification names the exact included paths and authority class.

### Shared Receipt Semantics

The pass semantics for archived child `support/validation.md` receipts move into a reusable validator helper. Both readiness projection and child readiness must call the helper. The helper accepts:

- literal `verdict: pass`;
- the legacy success sentence `All listed commands exited successfully.`;
- a markdown command table where every status row is pass and no row contains fail, failed, error, or blocked.

Strict `verdict: pass` remains required for implementation-run, implementation-conformance, drift/churn, closeout, delivery, and route receipts unless a separate proposal widens those semantics.

### Formal Postmortem Closeout

Proposal-program runs require validated lifecycle postmortem evidence before they are considered fully learned-from when any threshold is met:

- repeated materially identical blockers;
- delivery recovery from stale/dirty worktree state;
- cleaned outcome after route recovery;
- run duration, token usage, or blocker count above configured thresholds.

The postmortem validator must fail closed for missing `evaluation.yml`, `report.md`, `readiness-summary.md`, stale digest references, and missing run evidence bindings.

## Non-Goals

- This packet does not rerun or reinterpret any completed parent/program delivery.
- This packet does not authorize editing archived child receipts.
- This packet does not make generated projections authoritative.
- This packet does not create a PR requirement.
- This packet does not authorize broad destructive cleanup.
