# Assumptions and Blockers

## Assumptions

1. The user wants an active architecture proposal packet, not an archive-only
   normalization or a virtual packet.
2. No external audit artifact is required to make this packet review-ready; a
   source-item baseline derived from live repo inspection is acceptable.
3. Implementation can land authoritative `.octon/**` surfaces and dependent
   workflow integrations within one coherent change program.
4. The current build-to-delete spine remains authoritative and is available for
   reuse.

## Explicit blockers

### B-01 — Active proposal mixed-target prohibition

The live proposal standard forbids an active proposal from mixing `.octon/**`
and non-`.octon/**` promotion targets. This is not optional and cannot be
solved inside the packet by ignoring the rule.

**Resolution in this packet:** use `promotion_scope: octon-internal` and model
repo-local workflow edits as dependent implementation surfaces.

### B-02 — No external audit ids exist

The user did not supply a prior audit document with finding identifiers.

**Resolution in this packet:** derive packet-local source item ids and make the
baseline explicit in the normalization artifact. Do not fabricate audit ids.

### B-03 — Current active architecture proposal example is legacy-shaped

The single live architecture-proposal directory in the repo does not provide a
complete model for the richer packet contract requested here.

**Resolution in this packet:** use the current standards and validator-backed
contracts as binding; use archived normalized packet examples for style only
when they do not conflict.

## Non-blocking concerns

- The current validator minimum for architecture proposals is thinner than the
  packet structure requested here, but that is not a blocker; it simply means
  the packet is richer than the validator floor.
- Repo-local workflow edits may need linked implementation tracking if local
  change governance insists on scope separation. That does not block the
  architecture packet itself.
