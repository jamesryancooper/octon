# `.octon`: Super-Root

`.octon/` is Octon's single authoritative super-root. Its top level is
class-first, not domain-first.

## Class Roots

| Root | Role |
| --- | --- |
| `framework/` | Portable authored Octon core |
| `instance/` | Repo-specific durable authored authority |
| `inputs/` | Non-authoritative additive and exploratory inputs |
| `state/` | Operational truth and retained evidence |
| `generated/` | Rebuildable outputs only |

Only `framework/**` and `instance/**` are authored authority. Raw
`inputs/**` never participate directly in runtime or policy decisions.

## Canonical Bootstrap And Ingress

- Canonical ingress: `/.octon/instance/ingress/AGENTS.md`
- Canonical bootstrap docs: `/.octon/instance/bootstrap/`
- Root manifest: `/.octon/octon.yml`
- Canonical architecture contract:
  `/.octon/framework/cognition/_meta/architecture/specification.md`

## Portability

Portability is profile-driven through `octon.yml`, not a raw copy of the whole
tree. `bootstrap_core` ships framework plus minimal instance metadata;
`repo_snapshot` ships framework, instance, and enabled additive packs; `state`
and most `generated` surfaces are excluded from clean bootstrap.

## Human-Led Zone

Human-led ideation lives under `/.octon/inputs/exploratory/ideation/**`.
Autonomous access is blocked unless a human explicitly scopes it.
