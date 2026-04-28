# Repository Baseline Audit

## Audit date

2026-04-26

## Live repository posture observed

- Root README describes Octon as controlled autonomy, not reckless autonomy. It says Octon binds consequential runs to explicit objectives, run contracts, scoped capabilities, authorization decisions, retained evidence, rollback posture, continuity state, and review/disclosure surfaces.
- Root README states Octon is pre-1.0 and currently supports bounded admitted repo-local work, not universal live support for all future-facing designs.
- The `.octon` super-root divides authority into `framework`, `instance`, `state`, `generated`, and `inputs`.
- The umbrella architecture specification says durable authored authority may live only under `framework/**` and `instance/**`; `state/**` is operational truth split into control/evidence/continuity; `generated/**` is rebuildable and never mints authority; `inputs/**` is non-authoritative.
- Bootstrap START defines ingress, constitutional/workspace binding, architecture preflight, continuity resumption, and `octon run start --contract` for consequential runs.
- Ingress manifest defines mandatory reads, optional orientation, continuity reads, adapter parity targets, closeout workflow ref, and human-led blocked roots.
- Run lifecycle v1 defines canonical run roots, states, journal reconstruction, context-pack requirement, authorized-effect token readiness, and closeout gates.
- Execution authorization v1 defines engine-owned `authorize_execution(request) -> GrantBundle` and requires typed `AuthorizedEffect` verification before material side effects.
- Context Pack Builder v1 deterministically creates retained context evidence before authorization and explicitly rejects generated summaries, chat, labels, host UI, and raw inputs as authority sources.
- Support targets use bounded admitted support and default-deny posture. Live support remains finite and repo-local in the README framing.
- CLI currently exposes run-first lifecycle commands, including `run start --contract`, `inspect`, `resume`, `checkpoint`, `close`, `replay`, and `disclose`. It does not expose a first-class `start/profile/plan/arm` compiler flow.

## Baseline conclusion

The repository already has mature run-level governance and evidence machinery. The missing product-level step is a compiler that turns repo adoption/orientation/objective shaping into a first safe run-contract candidate without expanding live support claims.
