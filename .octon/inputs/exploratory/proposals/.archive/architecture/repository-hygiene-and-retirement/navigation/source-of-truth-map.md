# Source of Truth Map

This file defines the proposal-local precedence model, authority boundaries,
and evidence posture for `repository-hygiene-and-retirement`. It does not make
this proposal a canonical repository authority.

## Durable external authorities

| Concern | Durable source of truth | Why it outranks the packet |
| --- | --- | --- |
| Ingress read order, constitutional kernel, and profile-selection defaults | `AGENTS.md`, `/.octon/instance/ingress/AGENTS.md`, `/.octon/framework/constitution/**`, `/.octon/instance/charter/workspace.{md,yml}`, `/.octon/framework/agency/runtime/agents/orchestrator/AGENT.md` | These define the canonical constitutional read set, profile-selection expectations, and operator/boundary posture. |
| Super-root topology, authority classes, and generated/input boundaries | `/.octon/README.md`, `/.octon/framework/cognition/_meta/architecture/specification.md`, `/.octon/octon.yml` | These define the live authority/evidence/derived-view model that the proposal must preserve. |
| Proposal-system contract | `/.octon/inputs/exploratory/proposals/README.md`, `/.octon/framework/scaffolding/governance/patterns/proposal-standard.md`, `/.octon/framework/scaffolding/governance/patterns/architecture-proposal-standard.md` | These define the packet path, manifest fields, lifecycle rules, and minimum file obligations. |
| Proposal validation floor | `/.octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh`, `/.octon/framework/assurance/runtime/_ops/scripts/validate-architecture-proposal.sh` | These provide the live validator-backed minimum for proposal correctness. |
| Repository-hygiene lifecycle governance | `/.octon/instance/governance/contracts/retirement-policy.yml`, `/.octon/instance/governance/contracts/retirement-registry.yml`, `/.octon/instance/governance/contracts/retirement-review.yml`, `/.octon/instance/governance/contracts/drift-review.yml`, `/.octon/instance/governance/contracts/ablation-deletion-workflow.yml`, `/.octon/instance/governance/retirement-register.yml`, `/.octon/instance/governance/retirement/claim-gate.yml`, `/.octon/instance/governance/disclosure/release-lineage.yml` | These already own build-to-delete registration, review, ablation, and claim posture. |
| Runtime command and support boundaries | `/.octon/instance/capabilities/runtime/commands/README.md`, `/.octon/instance/capabilities/runtime/commands/manifest.yml`, `/.octon/instance/governance/support-targets.yml`, `/.octon/instance/capabilities/runtime/packs/registry.yml` | These determine where a repo-native cleanup command can live and which packs/workload classes are already admitted. |

## Proposal-local authorities

| Artifact | Role | Authority level within the packet |
| --- | --- | --- |
| `proposal.yml` | packet identity, scope, lifecycle, promotion targets, exit contract | highest proposal-local authority |
| `architecture-proposal.yml` | architecture subtype scope and decision classification | secondary proposal-local authority |
| `navigation/source-of-truth-map.md` | explicit proposal-local precedence and boundary map | tertiary proposal-local authority |
| `architecture/target-architecture.md` | chosen next-state design and operating model | primary narrative design surface |
| `architecture/acceptance-criteria.md` | proof contract for considering the architecture landed | binding within the packet |
| `architecture/implementation-plan.md` | workstream and sequencing plan | operational planning within the packet |
| `architecture/migration-cutover-plan.md` | profile selection receipt and cutover contract | operational migration authority within the packet |
| `architecture/validation-plan.md`, `architecture/closure-certification-plan.md` | validation and closeout burden | binding within the packet |
| `resources/*.md` | supporting normalization, evidence, risk, and rejection records | supporting but not authoritative over manifests |
| `README.md` and `PACKET_MANIFEST.md` | human entry point and reading order | explanatory only |
| `navigation/artifact-catalog.md` | inventory only | lowest proposal-local authority |

## Derived or non-authoritative surfaces

| Surface | Status | Rule |
| --- | --- | --- |
| `/.octon/generated/proposals/registry.yml` | generated discovery projection | may list this proposal, but never outranks `proposal.yml` or `architecture-proposal.yml` |
| copied resources under `resources/source_inputs/**` | faithful reproductions of user inputs | support traceability only |
| copied or excerpted repo evidence under `resources/repo_evidence/**` | retained packet-local evidence | helpful for review, never live repo authority |
| packet checksums in `SHA256SUMS.txt` | integrity aid | not semantic authority |

## Retained evidence surfaces that matter to this proposal

The architecture proposed here relies on the live distinction between
operational truth/evidence and derived projections. The most important retained
evidence families for this packet are:

- `/.octon/state/evidence/runs/**`
- `/.octon/state/evidence/validation/publication/build-to-delete/**`
- `/.octon/state/evidence/governance/build-to-delete/**`
- `/.octon/state/evidence/disclosure/releases/**`

This packet may refer to those evidence roots as proof obligations or future
output locations, but it does not itself become evidence authority for them.

## Boundary rules

1. Only `framework/**` and `instance/**` are authored authority.
2. `state/**` is authoritative only as operational truth and retained evidence.
3. `generated/**` is never source of truth.
4. Raw `inputs/**` must never become direct runtime or policy dependencies.
5. Active proposals may not mix `.octon/**` and non-`.octon/**` promotion
   targets. This packet therefore keeps official promotion targets under
   `.octon/**` and models `.github/workflows/**` edits as dependent
   implementation surfaces.
6. This proposal may shape durable implementation, but no durable target may
   depend on the proposal path after promotion.
7. Newly detected transitional residue must be routed into the existing
   retirement/build-to-delete governance spine rather than a new registry.

## Conflict resolution order for this packet

1. Durable constitutional, architecture, support-target, and retirement
   authorities in the live repo.
2. `proposal.yml`
3. `architecture-proposal.yml`
4. `architecture/target-architecture.md`
5. `architecture/acceptance-criteria.md`
6. `architecture/implementation-plan.md`
7. other `architecture/*.md`
8. `resources/*.md`
9. `README.md`
10. `navigation/artifact-catalog.md`
