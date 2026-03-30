# Source-of-Truth Map

## Canonical and proposal-local authority

| Concern | Canonical surface | Class | Notes |
| --- | --- | --- | --- |
| Closure claim boundary | `.octon/instance/governance/support-targets.yml` + proposed `.octon/instance/governance/closure/unified-execution-constitution.yml` | Authored repo authority | The claim may not widen beyond the certified tuple and adapter set. |
| Release claim wording | `.octon/instance/governance/disclosure/harness-card.yml` | Authored disclosure authority | Must match the closure manifest and the tested support envelope exactly. |
| Constitutional kernel | `.octon/framework/constitution/**` | Supreme repo-local authority | The packet does not create a second constitution or competing precedence chain. |
| Canonical authority decisions and grant bundles | `.octon/state/control/execution/approvals/**` + `.octon/state/evidence/control/execution/**` | Mutable control truth + retained evidence | GitHub labels, comments, and checks may mirror but never mint authority. |
| Consequential run lifecycle | `.octon/state/control/execution/runs/<run-id>/**` | Mutable control truth | `run-contract.yml` remains the execution-time authority root for consequential runs. |
| Run continuity | `.octon/state/continuity/runs/<run-id>/**` | Operational continuity | Continuity must consume run evidence, not substitute for it. |
| Retained run evidence | `.octon/state/evidence/runs/<run-id>/**` | Retained evidence | Measurement, intervention, replay, and assurance live here. |
| Retained disclosure | `.octon/state/evidence/disclosure/{runs,releases}/**` | Retained disclosure evidence | RunCards and HarnessCards never substitute for their referenced evidence. |
| Host adapter declarations | `.octon/framework/engine/runtime/adapters/host/**` | Authored adapter authority | Host support claims remain bounded by declared support targets. |
| Closure validation logic | proposed `.octon/framework/assurance/governance/_ops/scripts/assert-unified-execution-closure.sh` | Authored validation authority | Release-blocking closure logic must live in `.octon/**`, not in workflow-local logic. |
| Retirement evidence | `.octon/state/evidence/validation/publication/build-to-delete/**` | Retained publication evidence | At least one deletion or demotion receipt is required for closure. |
| Historical shim status | `.octon/framework/constitution/contracts/registry.yml` | Authored registry authority | Active shims may remain only as projection-only or historical, never as hidden authority. |

## Proposal-local lifecycle authority

1. `proposal.yml`
2. `architecture-proposal.yml`
3. `architecture/target-architecture.md`
4. `architecture/implementation-plan.md`
5. `architecture/acceptance-criteria.md`
6. `architecture/validation-plan.md`
7. `resources/*`
8. `navigation/source-of-truth-map.md`
9. `navigation/change-map.md`
10. `navigation/artifact-catalog.md`
11. `/.octon/generated/proposals/registry.yml`
12. `README.md`

## Boundary rules

- This proposal is **non-canonical** and may not become a runtime or policy
  authority after promotion.
- Promotion targets remain `.octon/**` only because active proposals may not mix
  `.octon/**` and non-`.octon/**` durable targets.
- Repo-local `.github/workflows/**` files are treated as **downstream binding or
  projection surfaces**. They may call into canonical `.octon/**` validators and
  materializers, but they are not part of the proposal’s promotion authority.
- Generated registries and summaries are discovery or read-model surfaces only.
  They do not substitute for canonical control or evidence.
