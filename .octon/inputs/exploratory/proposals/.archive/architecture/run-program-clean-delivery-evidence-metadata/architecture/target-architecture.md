# Target Architecture

Clean delivery must retain two different evidence classes without mixing them:

- publishable hosted/shared evidence under `.octon/state/evidence/runs/skills/**`
  for landing authorization, branch cleanup authorization, Change receipt
  truth, route validation, and delivery receipts;
- local/private terminal snapshots under
  `.octon/state/evidence/local/terminal-closeout/<change-id>/` for
  post-mutation terminal proof only.

The terminal writer should not synthesize a hosted/shared cleaned receipt that
depends on local/private landing or cleanup refs. It should either require
publishable authorization refs up front or emit an explicit blocked result.

Proposal metadata refresh should be route-owned and use canonical generators
for proposal registry, artifact indexes, spines, handoff capsules, and
navigation inventories. These generated outputs remain derived-only.

## Affected Artifact Model

The future implementation owns only the files declared in
`proposal.yml#promotion_targets`. The implementation-grade map in
`support/affected-artifact-map.md` is the packet-local target inventory for
current assumptions, required changes, owner, priority, rationale, retained
evidence expectations, generated-output boundaries, and rollback or closeout
expectations.

## Authority Boundaries

- `change-receipt-v1.schema.json` may validate receipt shape and disclosure
  tier requirements, but it must not authorize landing, cleanup, archive,
  delivery, or terminal status by itself.
- `write-terminal-closeout-local-evidence.sh` may retain local/private terminal
  proof and digests, but local/private refs must not become hosted/shared
  landing or cleanup dependencies.
- `validate-evidence-disclosure-tiers.sh` must classify evidence refs and fail
  closed when hosted/shared receipts cite local/private terminal evidence for
  authorization-grade claims.
- Proposal metadata generators may refresh derived indexes and registries, but
  the generated files remain non-authority and must record source/output
  digests rather than serving as policy or runtime truth.

## Review Gates

Architecture acceptance requires both a passing strict pre-integration
architecture receipt and a fresh proposal review digest. This packet carries
those gates as support evidence only; implementation authorization still
requires a later accepted `review-packet` pass.
