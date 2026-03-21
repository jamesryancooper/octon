# Source Of Truth Map

## Canonical Authority

| Concern | Source of truth | Notes |
| --- | --- | --- |
| Ratified super-root topology, class-root bindings, profile model, raw-input dependency policy, and generated commit defaults | `.octon/octon.yml` | Root manifest is the authoritative topology and profile contract that Packet 15 review must verify against the live repo |
| Human-readable topology, authority classes, ingress model, locality rules, portability contract, and proposal workspace rules | `.octon/README.md` and `.octon/instance/bootstrap/START.md` | Review must confirm human-facing guidance agrees with manifests and the ratified blueprint |
| Framework identity, supported schema range, generator set, and overlay registry binding | `.octon/framework/manifest.yml` | Phase 2 and Packet 5 completion claims depend on this companion manifest remaining aligned |
| Repo instance identity, enabled overlay points, and locality bindings | `.octon/instance/manifest.yml` | Review must confirm repo-native authority and overlay enablement remain machine-declared |
| Canonical ingress authority and repo-root adapter contract | `.octon/instance/ingress/AGENTS.md`, `.octon/AGENTS.md`, `AGENTS.md`, and `CLAUDE.md` | Repo-root adapters must remain thin parity or read-through shims only |
| Canonical locality authority | `.octon/instance/locality/**` | Scope identity and validation must be live before scope continuity is treated as valid |
| Desired extension configuration | `.octon/instance/extensions.yml` | Human-authored desired state for extension activation in v1 |
| Actual extension active and quarantine truth | `.octon/state/control/extensions/{active.yml,quarantine.yml}` | Mutable operational truth for what is published and what is blocked |
| Repo and scope continuity truth | `.octon/state/continuity/repo/**` and `.octon/state/continuity/scopes/**` | Review must prove repo continuity migrated before scope continuity |
| Retained migration plans and discovery index | `.octon/instance/cognition/context/shared/migrations/index.yml` and `/.octon/instance/cognition/context/shared/migrations/**` | Canonical authored migration-record lineage for correlating plans to evidence |
| Retained migration receipts and cutover bundles | `.octon/state/evidence/migration/**` | Canonical retained evidence for what actually happened during rollout |
| Ratified packet implementation lineage | `.octon/inputs/exploratory/proposals/.archive/architecture/**` | Archived packet proposals are retained non-canonical design lineage that the review must correlate to live state |
| Cross-subsystem authority and runtime trust invariants | `.octon/framework/cognition/_meta/architecture/specification.md` and `.octon/framework/cognition/_meta/architecture/runtime-vs-ops-contract.md` | Review must confirm runtime trust and write-target rules agree with the cutover state |

## Derived Or Enforced Projections

| Concern | Derived path or enforcement surface | Notes |
| --- | --- | --- |
| Runtime-facing extension compiled view | `.octon/generated/effective/extensions/{catalog.effective.yml,artifact-map.yml,generation.lock.yml}` | Valid only when active state, quarantine state, and publication receipts remain coherent |
| Runtime-facing locality compiled view | `.octon/generated/effective/locality/{scopes.effective.yml,artifact-map.yml,generation.lock.yml}` | Review must confirm scope publication depends on validated locality inputs only |
| Runtime-facing capability routing view | `.octon/generated/effective/capabilities/{routing.effective.yml,artifact-map.yml,generation.lock.yml}` | Routing must be compiled from canonical class-root inputs rather than raw packs or legacy path readers |
| Proposal discovery projection | `.octon/generated/proposals/registry.yml` | Committed discovery projection only; must never replace proposal manifests as lifecycle authority |
| Publication receipts and validation trace | `.octon/state/evidence/validation/publication/**` | Review must confirm runtime-facing publications are backed by retained receipts rather than file presence alone |
| Review enforcement and automation | `.octon/framework/assurance/runtime/**` and `.octon/framework/orchestration/runtime/workflows/**` | Durable home for the review workflow and any automation promoted from this proposal |

## Boundary Rules

- `framework/**` and `instance/**` remain the only authored authority
  surfaces.
- `state/**` remains authoritative only as mutable operational truth and
  retained evidence.
- `generated/**` remains rebuildable and non-authoritative even when runtime
  reads it.
- Proposal packages remain non-canonical before, during, and after this
  review.
- Raw `inputs/**` paths never become direct runtime or policy dependencies.
- Migration completion may be declared only from retained receipts plus live
  canonical surfaces, not from repository shape alone.
- Review output bundles belong under `state/evidence/migration/**`, not under
  `generated/**`.
- Repo-root adapters and any remaining legacy compatibility shims may not
  become writable peer authority surfaces.
- Absence of legacy paths must be treated as a required cutover signal, not
  as an optional hygiene improvement.
