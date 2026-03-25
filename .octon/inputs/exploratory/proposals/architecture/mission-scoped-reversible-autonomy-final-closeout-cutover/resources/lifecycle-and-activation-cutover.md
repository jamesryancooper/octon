# Lifecycle And Activation Cutover

## Final decision

The closeout packet adopts **seed-before-active** as the canonical lifecycle rule.

### Why this is the right final rule

It solves the audit gap **without** moving mutable control truth into authored mission scaffolds.
That preserves Octon’s source-of-truth discipline:

- mission scaffolds remain authored authority
- mission control remains mutable control truth
- summaries remain generated
- evidence remains retained evidence

## Lifecycle states

The architecture does not need a new top-level mission state enum.
It needs a stricter rule for when existing mission statuses are legal.

### Legal lifecycle
1. **Created**
   - mission charter exists
   - mission control may not exist yet
   - not autonomy-active

2. **Seeded / activation-ready**
   - mission control family exists
   - continuity stubs exist
   - route, summaries, and mission view can be generated
   - still not necessarily running

3. **Active or paused autonomous**
   - seeded state exists
   - route is fresh
   - summaries exist
   - machine mission view exists
   - validators pass

### Validation rule
If a mission is marked or treated as autonomy-active, it must be seed-complete.

## Canonical activation path

The runtime path should be:

1. create mission charter
2. run `seed-mission-autonomy-state.sh`
3. sync runtime artifacts
4. publish effective route
5. generate summaries, digests, and mission view
6. emit mission-seed control receipt
7. only then allow autonomy-active state

## Why the scaffold should not own control truth

Creating mutable `state/**` files directly from the authored mission scaffold would blur the class boundary between authority and control truth.

The correct closeout is:

- keep scaffold lean
- make activation canonical and enforced
- validate seed-before-active everywhere

## Required validator behavior

A dedicated lifecycle validator must fail if:

- a mission is active or paused
- but any required control file is missing
- or continuity stubs are missing
- or route linkage is missing
- or summaries/mission view are missing
- or a seed receipt is missing

## Migration rule

Any existing in-tree mission that is active or paused must either:

- already be seed-complete
- or be migrated to seed-complete in the closeout merge

No mixed population remains after merge.
