# Implementation Plan

## Delivery principle

This packet is **Preferred Change Path first**. Minimal paths are retained only as
fallbacks where the live repo can safely stage work without leaving pseudo-coverage.

## Phase 0 — Baseline confirmation and packet linkage
1. Link this packet from the active proposal workspace as a sibling packet, not a replacement.
2. Re-confirm that no support-target widening is implied.
3. Record the packet in proposal discovery once accepted.

## Phase 1 — Repo-shell execution narrowing
1. Create `instance/governance/policies/repo-shell-execution-classes.yml`.
2. Update `framework/engine/runtime/adapters/host/repo-shell.yml` to reference the new policy and to state classifier receipt expectations.
3. Extend `framework/engine/runtime/spec/policy-interface-v1.md` so classifier outcomes can be emitted through existing authorization/evidence flows.
4. Add `framework/assurance/functional/suites/repo-shell-execution-classification.yml`.

### Preferred Change Path
Implement a repo-owned classifier that distinguishes at least:
- safe read-only path and command classes
- workspace-write classes that remain inside the repo envelope
- escalated / blocked classes that must never silently execute

### Minimal Change Path fallback
Constrain only:
- out-of-workspace writes
- broad verification command classes
- mutating shell commands in read-only or wrong-profile contexts

Do **not** stop at prose policy without assurance and receipt wiring.

## Phase 2 — Bootstrap doctor and onboarding integration
1. Create `bootstrap-doctor` task workflow with `README.md`, `workflow.yml`, and stage asset.
2. Update `instance/bootstrap/START.md` to make `/bootstrap-doctor` the first recommended runtime check.
3. Update `agent-led-happy-path` contract and README so the onboarding flow requires or consumes a doctor receipt.
4. Add `framework/assurance/functional/suites/bootstrap-doctor-readiness.yml`.

### Preferred Change Path
A real workflow entrypoint `/bootstrap-doctor`, retained readiness receipt,
operator-facing short summary, and onboarding integration.

### Minimal Change Path fallback
Standalone workflow + `START.md` integration only, but **still** with retained
receipt and assurance coverage.

## Phase 3 — Observability refinement and degraded-status outputs
1. Extend `failure-taxonomy.yml` with the additional classes needed by the new workflows.
2. Extend `reporting.yml` so doctor/preflight/scenario workflows must emit short machine-grounded summaries citing failure classes.
3. Bind those outputs to `generated/cognition/summaries/operators/**` while retaining underlying evidence under `state/evidence/**`.

### Preferred Change Path
Taxonomy expansion + reporting policy + workflow output requirements across all new workflows.

### Minimal Change Path fallback
Taxonomy/reporting expansion limited to `bootstrap-doctor` and `repo-consequential-preflight` only.

## Phase 4 — Repo-shell supported scenario proof path
1. Create `framework/lab/scenarios/packs/repo-shell/repo-shell-supported-scenario.yml`.
2. Update `framework/lab/scenarios/registry.yml`.
3. Create `run-repo-shell-supported-scenario` task workflow with `README.md`, `workflow.yml`, and stage asset.
4. Add `framework/assurance/functional/suites/repo-shell-supported-scenario.yml`.

### Preferred Change Path
One repo-shell-specific supported scenario pack plus an actual workflow that runs it and retains scenario-proof outputs.

### Minimal Change Path fallback
Single admitted tuple only (`repo-local-governed / observe-and-read / reference-owned / english-primary / repo-shell`) with the same receipt and workflow requirements.

## Phase 5 — Branch freshness before blame
1. Create `instance/governance/policies/branch-freshness.yml`.
2. Create `repo-consequential-preflight` workflow with `README.md`, `workflow.yml`, and stage asset.
3. Patch repo-consequential workflows (`add-api-endpoint`, `add-ui-feature`, `fix-a-bug`, `handle-security-issue`, `run-data-migration`) so broad verification depends on repo-consequential-preflight.
4. Add `framework/assurance/functional/suites/repo-consequential-preflight.yml`.

### Preferred Change Path
Apply to all repo-consequential workflow units listed above.

### Minimal Change Path fallback
Apply first to `fix-a-bug` and `run-data-migration`, then expand to the rest in the same packet’s closure program. Do not mark the concept closed until all repo-consequential workflows listed above are covered.

## Phase 6 — Closeout
1. Run two consecutive validation passes with no new blockers.
2. Retain doctor/preflight/scenario receipts.
3. Confirm operator summaries are short, machine-grounded, and cited to retained evidence.
4. Certify closure using the packet-level closure plan.
## Recommendation ranking

1. Repo-shell supported scenario proof — highest leverage; strong fit; moderate proof burden
2. Repo-shell execution classifiers — high leverage; strong fit; moderate governance sensitivity
3. Bootstrap doctor/preflight — medium-high leverage; easiest to implement
4. Failure taxonomy + degraded summaries — medium leverage; depends on workflows
5. Branch freshness before blame — medium leverage; highest workflow touch count

## Immediate backlog
- repo-shell execution-class policy + adapter/spec refinement
- bootstrap-doctor workflow
- failure taxonomy/reporting refinements needed by the new workflows

## Proposal-first items inside this same packet
- repo-shell-supported scenario workflow
- repo-consequential-preflight workflow
- cross-workflow branch-freshness integration

## Deferred items
None inside the selected concept set.

## Rejection ledger
See `resources/rejection-ledger.md`.
