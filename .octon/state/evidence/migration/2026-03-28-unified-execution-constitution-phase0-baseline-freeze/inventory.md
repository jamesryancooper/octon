# Unified Execution Constitution Phase 0 Inventory

## Baseline Posture

- Governing input is the active
  `octon-unified-execution-constitution-cutover` packet plus its appended
  repository-grounded audit.
- This Phase 0 record is retrospective against the live repo on 2026-03-28.
  It does not attempt to recreate an earlier pre-cutover repository state.
- The packet's Phase 0 requirements are satisfied here through durable
  migration evidence, a frozen-input manifest, and a bounded baseline
  HarnessCard v0 outside the proposal workspace.

## Live Authority Surfaces

### Constitutional kernel and ingress

- `/.octon/framework/constitution/**` is active and already extracted. The
  kernel includes the charter, charter manifest, dual precedence,
  obligations, ownership roles, support-target schema, and contract registry.
- `/.octon/framework/constitution/contracts/registry.yml` already activates
  the `objective`, `authority`, `runtime`, `assurance`, `disclosure`,
  `adapters`, and `retention` families. This materially exceeds the packet's
  original pre-Phase-1 baseline.
- `/.octon/framework/constitution/charter.yml` still declares
  `adoption_state.wave: 6` and `change_profile: transitional`, so the live
  constitutional manifest still advertises a staged model rather than a fully
  settled target-state claim.
- `/.octon/instance/ingress/AGENTS.md` is constitution-first, but its live
  read order still includes `/.octon/framework/cognition/_meta/architecture/specification.md`
  and `/.octon/framework/cognition/governance/principles/README.md` after the
  constitutional kernel. Those legacy interpretive surfaces remain part of the
  operator path that later extraction or simplification work must account for.
- The live workspace objective pair remains
  `/.octon/instance/bootstrap/OBJECTIVE.md` plus
  `/.octon/instance/cognition/context/shared/intent.contract.yml`. The
  packet's dedicated `instance/charter/**` workspace-charter root is absent.
- `/.octon/octon.yml` runtime resolution still binds workspace-objective inputs
  to those bootstrap and cognition paths, so the current objective layer is
  still mis-bounded relative to the packet's target-state architecture.

### Governance, mission, and adapter authority

- `/.octon/instance/governance/support-targets.yml` is active and already
  drives the support-target matrix, adapter conformance criteria, and adapter
  bounds for repo-local execution claims.
- `/.octon/instance/orchestration/missions/**` remains the live mission
  authority and continuity container for long-horizon work.
- `/.octon/framework/engine/runtime/adapters/{host,model}/**` is live. The
  `github-control-plane` adapter explicitly declares itself
  non-authoritative and projection-only.
- `/.octon/state/control/execution/approvals/**` exists as the canonical live
  control family, but the current root contains only `README.md` plus
  `.gitkeep` placeholders under `requests/` and `grants/`. No materialized
  `ApprovalRequest` or `ApprovalGrant` artifacts were found.
- `/.octon/state/control/execution/exceptions/leases.yml` and
  `/.octon/state/control/execution/revocations/grants.yml` exist, so the
  exception and revocation control families are present but sparsely populated.
- `/.octon/instance/governance/disclosure/**` is absent. Live disclosure is
  retained under evidence roots only, which matches the audit's mis-bounded
  disclosure finding.

## Live Runtime Surfaces

- `/.octon/state/control/execution/runs/**` is the live per-run control root.
  Two normalized run control roots are present:
  `run-wave3-runtime-bridge-20260327` and
  `run-wave4-benchmark-evaluator-20260327`.
- Each normalized run control root contains the expected packet-aligned shape:
  `run-contract.yml`, `stage-attempts/initial.yml`, `checkpoints/bound.yml`,
  `runtime-state.yml`, and `rollback-posture.yml`.
- `/.octon/state/continuity/runs/**` contains two matching run continuity
  roots, showing that run resumability is already separated from mission
  continuity.
- `/.octon/state/evidence/runs/**` is active and contains both normalized
  retained run evidence for the two seeded run bundles and a larger set of
  older ACP and audit receipt roots. The live repo therefore mixes the newer
  run-root model with legacy retained evidence lineage.
- `/.octon/state/evidence/external-index/**` exists, but the only file present
  is `README.md`. The external immutable replay index root is structurally
  reserved and currently unexercised.

## Live Proof And Evidence Surfaces

- `/.octon/framework/assurance/{structural,functional,behavioral,maintainability,recovery,evaluators}/**`
  exists, so the proof-plane families are structurally present.
- At the top level, those proof-plane families remain mostly README-only plus a
  small amount of routing metadata. The live proof-plane structure is real but
  still thin compared with the packet's stronger target-state proof posture.
- `/.octon/framework/lab/**` and `/.octon/state/evidence/lab/**` are active.
  Before this Phase 0 work, the retained lab evidence root already contained:
  - 2 HarnessCard YAML artifacts
  - 2 scenario-proof bundles
  - 1 evaluator-review artifact
  - 1 benchmark summary bundle
- `/.octon/state/evidence/control/execution/**` already contains four
  authority decision or grant-bundle artifacts at the root plus additional
  control-mutation evidence receipts.
- `/.octon/instance/governance/contracts/disclosure-retention.yml` points the
  canonical disclosure roots at retained evidence:
  run cards under `state/evidence/runs/<run-id>/disclosure`,
  HarnessCards under `state/evidence/lab/harness-cards`, and external replay
  indexing under `state/evidence/external-index`.

## Phase 0 Findings

- The live repository is already past the packet's original Phase 0 baseline.
  Constitutional extraction, authority families, runtime families, disclosure
  contracts, adapter manifests, and retention roots already exist in durable
  repo surfaces.
- The strongest remaining Phase 1-era architectural blocker is objective and
  interpretive mis-bounding, not missing kernel files. The live workspace
  objective still resolves through bootstrap and cognition paths, and ingress
  still includes legacy cognition architecture/principles surfaces in its
  critical read path.
- Approval control roots are canonical in shape but under-populated in live
  artifacts. Requests and grants remain placeholder-only, which limits how
  much operational authority can currently be evidenced from those roots.
- Authored disclosure is still missing. HarnessCards exist only as retained lab
  evidence, not under an authored `instance/governance/disclosure/**` source
  root.
- External replay indexing remains structural only. The canonical root exists,
  but no immutable replay index entries were found.

## Phase 0 Blockers For Later Phases

- `instance/charter/**` does not exist, so the workspace objective layer is not
  yet re-homed into the packet's target-state authority layout.
- `instance/governance/disclosure/**` does not exist, so HarnessCard authorship
  remains evidence-only.
- The constitutional manifest still advertises wave-6 transitional adoption.
- Ingress still depends on cognition umbrella/principles surfaces after the
  constitutional kernel, so constitutional extraction and simplification are
  not yet fully complete.
- Approval request/grant control roots have canonical placement but no live
  request or grant artifacts.
- The external immutable replay index root is empty beyond its README.
