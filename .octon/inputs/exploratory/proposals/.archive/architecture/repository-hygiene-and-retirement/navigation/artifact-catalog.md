# Artifact Catalog

This is an inventory of packet artifacts and their roles. It is an inventory
only, not a semantic authority surface.

| Path | Class | Role | Authority posture | Notes |
| --- | --- | --- | --- | --- |
| `proposal.yml` | root manifest | packet lifecycle authority | proposal-local authority | primary lifecycle authority |
| `architecture-proposal.yml` | root manifest | architecture subtype authority | proposal-local authority | secondary lifecycle authority |
| `README.md` | root doc | human entry point and summary | explanatory | never outranks manifests |
| `PACKET_MANIFEST.md` | root doc | reading order and packet inventory | explanatory | inventory and reading order only |
| `SHA256SUMS.txt` | root integrity artifact | file integrity aid | non-semantic | generated after packet assembly |
| `navigation/source-of-truth-map.md` | navigation | boundary and precedence map | proposal-local authority | defines authority separation inside the packet |
| `navigation/artifact-catalog.md` | navigation | packet inventory | explanatory | this file |
| `architecture/target-architecture.md` | working doc | target-state design | proposal-local design authority | intended end state |
| `architecture/current-state-gap-map.md` | working doc | repo-grounded current state and gaps | supporting design authority | current-state baseline |
| `architecture/source-to-remediation-matrix.md` | working doc | full traceability matrix | supporting design authority | one row per in-scope source item |
| `architecture/file-change-map.md` | working doc | path/surface-level change manifest | supporting design authority | create/modify/move/retire/delete plan |
| `architecture/implementation-plan.md` | working doc | phased implementation program | supporting design authority | ordered workstreams and exit criteria |
| `architecture/migration-cutover-plan.md` | working doc | profile selection and cutover model | supporting design authority | includes Profile Selection Receipt |
| `architecture/validation-plan.md` | working doc | validation families and evidence burden | supporting design authority | structural plus evidentiary |
| `architecture/acceptance-criteria.md` | working doc | proof contract for landing | supporting design authority | acceptance gates |
| `architecture/closure-certification-plan.md` | working doc | closure burden and pass/fail logic | supporting design authority | closure-specific proof contract |
| `architecture/follow-up-gates.md` | working doc | deferred and future hardening gates | supporting design authority | explicit residual discipline |
| `architecture/conformance-card.md` | working doc | compact conformance snapshot | supporting design authority | reviewer quick-look artifact |
| `resources/input-baseline-and-source-normalization.md` | resource | normalized source inventory and conflict handling | supporting | source extraction and scope control |
| `resources/source-register.md` | resource | complete source register | supporting | every user input and material repo artifact |
| `resources/risk-register.md` | resource | risk inventory and mitigations | supporting | non-authoritative risk view |
| `resources/assumptions-and-blockers.md` | resource | assumptions, blockers, and nonblocking concerns | supporting | explicit blocker handling |
| `resources/evidence-plan.md` | resource | retained evidence burden | supporting | evidence families and sufficiency tests |
| `resources/rejection-ledger.md` | resource | rejected alternatives and rationale | supporting | prevents design drift |
| `resources/source_inputs/01_user_request_rust_shell_cleanup.md` | resource | user request reproduction | non-authoritative | traceability only |
| `resources/source_inputs/02_user_request_transitional_surfaces.md` | resource | user request reproduction | non-authoritative | traceability only |
| `resources/source_inputs/03_user_request_repo_hygiene_capability_spec.md` | resource | user request reproduction | non-authoritative | traceability only |
| `resources/source_inputs/04_user_request_proposal_packet_generation.md` | resource | user request reproduction | non-authoritative | traceability only |
| `resources/repo_evidence/01_ingress_constitutional_and_profile_excerpts.md` | resource | repo grounding excerpt set | non-authoritative | live repo outranks packet-local copy |
| `resources/repo_evidence/02_super_root_and_proposal_contract_excerpts.md` | resource | repo grounding excerpt set | non-authoritative | live repo outranks packet-local copy |
| `resources/repo_evidence/03_runtime_command_support_and_workflow_excerpts.md` | resource | repo grounding excerpt set | non-authoritative | live repo outranks packet-local copy |
| `resources/repo_evidence/04_retirement_and_ablation_spine_excerpts.md` | resource | repo grounding excerpt set | non-authoritative | live repo outranks packet-local copy |
| `resources/repo_evidence/05_runtime_workspace_and_ci_excerpts.md` | resource | repo grounding excerpt set | non-authoritative | live repo outranks packet-local copy |
| `resources/repo_evidence/06_proposal_workspace_observations.md` | resource | repo grounding excerpt set | non-authoritative | live repo outranks packet-local copy |
