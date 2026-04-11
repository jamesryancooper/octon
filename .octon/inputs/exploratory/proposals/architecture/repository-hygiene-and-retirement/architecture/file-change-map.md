# File Change Map

This is the path-and-surface-level proposal manifest for the target-state
implementation program. `Promotion target` indicates whether the surface is an
official active-proposal promotion target (`yes`) or a dependent implementation
surface outside the active proposal target family (`dependent-repo-local`).

| Action | Path or surface | Class-root / authority class | Promotion target | Rationale | Dependencies | Implementation risk | Rollback posture | Owner expectation |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| create | `.octon/instance/governance/policies/repo-hygiene.yml` | `instance/**` authored authority; overlay-capable governance policy | yes | Missing canonical hygiene scope, classification, protections, and mode boundaries. | existing governance policy overlay point enabled | low | revert file | Octon governance + octon-maintainers |
| modify | `.octon/instance/capabilities/runtime/commands/manifest.yml` | `instance/**` authored authority | yes | Register `repo-hygiene` as an instance-owned command. | command lane reserved and manifest currently empty | low | revert manifest entry | octon-maintainers |
| create | `.octon/instance/capabilities/runtime/commands/repo-hygiene/README.md` | `instance/**` authored authority | yes | Operator contract, usage, and prompt surface for the command. | command registration | low | delete file | octon-maintainers |
| create | `.octon/instance/capabilities/runtime/commands/repo-hygiene/repo-hygiene.sh` | `instance/**` authored authority | yes | Main command runner for scan/enforce/audit/packetize modes. | policy file; command registration | medium | revert file | octon-maintainers |
| create | `.octon/instance/capabilities/runtime/commands/repo-hygiene/repo-hygiene-common.sh` | `instance/**` authored authority | yes | Shared detector, classification, and packet helper library. | command runner | medium | revert file | octon-maintainers |
| modify | `.octon/instance/governance/contracts/retirement-policy.yml` | `instance/**` authored authority; overlay-capable contract | yes | Add repo-hygiene routing requirement without creating a new retirement plane. | policy and command definition | low | revert contract edits | Octon governance |
| modify | `.octon/instance/governance/contracts/retirement-review.yml` | `instance/**` authored authority | yes | Make high-confidence hygiene-triggered transitional residue a registration trigger. | retirement policy edits | low | revert contract edits | Octon governance |
| modify | `.octon/instance/governance/contracts/drift-review.yml` | `instance/**` authored authority | yes | Ensure retained historical/compatibility surfaces are reconciled against hygiene evidence. | retirement policy edits | low | revert contract edits | Octon governance |
| modify | `.octon/instance/governance/contracts/ablation-deletion-workflow.yml` | `instance/**` authored authority | yes | Ingest repo-hygiene findings into delete/retain/demote/register workflow. | retirement policy/review edits | medium | revert contract edits | Octon governance |
| modify | `.octon/instance/governance/retirement-register.yml` | `instance/**` authored authority | no; operational same-change target | Same-change rationale updates are required when new transitional or historical surfaces are registered. | specific cleanup PRs, not bootstrap | low | revert entry updates | Octon governance + octon-maintainers |
| modify | `.octon/instance/governance/contracts/retirement-registry.yml` | `instance/**` authored authority | no; operational same-change target | Same-change registration is required for newly detected transitional residue. | specific cleanup PRs, not bootstrap | low | revert entry updates | Octon governance + octon-maintainers |
| create | `.octon/framework/assurance/runtime/_ops/scripts/validate-repo-hygiene-governance.sh` | `framework/**` authored authority; portable assurance surface | yes | Structural validator for policy/command/packet linkage. | policy + command surfaces | low | delete file | Octon governance |
| modify | `.octon/framework/assurance/runtime/_ops/scripts/validate-phase7-build-to-delete-institutionalization.sh` | `framework/**` authored authority | yes | Require hygiene surfaces as part of build-to-delete institutionalization. | new validator; policy + command surfaces | low | revert script edits | Octon governance |
| modify | `.octon/framework/assurance/runtime/_ops/scripts/validate-global-retirement-closure.sh` | `framework/**` authored authority | yes | Require hygiene packet attachment and resolution posture for closure-grade claims. | new validator; release packet design | medium | revert script edits | Octon governance |
| create | `.github/workflows/repo-hygiene.yml` | repo-local integration surface | dependent-repo-local | Provide fast PR enforce path and scheduled full audits. | command + validators installed | medium | revert workflow | octon-maintainers |
| modify | `.github/workflows/architecture-conformance.yml` | repo-local integration surface | dependent-repo-local | Trigger on command lane changes and run hygiene validator. | new validator | low | revert workflow edits | octon-maintainers |
| modify | `.github/workflows/closure-certification.yml` | repo-local integration surface | dependent-repo-local | Invoke global retirement closure validator after hygiene packet integration. | global closure validator edits | low | revert workflow edits | octon-maintainers |

## Notes

- The packet intentionally does **not** propose support-target, capability-pack,
  ownership-registry, or runtime schema changes. Those live surfaces are read
  and reused, not widened.
- The retirement registry/register rows above are operational same-change
  surfaces, not necessarily part of the initial bootstrap PR.
- `.github/workflows/**` changes are required for full implementation but are
  modeled as dependent integration surfaces because this active proposal may not
  mix target families.
