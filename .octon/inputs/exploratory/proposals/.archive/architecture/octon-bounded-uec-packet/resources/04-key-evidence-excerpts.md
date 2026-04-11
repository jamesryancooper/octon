# Key Evidence Excerpts from the Live Repository

This file collects the excerpts most directly relevant to the proposal packet.

## 1. Active release lineage

**Path:** `/.octon/instance/governance/disclosure/release-lineage.yml`

> `active_release: release_id: 2026-04-09-uec-bounded-hardening-closure ... claim_scope: bounded-admitted-live-universe claim_status: complete`

Meaning: the repo currently exposes an active bounded complete claim.

## 2. Claim truth conditions

**Path:** `/.octon/framework/constitution/claim-truth-conditions.yml`

Key conditions include:

- `TC-04 canonical-authority`
- `TC-05 durable-run-semantics`
- `TC-06 classed-evidence`
- `TC-07 complete-proof`
- `TC-08 claim-calibrated-disclosure`

Key invalidators include:

- `host-only-approval-detected`
- `checkpoint-or-ledger-regression`
- `empty-evidence-classification`
- `proof-plane-failure`
- `authored-claim-outstates-ledgers`
- `support-universe-drift`
- `residual-ledger-disclosure-mismatch`

## 3. Registry and shim classification

**Path:** `/.octon/framework/constitution/contracts/registry.yml`

Highlights:

- `framework/constitution/**` kernel surfaces are active
- `instance/charter/**` workspace charter pair is active
- legacy constitutional surfaces are explicitly marked `historical-shim` or `subordinate-governance`
- objective / authority / runtime / assurance / disclosure / adapters / retention families are all active

## 4. Workspace charter canon

**Path:** `/.octon/instance/charter/README.md`

> `instance/charter/** is the canonical authored workspace-charter root for the live repository.`

> `workspace.md` and `workspace.yml` are the canonical pair.

> `instance/bootstrap/OBJECTIVE.md` and `instance/cognition/context/shared/intent.contract.yml` are historical non-runtime lineage artifacts.

## 5. Mission authority boundary

**Path:** `/.octon/instance/orchestration/missions/README.md`

> `mission remains the continuity container rather than the atomic execution unit`

> `consequential runs bind per-run objective contracts under state/control/execution/runs/<run-id>/**`

## 6. Authority family canon

**Approvals README**

> `state/control/execution/approvals/** is the canonical live control family`

> host labels, comments, checks, and env flags `never mint authority and cannot replace these artifacts`

**Exceptions README**

> `state/control/execution/exceptions/** is the canonical live control family`

> root-level aggregate lease files are not canonical and must not be recreated

**Revocations README**

> `state/control/execution/revocations/** is the canonical live control family`

> external comments or labels `do not revoke authority on their own`

## 7. Run evidence canon

**Path:** `/.octon/state/evidence/runs/README.md`

> `state/evidence/runs/ stores retained operational run evidence, receipts, and replay pointers.`

> `Canonical RunCards now live under state/evidence/disclosure/runs/<run-id>/`

## 8. Lab surface

**Path:** `/.octon/framework/lab/README.md`

> `framework/lab/** is Octon's authored lab surface for behavioral proof, replay, scenario design, shadow-run method, and adversarial discovery.`

> `The authored lab surface explicitly covers scenario proof, replay and shadow exercises, fault rehearsals, adversarial experiments.`

## 9. Observability surface

**Path:** `/.octon/framework/observability/README.md`

> `framework/observability/** is Octon's authored surface for normalized measurement, intervention accounting, and interpretable execution telemetry.`

> `Observability surfaces remain subordinate to the constitutional kernel and to the run root they summarize. They do not become a second control plane.`

## 10. Host adapter non-authority

**Path:** `/.octon/framework/engine/runtime/adapters/host/github-control-plane.yml`

> `description: Projects canonical PR-autonomy lane, blocker, and review status into GitHub checks, comments, and labels without minting authority.`

> `authority_mode: non_authoritative`

> `projection_sources: labels, comments, checks, workflow-env`

## 11. Sampled authority mismatch

**Run contract path:** `/.octon/state/control/execution/runs/uec-bounded-repo-shell-boundary-sensitive-20260409/run-contract.yml`

> `support_tier: boundary-sensitive`

**Approval request path:** `/.octon/state/control/execution/approvals/requests/uec-bounded-repo-shell-boundary-sensitive-20260409.yml`

> `target_id: governance:safe-stage-lease-revocation-exercise`

> `support_tier: repo-consequential`

> `reason_codes: LIVE_SAFE_STAGE_LEASE_REVOCATION_EXERCISE`

This is a direct ledger inconsistency.

## 12. Sampled exception residue

**Path:** `/.octon/state/control/execution/exceptions/leases/lease-uec-bounded-repo-shell-boundary-sensitive-20260409.yml`

> `service: governance/exercise`

> `host: example.invalid`

> `path_prefix: /safe-stage`

> `reason: Bounded safe-stage exception lease for revocation obedience exercise.`

## 13. Sampled revocation residue

**Path:** `/.octon/state/control/execution/revocations/revoke-uec-bounded-repo-shell-boundary-sensitive-20260409.yml`

> `notes: Active revocation proving the runtime must obey canonical revocation artifacts during the safe-stage exercise.`

## 14. Sampled instruction manifest thinness

**Path:** `/.octon/state/evidence/runs/uec-bounded-repo-shell-boundary-sensitive-20260409/instruction-layer-manifest.json`

The file contains only:

```json
{
  "schema_version": "instruction-layer-manifest-v1",
  "run_id": "uec-bounded-repo-shell-boundary-sensitive-20260409"
}
```

## 15. Sampled evidence classification emptiness

**Path:** `/.octon/state/evidence/runs/uec-bounded-repo-shell-boundary-sensitive-20260409/evidence-classification.yml`

> `artifacts: []`

This directly conflicts with closure-grade classed evidence expectations.
