# Octon Proposal Packet — Claim-Valid Unified Execution Constitution Closure

This archive defines the implementation, normalization, enforcement, staging, cutover, and certification program required to move the current Octon repository from a substantially transformed but still internally contradictory state to a claim-valid, fully unified execution constitution.

## Packet intent

The repository already contains a real constitutional kernel, run-first control roots, authority artifacts, adapters, support targets, lab, observability, and disclosure surfaces. The remaining work is not “more architecture” in the abstract. It is closure hardening:

- remove contradictory claim-bearing surfaces
- normalize split contracts and under-specified artifacts
- make disclosure a generated product rather than authored optimism
- force cross-artifact consistency across control, runtime, evidence, and disclosure
- institutionalize recertification, retirement, and drift governance

## Source basis

This packet is grounded in:

1. the current public `jamesryancooper/octon` repository on `main`, as inspected in the current thread
2. the normative target-state requirements stated in the current thread
3. the implementation audit already established in the current thread

Because the earlier Proposal and Design Packet was not present in this workspace as a standalone file, `resources/proposal-design-packet.md` reconstructs the authoritative design brief from the explicit target-state requirements that remained visible in the thread. Likewise, `resources/implementation-audit.md` reconstructs the current authoritative audit baseline as a packet resource.

## How to use the packet

Read in this order:

1. `packet/00-executive-closure-thesis.md`
2. `packet/01-current-state-closure-delta.md`
3. `packet/02-preserve-harden-normalize-delete-decisions.md`
4. `packet/03` through `packet/12` for target-state architecture and enforcement
5. `packet/13` through `packet/15` for staging, cutover, and certification
6. `packet/16` and `packet/17` for execution-level traceability
7. `appendices/` for contract catalog, regeneration map, skeletons, and rollback matrix

## Closure theorem

Octon should not declare complete target-state closure by prose, green checklists, or manually edited status files. Closure becomes true only when:

- all critical and high findings are resolved in substance
- all claim-bearing artifacts are regenerated from canonical inputs
- all gates pass twice in succession with identical outcomes
- all active proof-bundle exemplar runs have non-empty evidence classifications
- no active claim-bearing artifact carries superseded wording
- a single canonical run-contract family is live
- disclosure, support targets, control roots, and retained run evidence agree everywhere

## Root structure

This archive has the exact required structure:

```text
proposal-packet/
  README.md
  packet/
  resources/
  appendices/
```

The zip archive preserves this structure exactly.
