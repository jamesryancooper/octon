# Packet Manifest

This manifest enumerates the proposal packet artifacts for `octon-architecture-10of10-remediation`.

## Root files

| File | Role |
|---|---|
| `README.md` | Packet purpose, non-authority notice, reading order, closure intent. |
| `proposal.yml` | Lifecycle, scope, promotion targets, non-goals, source authorities. |
| `architecture-proposal.yml` | Machine-readable architecture decisions and dispositions. |
| `PACKET_MANIFEST.md` | This manifest. |
| `SHA256SUMS.txt` | Materialized checksums for packet artifacts. |

## Navigation

| File | Role |
|---|---|
| `navigation/source-of-truth-map.md` | Proposal-local precedence and non-authority map. |
| `navigation/artifact-catalog.md` | Catalog of every packet artifact and intended reviewer. |

## Architecture

| File | Role |
|---|---|
| `architecture/target-architecture.md` | True 10/10 target-state architecture. |
| `architecture/current-state-gap-map.md` | Current strengths, limitations, score drags, remedies. |
| `architecture/concept-coverage-matrix.md` | Evaluation finding to remediation/proof trace. |
| `architecture/file-change-map.md` | Concrete create/modify/relocate/delete/archive/regenerate/validate paths. |
| `architecture/implementation-plan.md` | Workstreams, sequencing, gates, evidence emission points. |
| `architecture/migration-cutover-plan.md` | Hybrid bounded cutover plan. |
| `architecture/validation-plan.md` | Deterministic validators and closure validation. |
| `architecture/acceptance-criteria.md` | Falsifiable 10/10 criteria. |
| `architecture/cutover-checklist.md` | Execution and signoff checklist. |
| `architecture/closure-certification-plan.md` | Required closure evidence and final review materials. |
| `architecture/execution-constitution-conformance-card.md` | Constitutional conformance assessment for the target state. |

## Resources

| File | Role |
|---|---|
| `resources/full-architectural-evaluation.md` | Full prior architecture evaluation preserved as source artifact. |
| `resources/repository-baseline-audit.md` | Repo-grounded baseline audit of current architecture. |
| `resources/coverage-traceability-matrix.md` | Deficit-to-change-to-validator-to-evidence trace. |
| `resources/evidence-plan.md` | Retained evidence, replay, disclosure, RunCard, HarnessCard plan. |
| `resources/decision-record-plan.md` | Required durable decision records. |
| `resources/risk-register.md` | Architectural/runtime/migration/proof risks. |
| `resources/assumptions-and-blockers.md` | Grounded assumptions and unresolved blockers. |
| `resources/rejection-ledger.md` | Alternatives explicitly rejected. |

## Additional generated packaging artifact

| File | Role |
|---|---|
| `PACKET_CONTENTS.md` | Generated transcript of all packet files in the requested `FILE:` format, excluding `SHA256SUMS.txt` to avoid recursive hash churn. |
