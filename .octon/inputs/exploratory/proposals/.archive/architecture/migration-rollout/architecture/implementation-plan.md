# Implementation Plan

This proposal does not define another structural cutover.
It defines the execution plan for the final evidence-backed review that proves
the structural cutovers already landed correctly.

## Workstream 1: Build The Review Manifest

- Enumerate the ratified Packet 15 phase order and convert it into one review
  checklist covering phases 1 through 15.
- Inventory the live canonical surfaces that each phase is expected to leave
  behind.
- Inventory the retained proof family for each phase:
  archived proposal package, migration plan, ADR where present, and migration
  evidence bundle.
- Define review exclusions explicitly so historical or bundled resource files
  are not misclassified as live regressions.

## Workstream 2: Run The Legacy-Path Grep Sweep

- Search the live repository for legacy external-workspace references such as
  `.proposals/**`.
- Search for numbered active proposal-package path assumptions under
  `inputs/exploratory/proposals/architecture/`.
- Search for `repo_snapshot_minimal` or any equivalent minimal-snapshot
  fallback language.
- Search for direct runtime or policy reads from raw
  `inputs/additive/extensions/**` and `inputs/exploratory/proposals/**`.
- Search for stale mixed-path or external-workspace terminology that would
  imply the migration is incomplete.
- Search for shim misuse, including repo-root adapter paths being treated as
  writable peer authority surfaces.

## Workstream 3: Run The Cross-Reference Audit

- Read the root manifest, companion manifests, README, START, ingress files,
  migration index, proposal registry, and retained evidence bundle metadata.
- Extract the canonical paths referenced in those files and verify each path
  resolves on disk.
- Confirm that generated effective families, control-state files, continuity
  directories, and proposal paths cited by the docs all exist where the live
  contract says they should.
- Confirm that references to archived packet proposals, migration plans, and
  retained cutover bundles still resolve and remain internally coherent.

## Workstream 4: Correlate Phase Claims To Live And Retained Proof

- For each ratified phase, map the expected live state to the matching
  archived packet proposal, migration plan, ADR or decision record where
  applicable, and retained evidence bundle.
- Confirm that phase ordering constraints still hold in the historical record,
  especially:
  repo continuity before scope continuity,
  raw-input dependency enforcement before extension internalization, and
  locality before scope continuity.
- Confirm that proposal internalization, generated registry publication, and
  legacy external-workspace retirement all appear as closed phases rather than
  open-ended assumptions.

## Workstream 5: Verify Publication And Snapshot Integrity

- Re-verify the extension desired/actual/quarantine/compiled split across
  `instance/`, `state/control/`, `state/evidence/validation/publication/`, and
  `generated/effective/extensions/**`.
- Re-verify locality and capability publication coherence through their
  effective views, artifact maps, and generation locks.
- Re-verify that `repo_snapshot` still includes enabled-pack dependency
  closure and that no minimal v1 snapshot contract is present.
- Re-verify that proposal discovery remains generated and non-authoritative.

## Workstream 6: Self-Challenge The Clean Verdict

- Re-run targeted searches for counter-examples in files not used as primary
  proof sources.
- Sample the newest migration bundles and archived packet proposals for stale
  assumptions that the first pass may have missed.
- Try to disprove any clean verdict by checking whether legacy assumptions
  survive in authoring workflows, runtime guidance, or retained receipts.
- Downgrade only genuinely historical residue that cannot affect runtime,
  policy, or authoring behavior.

## Workstream 7: Publish The Final Completion Receipt

- Write the final review bundle to
  `state/evidence/migration/<YYYY-MM-DD>-migration-rollout-review/`.
- Record the exact search patterns used, the files reviewed, the evidence
  bundles correlated, the findings by severity, and the coverage proof.
- If the review passes cleanly, record that migration completion was declared
  from retained evidence plus live state rather than from directory shape
  alone.
- If the review does not pass, record the blocking gaps as explicit follow-up
  batches and keep the migration incomplete until they are closed.

## Exit Condition

This proposal is complete only when the repository has one durable,
repeatable, retained way to prove that the ratified super-root migration
finished correctly, that legacy path assumptions are gone, and that rollback
can rely on evidence plus version-controlled restore rather than on reviving
abandoned authority surfaces.
