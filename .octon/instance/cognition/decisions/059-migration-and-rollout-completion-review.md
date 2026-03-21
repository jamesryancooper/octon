# ADR 059: Migration And Rollout Completion Review

- Date: 2026-03-20
- Status: Accepted
- Deciders: Octon maintainers
- Related:
  - `/.octon/inputs/exploratory/proposals/architecture/migration-rollout/`
  - `/.octon/instance/cognition/context/shared/migrations/2026-03-20-migration-rollout-review/plan.md`
  - `/.octon/state/evidence/migration/2026-03-20-migration-rollout-review/evidence.md`

## Context

Packets 1 through 14 had already been promoted and archived, and the live
repository already reflected the ratified five-class super-root in its
manifests, class roots, extension pipeline, proposal workspace, retained
state, and generated effective families.

What remained missing was one retained closeout decision proving that the
migration was complete across both live state and retained receipts.

During the Packet 15 completion review, four issues surfaced:

1. capability routing publication still referenced stale extension catalog and
   extension generation-lock digests,
2. the active Packet 15 proposal package failed proposal validation because
   its promotion target pointed at the full retained migration-evidence tree,
3. Packet 14 and Packet 15 discovery lineage was incomplete because the
   canonical migration and ADR indices were missing entries, and
4. the native-collision extension publication regression case still expected a
   validator failure even though the live publisher already quarantined the
   colliding pack before validating the published set.

The review also required an escalated rerun of
`alignment-check.sh --profile harness`
to refresh `.codex/**` host projections in this environment.

## Decision

Treat Packet 15 as the final migration completion gate and close it with one
retained review bundle plus one closeout ADR.

Rules:

1. Migration completion must be proved from live canonical surfaces plus
   retained evidence, not from directory shape alone.
2. The final review bundle lives under
   `state/evidence/migration/2026-03-20-migration-rollout-review/`.
3. Capability routing publication must be republished whenever upstream
   extension or locality publication digests drift.
4. Packet 15 proposal promotion targets must point at durable contract
   surfaces that do not retain active proposal-path dependencies.
5. Packet 14 and Packet 15 must both resolve from the canonical migration and
   ADR discovery indices.
6. Native-versus-extension capability collisions remain invalid only if they
   survive into the active published generation; quarantine-before-validation
   is the correct behavior for the publisher and the regression suite.
7. A clean completion verdict may retain only non-blocking historical or
   empty-container warnings; no authority, runtime, or policy blocking finding
   may remain open.

## Consequences

### Benefits

- One retained completion record now proves the migration end to end.
- Capability routing publication is back in sync with the current extension
  publication.
- Packet 14 and Packet 15 discovery lineage is complete in both migration and
  ADR indices.
- The Packet 15 proposal package and its proposal-registry projection validate
  cleanly.
- Extension publication regression coverage now matches the live
  quarantine-first publication behavior.

### Costs

- The completion review required another generated capability-routing
  publication refresh.
- The proposal package and registry needed follow-up metadata correction during
  the review itself.
- Harness alignment still needs an escalated rerun in environments where
  `.codex/**` host projections cannot be refreshed inside the sandbox.

### Follow-On Work

1. Archive the active `migration-rollout` proposal once durable workflow or
   architecture surfaces absorb the remaining Packet 15 review guidance.
2. Optionally clean empty retained run directories under `state/evidence/runs`
   if governance wants zero-warning continuity-memory validation.
3. Leave allowlisted historical framing tokens in ADRs 009 and 017 as
   historical material unless governance explicitly wants a superseding-note
   rewrite.

## Addendum: Packet 15 Self-Challenge And Resolution

After the initial Packet 15 closeout, a broader comprehensive check reran
`validate-export-profile-contract.sh` and then immediately reran
`validate-runtime-effective-state.sh`.

That self-challenge found a high-severity dependency gap:

- `validate-export-profile-contract.sh` refreshes extension publication in
  place,
- capability routing is not republished after that refresh, and
- runtime-effective validation then fails because capability publication still
  points at stale extension digests.

Resolution:

- update the export-profile validator to republish and validate capability
  routing after extension publication refresh
- update the repo-snapshot validation path in `export-harness.sh` to do the
  same
- add regression coverage proving the export validator preserves
  runtime-effective coherence
- restore executable bits on the capability publication validator and
  capability routing publisher so the validator can enforce the new behavior

Packet 15 completion is unblocked after those fixes.
Use the retained follow-up detail in:

- `/.octon/state/evidence/migration/2026-03-20-migration-rollout-review/evidence.md`

as the authoritative current status for migration closeout.
