---
title: Archive Proposal
description: Move the proposal into the canonical archive path, rewrite archive metadata, and regenerate the committed proposal registry.
---

# Step 2: Archive Proposal

## Actions

1. Validate the requested disposition and any required `promotion_evidence` paths.
2. Fail closed unless the archive destination path is exactly `.archive/<kind>/<proposal_id>/`.
3. Move the proposal packet to the canonical archive path.
4. Rewrite `proposal.yml` to `status: archived` and populate `archive.*` metadata.
5. Regenerate `navigation/artifact-catalog.md` for the archived package.
6. Regenerate the proposal artifact index for the archived package and validate
   the artifact spine after the archive path and manifest mutation.
7. Add the archived package path to the repo archive allow-list so canonical
   archived packets are git-visible instead of silently ignored.
8. Regenerate `generated/proposals/registry.yml` from manifests instead of editing it manually.
9. If a prior owned archive run moved the packet but failed before emitting the
   archive stage outcome, recover only when the archived manifest exactly
   matches the active-path kind/id, original path, disposition, and promotion
   evidence supplied to this route.
10. For terminal closeout, run
   `validate-proposal-lifecycle-terminal-freshness.sh --proposal <archived_path>
   --run-registry-check` after the final archive mutation.
