# File Change Map

This is the path-and-surface-level proposal manifest for the target-state
implementation program.

| Action | Path or surface | Class-root / authority class | Promotion target | Rationale | Dependencies | Implementation risk | Owner expectation |
| --- | --- | --- | --- | --- | --- | --- | --- |
| create | `.octon/framework/capabilities/runtime/host-tools/README.md` | `framework/**` authored authority | yes | Publish the new host-tool contract family entry point. | none | low | Octon governance |
| create | `.octon/framework/capabilities/runtime/host-tools/registry.yml` | `framework/**` authored authority | yes | Canonical registry of tool ids and contract paths. | README | low | Octon governance |
| create | `.octon/framework/capabilities/runtime/host-tools/contracts/*.yml` | `framework/**` authored authority | yes | Tool-specific installer and verification contracts. | registry | medium | Octon governance |
| modify | `.octon/framework/capabilities/runtime/commands/manifest.yml` | `framework/**` authored authority | yes | Register shared provisioning command. | command doc | low | Octon governance |
| create | `.octon/framework/capabilities/runtime/commands/provision-host-tools.md` | `framework/**` authored authority | yes | Shared command contract for verify/install/repair. | manifest registration | low | Octon governance |
| create | `.octon/framework/scaffolding/runtime/_ops/scripts/provision-host-tools.sh` | `framework/**` authored authority | yes | Host-tool installer/resolver implementation. | command contract and tool registry | medium | Octon governance |
| create | `.octon/framework/assurance/runtime/_ops/scripts/validate-host-tool-governance.sh` | `framework/**` authored authority | yes | Structural validator for host-tool governance. | tool contracts and requirements | low | Octon governance |
| create | `.octon/instance/capabilities/runtime/host-tools/requirements.yml` | `instance/**` authored authority | yes | Repo-owned desired tool requirements. | framework registry | low | repo maintainers |
| create | `.octon/instance/governance/policies/host-tool-resolution.yml` | `instance/**` authored authority | yes | Repo-local policy for required versus optional tool resolution and fail-closed posture. | requirements surface | medium | repo maintainers |
| modify | `.octon/instance/governance/policies/repo-hygiene.yml` | `instance/**` authored authority | yes | Rebind repo-hygiene onto the new host-tool subsystem. | host-tool requirements | medium | repo maintainers |
| modify | `.octon/instance/capabilities/runtime/commands/repo-hygiene/README.md` | `instance/**` authored authority | yes | Document governed resolution rather than temp-install fallback. | host-tool requirements | low | repo maintainers |
| modify | `.octon/instance/bootstrap/START.md` | `instance/**` authored authority | yes | Clarify bootstrap versus provisioning boundaries. | final command posture | low | Octon governance |
| modify | `.octon/instance/bootstrap/catalog.md` | `instance/**` authored authority | yes | Publish the new provisioning command in operator docs. | command registration | low | Octon governance |
| external runtime state | `$OCTON_HOME/**` | host-scoped operational truth | no | Actual installs, caches, and receipts live outside repo authority. | command implementation | medium | operator environment |
