# Artifact Catalog

| Artifact | Type | Purpose | Read after |
|---|---|---|---|
| `proposal.yml` | Manifest | Shared proposal authority and promotion targets | first |
| `architecture-proposal.yml` | Subtype manifest | Architecture-specific scope and decision type | `proposal.yml` |
| `README.md` | Orientation | Executive purpose and reading order | manifests |
| `PACKET_MANIFEST.md` | Manifest | Packet inventory and closure manifest | manifests |
| `SHA256SUMS.txt` | Checksum manifest | Packet-local checksum validation | after edits |
| `architecture/target-architecture.md` | Architecture | Desired implementation shape for lifecycle enforcement | baseline/gap docs |
| `architecture/current-state-gap-map.md` | Architecture | Current coverage versus required target | baseline audit |
| `architecture/concept-coverage-matrix.md` | Architecture | Concepts, repo coverage, target disposition | gap map |
| `architecture/file-change-map.md` | Architecture | Expected durable repository changes | target architecture |
| `architecture/implementation-plan.md` | Execution plan | Ordered work plan | file-change map |
| `architecture/migration-cutover-plan.md` | Cutover plan | Safe transition and compatibility handling | implementation plan |
| `architecture/validation-plan.md` | Assurance plan | Validator and test design | implementation plan |
| `architecture/acceptance-criteria.md` | Closure criteria | Promotion-ready acceptance bar | validation plan |
| `architecture/cutover-checklist.md` | Checklist | Operator-ready cutover sequence | validation plan |
| `architecture/closure-certification-plan.md` | Closure plan | Evidence required before archive/removal | acceptance criteria |
| `architecture/execution-constitution-conformance-card.md` | Governance card | Confirms Octon boundary conformance | target architecture |
| `resources/repository-baseline-audit.md` | Resource | Live-repo baseline relevant to this step | source map |
| `resources/current-runtime-surface-inventory.md` | Resource | Runtime surface inventory used for implementation scoping | baseline audit |
| `resources/implementation-gap-analysis.md` | Resource | Blocking factors and remediation | baseline audit |
| `resources/full-architectural-evaluation.md` | Resource | Focused architectural evaluation | baseline audit |
| `resources/concept-extraction-output.md` | Resource | Extracted source concepts carried into the packet | source artifact |
| `resources/concept-verification-output.md` | Resource | Verification of extracted concepts against repo evidence | concept extraction |
| `resources/coverage-traceability-matrix.md` | Resource | Concept -> repo -> gap -> validation linkage | gap analysis |
| `resources/assumptions-and-blockers.md` | Resource | Assumptions, blockers, and closure posture | implementation plan |
| `resources/decision-record-plan.md` | Resource | Planned durable decision-record surface | target architecture |
| `resources/evidence-plan.md` | Resource | Retained proof requirements | validation plan |
| `resources/risk-register.md` | Resource | Risks and mitigations | implementation plan |
| `resources/rejection-ledger.md` | Resource | Explicit non-adoptions | full evaluation |
| `resources/source-artifact.md` | Resource | Packet-local source artifact and provenance | first |
| `navigation/artifact-catalog.md` | Navigation | Packet inventory for archive completeness checks | manifests |
| `navigation/source-of-truth-map.md` | Navigation | Authority map distinguishing durable surfaces from proposal lineage | first |
