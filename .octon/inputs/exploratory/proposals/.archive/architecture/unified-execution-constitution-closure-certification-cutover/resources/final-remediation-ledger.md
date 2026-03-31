# Final Remediation Ledger

| Blocker | Severity | Required remediation | Canonical target | Proof artifact / gate |
| --- | --- | --- | --- | --- |
| Claim wider than proof | Critical | Add machine-readable closure manifest and align release wording | `.octon/instance/governance/closure/**`, `.octon/instance/governance/disclosure/harness-card.yml` | closure-manifest check + HarnessCard wording parity |
| Hidden host authority | Critical | Move consequential lane/blocker/manual decisions into canonical artifacts | `.octon/state/evidence/control/execution/**`, `.octon/framework/engine/runtime/adapters/host/**` | authority de-hosting audit |
| Non-universal run bundle | Critical | Add release-blocking validator keyed to `run-contract.yml#required_evidence` | `.octon/framework/assurance/governance/**`, `.octon/state/control/execution/runs/**` | positive supported-envelope run gate |
| Support matrix not executable | Critical | Add positive and negative certification fixtures | `.octon/instance/governance/support-targets.yml`, publication evidence root | reduced/unsupported stage-or-deny gates |
| Disclosure can overclaim | Critical | Resolve every RunCard/HarnessCard proof reference before release | `.octon/state/evidence/disclosure/**` | disclosure-parity gate |
| Historical shims not disproven | High | Add static audit over launchers, workflows, validators, ingress, bootstrap | `.octon/framework/constitution/contracts/registry.yml` | shim-independence gate |
| Build-to-delete under-evidenced | High | Publish at least one deletion or demotion receipt | `.octon/state/evidence/validation/publication/build-to-delete/**` | retirement receipt gate |
