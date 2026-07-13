# Cutover Plan

## Cutover Profile

- release state: `pre-1.0`
- change profile: `atomic`
- atomic mode: clean break after an evidence-backed compatibility interval

The interval is not dual authority. The existing singleton Project Profile is
read-only input while Workspace Project records become the sole project
identity/boundary source.

## Stage 0 — Admission

Confirm RP-01 exit, inventory every singleton Profile reader/writer, bind the
implementation commit, and keep all project-derived authority claims denied.

## Stage 1 — Inert Contracts and Records

Publish schemas, registry entries, and first-project candidate records without
changing active-run selection. Validate path safety, strict fields, digests,
and explicit monorepo relationships.

Safe resting point: records exist but runtime continues through the read-only
singleton Profile compatibility path.

## Stage 2 — Governed Project Selection

Adopt the current project and select its exact project/Profile pair. New runs
record the pair while existing runs retain their prior snapshot. Inference
produces candidates; durable selection uses the existing governed change route
and never an RP-10-specific writer.

Safe resting point: one project is active and every bound run is immutable.

## Stage 3 — Two-Project Continuity

Adopt a second project, validate overlap and relocation, preserve corrections,
and tag mission continuity with project identity. Enable the read-only inbox
only after its before/after control-root digest proves no mutation.

Safe resting point: two projects and the inbox work; RP-11 may consume exact
project/Profile refs and digests.

## Stage 4 — Compatibility Retirement

Prove every direct singleton Profile consumer now resolves through the selected
Workspace Project binding. Retain old Profile data as historical/read-only
facts but retire singleton selection as live behavior.

## Prohibited States

- two project identity authorities or writable registries;
- a project refresh changing an active-run binding;
- inferred metadata directly activating a durable record;
- ambiguous overlap silently selecting a project;
- a location index or inbox view becoming control truth;
- a nested project installing another `.octon`; and
- RP-10 changing RP-01 authority semantics or RP-11 Harness semantics.

## Promotion Handoff

After implementation proof, the packet supplies exact target diffs, validation
receipts, rollback posture, and registry/projection freshness to the canonical
promotion route. Proposal prose is never copied into runtime as authority.
