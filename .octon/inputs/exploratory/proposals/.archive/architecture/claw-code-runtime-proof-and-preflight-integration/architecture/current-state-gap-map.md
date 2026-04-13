# Current-State Gap Map

## Baseline

Live Octon already has:

- a single super-rooted architecture with `framework/`, `instance/`, `inputs/`, `state/`, and `generated/`
- explicit host adapter contracts, including `repo-shell`
- authored lab scenario roots and scenario registry
- observability governance with failure taxonomy and reporting policy
- canonical bootstrap/orientation surfaces
- canonical task workflows discoverable through workflow manifest and registry
- explicit support-target and governance-exclusion declarations

That baseline means the selected concept set is **not** greenfield.

## Concept-by-concept gap map

### 1. Deterministic tuple-scoped parity scenarios with retained proof receipts
- Current evidence:
  - `framework/lab/README.md`
  - `framework/lab/scenarios/registry.yml`
  - existing packs such as `runtime-proof-pack`, browser, and api scenarios
- Coverage judgment:
  - `partially_covered`
- Gap:
  - no repo-shell-specific supported scenario pack
  - no selected task workflow that executes a repo-shell-supported scenario and emits the intended retained proof receipts

### 2. Repo-shell execution classifiers for path/command gating
- Current evidence:
  - `framework/engine/runtime/adapters/host/repo-shell.yml`
  - adapter references to `policy-interface-v1.md`, conformance suites, and the observability failure taxonomy
- Coverage judgment:
  - `partially_covered`
- Gap:
  - no repo-owned governance policy that classifies path/command classes for repo-shell narrowing
  - no dedicated assurance suite proving classifier behavior against allowed modes

### 3. Bootstrap doctor/preflight integrated into existing onboarding workflow
- Current evidence:
  - `instance/bootstrap/START.md`
  - `framework/orchestration/runtime/workflows/tasks/agent-led-happy-path/**`
- Coverage judgment:
  - `partially_covered`
- Gap:
  - no concrete doctor/preflight workflow unit
  - no retained readiness receipt family tied to the onboarding flow

### 4. Structured failure taxonomy + machine-readable degraded-status/operator summaries
- Current evidence:
  - `framework/observability/governance/failure-taxonomy.yml`
  - `framework/observability/governance/reporting.yml`
  - generated operator digest family declared in `octon.yml`
- Coverage judgment:
  - `partially_covered`
- Gap:
  - taxonomy is too coarse for the selected integration set
  - no defined machine-readable degraded-startup / preflight summary pattern for operators

### 5. Branch freshness gating before broad repo-consequential verification
- Current evidence:
  - branch closeout prompt in ingress
  - repo-consequential task workflows exist
- Coverage judgment:
  - `not_currently_present`
- Gap:
  - no freshness policy
  - no pre-broad-verification freshness gate
  - no retained freshness receipt or operator summary pattern

## Active-packet overlap judgment

The active packet `octon_bounded_uec_proposal_packet` is adjacent but not duplicative.
It governs a broader constitutional closure program. The selected concept set belongs
to runtime-proof, repo-shell, bootstrap, workflow, and observability refinement and
should remain a sibling packet with explicit cross-reference.
