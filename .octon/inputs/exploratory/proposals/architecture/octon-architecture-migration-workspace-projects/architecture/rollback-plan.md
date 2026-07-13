# Rollback Plan

## Prepared Before Cutover

- retain the last valid singleton Project Profile and its digest;
- retain every activated project and Profile revision referenced by a run;
- capture registry and pointer digests before each activation;
- keep a feature/route disable for inference, refresh, and inbox presentation;
- retain adoption, correction, relocation, and pointer-transition receipts; and
- verify that disabling RP-10 does not disable canonical mission authority or
  candidate preservation.

## Rollback by Stage

| Stage | Action | Preserved data |
| --- | --- | --- |
| Inert contracts only | Stop project selection and remove no referenced records. | Schemas, candidate records, singleton Profile |
| One active project | Disable inference/refresh and return new selection to the read-only singleton compatibility path. | Project ID, revisions, Profile, active-run bindings |
| Two projects/inbox | Disable inbox and new project selection; keep mission authority/control untouched. | Both project identities, mission continuity, candidate work |
| Post-retirement defect | Restore the last certified selection resolver against retained records; otherwise fail affected project selection closed and repair forward. | All immutable revisions and receipts |

## Recovery Procedures

- Rebuild a missing location index from durable project records, repository
  identity, and current filesystem observation.
- On registry/pointer digest mismatch, stop new affected selection, retain
  active runs, compare retained transition receipts, and restore only a
  certified pointer or repair forward.
- On ambiguous identity or overlap, quarantine only the affected project
  candidate and request one bounded operator correction.
- On stale Profile facts, keep safe pinned work available, regenerate a
  candidate Profile revision, and never update an active run.
- On missing project tags in legacy mission continuity, display
  `legacy-unassigned` and require deterministic association before resume;
  never infer authority from the missing tag.

## Rollback Invariant

Rollback may reduce project automation or return to read-only singleton Profile
selection. It may not restore path-as-identity, allow project metadata to
authorize, rewrite referenced revisions, or discard candidate/mission state.
