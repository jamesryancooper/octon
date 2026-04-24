# Source of Truth Map

## Canonical authority hierarchy used by this packet

| Layer | Role | Current source(s) | Why it matters here |
|---|---|---|---|
| Constitutional kernel | Supreme repo-local control regime | `/.octon/framework/constitution/**` | Prevents the packet from inventing a rival context authority or control plane. |
| Umbrella architecture | Cross-subsystem topology and class-root placement | `/.octon/framework/cognition/_meta/architecture/specification.md` | Determines legal placement across authored authority, mutable control, retained evidence, continuity, and generated read models. |
| Root manifest | Runtime-resolution and class-root bindings | `/.octon/octon.yml` | Confirms the active runtime contract family and super-root model. |
| Instance manifest | Overlay enablement | `/.octon/instance/manifest.yml` | Confirms this repo can legally add repo-specific governance policy and assurance runtime overlays. |
| Ingress manifest | Mandatory read order | `/.octon/instance/ingress/manifest.yml` | Confirms constitutional and workspace-charter precedence before runtime role behavior. |
| Workspace charter pair | Repo-owned objective layer | `/.octon/instance/charter/workspace.md`, `workspace.yml` | Confirms runs are the atomic consequential execution unit and support claims remain bounded. |
| Runtime constitutional contract | Canonical context pack contract | `/.octon/framework/constitution/contracts/runtime/context-pack-v1.schema.json` | Existing authority surface to refine rather than replace. |
| Instruction-layer evidence | Current run instruction evidence | `/.octon/framework/constitution/contracts/runtime/instruction-layer-manifest-v2.schema.json` | Existing per-run evidence surface that should bind context-pack receipts and hashes. |
| Canonical Run Journal events | Append-only lifecycle event contract and alias map | `/.octon/framework/constitution/contracts/runtime/run-event-v2.schema.json`, `family.yml`, `state-reconstruction-v2.md` | Ensures context-pack lifecycle events are canonical hyphenated journal entries and dot names remain compatibility aliases only. |
| Engine runtime spec | Request / grant / receipt / events / authorization | `/.octon/framework/engine/runtime/spec/**` | Current execution substrate where builder contract, receipt, and runtime binding must land. |
| Engine runtime implementation | Authority engine and runtime state landing zone | `/.octon/framework/engine/runtime/README.md` and referenced crate modules | Likely code landing zone for builder emission and lifecycle binding. |
| Support-target declarations | Live support universe and required evidence | `/.octon/instance/governance/support-targets.yml` | Prevents support-universe widening and localizes any evidence-strengthening edits. |
| Repo-local governance overlays | Repo-specific runtime policy surfaces | `/.octon/instance/governance/policies/**` | Legal place to put context QoS / trust / freshness policy. |
| Assurance runtime | Durable validator, tests, and fixtures | `/.octon/framework/assurance/runtime/_ops/scripts/validate-context-pack-builder.sh`, `/.octon/framework/assurance/runtime/_ops/tests/test-context-pack-builder.sh`, `/.octon/framework/assurance/runtime/_ops/fixtures/context-pack-builder-v1` | Required to make the packet promotion-safe instead of documentation-only. |
| State/control and evidence roots | Canonical runtime truth and proof | `/.octon/state/control/execution/**`, `/.octon/state/evidence/runs/**` | Required landing zones for emitted builder state and retained context-pack proof. |

## Proposal-local authority order

1. `proposal.yml`
2. `architecture-proposal.yml`
3. `navigation/source-of-truth-map.md`
4. `architecture/*.md`
5. `navigation/artifact-catalog.md`
6. `README.md`

## Non-authoritative surfaces explicitly excluded from promotion targets

- `/.octon/generated/**` except optional derived projections after authoritative changes land
- `/.octon/inputs/**` except this packet itself
- host UI or control-plane projections
- chat transcripts or prompt logs
- generated summaries used as runtime truth
- raw additive inputs promoted into authority
