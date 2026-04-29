# Octon Adoption Standards

External project adoption is a local preflight and initialization path, not a
state-copy shortcut.

## Participation Tiers

Octon Compatibility Profile values are:

- `external_evidence_source`: a non-Octon system that can provide normalized
  evidence only.
- `octon_compatible_emitter`: a system that emits Octon-shaped proof or
  attestation artifacts without running full Octon.
- `octon_mediated_connector`: a non-Octon system reached through connector
  admission.
- `octon_enabled_repo`: a repo with portable framework, repo-specific instance
  authority, and local control/evidence/continuity roots.
- `octon_federation_peer`: an Octon-enabled repo admitted through local trust
  registry and compact approval.

## Safe Adoption Path

`octon compatibility inspect <repo>` classifies a path without changing the
target. `octon adopt <repo>` records a local adoption preflight receipt under
`state/evidence/trust/external-project-adoption/**`; it does not copy the
target repo's `.octon/` state and does not mutate the external repo.

Adoption may proceed only by:

1. Detecting whether `.octon/` already exists.
2. Classifying the compatibility profile.
3. Installing or verifying portable `framework/**` material.
4. Initializing repo-specific `instance/**` authority.
5. Creating or reconciling the workspace charter.
6. Initializing ingress and bootstrap surfaces.
7. Initializing governance and support-target posture.
8. Initializing `state/control/**`, `state/evidence/**`, and
   `state/continuity/**`.
9. Rebuilding `generated/**` locally.
10. Running bootstrap and doctor checks.
11. Assigning the compatibility profile.
12. Considering federation compact membership only after local trust admission.

Blind copying another repository's full `.octon/` tree is forbidden. Imported
state, generated projections, proposal packets, proof bundles, attestations,
certificates, dashboards, and peer claims remain evidence candidates only until
local policy accepts them.

## Fail-Closed Boundary

No external project is treated as Octon-enabled until topology, portable
framework, repo-specific instance authority, support posture, state roots,
generated rebuild posture, and bootstrap checks are valid. Non-Octon systems
may be evidence sources or connector targets; they are not federation peers.
