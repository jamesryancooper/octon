# Target Architecture

The proposal lifecycle surface set becomes coherent around one canonical capability: running a proposal program through clean delivery.

## Canonical Delivery Spine

- Canonical runtime commands, skills, workflows, prompt bundles, contracts, and validators agree on the required inputs for `proposal-program-delivery`.
- Packet and program delivery wrappers keep their shared delivery semantics aligned while preserving packet/program lifecycle differences.
- Product catalog entries describe only surfaces that are actually available or explicitly scheduled for publication.

## Host Projection Layer

- `.codex/commands/` and `.codex/skills/` expose implemented delivery capabilities that the product catalog claims are available.
- Host projections remain generated or adapter-facing mirrors, not authority.
- Publication or projection freshness evidence is required before a generated or projected surface is used as discovery evidence.

## Program Review And Revision

- Program review/revision remains parent-local coordination over the parent manifest, child registry, child index, sequence, contract, validation plan, closeout plan, and parent support artifacts.
- Child manifests, child receipts, child promotion targets, child validation verdicts, child archive metadata, and child terminal outcomes remain child-owned.
- The lifecycle docs explain why a standalone program `review-and-revise-loop` wrapper is not required unless future evidence shows operational demand.

## Delivery, Closeout, Archive, Cleanup, And Terminal Proof

- Program delivery can run or resume child lifecycles without absorbing child authority.
- Aggregate verification and correction summarize child posture but never replace child receipts.
- Parent closeout and archive handoff require allowed child terminal outcomes, aggregate evidence, cleanup disposition, and terminal proof.
- Cleanup detection remains non-authorizing until an owning route has explicit authority.

## Safety Properties

- Raw inputs and proposal packets remain planning lineage only.
- Generated projections remain derived-only.
- Parent summaries cannot satisfy child gates.
- Convenience aliases cannot widen canonical capability authority.
- Validators and tests cover lifecycle symmetry, intentional asymmetry, required input contracts, and projection/catalog coherence.
