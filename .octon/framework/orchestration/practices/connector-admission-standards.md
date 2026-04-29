# Connector Admission Runtime Standards

Connector Admission Runtime governs external tools at operation level:

`Connector -> Operation -> Capability Packs -> Material-Effect Classes -> Support Posture -> Policy -> Authorization -> Evidence`

Connectors do not replace capability packs, support targets, run contracts, or execution authorization. Connector identity, operation contracts, admissions, trust dossiers, support-proof maps, and capability maps are authored authority under `instance/governance/**`. Connector lifecycle state lives under `state/control/connectors/**`, and retained connector proof lives under `state/evidence/connectors/**`.

Generated connector projections under `generated/cognition/projections/materialized/connectors/**` are read models only. They must carry a non-authority notice and may not widen support, admit live effects, or serve as an approval source.

The current Connector Admission Runtime admits only observe, read, and stage-only connector operations by default. `live_effectful` remains blocked unless a future promotion supplies support admission, proof bundle, trust dossier sufficiency, credential and egress posture, data-boundary posture, rollback or compensation plan, resolved Decision Request, run contract, context pack, execution authorization, authorized-effect token verification, run journal evidence, connector receipts, and disclosure.

Quarantine is fail-closed. Active quarantine blocks admission posture changes until reset evidence and required operator/quorum approval exist. Drift in connector manifest, operation schema, support posture, egress, credential class, capability mapping, evidence obligations, rollback posture, allowed mode, failure taxonomy, or budget/rate class routes to quarantine or Decision Request.

Administrative connector CLI commands prepare or inspect connector control state. They must not execute connector operations. Any material connector operation must enter through a governed run contract and the runtime authorization boundary.

## Federated Trust Boundary

Federated Trust may classify a non-Octon system as an
`octon_mediated_connector`, but that classification does not make the external
system a federation peer. Connector participation remains operation-level:

`Connector -> Operation -> Capability Packs -> Material-Effect Classes -> Support Posture -> Policy -> Authorization -> Evidence`

Attestations, proof bundles, certifications, compacts, dashboards, or external
auditor statements may support connector evidence only after local verification
and acceptance. They do not admit live effects, widen support claims, or bypass
run contracts and execution authorization.
