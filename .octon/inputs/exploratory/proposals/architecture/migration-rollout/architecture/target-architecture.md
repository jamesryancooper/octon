# Target Architecture

## Decision

Ratify one final migration-completion review contract for the five-class
super-root rollout where:

- migration completion is proved from live canonical surfaces plus retained
  migration evidence, not inferred from current tree shape alone
- every ratified packet from 1 through 14 has correlated design lineage,
  migration-plan lineage, retained cutover receipts, and live canonical
  implementation proof
- review is evidence-first and fail-closed: unresolved critical or high
  findings block any claim that the migration is complete
- the review explicitly re-verifies the settled Packet 15 guarantees:
  one authority model, profile-driven export/install semantics, raw-input
  runtime isolation, repo continuity before scope continuity, extension and
  proposal internalization, behaviorally complete `repo_snapshot`, thin shim
  behavior, and rollback-safe retained evidence
- legacy `.proposals/**`, numbered architecture proposal paths, mixed-path
  runtime or policy readers, and external-workspace assumptions are treated as
  blocking migration regressions if they remain in live authoring, runtime, or
  policy flows
- repo-root adapters such as `AGENTS.md` and `CLAUDE.md` remain thin parity or
  read-through shims only and never become a second authority surface
- final review outputs live under `state/evidence/migration/**` as retained
  evidence and are never treated as generated cache

This proposal converts Packet 15 from a sequencing contract into the final
completion-review contract that proves the repository now actually matches the
ratified super-root blueprint.

## Status

- status: accepted proposal drafted from ratified Packet 15 inputs and the
  live post-cutover repository state
- proposal area: post-migration completion review, receipt correlation,
  legacy-retirement verification, snapshot completeness verification, shim
  retirement validation, and rollback-safe final sign-off
- implementation order: 15 of 15 in the ratified proposal sequence
- dependencies:
  - `super-root-semantics-and-taxonomy`
  - `root-manifest-profiles-and-export-semantics`
  - `framework-core-architecture`
  - `repo-instance-architecture`
  - `overlay-and-ingress-model`
  - `locality-and-scope-registry`
  - `state-evidence-continuity`
  - `inputs-additive-extensions`
  - `inputs-exploratory-proposals`
  - `generated-effective-cognition-registry`
  - `memory-context-adrs-operational-decision-evidence`
  - `capability-routing-host-integration`
  - `portability-compatibility-trust-provenance`
  - `validation-fail-closed-quarantine-staleness`
- migration role: review and confirm that the implemented repository matches
  the ratified five-class super-root without dual authority, raw-input
  leakage, legacy workspace coupling, missing receipts, or ambiguous rollback
  semantics

## Why This Proposal Exists

Packets 1 through 14 defined and landed the target topology.
The live repository now already shows most of the intended endpoint:

- `.octon/README.md` is class-first and root-owned
- `.octon/octon.yml` binds the five class roots and the ratified profiles
- `framework/manifest.yml` and `instance/manifest.yml` are present at the
  ratified schema generations
- `instance/extensions.yml` plus
  `state/control/extensions/{active,quarantine}.yml` implement the desired/
  actual/quarantine split
- `generated/effective/{extensions,locality,capabilities}/**` is published
- `state/continuity/repo/**` and `state/continuity/scopes/**` both exist
- `inputs/exploratory/proposals/**` is the active proposal workspace and the
  packet proposals are archived under `.archive/**`
- `state/evidence/migration/**` already contains retained cutover bundles
- `.proposals/**` is gone
- repo-root `AGENTS.md` and `CLAUDE.md` remain byte-identical adapters to
  `.octon/AGENTS.md`

What remains is not another topology decision.
What remains is a governed answer to these final-review questions:

- Which evidence proves each ratified phase actually landed?
- How do we prove the repo does not still rely on legacy path assumptions?
- How do we verify that snapshot/export semantics are complete rather than
  merely documented?
- How do we prove continuity sequencing, extension publication, and proposal
  internalization stayed correct after cutover?
- How do we close migration without losing rollback trace or reviving dual
  authority?

Packet 15 exists to make that review itself an explicit architecture surface.

### Current Live Signals This Proposal Must Verify

