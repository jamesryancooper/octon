# `.octon`: Super-Root

`.octon/` is Octon's single authoritative super-root. Its top level is
class-first, not domain-first.

## Class Roots

| Root | Role |
| --- | --- |
| `framework/` | Portable authored Octon core plus portable helper assets only |
| `instance/` | Repo-specific durable authored authority |
| `inputs/` | Non-authoritative additive and exploratory inputs |
| `state/` | Operational truth and retained evidence |
| `generated/` | Rebuildable outputs only |

Only `framework/**` and `instance/**` are authored authority. Raw
`inputs/**` never participate directly in runtime or policy decisions.
`framework/**` must not contain repo-local authority, mutable operational
truth, retained evidence, or generated outputs.
`instance/**` is the canonical repo-owned authority layer. Most of
`instance/**` is instance-native; only declared enabled overlay points may
carry overlay-capable repo authority.

`state/**` is class-organized into three lifecycle subdomains:

- `state/continuity/**` for active resumable work state
- `state/evidence/**` for retained operational trace and receipts
- `state/control/**` for mutable current-state publication and quarantine truth

## Constitutional Kernel

`/.octon/framework/constitution/**` is the supreme repo-local control regime
beneath non-waivable external obligations, break-glass controls, and live
revocations.

Core kernel artifacts:

- `/.octon/framework/constitution/CHARTER.md`
- `/.octon/framework/constitution/charter.yml`
- `/.octon/framework/constitution/precedence/{normative.yml,epistemic.yml}`
- `/.octon/framework/constitution/obligations/{fail-closed.yml,evidence.yml}`
- `/.octon/framework/constitution/ownership/roles.yml`
- `/.octon/framework/constitution/contracts/registry.yml`
- `/.octon/framework/constitution/contracts/objective/**`
- `/.octon/framework/constitution/contracts/authority/**`
- `/.octon/framework/constitution/contracts/runtime/**`
- `/.octon/framework/constitution/contracts/assurance/**`
- `/.octon/framework/constitution/contracts/disclosure/**`
- `/.octon/framework/constitution/support-targets.schema.json`

`/.octon/framework/cognition/_meta/architecture/specification.md` remains the
canonical cross-subsystem topology and placement contract, but it is
subordinate to the constitutional kernel and must not restate competing
constitutional authority.

## Instance Authority

### Instance-Native Surfaces

- `instance/manifest.yml`
- `instance/ingress/**`
- `instance/charter/**`
- `instance/bootstrap/**`
- `instance/locality/**`
- `instance/cognition/context/**`
- `instance/cognition/decisions/**`
- `instance/capabilities/runtime/**`
- `instance/orchestration/missions/**`
- `instance/extensions.yml`

### Overlay-Capable Surfaces

Overlay-capable repo authority is legal only when
`framework/overlay-points/registry.yml` declares the point and
`instance/manifest.yml#enabled_overlay_points` enables it.

| Overlay point | Instance path | Merge mode | Precedence |
| --- | --- | --- | ---: |
| `instance-governance-policies` | `instance/governance/policies/**` | `replace_by_path` | 10 |
| `instance-governance-contracts` | `instance/governance/contracts/**` | `replace_by_path` | 20 |
| `instance-governance-adoption` | `instance/governance/adoption/**` | `replace_by_path` | 25 |
| `instance-governance-retirement` | `instance/governance/retirement/**` | `replace_by_path` | 26 |
| `instance-governance-exclusions` | `instance/governance/exclusions/**` | `replace_by_path` | 27 |
| `instance-governance-capability-packs` | `instance/governance/capability-packs/**` | `replace_by_path` | 28 |
| `instance-governance-decisions` | `instance/governance/decisions/**` | `append_only` | 29 |
| `instance-execution-roles-runtime` | `instance/execution-roles/runtime/**` | `merge_by_id` | 30 |
| `instance-assurance-runtime` | `instance/assurance/runtime/**` | `append_only` | 40 |

No other `instance/**` subtree is overlay-capable in v1.

