# Domain Architecture Audit: orchestration-domain-design-package

- Date: `2026-03-08`
- Run ID: `orchestration-domain-design-package-audit`
- Target: `.design-packages/orchestration-domain-design-package`
- Mode: `observed`
- Criteria: `modularity`, `discoverability`, `coupling`, `operability`, `change-safety`, `testability`
- Overall verdict: `architecturally strong, but not yet fully implementation-ready`

The package is complete and coherent as a design and control bundle. It is not
yet ready to be treated as implementation-ready in the stronger sense implied by
its readiness verdict because two high-sensitivity authority seams remain
unresolved and the validation story is still prose-only.

## Current Surface Map

The package is well-structured and discoverable.

- Root framing and readiness:
  `.design-packages/orchestration-domain-design-package/README.md`,
  `.design-packages/orchestration-domain-design-package/implementation-readiness.md`,
  `.design-packages/orchestration-domain-design-package/profile-selection-and-compliance.md`
- Normative control layer:
  `.design-packages/orchestration-domain-design-package/normative-dependencies-and-source-of-truth-map.md`,
  `.design-packages/orchestration-domain-design-package/lifecycle-and-state-machine-spec.md`,
  `.design-packages/orchestration-domain-design-package/routing-authority-and-execution-control.md`,
  `.design-packages/orchestration-domain-design-package/evidence-observability-and-retention-spec.md`,
  `.design-packages/orchestration-domain-design-package/assurance-and-acceptance-matrix.md`,
  `.design-packages/orchestration-domain-design-package/operator-and-authoring-runbook.md`
- Contract layer:
  `.design-packages/orchestration-domain-design-package/contracts/README.md`
  plus 12 concrete contracts covering identifiers, decisions, queue, runs,
  incidents, automations, discovery layering, and coordination boundaries.
- Surface specs:
  `.design-packages/orchestration-domain-design-package/surfaces/workflows.md`,
  `.design-packages/orchestration-domain-design-package/surfaces/missions.md`,
  `.design-packages/orchestration-domain-design-package/surfaces/automations.md`,
  `.design-packages/orchestration-domain-design-package/surfaces/watchers.md`,
  `.design-packages/orchestration-domain-design-package/surfaces/queue.md`,
  `.design-packages/orchestration-domain-design-package/surfaces/runs.md`,
  `.design-packages/orchestration-domain-design-package/surfaces/incidents.md`,
  `.design-packages/orchestration-domain-design-package/surfaces/campaigns.md`
- Promotion planning:
  `.design-packages/orchestration-domain-design-package/canonicalization-target-map.md`,
  `.design-packages/orchestration-domain-design-package/adoption-roadmap.md`
- Architecture and rationale:
  `.design-packages/orchestration-domain-design-package/mature-harmony-orchestration-model.md`,
  `.design-packages/orchestration-domain-design-package/layered-model.md`,
  `.design-packages/orchestration-domain-design-package/surface-shape-architectural-review.md`,
  `.design-packages/orchestration-domain-design-package/failure-modes-and-safety-analysis.md`,
  `.design-packages/orchestration-domain-design-package/reference-examples.md`,
  `.design-packages/orchestration-domain-design-package/end-to-end-flow.md`,
  `.design-packages/orchestration-domain-design-package/adr/README.md`

Observed inventory facts:

- Total files under the package: `52`
- Non-Markdown contract or validation artifacts in-package: `0`
- Live comparator surfaces present today:
  `.harmony/orchestration/_meta/architecture/specification.md`,
  `.harmony/orchestration/practices/workflow-authoring-standards.md`,
  `.harmony/orchestration/practices/mission-lifecycle-standards.md`,
  `.harmony/orchestration/governance/incidents.md`,
  `.harmony/continuity/_meta/architecture/continuity-plane.md`,
  `.harmony/continuity/runs/README.md`

## Critical Gaps

### ODP-AUD-001

- Severity: `high`
- Title: `decision evidence is assigned to a continuity surface that does not yet exist in live continuity authority`
- Impact:
  the package treats `continuity/decisions/` as canonical evidence storage for
  `decision_id`, but live continuity authority does not currently define or own
  that surface.
- Risk:
  implementers will have to invent retention, ownership, and schema rules at
  the point of implementation, which breaks the package's source-of-truth claim
  for one of its most important evidence paths.
- Evidence:
  `.design-packages/orchestration-domain-design-package/contracts/decision-record-contract.md`
  requires `continuity/decisions/<decision-id>/decision.json`.
  `.design-packages/orchestration-domain-design-package/normative-dependencies-and-source-of-truth-map.md`
  says decision evidence depends on the continuity plane architecture.
  `.design-packages/orchestration-domain-design-package/canonicalization-target-map.md`
  separately lists `continuity/decisions/` as a future shared target.
  `.harmony/continuity/_meta/architecture/continuity-plane.md`
  only canonizes the four-file continuity contract plus `runs/`.
- Acceptance criteria:
  add canonical continuity authority for `continuity/decisions/` including
  storage contract, retention class, and validation expectations, or narrow the
  readiness claim until that dependency is promoted.

### ODP-AUD-002

- Severity: `high`
- Title: `incident promotion depends on a live governance baseline that is product-specific, not Harmony-generic`
- Impact:
  the package's incident runtime model assumes a reusable governance baseline,
  but the live target it cites is a production rollback runbook with product
  commands and operational heuristics, not a canonical incident policy for the
  proposed incident object model.
