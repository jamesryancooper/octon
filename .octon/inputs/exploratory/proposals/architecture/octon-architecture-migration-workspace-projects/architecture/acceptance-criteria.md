# Acceptance Criteria

## Entry Criteria

- RP-01 has exited with a frozen versioned authority and exact launch-guard
  interface.
- ED-005 is represented in the schema, inference, correction, and snapshot
  design.
- Current Project Profile, engagement, mission, continuity, and Harness input
  consumers have been inventoried at the implementation commit.

## Target Criteria

| ID | Required condition | Proof |
| --- | --- | --- |
| RP10-AC-001 | Two distinct projects retain stable IDs, strict active records, and exact project/Profile refs and digests. | Create and reopen two records; validate schemas and digest bindings. |
| RP10-AC-002 | Relocating a repository or project path does not create a new project identity or rewrite an immutable project revision. | Relocation scenario and discovery/repair receipt comparison. |
| RP10-AC-003 | An operator correction survives repeated inference and refresh. | Correct a boundary/default, rerun inference twice, and compare the selected revision. |
| RP10-AC-004 | Ambiguous overlap rejects selection unless an explicit parent/child relation resolves it. | Overlap, nested-monorepo, sibling, and case-alias negative fixtures. |
| RP10-AC-005 | Project and Profile data can only narrow; unknown or authority-shaped fields cannot mint or widen authority. | Schema negatives and mutated-field authorization denial matrix. |
| RP10-AC-006 | An active run retains its original project/Profile refs and digests after a refresh or correction. | Start a fixture run, publish a successor revision, and prove the bound snapshot is unchanged. |
| RP10-AC-007 | `octon mission inbox` distinguishes missions across two projects and reports exact status/resume actions without mutating mission state. | Before/after control-root digests plus inbox/status/resume fixtures. |
| RP10-AC-008 | Missing/corrupt location indexes rebuild; missing/corrupt registry or pointer data fails only affected project selection closed. | Delete/rebuild index; corrupt pointer/digest; verify scoped denial and repair output. |
| RP10-AC-009 | Existing singleton Project Profile consumers are migrated or explicitly bound through the read-only compatibility bridge. | Static call-path census and compatibility retirement checklist. |
| RP10-AC-010 | No descendant `.octon`, portfolio control plane, second writer, or project authority source is introduced. | Filesystem/source-ownership scan and architecture review. |

## Proof Obligation

Passing RP10-AC-001 through RP10-AC-010 satisfies the RP-10 portion of
PO-FD-019 and gate PG-10-PROJECT-NONAUTHORITY. UE-010 remains open until RP-11
also proves deterministic full-input compilation and exact launch binding.

## Exit Criteria

- structural, schema, runtime, negative, relocation, recovery, and inbox tests
  pass at the exact implementation commit;
- evidence is retained at the declared proposal-validation root;
- the pre-integration architecture review, implementation conformance review,
  and post-implementation drift/churn review pass;
- generated projections are refreshed only through their owners; and
- no durable target depends on this proposal path.

These criteria are future gates. None is claimed as executed by this draft.
