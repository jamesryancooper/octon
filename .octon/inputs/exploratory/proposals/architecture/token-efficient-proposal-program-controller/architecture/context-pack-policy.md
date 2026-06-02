# Proposal Lifecycle Context-Pack Policy

## Purpose

Make lifecycle context construction deterministic, auditable, budgeted, and source-class preserving. This policy reuses Context Pack Builder inclusion modes: `full`, `excerpt`, `summary`, `handle-only`, `digest-only`, and `omitted`.

## Global Rules

- Every source record must include path, digest, source class, authority label, inclusion mode, bytes included, estimated tokens, and model-visible flag.
- Every omission must record an omission reason and escalation condition.
- Generated and proposal-local files must never be marked as authority.
- Raw logs are retained evidence but handle-only by default.
- Context compaction is valid only when retained model-visible serialization and hash are preserved.
- Authorization fails closed on missing, stale, invalid, or unverifiable required context.

## Source Inclusion Defaults

| Source | Default Inclusion | Reason / Escalation |
|---|---|---|
| parent proposal manifest | full | proposal.yml is proposal-local lifecycle source; include full for parent start and completion. |
| child proposal manifest | full | Child proposal.yml is child-local lifecycle source; include full for child route. |
| subtype manifest | full | Architecture subtype manifest is lifecycle source for proposal subtype. |
| child registry | full for parent start; digest/summary for child | Required to plan program; children need only own entry and dependency vector. |
| parent source lineage docs | summary | Full only on source-trace dispute, missing digest, or architecture review escalation. |
| child packet contract | summary or excerpt | Full only when child authority boundary is disputed. |
| source traceability matrix | summary; handle-only after digest stable | Full only for gap-map or acceptance review. |
| proposal standard | short governance capsule | Full only on validator dispute or proposal standard ambiguity. |
| subtype standard | short subtype capsule | Full only on architecture subtype ambiguity. |
| runtime contracts | excerpt | Only relevant contract sections for target write scope. |
| lifecycle contracts | excerpt | Include route/state sections required for current transition. |
| prompt assets | digest-only plus capsule | Full only under prompt expansion policy triggers. |
| reference assets | handle-only/digest-only | Full only on route-specific ambiguity. |
| shared-reference assets | handle-only/digest-only | Full only on governance/source conflict. |
| generated effective tree | digest-only freshness handle | Never authority; full tree omitted by default. |
| generated proposal registry | digest-only or selected entry | Registry is discovery-only; cannot replace manifests. |
| run-health receipt | summary/failing-slice handle | Full receipt only on health dispute. |
| publication freshness receipt | manifest handle | Full only on freshness conflict. |
| prior child receipts | structured fields + digest | Full only on child outcome dispute. |
| raw stdout/stderr | handle-only | Use raw-log-summary and failing slices; raw only on audit/escalation. |
| program plan | handle-only | Planner uses planner-state; full plan retained audit only. |
| planner state | full | Compact primary planner input. |
| blocker ledger | full for recovery; summary for normal run | Includes latest blocker deltas and fingerprints. |
| validator manifests | full | Machine-readable pass/fail counts and failing slices. |
| archived proposal packets | digest-only/indexed | Full only on historical precedent request or archive dispute. |
| closeout receipts | closeout projection + digest | Full only on closeout dispute. |
| rollback refs | full/excerpt | Required before closeout or material execution. |
| support-proof evidence | structured refs + summary | Full evidence only on support-proof conflict. |

## Stage-Specific Rules

### Parent Start

Full: parent `proposal.yml`, `architecture-proposal.yml`, child registry.

Summary: target architecture, source findings, source traceability.

Digest-only: generated proposal registry, generated effective tree.

Omitted: raw logs, sibling child packet bodies unless selected.

### Child Dispatch

Full: child manifests, child-specific handoff capsule.

Summary/excerpt: parent objective capsule, dependency vector, target write-scope map, relevant contracts.

Handle-only: parent source docs, sibling receipts, raw evidence.

### Implementation Planning

Full/excerpt: target files, relevant runtime/lifecycle contracts, implementation plan.

Summary: artifact index, repo authority graph slice, validator matrix.

Handle-only: raw logs and prior full receipts.

### Verification

Full: validator result manifest, failing slices.

Handle-only: stdout/stderr, raw evidence.

Digest-only: generated freshness handles when pass.

### Recovery

Full: blocker ledger, latest recovery delta, failing-slice manifest.

Handle-only: old recovery logs and stale receipts.

### Promotion

Full/excerpt: promotion route contract, promotion evidence binding, rollback refs.

Structured refs: child receipt digests and evidence refs.

### Archive/Closeout

Full: closeout projection, archive metadata, rollback refs.

Summary: child status table, conformance/drift status.

Handle-only: full closeout receipt and full raw evidence.

## Omission Reasons

Use these omission reasons: `over_budget`, `stale`, `non_authoritative_disallowed`, `unsupported_surface_class`, `trust_rejected`, `duplicate_or_shadowed`, `unresolved_handle`, `explicit_policy_exclusion`, `redacted_secret_or_sensitive`, `support_target_disallowed`, `stage_irrelevant`, `annex_not_cited`, `raw_evidence_handle_only`.

## Escalation Conditions

Escalate when required source is omitted, digest drift appears, context hash cannot be reconstructed, generated freshness is stale, authority boundary is ambiguous, validator output conflicts with compact manifest, or operator requests audit expansion.
