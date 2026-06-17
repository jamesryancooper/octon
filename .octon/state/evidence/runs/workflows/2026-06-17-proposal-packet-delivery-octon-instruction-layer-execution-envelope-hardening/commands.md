# Commands

- validate delivery profile:
  `bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-packet-delivery-profile.sh --profile .octon/state/evidence/runs/workflows/2026-06-17-proposal-packet-delivery-octon-instruction-layer-execution-envelope-hardening/profile.yml`
- reconfirm proposal review gate:
  `bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-review-gate.sh --package .octon/inputs/exploratory/proposals/.archive/architecture/octon-instruction-layer-execution-envelope-hardening --require-implementation-authorization`
- reconfirm architecture proposal:
  `bash .octon/framework/assurance/runtime/_ops/scripts/validate-architecture-proposal.sh --package .octon/inputs/exploratory/proposals/.archive/architecture/octon-instruction-layer-execution-envelope-hardening`
- reconfirm implementation readiness:
  `bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-readiness.sh --package .octon/inputs/exploratory/proposals/.archive/architecture/octon-instruction-layer-execution-envelope-hardening`
- reconfirm implementation conformance:
  `bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-conformance.sh --package .octon/inputs/exploratory/proposals/.archive/architecture/octon-instruction-layer-execution-envelope-hardening`
- reconfirm post-implementation drift:
  `bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-post-implementation-drift.sh --package .octon/inputs/exploratory/proposals/.archive/architecture/octon-instruction-layer-execution-envelope-hardening`
- validate generated freshness:
  `bash .octon/framework/assurance/runtime/_ops/scripts/validate-support-envelope-reconciliation.sh`
- validate generated run-health read model:
  `bash .octon/framework/assurance/runtime/_ops/scripts/validate-run-health-read-model.sh`
- validate architecture conformance:
  `bash .octon/framework/assurance/runtime/_ops/scripts/validate-architecture-conformance.sh`
- validate generated non-authority:
  `bash .octon/framework/assurance/runtime/_ops/scripts/validate-generated-non-authority.sh`
- validate aggregate delivery receipt:
  `bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-packet-delivery-receipt.sh --receipt .octon/state/evidence/runs/workflows/2026-06-17-proposal-packet-delivery-octon-instruction-layer-execution-envelope-hardening/proposal-packet-delivery-receipt.yml`

The terminal-freshness validator was also started against the archived packet
with `--run-registry-check`, but that redundant full registry scan was
interrupted after several minutes. The archive workflow already retained a
passing archived terminal-freshness log, and this wrapper retained fresh direct
support-envelope, run-health, generated non-authority, and architecture
conformance validation logs.
