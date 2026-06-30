# Implementation Plan

1. Inspect the current `change-receipt-v1.schema.json` fields for landing,
   cleanup, delivery, archive, terminal, and evidence refs. Add or tighten only
   the minimum schema coverage needed to require publishable hosted/shared
   landing and cleanup refs before any hosted/shared `cleaned` claim.
2. Harden `write-terminal-closeout-local-evidence.sh` so local/private input
   refs are retained only under the local terminal evidence path and cannot be
   copied into hosted/shared Change, delivery, archive, or cleanup receipt
   dependencies.
3. Extend `validate-evidence-disclosure-tiers.sh` with positive and negative
   controls for hosted/shared refs, local/private terminal refs, mixed-tier
   receipt misuse, missing publishable authorization refs, and blocked-result
   routing.
4. Add metadata refresh receipt requirements to the canonical proposal registry
   and artifact-index generators. The receipt must name source refs, source
   digests, output refs, output digests, owning route, generated-output
   non-authority classification, and the next owning route when refresh cannot
   complete.
5. Add generator validation for proposal registry, artifact catalog, artifact
   index spine, handoff capsule, and navigation inventory refresh behavior.
   Generated output remains derived-only and must be refreshed through the
   generators rather than hand edited.
6. Record implementation evidence under the owning validation evidence root,
   including terminal local proof negative controls, disclosure-tier validator
   logs, metadata refresh digest checks, and rollback notes for the changed
   receipt, writer, validator, and generator surfaces.

## Target Sequence

1. Receipt schema and disclosure-tier validator changes land together.
2. Terminal writer behavior is updated against the validator contract.
3. Proposal metadata generators add refresh receipts and digest checks.
4. Tests and fixtures exercise each evidence class and each generated metadata
   refresh path.
5. Generated metadata refresh is performed by the owning generated-projection
   route only after durable source changes are accepted.