- Risk:
  implementers can wire the incident surface to the wrong authority model,
  blending product incident response with Harmony orchestration governance and
  weakening authority-boundary clarity.
- Evidence:
  `.design-packages/orchestration-domain-design-package/normative-dependencies-and-source-of-truth-map.md`
  lists `.harmony/orchestration/governance/incidents.md` as the incident
  governance baseline.
  `.design-packages/orchestration-domain-design-package/canonicalization-target-map.md`
  says promoted incident runtime state should extend the existing
  `governance/incidents.md`.
  `.harmony/orchestration/governance/incidents.md`
  is explicitly a production rollback guide with `vercel promote` and feature
  flag commands, not a generic incident authority contract.
  `.design-packages/orchestration-domain-design-package/contracts/incident-object-contract.md`
  expects lifecycle, closure authority, and object invariants that the current
  governance baseline does not define.
- Acceptance criteria:
  split a generic Harmony incident governance contract from the product runbook,
  then retarget the package's normative map and canonicalization target to that
  contract.

### ODP-AUD-003

- Severity: `medium`
- Title: `validation gates are specified, but the package has no machine-readable schemas, fixtures, or validator contract`
- Impact:
  the package can guide implementation planning, but it cannot yet prove
  contract validity, routing determinism, or fail-closed behavior without a
  second derivation step by implementers.
- Risk:
  different implementers can translate the prose contracts into different
  validators or object schemas and still claim compliance, which weakens
  reproducibility and change safety.
- Evidence:
  `.design-packages/orchestration-domain-design-package/implementation-readiness.md`
  says the package is implementation-ready and lists a concrete implementation
  gate checklist.
  `.design-packages/orchestration-domain-design-package/assurance-and-acceptance-matrix.md`
  requires contract validation, shape validation, routing checks, fail-closed
  checks, and promotion gates `G0` through `G6`.
  `.design-packages/orchestration-domain-design-package/canonicalization-target-map.md`
  requires validation hooks for promoted surfaces.
  Observed inventory fact: all `52` files in the package are `.md`; there are
  no package-local schema, fixture, or validator artifacts.
- Acceptance criteria:
  add machine-readable schema exemplars and scenario fixtures, or downgrade the
  readiness claim to "implementation-planning ready" until those artifacts are
  defined.

## Recommended Changes

1. `P1`: promote continuity decision-evidence authority before treating
   `decision_id` linkage as implementation-ready.
   Expected benefit: closes the package's biggest evidence ownership gap.
   Tradeoff: requires cross-domain continuity work, not just orchestration docs.
2. `P1`: split generic Harmony incident governance from the current
   production-specific rollback runbook.
   Expected benefit: gives incident runtime state a correct policy anchor.
   Tradeoff: one more governance surface to maintain.
3. `P2`: add schema/fixture/validator contracts for queue items, watcher events,
   run records, decision records, and incident objects.
   Expected benefit: turns narrative gates into testable gates.
   Tradeoff: more up-front artifact authoring and maintenance.
4. `P3`: clarify how mission-owned verification outputs in
   `.harmony/orchestration/practices/mission-lifecycle-standards.md`
   relate to `continuity/runs/` and future `continuity/decisions/`.
   Expected benefit: removes evidence-placement ambiguity for mission-linked
   executions.
   Tradeoff: may require light updates across continuity and mission practices.

## Keep As-Is Decisions

- Keep the surface decomposition. The split across `workflows`, `missions`,
  `automations`, `watchers`, `queue`, `runs`, `incidents`, and optional
  `campaigns` is clear and minimally coupled.
- Keep `queue` as automation-ingress only. That boundary is one of the package's
  strongest anti-coupling decisions.
- Keep `runs` as a projection and linkage layer over continuity evidence instead
  of a second evidence store.
- Keep recurrence out of `workflows`. The package is correct to put recurrence
  and event-trigger launch policy in `automations`.
- Keep reuse of live `workflows` and `missions` rather than proposing a clean
  break for already-canonical surfaces.

## Open Questions / Unknowns

- Should mission verification artifacts continue to land in
  `/.harmony/output/reports/` while material execution evidence lands in
  `continuity/runs/`, or should one become a projection of the other?
- What is the canonical machine-readable schema format for promoted
  orchestration contracts: YAML schema, JSON Schema, shell validators, or a
  mixed pattern?
- What retention class and review lifecycle should `continuity/decisions/`
  receive once promoted?

## Gate Verdict

| Gate | Status | Notes |
|---|---|---|
| `G0` | pass | required docs, contracts, and indexes exist |
| `G1` | fail | no machine-readable validation layer; decision evidence authority unresolved |
| `G2` | fail | routing scenarios exist only as prose examples, not proof artifacts |
| `G3` | fail | run evidence is grounded, decision evidence is not yet grounded in live continuity |
| `G4` | at-risk | authority boundaries are strong in-package, but incident governance baseline is misaligned |
| `G5` | at-risk | queue, automation, and incident safety rules are specified but not yet testable |
| `G6` | at-risk | promotion targets are listed, but incidents and decision evidence still depend on unresolved authority work |

## Done Gate

- Discovery mode: `complete`
- Done-gate decision: `planning-complete-but-not-remediation-complete`
- Rationale:
  enough evidence exists to issue stable findings and a clear remediation path,
  but the package should not be treated as fully implementation-ready until the
  authority and validation gaps above are closed.
