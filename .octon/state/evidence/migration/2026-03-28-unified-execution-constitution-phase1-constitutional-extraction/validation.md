# Phase 1 Validation

- `yq -e '.records[] | select(.id == "2026-03-28-unified-execution-constitution-phase1-constitutional-extraction")' .octon/instance/cognition/context/shared/migrations/index.yml`: PASS
- `yq -e '.records[] | select(.id == "077-unified-execution-constitution-phase1-constitutional-extraction")' .octon/instance/cognition/decisions/index.yml`: PASS
- `yq -e '.records[] | select(.id == "2026-03-28-unified-execution-constitution-phase1-constitutional-extraction")' .octon/instance/cognition/context/shared/evidence/index.yml`: PASS
- `yq -e '.' .octon/framework/constitution/contracts/registry.yml`: PASS
- `bash .octon/framework/agency/_ops/scripts/validate/validate-agency.sh`: PASS
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-bootstrap-ingress.sh`: PASS
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-ssot-precedence-drift.sh`: PASS
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-framing-alignment.sh`: PASS with historical allowlisted warnings only
- `cmp -s AGENTS.md .octon/AGENTS.md && echo ag_ok`: PASS
- `cmp -s CLAUDE.md .octon/AGENTS.md && echo cl_ok`: PASS
- `git diff --check`: PASS
