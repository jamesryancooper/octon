# Source-of-Truth Map

## Proposal-local lifecycle authorities

The only proposal-local lifecycle authorities are:

1. `proposal.yml`
2. `architecture-proposal.yml`

All other packet files are implementation guidance, analysis, navigation,
validation planning, or support material.

## Durable authority this packet must preserve

| Surface | Role | Packet posture |
| --- | --- | --- |
| `/.octon/framework/constitution/CHARTER.md` | Supreme repo-local constitutional regime | Preserve unchanged except companion references if needed. |
| `/.octon/framework/constitution/precedence/normative.yml` | Normative authority order | Preserve; add checks, not alternate precedence. |
| `/.octon/framework/constitution/obligations/fail-closed.yml` | Fail-closed reason-code obligations | Preserve and validate against runtime coverage. |
| `/.octon/framework/constitution/obligations/evidence.yml` | Evidence obligations | Preserve and require proof bundles to satisfy current obligations. |
| `/.octon/framework/cognition/_meta/architecture/contract-registry.yml` | Machine-readable structural authority | Promote target-state path-family, publication, validator, and doc-target updates here. |
| `/.octon/octon.yml` | Root manifest and profile-driven portability anchor | Keep as anchor; reduce operational overload by moving bulky policy into referenced contracts. |
| `/.octon/instance/governance/support-targets.yml` | Bounded support universe | Preserve bounded claim posture; partition and validate support claims. |

## Operational control and evidence roots

| Surface | Role | Boundary rule |
| --- | --- | --- |
| `/.octon/state/control/execution/runs/**` | Mutable run control truth | Runtime-consumed; never authored authority. |
| `/.octon/state/control/execution/{approvals,exceptions,revocations}/**` | Current run decision controls | May narrow/stop execution; cannot widen constitutional authority. |
| `/.octon/state/evidence/**` | Retained evidence, receipts, proof, disclosure | Retained proof; not rebuildable generated output. |
| `/.octon/state/continuity/**` | Handoff/resumption continuity | May inform resumption; never a substitute for run contracts. |

## Generated and proposal surfaces

| Surface | Role | Boundary rule |
| --- | --- | --- |
| `/.octon/generated/effective/**` | Runtime-facing derived publication | Runtime may consume only when freshness and publication receipts are current. |
| `/.octon/generated/cognition/**` | Operator/read-model projections | Non-authoritative; must trace to authority/control/evidence. |
| `/.octon/generated/proposals/registry.yml` | Deterministic proposal discovery | Projection only; never lifecycle authority. |
| `/.octon/inputs/exploratory/proposals/**` | Temporary proposal workspace | Excluded from runtime and policy resolution. |
| `/.octon/inputs/additive/extensions/**` | Raw additive extension inputs | Non-authoritative until selected, activated, published, and freshness-bound. |

## Promotion boundary

No durable target may depend on this proposal path after implementation. The
proposal can be archived only after promoted surfaces stand alone and retained
promotion evidence exists under canonical evidence roots.
