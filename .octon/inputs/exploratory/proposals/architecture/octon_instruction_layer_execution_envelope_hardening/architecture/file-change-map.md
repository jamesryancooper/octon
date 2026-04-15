# File Change Map

## Durable target artifacts

| Target artifact | Class | Existing/New | Why it is touched | Migration required? | Concept(s) served | Required for genuine usability? |
|---|---|---|---|---|---|---|
| `/.octon/framework/constitution/contracts/runtime/instruction-layer-manifest-v2.schema.json` | framework authority | existing/edit | Additive provenance fields and conditional completeness hooks | no big-bang; additive | Concept 1 | yes |
| `/.octon/instance/agency/runtime/tool-output-budgets.yml` | instance authority via enabled runtime overlay | existing/edit | Normalize output-envelope policies and raw-payload offload expectations | additive | Concept 1 + 2 | yes |
| `/.octon/framework/engine/runtime/spec/execution-request-v2.schema.json` | framework authority | existing/edit | Additive capability-pack / class / envelope request semantics | additive | Concept 2 | yes |
| `/.octon/framework/engine/runtime/spec/execution-grant-v1.schema.json` | framework authority | existing/edit | Additive granted pack/class/envelope semantics | additive | Concept 2 | yes |
| `/.octon/framework/engine/runtime/spec/execution-receipt-v2.schema.json` | framework authority | existing/edit | Additive retained proof of pack/class/envelope semantics | additive | Concept 2 | yes |
| `/.octon/instance/governance/policies/repo-shell-execution-classes.yml` | instance authority via enabled governance overlay | existing/edit | Tighten class -> receipt -> envelope normalization | additive | Concept 2 | yes |
| `/.octon/framework/capabilities/packs/shell/manifest.yml` | framework authority | existing/edit | Clarify required evidence and envelope linkage | additive | Concept 2 | yes |
| `/.octon/framework/capabilities/packs/repo/manifest.yml` | framework authority | existing/edit | Clarify repo-surface linkage where shell and repo pack boundaries interact | additive | Concept 2 | maybe |
| `/.octon/instance/governance/capability-packs/shell.yml` | instance authority via enabled governance overlay | existing/edit | Localize required evidence and default-route semantics to normalized envelope model | additive | Concept 2 | yes |
| `/.octon/instance/capabilities/runtime/packs/admissions/shell.yml` | instance durable admission artifact | existing/edit | Align shell pack admission with new validator and evidence posture | additive | Concept 2 | yes |
| `/.octon/framework/cognition/_meta/architecture/specification.md` | framework authority | existing/edit | Record refined cross-subsystem placement / non-goals if needed after acceptance | no | Concept 1 + 2 | maybe |
| `/.octon/framework/assurance/runtime/_ops/scripts/validate-instruction-layer-manifest-depth.sh` | framework assurance runtime | new | Enforce manifest completeness and provenance depth | no | Concept 1 | yes |
| `/.octon/framework/assurance/runtime/_ops/scripts/validate-capability-envelope-normalization.sh` | framework assurance runtime | new | Enforce request/grant/receipt/class/pack/envelope coherence | no | Concept 2 | yes |
| `/.octon/framework/assurance/runtime/_ops/tests/test-instruction-layer-manifest-depth.sh` | framework assurance runtime | new | Regression coverage for Concept 1 validator | no | Concept 1 | yes |
| `/.octon/framework/assurance/runtime/_ops/tests/test-capability-envelope-normalization.sh` | framework assurance runtime | new | Regression coverage for Concept 2 validator | no | Concept 2 | yes |
| `.github/workflows/architecture-conformance.yml` | repo workflow | existing/edit | Call new validators and block drift | no | Concept 1 + 2 | yes |

## Explicitly unchanged roots

- `/.octon/state/control/**` top-level layout
- `/.octon/state/evidence/**` top-level layout
- `/.octon/state/continuity/**`
- `/.octon/generated/**` top-level families
- `/.octon/framework/constitution/contracts/authority/**`
- `/.octon/instance/governance/support-targets.yml`
- `/.octon/instance/governance/exclusions/action-classes.yml`

These remain unchanged because the packet is a refinement of already-admitted runtime behavior, not a support-universe or constitutional-authority expansion.