| Current live signal | Current live source | Review implication |
| --- | --- | --- |
| The five class roots and profile-driven export model are already encoded in durable docs and manifests | `.octon/README.md`, `.octon/octon.yml`, `.octon/framework/manifest.yml`, `.octon/instance/manifest.yml` | Review must prove topology and profile semantics are aligned across live authority surfaces rather than treating directory presence as enough |
| Desired extension state, actual extension state, and quarantine state are already split | `.octon/instance/extensions.yml`, `.octon/state/control/extensions/{active,quarantine}.yml` | Review must prove Packet 8, Packet 13, and Packet 14 remained coherent after migration |
| Runtime-facing effective publications already exist | `.octon/generated/effective/{extensions,locality,capabilities}/**` | Review must prove runtime trust terminates at compiled publications rather than raw inputs or legacy mixed paths |
| Migration plans and retained cutover bundles already exist | `.octon/instance/cognition/context/shared/migrations/**`, `.octon/state/evidence/migration/**` | Review must correlate live state to retained receipts and plans rather than rely on memory or ad hoc claims |
| Ratified packet proposals 1 through 14 are archived | `.octon/inputs/exploratory/proposals/.archive/architecture/**` | Review must prove proposal-local design intent was promoted and retired cleanly |
| Proposal discovery is already generated and committed | `.octon/generated/proposals/registry.yml` | Review must confirm the registry remains non-authoritative while still reflecting current active and archived proposal lineage |
| Repo and scope continuity both live under `state/**` | `.octon/state/continuity/repo/**`, `.octon/state/continuity/scopes/**` | Review must confirm repo continuity landed before scope continuity and that scope continuity depends on validated locality |
| Legacy external proposal workspace is absent | absence of `.proposals/**` in the live repository | Review must treat absence of legacy workspace as a required cutover gate, not an incidental cleanup |

## Review Scope

This proposal defines all of the following:

- the final evidence model for declaring the migration complete
- the mandatory review layers and their isolation rules
- the severity model and completion verdict rules
- the phase-by-phase review matrix for ratified phases 1 through 15
- the completion gates for topology, sequencing, publication, snapshot
  completeness, legacy retirement, and rollback traceability
- the final retained output bundle contract for migration-completion review

## Non-Goals

- re-litigating the five-class super-root
- re-opening extension or proposal placement decisions
- treating proposal-local text as lasting authority after promotion
- reviving `.proposals/**`, mixed-path readers, or external-workspace flows
- introducing a v1 `repo_snapshot_minimal` profile
- creating permissive fallback from required generated effective outputs to
  raw `inputs/**`
- declaring completion based only on repository appearance without retained
  receipts

## Review Contract

### Evidence Families

| Review concern | Required review sources | Why they are required |
| --- | --- | --- |
| Ratified design baseline | `resources/octon_packet_15_migration_and_rollout.md` and `resources/octon_ratified_architectural_blueprint.md` | Define the non-negotiable Packet 15 review contract and the settled blueprint invariants |
| Live canonical topology and authority | `.octon/octon.yml`, `.octon/README.md`, `.octon/framework/manifest.yml`, `.octon/instance/manifest.yml`, `.octon/instance/bootstrap/START.md` | Prove the current live repository matches the intended authority model |
| Migration execution lineage | `.octon/instance/cognition/context/shared/migrations/index.yml`, matching `plan.md` files, and related ADRs | Prove each phase had an explicit authored migration record |
| Retained cutover evidence | `.octon/state/evidence/migration/**` | Prove migration claims are backed by retained receipts, command logs, inventories, and validation notes |
| Archived packet lineage | `.octon/inputs/exploratory/proposals/.archive/architecture/**` | Prove the ratified packet proposals were promoted and retired rather than left as active authority |
| Runtime-facing publication state | `.octon/state/control/**`, `.octon/state/evidence/validation/publication/**`, and `.octon/generated/effective/**` | Prove generated trust, quarantine, and active-state publication remain coherent after migration |
| Legacy-retirement signals | repo-root adapters, absence of `.proposals/**`, absence of numbered proposal directories, and grep results for legacy path assumptions | Prove legacy surfaces are actually retired or reduced to thin adapters only |

### Mandatory Audit Layers

The final review uses four mandatory layers adapted from the bounded
post-migration audit model.
No layer may be skipped just because the repo looks clean.

1. Grep sweep:
   Search for legacy paths, mixed-path assumptions, raw-input runtime or
   policy dependencies, numbered proposal directories, obsolete snapshot
   profiles, and shim misuse.
2. Cross-reference audit:
   Extract canonical paths from manifests, docs, migration plans, ADRs, and
   retained receipts, then verify every cited path resolves on disk.
3. Semantic read-through:
   Read the core topology, bootstrap, manifest, state, generated, and
   migration-evidence surfaces end-to-end to catch conceptual drift that a
   string search would miss.
4. Self-challenge:
   Re-check the coverage set, try to disprove clean findings, and search for
   counter-examples outside the initial sweep so the review cannot be passed by
   a lucky first pass.

### Severity Model

| Severity | Meaning in this review |
| --- | --- |
| CRITICAL | Migration claims are false in a way that can misroute runtime, policy, or authority resolution |
| HIGH | Live docs, manifests, validators, or workflows still encode a legacy or contradictory migration assumption |
| MEDIUM | Review-facing or operator-facing surfaces are stale or incomplete but do not currently change runtime authority |
| LOW | Cosmetic drift, redundant residue in clearly historical material, or clarity issues that do not change behavior |

No clean-completion verdict is allowed while any unresolved `CRITICAL` or
`HIGH` finding remains open.

## Phase Review Matrix

