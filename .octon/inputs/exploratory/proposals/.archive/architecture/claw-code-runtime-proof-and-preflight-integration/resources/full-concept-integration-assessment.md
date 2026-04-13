# Full Concept Integration Assessment

## Concept 1 — Deterministic tuple-scoped parity scenarios with retained proof receipts

### A. Upstream concept record
- Upstream mechanism: deterministic mock parity harness + scenario manifest + diff runner
- Why it mattered upstream: gave the source repo reproducible end-to-end parity coverage
- Verification correction: keep as `Adapt`, but remap to Octon’s existing lab scenario roots rather than a bespoke subtree

### B. Current Octon coverage
Current evidence:
- `framework/lab/README.md`
- `framework/lab/scenarios/registry.yml`
- existing scenario packs including `runtime-proof-pack`, browser, and api packs

Authority/evidence posture:
- authored scenario definitions already belong in `framework/lab/scenarios/**`
- retained proof already belongs in `state/evidence/lab/**`
- publication validation receipts already belong in `state/evidence/validation/publication/**`

### C. Coverage judgment
- `partially_covered`

### D. Conflict / overlap / misalignment analysis
- Overlap is with existing scenario packs and runtime-proof-pack.
- A new standalone “parity subsystem” would duplicate the lab model and create avoidable sprawl.
- A scenario-pack-only addition would still be incomplete because there would be no operator/runtime touchpoint to execute it.

### E. Integration decision rubric outcome
- Selected approach: extend existing lab scenario roots and add a dedicated task workflow.
- Narrower alternatives rejected:
  - docs-only: pseudo-coverage
  - registry-only: pseudo-coverage
  - scenario-pack-only without workflow: unusable
- Broader alternative rejected:
  - no need for a new top-level proof subsystem because lab + workflows + evidence roots already exist

### F. Canonical placement
- authoritative:
  - `framework/lab/scenarios/packs/repo-shell/repo-shell-supported-scenario.yml`
  - `framework/lab/scenarios/registry.yml`
  - `framework/orchestration/runtime/workflows/tasks/run-repo-shell-supported-scenario/**`
- control:
  - existing run checkpoints under `state/control/execution/runs/<run-id>/checkpoints/**`
- evidence:
  - `state/evidence/lab/**`
  - `state/evidence/validation/publication/**`
- generated:
  - optional operator digest only

### G. Implementation shape
Preferred:
- add repo-shell-supported scenario pack
- add dedicated task workflow that runs it and emits proof receipts
Minimal fallback:
- single admitted tuple only, but still with a real task workflow and retained proof

### H. Validation and proof
- scenario registry integrity
- workflow discovery integrity
- retained scenario-proof bundle
- retained publication receipt
- no support-universe widening

### I. Operationalization
Operators/agents use `/run-repo-shell-supported-scenario` rather than manually piecing together scenario execution.

### J. Rollback / reversal / deferment posture
Rollback is safe:
- unregister workflow
- remove scenario pack entry
- keep retained proof/evidence from prior runs

### K. Final disposition
- `adapt`

---

## Concept 2 — Repo-shell execution classifiers for path/command gating

### A. Upstream concept record
- Upstream mechanism: `permission_enforcer.rs` path, write, and bash classification
- Verification correction: keep as `Adapt`, narrow to repo-shell refinement

### B. Current Octon coverage
Current evidence:
- `framework/engine/runtime/adapters/host/repo-shell.yml`
- adapter already references policy interface, conformance suite, and failure taxonomy

Authority/evidence posture:
- adapter contract exists, but no explicit repo-owned execution-class policy was found

### C. Coverage judgment
- `partially_covered`

### D. Conflict / overlap / misalignment analysis
- Existing repo-shell adapter is the right anchor.
- A new separate policy engine or shadow approval layer would violate Octon invariants.
- The missing piece is deterministic repo-owned narrowing logic and its assurance coverage.

