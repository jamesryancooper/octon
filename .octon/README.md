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

## Instance Authority

### Instance-Native Surfaces

- `instance/manifest.yml`
- `instance/ingress/**`
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
| `instance-agency-runtime` | `instance/agency/runtime/**` | `merge_by_id` | 30 |
| `instance-assurance-runtime` | `instance/assurance/runtime/**` | `append_only` | 40 |

No other `instance/**` subtree is overlay-capable in v1.

## Canonical Bootstrap And Ingress

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
- Canonical effective locality outputs:
  `/.octon/generated/effective/locality/`
- Canonical repo context and ADRs: `/.octon/instance/cognition/`
- Canonical repo missions: `/.octon/instance/orchestration/missions/`
- Root manifest: `/.octon/octon.yml`
- Export workflow: `/.octon/framework/orchestration/runtime/workflows/meta/export-harness/`
- Canonical architecture contract:
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

## Portability

Portability is profile-driven through `octon.yml`, not a raw copy of the whole
tree. `bootstrap_core` is the install contract completed by `/init`;
`repo_snapshot` exports `octon.yml`, `framework/**`, `instance/**`, and the
enabled-pack dependency closure through `/export-harness`; `pack_bundle`
exports selected packs plus dependency closure only; `full_fidelity` is
advisory only and uses a normal Git clone. `state/**` and `generated/**` stay
out of clean bootstrap and repo snapshots.

## Human-Led Zone

Human-led ideation lives under `/.octon/inputs/exploratory/ideation/**`.
Autonomous access is blocked unless a human explicitly scopes it.
