# Commands

- `mkdir -p .octon/inputs/exploratory/proposals/.archive/architecture`
- `mv .octon/inputs/exploratory/proposals/architecture/mission-scoped-reversible-autonomy-provenance-alignment-closeout .octon/inputs/exploratory/proposals/.archive/architecture/mission-scoped-reversible-autonomy-provenance-alignment-closeout`
- `git check-ignore -v .octon/inputs/exploratory/proposals/.archive/architecture/mission-scoped-reversible-autonomy-{steady-state-cutover,final-closeout-cutover,provenance-alignment-closeout}/README.md`
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-architecture-proposal.sh --package .octon/inputs/exploratory/proposals/.archive/architecture/mission-scoped-reversible-autonomy-steady-state-cutover`
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-architecture-proposal.sh --package .octon/inputs/exploratory/proposals/.archive/architecture/mission-scoped-reversible-autonomy-final-closeout-cutover`
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-architecture-proposal.sh --package .octon/inputs/exploratory/proposals/.archive/architecture/mission-scoped-reversible-autonomy-provenance-alignment-closeout`
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh --all-standard-proposals --skip-registry-check`
- `bash .octon/framework/assurance/runtime/_ops/scripts/generate-proposal-registry.sh --write`
- `bash .octon/framework/assurance/runtime/_ops/scripts/generate-proposal-registry.sh --check`
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh --all-standard-proposals`
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-version-parity.sh`
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-architecture-conformance.sh`
- `bash .octon/framework/assurance/runtime/_ops/scripts/alignment-check.sh --profile harness,mission-autonomy`
- `rg -n "inputs/exploratory/proposals/architecture/mission-scoped-reversible-autonomy-(steady-state-cutover|final-closeout-cutover|provenance-alignment-closeout)" .octon`