## Canonical Bootstrap And Ingress

- Canonical constitutional kernel: `/.octon/framework/constitution/`
- Supreme repo-local charter: `/.octon/framework/constitution/CHARTER.md`
- Canonical constitutional manifest:
  `/.octon/framework/constitution/charter.yml`
- Canonical normative authority precedence:
  `/.octon/framework/constitution/precedence/normative.yml`
- Canonical epistemic grounding precedence:
  `/.octon/framework/constitution/precedence/epistemic.yml`
- Canonical fail-closed obligations:
  `/.octon/framework/constitution/obligations/fail-closed.yml`
- Canonical evidence obligations:
  `/.octon/framework/constitution/obligations/evidence.yml`
- Canonical overlay registry: `/.octon/framework/overlay-points/registry.yml`
- Repo-side overlay enablement: `/.octon/instance/manifest.yml#enabled_overlay_points`
- Projected ingress surface: `/.octon/AGENTS.md`
- Canonical ingress: `/.octon/instance/ingress/AGENTS.md`
- Canonical bootstrap docs: `/.octon/instance/bootstrap/`
- Canonical locality authority:
  `/.octon/instance/locality/{manifest.yml,registry.yml,scopes/<scope-id>/scope.yml}`
- Canonical scope-local durable context:
  `/.octon/instance/cognition/context/scopes/<scope-id>/`
- Canonical locality quarantine:
  `/.octon/state/control/locality/quarantine.yml`
- Canonical extension actual/quarantine state:
  `/.octon/state/control/extensions/{active.yml,quarantine.yml}`
- Canonical raw additive extension inputs:
  `/.octon/inputs/additive/extensions/<pack-id>/`
- Canonical repo continuity:
  `/.octon/state/continuity/repo/`
- Canonical workspace objective brief:
  `/.octon/instance/charter/workspace.md`
- Canonical workspace intent contract:
  `/.octon/instance/charter/workspace.yml`
- Historical compatibility workspace objective shim:
  `/.octon/instance/bootstrap/OBJECTIVE.md`
- Historical compatibility workspace intent shim:
  `/.octon/instance/cognition/context/shared/intent.contract.yml`
- Canonical run-contract control roots:
  `/.octon/state/control/execution/runs/<run-id>/`
- Canonical run lifecycle control files:
  `/.octon/state/control/execution/runs/<run-id>/{run-manifest.yml,runtime-state.yml,rollback-posture.yml,checkpoints/**}`
- Canonical mission continuity:
  `/.octon/state/continuity/repo/missions/`
- Canonical scope continuity:
  `/.octon/state/continuity/scopes/<scope-id>/`
- Canonical retained operational evidence:
  `/.octon/state/evidence/`
- Canonical retained control-plane evidence:
  `/.octon/state/evidence/control/execution/`
- Canonical publication validation receipts:
  `/.octon/state/evidence/validation/publication/`
- Canonical lab-authored scenario and replay surfaces:
  `/.octon/framework/lab/`
- Canonical observability-authored measurement and intervention surfaces:
  `/.octon/framework/observability/`
- Canonical retained lab evidence:
  `/.octon/state/evidence/lab/`
- Canonical effective locality outputs:
  `/.octon/generated/effective/locality/`
- Canonical effective capability-routing outputs:
  `/.octon/generated/effective/capabilities/`
- Canonical effective extension outputs:
  `/.octon/generated/effective/extensions/`
- Canonical derived cognition outputs:
  `/.octon/generated/cognition/`
- Canonical mission summaries:
  `/.octon/generated/cognition/summaries/missions/`
- Canonical operator digests:
  `/.octon/generated/cognition/summaries/operators/`
- Canonical ADR discovery index:
  `/.octon/instance/cognition/decisions/index.yml`
- Local generated readable decision summary (when generated outputs are
  present locally):
  `/.octon/generated/cognition/summaries/decisions.md`
- Canonical raw exploratory proposal inputs:
  `/.octon/inputs/exploratory/proposals/<kind>/<proposal_id>/`
