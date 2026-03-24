---
title: Archive Proposal
description: Move the proposal into the canonical archive path, rewrite archive metadata, and regenerate the committed proposal registry.
---

# Step 2: Archive Proposal

## Actions

1. Validate the requested disposition and any required `promotion_evidence` paths.
2. Fail closed unless the archive destination path is exactly `.archive/<kind>/<proposal_id>/`.
3. Move the proposal package to the canonical archive path.
4. Rewrite `proposal.yml` to `status: archived` and populate `archive.*` metadata.
5. Regenerate `navigation/artifact-catalog.md` for the archived package.
6. Regenerate `generated/proposals/registry.yml` from manifests instead of editing it manually.
