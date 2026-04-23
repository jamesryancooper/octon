# Source Artifact

## Primary repository sources inspected

| Source | Role in this packet |
|---|---|
| `README.md` | Establishes Octon as a Constitutional Engineering Harness with a Governed Agent Runtime. |
| `/.octon/README.md` | Establishes class-root model and proposal discovery posture. |
| `/.octon/inputs/exploratory/proposals/README.md` | Defines manifest-governed proposal packet structure. |
| `/.octon/framework/scaffolding/governance/patterns/proposal-standard.md` | Defines proposal manifest, lifecycle, authority, and path rules. |
| `/.octon/framework/scaffolding/governance/patterns/architecture-proposal-standard.md` | Defines architecture proposal requirements. |
| `/.octon/framework/cognition/_meta/architecture/specification.md` | Defines class roots, path families, generated/read-model discipline, state/control/evidence placement. |
| `/.octon/framework/constitution/obligations/fail-closed.yml` | Defines fail-closed obligations including missing evidence, missing run contract, authorization-boundary coverage, and generated authority failures. |
| `/.octon/framework/engine/runtime/README.md` | Defines runtime entrypoints, authority engine module structure, and Run-first operator surfaces. |
| `/.octon/framework/engine/runtime/spec/execution-authorization-v1.md` | Declares engine-owned material execution boundary. |
| `/.octon/framework/engine/runtime/spec/authorized-effect-token-v1.md` | Existing token doctrine and effect class list. |
| `/.octon/framework/engine/runtime/spec/authorization-boundary-coverage-v1.md` | Existing coverage proof requirements. |
| `/.octon/framework/engine/runtime/spec/material-side-effect-inventory-v1.schema.json` | Existing material inventory schema. |
| `/.octon/framework/engine/runtime/spec/execution-request-v3.schema.json` | Existing execution request contract. |
| `/.octon/framework/engine/runtime/spec/execution-grant-v1.schema.json` | Existing grant contract. |
| `/.octon/framework/engine/runtime/spec/execution-receipt-v3.schema.json` | Existing receipt contract. |
| `/.octon/framework/engine/runtime/spec/runtime-event-v1.schema.json` | Existing runtime event contract. |
| `/.octon/framework/engine/runtime/spec/run-lifecycle-v1.md` | Existing Run lifecycle state machine. |
| `/.octon/framework/engine/runtime/spec/evidence-store-v1.md` | Existing retained evidence store contract. |
| `/.octon/framework/engine/runtime/crates/authorized_effects/src/lib.rs` | Existing token type implementation. |
| `/.octon/framework/engine/runtime/crates/authority_engine/src/implementation/api.rs` | Existing grant/token helper implementation. |
| `/.octon/instance/governance/support-targets.yml` | Live and stage-only support target matrix and evidence requirements. |
| `/.octon/instance/governance/policies/repo-shell-execution-classes.yml` | Live repo-shell execution-class policy. |

## External evidence used as boundary rationale

| Source | Relevance |
|---|---|
| GAP benchmark, `arXiv:2602.16943` | Tool-call safety must be measured and enforced separately from text safety; supports external token gating. |
| OpenAI Codex App Server writeup | Supports typed runtime items/events, approvals, durable state, and reconnectable long-running agent execution. |

## Extraction result

The single implementation target is not “more authorization documentation.” It is API-level enforcement:

> Material side-effect APIs must consume verified, typed Authorized Effect Tokens and negative tests must prove bypass attempts fail closed.
