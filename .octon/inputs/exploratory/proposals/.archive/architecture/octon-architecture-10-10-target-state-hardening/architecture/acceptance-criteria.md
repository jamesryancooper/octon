# Acceptance Criteria

This proposal is acceptance-ready when the following criteria are satisfied.

## Architecture criteria

- [ ] `/.octon/` remains the only super-root.
- [ ] Class-root semantics remain unchanged and validator-enforced.
- [ ] `framework/**` and `instance/**` remain the only authored authority roots.
- [ ] `state/**`, `generated/**`, and `inputs/**` are not used as authored authority.
- [ ] Structural registry remains the machine-readable structural anchor.
- [ ] Active docs remain registry-backed and do not restate full path matrices.

## Runtime criteria

- [ ] Every material side-effect class is inventoried.
- [ ] Every material path has authorization-boundary coverage metadata.
- [ ] Every material path has negative-control tests.
- [ ] No material side effect can occur before a valid GrantBundle exists.
- [ ] Workflow compatibility wrapper cannot bypass run-first lifecycle.
- [ ] Protected execution requires hard-enforce posture.

## Run/mission/control criteria

- [ ] Run contracts remain the atomic consequential execution unit.
- [ ] Missions remain continuity containers, not material execution authority.
- [ ] All run lifecycle transitions have required roots, evidence, rollback,
      receipts, and operator-visible state.
- [ ] Active missions do not default to non-live support without explicit
      stage-only posture.

## Support criteria

- [ ] Admissions are partitioned into live/stage-only/unadmitted/retired.
- [ ] Dossiers are partitioned into live/stage-only/unadmitted/retired.
- [ ] Live tuples have proof bundles, negative controls, representative runs,
      disclosure coverage, SupportCards, and dossier sufficiency.
- [ ] Stage-only and unadmitted surfaces cannot appear in live support claims.
- [ ] Pack admission cannot widen support claims.

## Publication criteria

- [ ] Runtime-facing generated/effective outputs require current publication
      receipts and freshness artifacts.
- [ ] Stale or receiptless generated/effective outputs fail closed.
- [ ] Generated/cognition read models are traceable and non-authoritative.
- [ ] Generated/proposals registry remains discovery-only.

## Pack/extension criteria

- [ ] Capability pack lifecycle has one canonical source/control graph and
      generated projections.
- [ ] Runtime pack admissions align with support targets and grant/receipt usage.
- [ ] Raw additive extensions are never runtime/policy authority.
- [ ] Extension active/quarantine state and generated/effective publication agree.

## Proof criteria

- [ ] Architecture health report retained.
- [ ] Support tuple proof bundles retained.
- [ ] RunCard, HarnessCard, and SupportCard examples retained.
- [ ] Replay and recovery bundles retained.
- [ ] Negative-control evidence retained.
- [ ] Two consecutive clean full validation passes retained.

## Operator criteria

- [ ] Ingress manifest is boot/orientation-only, with closeout delegated.
- [ ] Bootstrap START includes a clear doctor/first-run path.
- [ ] Generated architecture maps exist or are spec-defined and non-authoritative.
- [ ] A reviewer can inspect support claim state by path placement.

## Closure criteria

- [ ] Durable promotion targets stand alone.
- [ ] No durable target depends on proposal-local paths.
- [ ] Promotion evidence exists.
- [ ] Packet can be archived as implemented.
