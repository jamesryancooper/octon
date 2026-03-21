# Commands

## Grep Sweep

```bash
rg -n '\.proposals/' . -g '!**/resources/**' -g '!**/.git/**' -g '!**/state/evidence/migration/**'
find .octon/inputs/exploratory/proposals/architecture -mindepth 1 -maxdepth 1 -type d | sort
rg -n 'repo_snapshot_minimal' . -g '!**/.git/**'
rg -n 'external-workspace|mixed-path|mixed tree|mixed-tree|legacy mixed-path' .octon -g '!**/resources/**' -g '!**/state/evidence/migration/**' -g '!**/.archive/**'
cmp -s AGENTS.md .octon/AGENTS.md && cmp -s CLAUDE.md .octon/AGENTS.md
```

## Cross-Reference And Lineage Audit

- Ruby audit: verify every `generated/proposals/registry.yml` entry path
  resolves on disk and every
  `instance/cognition/context/shared/migrations/index.yml`
  record resolves its `path`, `adr`, and `evidence` targets.
- Ruby audit: verify all 14 ratified packet proposal directories exist under
  `/.octon/inputs/exploratory/proposals/.archive/architecture/`.

## Validation And Remediation Commands

```bash
bash .octon/framework/assurance/runtime/_ops/tests/test-validate-root-manifest-profiles.sh
bash .octon/framework/assurance/runtime/_ops/tests/test-validate-companion-manifests.sh
bash .octon/framework/assurance/runtime/_ops/tests/test-validate-overlay-points.sh
bash .octon/framework/assurance/runtime/_ops/tests/test-validate-repo-instance-boundary.sh
bash .octon/framework/assurance/runtime/_ops/tests/test-validate-bootstrap-ingress.sh
bash .octon/framework/assurance/runtime/_ops/tests/test-validate-raw-input-dependency-ban.sh
bash .octon/framework/assurance/runtime/_ops/tests/test-validate-locality-registry.sh
bash .octon/framework/assurance/runtime/_ops/tests/test-validate-locality-publication-state.sh
bash .octon/framework/assurance/runtime/_ops/tests/test-validate-extension-publication-state.sh
bash .octon/framework/assurance/runtime/_ops/tests/test-validate-capability-publication-state.sh
bash .octon/framework/assurance/runtime/_ops/tests/test-validate-runtime-effective-state.sh
bash .octon/framework/assurance/runtime/_ops/tests/test-export-harness.sh

bash .octon/framework/assurance/runtime/_ops/scripts/validate-root-manifest-profiles.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-companion-manifests.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-overlay-points.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-repo-instance-boundary.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-locality-registry.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-continuity-memory.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-raw-input-dependency-ban.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-locality-publication-state.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-extension-publication-state.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-capability-publication-state.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-runtime-effective-state.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-export-profile-contract.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh --package .octon/inputs/exploratory/proposals/architecture/migration-rollout
bash .octon/framework/assurance/runtime/_ops/scripts/validate-architecture-proposal.sh --package .octon/inputs/exploratory/proposals/architecture/migration-rollout

bash .octon/framework/capabilities/_ops/scripts/publish-capability-routing.sh
bash .octon/framework/assurance/runtime/_ops/scripts/alignment-check.sh --profile harness
```

## Environment Note

- `alignment-check.sh --profile harness` required an escalated rerun in this
  environment so `.codex/**` host projections could refresh successfully.
