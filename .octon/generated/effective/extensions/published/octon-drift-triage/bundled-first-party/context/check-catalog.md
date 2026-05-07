# Check Catalog

`octon-drift-triage` selects only existing read-only validators and one
existing recommendation bundle.

## Direct Checks

| Check Id | Command | Role |
|---|---|---|
| `validate-extension-pack-contract` | `bash .octon/framework/assurance/runtime/_ops/scripts/validate-extension-pack-contract.sh` | verifies raw extension-pack contract shape |
| `validate-extension-publication-state` | `bash .octon/framework/assurance/runtime/_ops/scripts/validate-extension-publication-state.sh` | verifies effective extension publication coherence |
| `validate-runtime-effective-state` | `bash .octon/framework/assurance/runtime/_ops/scripts/validate-runtime-effective-state.sh` | verifies effective runtime views and upstream publication coherence |
| `validate-capability-publication-state` | `bash .octon/framework/assurance/runtime/_ops/scripts/validate-capability-publication-state.sh` | verifies capability routing publication |
| `validate-host-projections` | `bash .octon/framework/assurance/runtime/_ops/scripts/validate-host-projections.sh` | verifies `.claude/`, `.cursor/`, and `.codex/` projections |
| `octon-drift-triage-test-routing-matrix` | `bash .octon/inputs/additive/extensions/octon-drift-triage/validation/tests/test-routing-matrix.sh` | validates this pack’s path-to-check routing table |
| `octon-drift-triage-test-packet-contract` | `bash .octon/inputs/additive/extensions/octon-drift-triage/validation/tests/test-packet-contract.sh` | validates this pack’s emitted packet contract |
| `validate-bootstrap-ingress` | `bash .octon/framework/assurance/runtime/_ops/scripts/validate-bootstrap-ingress.sh` | validates ingress adapter and workspace bootstrap posture |
| `validate-bootstrap-projections` | `bash .octon/framework/assurance/runtime/_ops/scripts/validate-bootstrap-projections.sh` | validates bootstrap projection parity |
| `validate-ssot-precedence-drift` | `bash .octon/framework/assurance/runtime/_ops/scripts/validate-ssot-precedence-drift.sh` | validates SSOT precedence wording and authority drift |
| `validate-non-authority-register` | `bash .octon/framework/assurance/runtime/_ops/scripts/validate-non-authority-register.sh` | validates non-authority register coverage |
| `validate-repo-hygiene-governance` | `bash .octon/framework/assurance/runtime/_ops/scripts/validate-repo-hygiene-governance.sh` | validates repo-hygiene governance wiring |

## Recommended Bundle

| Bundle Id | Command | Role |
|---|---|---|
| `alignment-check-harness` | `bash .octon/framework/assurance/runtime/_ops/scripts/alignment-check.sh --profile harness` | broad follow-up bundle when extension or fallback drift needs wider coverage |

The bundle is recommendation-only in v1 and never auto-runs.

## Conditional `repo-hygiene`

When the `repo-hygiene-governance` routing family matches, v1 may additionally
run:

```bash
bash .octon/instance/capabilities/runtime/commands/repo-hygiene/repo-hygiene.sh scan
```

This remains conditional, read-only, and scan-only.