| Phase | What the review must prove |
| --- | --- |
| 1. Ratify super-root semantics and overlay model | The five-class super-root is the only live topology, the overlay model is machine-declared, and no alternate topology remains active in docs, manifests, or runtime consumers |
| 2. Extend root and companion manifests | `octon.yml`, `framework/manifest.yml`, and `instance/manifest.yml` are present at the ratified schema generations and expose the required class-root, versioning, profile, and overlay metadata |
| 3. Enforce raw-input dependency ban | Runtime and policy flows remain fail-closed on raw `inputs/**` dependency violations and do not consume raw extension or proposal paths directly |
| 4. Introduce class roots with compatibility shims | `framework/`, `instance/`, `inputs/`, `state/`, and `generated/` exist as the unambiguous canonical roots, while repo-root adapters remain thin, non-authoritative shims only |
| 5. Move generated/effective outputs | Runtime-facing compiled outputs publish only from `generated/effective/**` and proposal discovery publishes from `generated/proposals/registry.yml` |
| 6. Move repo continuity and retained evidence | Repo continuity lives under `state/continuity/repo/**`, retained evidence lives under `state/evidence/**`, and migration receipts are preserved under `state/evidence/migration/**` |
| 7. Move durable repo authority into `instance/**` | Canonical ingress, bootstrap, repo context, decisions, missions, repo-native capabilities, desired extension config, and overlay-capable repo authority resolve through `instance/**` rather than legacy mixed paths |
| 8. Introduce locality registry and scope validation | `instance/locality/**` is authoritative, locality generation is live, and invalid locality is quarantined locally rather than tolerated silently |
| 9. Introduce scope continuity | Scope continuity exists only under `state/continuity/scopes/<scope-id>/**` for validated scopes and does not predate locality cutover |
| 10. Internalize extension packs | Raw extension packs live under `inputs/additive/extensions/**`, are discoverable there, and are excluded from direct runtime trust |
| 11. Add desired/actual/quarantine/compiled extension pipeline | Desired config, actual active state, quarantine state, and compiled effective outputs remain distinct, coherent, and publication-safe |
| 12. Internalize proposal workspace | Active and archived proposals live only under `inputs/exploratory/proposals/**`, packet numbering is not encoded in live paths, and external workspace assumptions are retired |
| 13. Move proposal registry into `generated/**` | `generated/proposals/registry.yml` is committed, discoverable, and explicitly non-authoritative |
| 14. Update routing, graph, projection, and generation pipelines | Capability routing and other generated read models consume canonical class-root inputs only and no longer depend on legacy mixed paths |
| 15. Remove legacy mixed-path and external-workspace support | No runtime, policy, or authoring workflow depends on legacy paths; any remaining shim exists only as a thin non-authoritative adapter with explicit retirement evidence |

## Completion Gates

| Gate | Pass condition | Blocking examples |
| --- | --- | --- |
| Authority closure | Only `framework/**` and `instance/**` remain authored authority | Repo-root adapters or legacy paths become editable peer authority surfaces |
| State sequencing | Repo continuity and retained evidence are under `state/**`, and scope continuity depends on locality | Scope continuity exists without validated locality or appears before repo continuity cutover evidence |
| Input isolation | Raw `inputs/**` remain non-authoritative and non-runtime | Runtime or policy consumers read raw extension or proposal inputs directly |
| Snapshot completeness | `repo_snapshot` still requires enabled-pack dependency closure and no minimal v1 profile exists | Snapshot semantics omit enabled packs, tolerate missing closure, or revive `repo_snapshot_minimal` |
| Publication coherence | Active state, quarantine state, publication receipts, and generated effective outputs align | Published generation ids, locks, or receipts disagree or are missing |
| Legacy retirement | `.proposals/**`, numbered proposal paths, mixed-path readers, and obsolete write targets are absent from live flows | Grep sweep finds active legacy consumers or writable shim paths |
| Rollback traceability | Retained migration receipts and plans are sufficient to explain and repeat cutover state | Cutover claims depend on memory, proposal-local text, or destructive restoration of abandoned authority surfaces |

## Final Review Outputs

Promotion of this proposal should create one retained completion-review bundle
under:

```text
state/evidence/migration/<YYYY-MM-DD>-migration-rollout-review/
```

That bundle must include:

- `bundle.yml`
- `evidence.md`
- `commands.md`
- `validation.md`
- `inventory.md`

If the review also records a final migration-completion ADR, it belongs under
`instance/cognition/decisions/**`.

## Completion Rule

The migration may be declared complete only when all of the following are
true:

1. Every ratified phase in the review matrix has both live proof and retained
   proof.
2. No unresolved `CRITICAL` or `HIGH` findings remain.
3. Legacy external-workspace and mixed-path assumptions are absent from
   runtime, policy, and authoring flows.
4. Any surviving shim is demonstrably thin, non-authoritative, and eligible
   for retirement under the Packet 15 shim rule.
5. The final completion review itself is retained as operational evidence
   under `state/evidence/migration/**`.
