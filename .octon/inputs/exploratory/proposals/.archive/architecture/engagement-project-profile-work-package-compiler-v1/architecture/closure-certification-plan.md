# Closure Certification Plan

## Purpose

Define the evidence required to certify this proposal as implemented and ready for archival after promotion.

## Certification gates

1. **Durable targets exist.** All promoted contracts, runtime command surfaces, validators, and instance policies exist outside `inputs/exploratory/proposals/**`.
2. **Proposal path dependency removed.** No durable promoted file depends on this proposal path as authority.
3. **Compiler works prepare-only.** `octon start/profile/plan/arm --prepare-only/decide/status` can produce and inspect Engagement, Project Profile, per-engagement Objective Brief candidate, Work Package, Decision Requests, context-pack request, and first run-contract candidate for a repo-local scenario.
4. **Run handoff preserved.** Material execution still enters through `octon run start --contract`.
5. **Support remains bounded.** Non-admitted MCP/API/browser connectors remain stage-only, blocked, or denied.
6. **Evidence retained.** Promotion evidence and compiler demonstration evidence are retained under `state/evidence/**`.
7. **Generated projections remain projections.** Engagement and Work Package read models are traceable and never consumed as authority.
8. **Validators pass.** Proposal, architecture, runtime, context, support, and generated/effective handle validators pass or produce documented stage-only blockers.

## Required closeout evidence

- promotion receipt;
- file-change summary;
- validator output;
- demonstration Engagement bundle;
- demonstration Project Profile evidence;
- demonstration Work Package evidence;
- first run-contract candidate;
- Decision Request demonstration;
- blocked/stage-only connector demonstration;
- generated read-model traceability output;
- rollback-readiness note.

## Current readiness notes

The packet is not archive-ready until these live-repo facts are true and
validated:

- the prepare-only compiler commands compile and run;
- any command module referenced by the kernel dispatcher exists in the live
  tree;
- the Project Profile authority target exists only after retained source
  evidence is created;
- connector posture remains machine-readable stage/block/deny policy and does
  not imply live MCP/API/browser support;
- generated proposal and compiler projections remain non-authoritative
  discovery/read-model outputs;
- validators prove proposal-path independence and generated-projection
  non-authority.

## Archival condition

This packet may be archived only after durable targets stand alone and retained promotion evidence identifies where the implemented contracts, runtime commands, validators, and instance policies landed.