- Canonical archived proposal inputs:
  `/.octon/inputs/exploratory/proposals/.archive/<kind>/<proposal_id>/`
- Canonical generated proposal discovery:
  `/.octon/generated/proposals/registry.yml`
- Canonical repo context and ADRs: `/.octon/instance/cognition/`
- Canonical repo missions: `/.octon/instance/orchestration/missions/`
- Canonical mission control truth:
  `/.octon/state/control/execution/missions/<mission-id>/`
- Canonical mission autonomy policy:
  `/.octon/instance/governance/policies/mission-autonomy.yml`
- Canonical ownership registry:
  `/.octon/instance/governance/ownership/registry.yml`
- Root manifest: `/.octon/octon.yml`
- Execution authorization contracts:
  `/.octon/framework/engine/runtime/spec/execution-authorization-v1.md`,
  `execution-request-v3.schema.json`, `execution-grant-v1.schema.json`,
  `execution-receipt-v3.schema.json`, `policy-receipt-v2.schema.json`,
  `policy-digest-v2.md`, and `executor-profile-v1.schema.json`
- Export workflow: `/.octon/framework/orchestration/runtime/workflows/meta/export-harness/`
- Canonical structural architecture contract:
  `/.octon/framework/cognition/_meta/architecture/specification.md`

Repo-root `AGENTS.md` and `CLAUDE.md` are thin adapters to `/.octon/AGENTS.md`
only. They must be a symlink to `/.octon/AGENTS.md` or a byte-for-byte parity
copy and may not add runtime or policy text.

## Locality And Scope Registry

Locality is root-owned under `instance/locality/**`, not implemented through
descendant `.octon/` roots, sidecars, or ancestor-chain lookup. In v1:

- each `scope_id` declares exactly one `root_path`
- each target path resolves to zero or one active scope
- overlapping active scopes fail closed and quarantine locally
- missions may reference scopes, but they do not define scope identity
- runtime-facing locality consumers use
  `generated/effective/locality/**`, which is compiled and non-authoritative
- runtime-facing capability consumers use
  `generated/effective/capabilities/**`, which is compiled and
  non-authoritative
- runtime and policy trust these effective families only when freshness,
  generation-lock coherence, and publication receipts remain current
- derived cognition summaries, graphs, and projections live under
  `generated/cognition/**` and remain rebuildable only

When work is primarily owned by one declared scope, active continuity belongs
under `state/continuity/scopes/<scope-id>/**`. Repo-wide and cross-scope work
remains under `state/continuity/repo/**`.

## Portability

Portability is profile-driven through `octon.yml`, not a raw copy of the whole
tree. `bootstrap_core` is the install contract completed by `/init`;
`repo_snapshot` exports `octon.yml`, `framework/**`, `instance/**`, and the
clean published enabled-pack dependency closure through `/export-harness`; `pack_bundle`
exports selected packs plus dependency closure only and does not apply repo
trust activation policy; `full_fidelity` is advisory only and uses a normal
Git clone. `inputs/exploratory/**`,
`state/**`, and `generated/**` stay out of clean bootstrap and repo snapshots.

This is architectural transport intent, not a blanket live support claim. The
currently proved live consequential envelope is the retained
`MT-B / WT-2 / LT-REF / LOC-EN` tuple using the `repo-shell` host adapter and
the `repo-local-governed` model adapter. Broader adapter, locale, context, or
cross-environment support requires explicit support-target declaration plus
retained disclosure proof before it may be published as supported or
reduced-live.

Raw additive pack compatibility and provenance travel with
`inputs/additive/extensions/<pack-id>/pack.yml`.
Repo trust stays authored in `instance/extensions.yml`.

`octon.yml#policies.generated_commit_defaults` defines which generated families
are committed for reviewability versus rebuilt locally by default.

## Proposal Workspace

Proposal packages live only under
`/.octon/inputs/exploratory/proposals/<kind>/<proposal_id>/` and remain
non-canonical even while they live inside the super-root. Their lifecycle
authority lives in `proposal.yml` and the subtype manifest. Proposal-local
reading order then flows through `navigation/source-of-truth-map.md`,
subtype working docs, `navigation/artifact-catalog.md`, and finally the
generated registry as discovery-only projection.