### E. Integration decision rubric outcome
- Selected approach: add repo-owned execution-class policy under enabled governance policy surfaces and refine repo-shell adapter/spec references.
- Narrower alternative rejected:
  - prose-only policy with no assurance or receipt wiring
- Broader alternative rejected:
  - no need for a new adapter family

### F. Canonical placement
- authoritative:
  - `instance/governance/policies/repo-shell-execution-classes.yml`
  - `framework/engine/runtime/adapters/host/repo-shell.yml`
  - `framework/engine/runtime/spec/policy-interface-v1.md`
  - `framework/assurance/functional/suites/repo-shell-execution-classification.yml`
- control/evidence:
  - existing run/control and evidence roots only
- generated:
  - none required

### G. Implementation shape
Preferred:
- explicit classifier policy + adapter/spec/suite updates
Minimal fallback:
- initial classifier coverage limited to out-of-workspace writes, mutating shell commands, and broad verification command classes

### H. Validation and proof
- deterministic suite proving allow/deny/escalate behavior
- policy/run receipts showing decisions are canonicalized through existing evidence flows

### I. Operationalization
Runtime consumers benefit automatically through the repo-shell adapter; operators see structured allow/deny reasons in retained receipts rather than inferring from shell output.

### J. Rollback / reversal / deferment posture
Remove the new repo policy and corresponding adapter references if classification proves too narrow or too broad; keep receipts.

### K. Final disposition
- `adapt`

---

## Concept 3 — Bootstrap doctor/preflight integrated into existing onboarding workflow

### A. Upstream concept record
- Upstream mechanism: `claw doctor` / `/doctor` as first health check
- Verification correction: downgrade from `Adopt` to `Adapt` because Octon already has bootstrap/onboarding surfaces

### B. Current Octon coverage
Current evidence:
- `instance/bootstrap/START.md`
- `framework/orchestration/runtime/workflows/tasks/agent-led-happy-path/**`

### C. Coverage judgment
- `partially_covered`

### D. Conflict / overlap / misalignment analysis
- Onboarding already exists; the gap is a deterministic preflight step with retained evidence.
- Docs-only insertion into `START.md` would not make the capability operational.

### E. Integration decision rubric outcome
- Selected approach: add a real `bootstrap-doctor` task workflow and integrate it into onboarding.
- Narrower alternative rejected:
  - `START.md` text only
- Broader alternative rejected:
  - no need for a new top-level bootstrap subsystem

### F. Canonical placement
- authoritative:
  - `instance/bootstrap/START.md`
  - `framework/orchestration/runtime/workflows/tasks/bootstrap-doctor/**`
  - `framework/orchestration/runtime/workflows/tasks/agent-led-happy-path/**`
  - `framework/assurance/functional/suites/bootstrap-doctor-readiness.yml`
- control/evidence:
  - doctor checkpoint under existing run roots
  - publication/validation receipts under existing evidence roots
- generated:
  - operator digest may summarize outcome

### G. Implementation shape
Preferred:
- standalone doctor workflow + onboarding integration + receipt/suite coverage
Minimal fallback:
- standalone workflow + `START.md` prerequisite if direct workflow composition remains unavailable

### H. Validation and proof
- doctor workflow discovery
- retained readiness receipt
- assurance suite for receipt and failure-mode integrity
- onboarding flow confirms doctor prerequisite is honored

### I. Operationalization
Operators/agents invoke `/bootstrap-doctor` before onboarding work. `agent-led-happy-path` reflects that requirement.

### J. Rollback / reversal / deferment posture
Workflow can be removed cleanly; retained readiness receipts remain historical evidence.

### K. Final disposition
- `adapt`

---

## Concept 4 — Structured failure taxonomy + machine-readable degraded-status/operator summaries

### A. Upstream concept record
- Upstream mechanism: roadmap-level failure taxonomy normalization + degraded-mode reporting
- Earlier extraction missed it; verification added it

