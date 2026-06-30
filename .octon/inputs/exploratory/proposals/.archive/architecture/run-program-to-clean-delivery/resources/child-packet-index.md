# Child Packet Index

1. `run-program-clean-delivery-architecture` - Defines the capability boundary and route shape.
2. `run-program-clean-delivery-runner-routing` - Plans runner defaults, retries, resume, and next-route selection.
3. `run-program-clean-delivery-workflow-handoff` - Plans delivery workflow, closeout, archive, hygiene, and Change handoff integration.
4. `run-program-clean-delivery-evidence-metadata` - Plans receipt, metadata refresh, projection, and disclosure-tier hardening.
5. `run-program-clean-delivery-validators` - Plans terminal readiness validators, acceptance gates, and regression tests.
6. `run-program-clean-delivery-operator-surface` - Plans command, skill, and documentation surfaces.

All child packets are siblings under `.octon/inputs/exploratory/proposals/architecture/`.
The parent program is coordination lineage only.
