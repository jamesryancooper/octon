# Repository baseline audit

Prepared on 2026-04-09 against `https://github.com/jamesryancooper/octon` @ `main`.

## Scope and method

This audit was performed against the live public repository, not against prior research assumptions. Because no narrower selected-concept subset was supplied in the conversation, the full extracted concept set from the immediately prior extraction run is treated as the **in-scope concept** set for this packet.

## Verified authority and topology anchors

The following anchors were inspected first and treated as the primary baseline:

1. `README.md`
2. `/.octon/README.md`
3. `/.octon/AGENTS.md`
4. `/.octon/instance/ingress/AGENTS.md`
5. `/.octon/octon.yml`
6. `/.octon/framework/manifest.yml`
7. `/.octon/instance/manifest.yml`
8. `/.octon/framework/cognition/_meta/architecture/specification.md`
9. `/.octon/framework/constitution/**`
10. `/.octon/framework/overlay-points/registry.yml`
11. relevant `/.octon/instance/**`
12. relevant `/.octon/state/**`
13. relevant `/.octon/generated/**`
14. active proposal packet convention under `/.octon/inputs/exploratory/proposals/architecture/**`

## Observed current-state architecture

### Super-root and class roots

The repo root README and `.octon/README.md` both confirm a single `/.octon/` super-root and the canonical class roots:

- `framework/`
- `instance/`
- `inputs/`
- `state/`
- `generated/`

### Authority model

The same anchors confirm the expected authority model:

- `framework/**` and `instance/**` are authored authority.
- `state/**` is authoritative as operational truth and retained evidence.
- `generated/**` is derived-only.
- `inputs/**` is exploratory/additive and must not become direct runtime or policy truth.

### Constitutional kernel and ingress

The repo matches the expected constitutional pattern:

- supreme repo-local control regime under `/.octon/framework/constitution/**`
- umbrella architecture contract at `/.octon/framework/cognition/_meta/architecture/specification.md`
- projected ingress at `/.octon/AGENTS.md`
- canonical internal ingress at `/.octon/instance/ingress/AGENTS.md`

### State-class organization

`/.octon/state/` is materially organized into:

- `state/control/**`
- `state/evidence/**`
- `state/continuity/**`

### Generated publication model

`/.octon/generated/` currently includes:

- `generated/effective/**`
- `generated/cognition/**`
- `generated/proposals/**`

These align with the expected derived/publication/read-model posture.

### Overlay model

The overlay registry is present under `/.octon/framework/overlay-points/registry.yml`, and the instance manifest currently enables the following overlay points that are directly relevant to this packet:

- `instance-governance-policies`
- `instance-governance-contracts`
- `instance-governance-adoption`
- `instance-governance-retirement`
- `instance-governance-exclusions`
- `instance-governance-capability-packs`
- `instance-governance-decisions`
- `instance-agency-runtime`
- `instance-assurance-runtime`

This is important because it means the recommended repo-specific changes can stay inside already-declared overlay and instance-native authority surfaces.

## Relevant current subsystems already present

### Cognition / context

Observed existing surfaces show that Octon already embodies a strong progressive-disclosure design:

- `/.octon/instance/cognition/context/index.yml`
- `/.octon/instance/cognition/context/shared/**`
- ADR `ADR-036-cognition-sidecar-section-index-architecture.md`

This is a material current capability, not proposal-only text.

### Mission / execution control

Observed mission and run surfaces show that reversible autonomy is already highly formalized:

- `/.octon/instance/orchestration/missions/registry.yml`
- `/.octon/framework/constitution/contracts/objective/run-contract-v1.schema.json`
- `/.octon/framework/constitution/contracts/objective/stage-attempt-v1.schema.json`
- `/.octon/state/control/execution/missions/**`
- `/.octon/state/control/execution/runs/**`

### Evidence / disclosure / observability

Observed evidence and disclosure surfaces show that Octon already has a sophisticated proof model:

- `/.octon/state/evidence/runs/**`
- `/.octon/state/evidence/disclosure/releases/**`
- `/.octon/framework/constitution/contracts/disclosure/**`
- `/.octon/framework/constitution/contracts/assurance/**`

This is especially relevant for the evidence-bundles concept, which is already materially embodied.

### Assurance / review

Observed assurance contracts already include evaluator review, evaluator independence, hidden-check policies, and proof-plane reporting. This means review governance exists, but it is not yet clearly expressed as a finding/disposition pair.

### Build-to-delete / remediation / ablation

Observed ADR and workflow surfaces already encode recurring structural hardening and ablation-driven deletion:

- ADR `ADR-083-build-to-delete-as-a-first-class-invariant.md`
- `/.octon/framework/constitution/contracts/repo/ablation-deletion-workflow.yml`

These provide partial but not complete coverage for failure-driven hardening.

## Proposal-packet convention check

### Observed active packet layout

The currently active architecture packet under:

`/.octon/inputs/exploratory/proposals/architecture/octon_uec_remediation_packet/`

uses a numbered Markdown layout (`00_...md` through `11_...md`) plus a `12_resources/` folder.

### Repository Drift Note

This differs from the packet shape requested in the present user instruction, which explicitly requires a manifest-governed packet with:

- `proposal.yml`
- `architecture-proposal.yml`
- `PACKET_MANIFEST.md`
- `SHA256SUMS.txt`
- named `architecture/`, `navigation/`, and `resources/` directories

Because the live repo does **not** presently expose that packet convention, this packet treats the requested structure as an **externalized, archive-ready proposal shape** rather than as evidence of existing repo convention. The packet is still rooted under the requested repo path, but this drift should be acknowledged if the packet is ever promoted into the repository.

## Existing packet overlap check

The observed active packet focuses on UEC remediation and adjacent constitutional/runtime normalization. It is not the same problem-space as the present concept-integration packet. Therefore, this packet is authored as a **new sibling proposal packet**, not an extension of the active UEC remediation packet.

## Assumptions and confidence posture

- The repo baseline findings above are grounded in inspected live files and directory listings.
- Absence judgments in later concept dossiers are limited to the inspected live repo surfaces and to direct mechanism evidence. They should not be read as claims about private tooling or unpublished operational habits.
- Where a surface was only referenced indirectly (for example, the migration workflow path named in `/.octon/octon.yml`), the packet calls that out explicitly rather than pretending full verification.
