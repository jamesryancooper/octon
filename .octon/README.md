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

## Canonical Bootstrap And Ingress

- Canonical ingress: `/.octon/instance/ingress/AGENTS.md`
- Canonical bootstrap docs: `/.octon/instance/bootstrap/`
- Root manifest: `/.octon/octon.yml`
- Export workflow: `/.octon/framework/orchestration/runtime/workflows/meta/export-harness/`
- Canonical architecture contract:
  `/.octon/framework/cognition/_meta/architecture/specification.md`

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
