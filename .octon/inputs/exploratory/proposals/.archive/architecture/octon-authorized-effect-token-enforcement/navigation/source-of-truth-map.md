# Source of Truth Map

## Canonical authority hierarchy used by this packet

| Layer | Role | Current source(s) | Why it matters here |
|---|---|---|---|
| Constitutional kernel | Supreme repo-local control regime | `/.octon/framework/constitution/**` | Prevents token enforcement from becoming a rival Control Plane. |
| Umbrella architecture | Class-root placement and generated/read-model discipline | `/.octon/framework/cognition/_meta/architecture/specification.md` | Confirms proposals stay non-authoritative, state/evidence placement, and generated non-authority. |
| Proposal standard | Packet shape and lifecycle rules | `/.octon/framework/scaffolding/governance/patterns/proposal-standard.md` | Defines required manifests, path contract, promotion scope, and non-canonical status. |
| Architecture proposal standard | Architecture packet requirements | `/.octon/framework/scaffolding/governance/patterns/architecture-proposal-standard.md` | Requires target architecture, implementation plan, acceptance criteria, and source-of-truth map. |
| Runtime authorization contract | Engine-owned material execution boundary | `/.octon/framework/engine/runtime/spec/execution-authorization-v1.md` | The token can only be derived from this boundary; it does not replace it. |
| Authorized Effect Token contract | Existing token contract | `/.octon/framework/engine/runtime/spec/authorized-effect-token-v1.md` | Already declares typed effect tokens as required side-effect API inputs. |
| Authorization boundary coverage | Coverage proof contract | `/.octon/framework/engine/runtime/spec/authorization-boundary-coverage-v1.md` | Already requires inventory, negative controls, retained authority evidence, and fail-closed coverage. |
| Material side-effect inventory | Material effect classification schema | `/.octon/framework/engine/runtime/spec/material-side-effect-inventory-v1.schema.json` | Provides the machine-readable path family substrate to connect material APIs to effect tokens. |
| Runtime specs | Request/grant/receipt/event/lifecycle/evidence semantics | `/.octon/framework/engine/runtime/spec/**` | Must carry token minting, consumption, and receipt semantics. |
| Runtime implementation | Governed Agent Runtime implementation | `/.octon/framework/engine/runtime/crates/**` | Must enforce tokens in code, not only in documentation. |
| Support targets | Live support universe and proof expectations | `/.octon/instance/governance/support-targets.yml` | Ensures token hardening does not widen support claims. |
| Capability subsystem | Capability taxonomy and pack governance | `/.octon/framework/capabilities/**`, `/.octon/instance/governance/capability-packs/**` | Token scopes must align with capability packs and admissions. |
| Control state | Mutable execution truth | `/.octon/state/control/execution/**` | Token issuance, revocation, and consumption state materialize here. |
| Retained evidence | Closure and replay evidence | `/.octon/state/evidence/**` | Token lifecycle, negative tests, and coverage proof materialize here. |
| Generated/read models | Derived operator/runtime projections only | `/.octon/generated/**` | May display token status but must not mint, validate, or consume tokens as authority. |

## Proposal-local authority for this packet

| File | Role |
|---|---|
| `proposal.yml` | Lifecycle authority for this temporary proposal. |
| `architecture-proposal.yml` | Subtype manifest. |
| `navigation/source-of-truth-map.md` | Manual precedence and boundary map. |
| `architecture/target-architecture.md` | Intended end state for the promoted changes. |
| `architecture/acceptance-criteria.md` | Conditions that prove the target architecture has landed. |
| `architecture/implementation-plan.md` | Implementable workstreams. |

## Non-authoritative surfaces explicitly excluded

- `inputs/**` outside this packet as runtime/policy dependencies.
- this packet path after promotion.
- generated proposal registry entries.
- generated operator summaries.
- host labels, comments, checks, or UI state.
- chat transcripts.
- raw filesystem paths or shell assertions as substitutes for authorized tokens.

## Promotion boundary

This packet declares `promotion_scope: octon-internal`; therefore promotion targets are under `.octon/**` only. Any required `.github/**` workflow wiring must be handled as a linked repo-local change or by existing validator discovery, not as a mixed-scope target in this packet.