Runtime and policy consumers must never read proposal paths directly.
Proposal discovery lives only in `/.octon/generated/proposals/registry.yml`,
which is committed by default, rebuilt deterministically from manifests, and
remains non-authoritative.

## Mission-Scoped Reversible Autonomy

Mission-Scoped Reversible Autonomy is Octon's canonical operating model for
long-running and always-running autonomous agents.

- durable mission authority lives under
  `instance/orchestration/missions/<mission-id>/{mission.yml,mission.md}`
- run-contract control roots live under
  `state/control/execution/runs/<run-id>/`
- run lifecycle control files live under
  `state/control/execution/runs/<run-id>/{run-manifest.yml,runtime-state.yml,rollback-posture.yml,checkpoints/**}`
- canonical approval control roots live under
  `state/control/execution/approvals/**`
- canonical exception and revocation roots live under
  `state/control/execution/{exceptions,revocations}/**`
- mutable mission control truth lives under
  `state/control/execution/missions/<mission-id>/`
- retained control-plane mutation evidence lives under
  `state/evidence/control/execution/**`
- retained execution evidence remains under `state/evidence/runs/**`
- canonical run receipts and replay pointers live under
  `state/evidence/runs/<run-id>/{receipts/**,checkpoints/**,replay-pointers.yml,trace-pointers.yml,evidence-classification.yml}`
- mission continuity lives under `state/continuity/repo/missions/<mission-id>/`
- derived `now / next / recent / recover` views live under
  `generated/cognition/summaries/missions/<mission-id>/`
- derived machine-readable mission views live under
  `generated/cognition/projections/materialized/missions/<mission-id>/mission-view.yml`

Seed-before-active is mandatory for mission-scoped autonomy.
Mission authority stays under `instance/orchestration/missions/**`, and the
activation path must seed control truth, continuity, route publication,
generated summaries, and `mission-view.yml` before autonomous active or paused
runtime state is legal.

Wave 1 objective binding cutover makes mission the continuity container while
run contracts become the atomic execution unit for consequential runs. Mission-
only execution remains an explicit transitional compatibility path until a
later lifecycle wave moves primary execution-time state to run roots.

Wave 2 authority normalization routes approvals, exceptions, revocations, and
retained decision evidence through canonical authority artifacts. Labels,
comments, checks, and similar host affordances may project approval intent,
but they never become authority without those runtime artifacts.

MSRAOM runtime closeout is recorded in
`/.octon/instance/cognition/decisions/067-mission-scoped-reversible-autonomy-final-closeout-cutover.md`.
Proposal-lineage closeout is recorded separately in
`/.octon/instance/cognition/decisions/068-mission-scoped-reversible-autonomy-provenance-alignment-closeout.md`
and
`/.octon/instance/cognition/context/shared/migrations/2026-03-25-mission-scoped-reversible-autonomy-provenance-alignment-closeout/plan.md`.
Proposal packets remain historical lineage only.

No autonomous runtime path may silently fall back to mission-less execution,
and no external UI, chat transcript, or in-memory state may become a second
authoritative control plane.

## Generated Contract

Generated outputs are class-rooted, rebuildable, and never source-of-truth.

- runtime-facing published outputs live only under `generated/effective/**`
- derived cognition outputs live only under `generated/cognition/**`
- proposal discovery lives only under `generated/proposals/registry.yml`
- retained validation and assurance receipts live under `state/evidence/**`,
  not under `generated/**`
- machine-readable publication receipts live under
  `state/evidence/validation/publication/**`
- `generated/artifacts/**`, `generated/assurance/**`, and
  `generated/effective/assurance/**` are not canonical Packet 10 families

## Human-Led Zone

Human-led ideation lives under `/.octon/inputs/exploratory/ideation/**`.
Autonomous access is blocked unless a human explicitly scopes it.