### B. Current Octon coverage
Current evidence:
- `framework/observability/governance/failure-taxonomy.yml`
- `framework/observability/governance/reporting.yml`
- generated operator digest family declared in `octon.yml`

### C. Coverage judgment
- `partially_covered`

### D. Conflict / overlap / misalignment analysis
- Existing taxonomy/reporting surfaces are correct, but too narrow for the selected concept set.
- A new separate operator-status subsystem would duplicate observability governance and generated summary roots.

### E. Integration decision rubric outcome
- Selected approach: extend existing observability governance and bind the new workflows to emit short machine-grounded summaries citing failure classes.
- Narrower alternative rejected:
  - taxonomy extension without output requirements
- Broader alternative rejected:
  - no need for a new output family outside `generated/cognition/summaries/operators/**`

### F. Canonical placement
- authoritative:
  - `framework/observability/governance/failure-taxonomy.yml`
  - `framework/observability/governance/reporting.yml`
- evidence:
  - `state/evidence/control/execution/**`
  - `state/evidence/runs/**`
- generated:
  - `generated/cognition/summaries/operators/**`
- control:
  - no new standalone control surface; failure classes annotate existing run/control evidence

### G. Implementation shape
Preferred:
- taxonomy/reporting refinement + workflow output requirements for doctor/preflight/scenario workflows
Minimal fallback:
- doctor/preflight only

### H. Validation and proof
- summaries cite failure classes
- retained evidence exists for every non-happy-path summary
- generated summaries remain derived-only

### I. Operationalization
Operators receive short summaries that reflect canonical retained evidence rather than ad hoc logs.

### J. Rollback / reversal / deferment posture
Taxonomy entries can be narrowed or reverted; evidence already produced remains valid historical trace.

### K. Final disposition
- `adapt`

---

## Concept 5 — Branch freshness gating before broad repo-consequential verification

### A. Upstream concept record
- Upstream mechanism: `stale_branch.rs` + roadmap policy “branch freshness before blame”
- Earlier extraction missed it; verification added it

### B. Current Octon coverage
Current evidence:
- repo-consequential task workflows exist
- ingress only has a branch closeout prompt, not freshness gating

### C. Coverage judgment
- `not_currently_present`

### D. Conflict / overlap / misalignment analysis
- Adjacent existing surface: branch closeout gate in ingress.
- Misalignment: closeout prompt is about ending work after mutation, not freshness before broad verification.
- New capability must live in workflow + repo policy surfaces, not in chat practice.

### E. Integration decision rubric outcome
- Selected approach: new repo-owned branch-freshness policy + reusable preflight workflow + targeted edits to repo-consequential task workflows.
- Narrower alternative rejected:
  - documenting “remember to refresh branch first” would be pseudo-coverage
- Broader alternative rejected:
  - no need for a generalized new branch-control plane outside workflows/policies

### F. Canonical placement
- authoritative:
  - `instance/governance/policies/branch-freshness.yml`
  - `framework/orchestration/runtime/workflows/tasks/repo-consequential-preflight/**`
  - edits to repo-consequential task workflow contracts
  - `framework/assurance/functional/suites/repo-consequential-preflight.yml`
- control/evidence:
  - freshness checkpoint in existing run roots
  - retained run/publication evidence
- generated:
  - optional operator digest

### G. Implementation shape
Preferred:
- apply preflight to all current repo-consequential task workflows
Minimal fallback:
- phase `fix-a-bug` and `run-data-migration` first, but do not mark the concept closed until all listed workflows are covered

### H. Validation and proof
- fresh/stale/diverged outcomes behave according to policy
- broad verification is blocked or rerouted when required
- retained freshness receipt exists
- operator summary stays short and evidence-backed

### I. Operationalization
Operators/agents run `/repo-consequential-preflight` or hit it automatically through repo-consequential workflows before broad verification.

### J. Rollback / reversal / deferment posture
Remove workflow and policy if they prove unsound; keep historical evidence of freshness checks.

### K. Final disposition
- `adapt`
