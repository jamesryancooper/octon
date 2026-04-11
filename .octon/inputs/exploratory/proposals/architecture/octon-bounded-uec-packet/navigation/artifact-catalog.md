# Artifact Catalog

This is an inventory of packet artifacts and their roles. It is an inventory
only, not a semantic authority surface.

| Path | Class | Role | Authority posture | Notes |
| --- | --- | --- | --- | --- |
| `proposal.yml` | root manifest | packet lifecycle authority | proposal-local authority | primary lifecycle authority |
| `architecture-proposal.yml` | root manifest | architecture subtype authority | proposal-local authority | secondary lifecycle authority |
| `README.md` | root doc | human entry point and summary | explanatory | never outranks manifests |
| `00-master-proposal-packet.md` | root doc | primary closure-hardening packet | proposal-local design authority | main narrative and decision record |
| `navigation/source-of-truth-map.md` | navigation | boundary and precedence map | proposal-local authority | defines authority separation inside the packet |
| `navigation/artifact-catalog.md` | navigation | packet inventory | explanatory | this file |
| `architecture/target-architecture.md` | working doc | target-state summary | proposal-local design authority | condensed end-state definition |
| `architecture/acceptance-criteria.md` | working doc | proof contract for landing | proposal-local design authority | bounded recertification gates |
| `architecture/implementation-plan.md` | working doc | staged implementation program | proposal-local design authority | ordered workstreams and receipts |
| `specs/01-target-state-specification.md` | working doc | detailed target-state definition | supporting design authority | full invariants and closure criteria |
| `specs/02-path-specific-remediation-specs.md` | working doc | path-specific remediation plan | supporting design authority | exact surface-level changes |
| `specs/03-validator-and-evidence-program.md` | working doc | validator and evidence contract | supporting design authority | certification burden |
| `specs/04-claim-governance-and-disclosure-plan.md` | working doc | claim-state and disclosure plan | supporting design authority | release and disclosure posture |
| `specs/05-migration-cutover-recertification-checklists.md` | working doc | migration and recertification checklist | supporting design authority | cutover execution control |
| `traceability/01-master-closure-blocker-register.md` | traceability | master blocker register | supporting authority | closure blocker control surface |
| `traceability/02-audit-finding-to-remediation-to-validator-to-evidence-matrix.md` | traceability | end-to-end crosswalk | supporting authority | audit-to-fix traceability |
| `traceability/03-file-and-workflow-change-register.md` | traceability | file and workflow change manifest | supporting authority | durable change inventory |
| `resources/01-full-implementation-audit.md` | resource | acceptance-delta audit baseline | supporting | retained audit basis |
| `resources/02-repo-grounding-evidence-map.md` | resource | canonical surface map | supporting | repo-grounding aid |
| `resources/03-current-claim-vs-target-state-delta.md` | resource | concise current-to-target delta | supporting | summary of remaining gaps |
| `resources/04-key-evidence-excerpts.md` | resource | key live evidence excerpts | supporting | review aid, not live authority |
