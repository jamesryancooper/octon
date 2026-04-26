# Operator Run-Health Read Model Design

## Purpose

The run-health read model gives a serious solo operator a compact answer to:

- Is this run healthy?
- Is it safe to continue?
- Is it waiting on me?
- Is it unsupported or stale?
- Has authorization been revoked?
- Is evidence complete?
- Can it be closed?
- What should I do next?

## Authority status

Run health is generated-only and non-authoritative. It must include:

```yaml
authority:
  classification: generated_read_model_non_authoritative
  may_authorize: false
  may_widen_support: false
```

## Proposed file placement

```text
.octon/generated/cognition/projections/materialized/runs/<run_id>/health.yml
.octon/generated/cognition/projections/materialized/runs/index.yml
```

## Required fields

```yaml
schema_version: run-health-read-model-v1
run_id: <id>
generated_at: <timestamp>
freshness:
  status: fresh|stale|unknown
  expires_at: <timestamp>
source_refs:
  run_manifest: <path>
  events_journal: <path>
  runtime_state: <path>
  authority_bundle: <path>
  evidence_root: <path>
  support_reconciliation: <path>
  rollback_posture: <path>
health:
  status: healthy|review_required|awaiting_approval|blocked|stale|unsupported|revoked|evidence_incomplete|rollback_required|closure_ready
  summary: <plain language operator summary>
  next_required_action: <operator action or none>
support:
  tuple: <support tuple ref>
  route_status: allow|stage_only|deny|unknown
  pack_status: allow|stage_only|deny|unknown
authorization:
  status: authorized|awaiting_approval|revoked|denied|unknown
  active_grants: []
  open_approvals: []
  active_exceptions: []
  active_revocations: []
evidence:
  completeness: complete|incomplete|unknown
  missing_required: []
rollback:
  status: ready|required|unavailable|unknown
closure:
  status: not_ready|ready|blocked|unknown
diagnostics: []
```

## Health derivation rules

- If support reconciliation fails, health is `unsupported` or `blocked`.
- If route/proof freshness is stale, health is `stale`.
- If revocation applies, health is `revoked`.
- If approval is missing, health is `awaiting_approval`.
- If evidence required for closure is missing, health is `evidence_incomplete`.
- If rollback posture is required and absent, health is `rollback_required`.
- If lifecycle is succeeded and all evidence/disclosure/rollback checks pass,
  health is `closure_ready`.
- If inputs disagree, health must be `review_required` or `blocked` with
  diagnostics.

## Validation rule

A run-health artifact is invalid if it lacks source refs, source digests,
freshness metadata, non-authority classification, or diagnostics for known
input disagreement.
