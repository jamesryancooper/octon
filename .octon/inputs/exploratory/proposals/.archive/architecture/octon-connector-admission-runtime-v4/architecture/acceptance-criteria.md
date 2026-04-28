# Acceptance Criteria

The implementation is accepted for closure when all of the following are true:

1. Connector operation/admission/dossier/receipt contracts are defined under durable framework surfaces.
2. Repo-specific connector registry/admission placement is defined under instance governance.
3. Control/evidence root placement is explicit and validated.
4. Connector operations map to capability packs and material-effect classes.
5. Admission modes are enforced.
6. Stage-only/read-only posture is usable without enabling effectful external execution.
7. Live-effectful posture is impossible without support-target admission, trust dossier, policy, authorization, and evidence.
8. CLI shape is implemented for connector list, inspect, status, validate, admit, stage, quarantine, retire, dossier, evidence, drift, and decision workflows.
9. Generated connector views are derived-only and validated as non-authoritative.
10. Existing run lifecycle and execution authorization remain intact.
11. Browser/API/MCP broad autonomy remains explicitly deferred.
12. Campaigns, releases, portfolios, and cross-repo work are positioned as later dependents, not silently included.
13. Connector validator and negative controls pass with no new blocking issues.
14. Closure evidence demonstrates no rival control plane was introduced.
15. Material connector execution remains deferred unless routed through run contract, context pack, execution authorization, authorized-effect token verification, run journal events, and retained receipts.
