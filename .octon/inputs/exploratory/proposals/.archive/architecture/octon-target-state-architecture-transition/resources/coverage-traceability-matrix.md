# Coverage Traceability Matrix

| Decision | Change | Validator | Evidence output |
|---|---|---|---|
| Preserve class roots | No root change; update docs only where needed. | `validate-architecture-conformance.sh` | architecture conformance receipt. |
| Deduplicate FCR IDs | Edit `fail-closed.yml`. | `validate-fail-closed-obligation-ids.sh` | obligation ID report. |
| Deduplicate EVI IDs | Edit `evidence.yml`. | `validate-evidence-obligation-ids.sh` | obligation ID report. |
| Prove material side-effect mediation | Add inventory and coverage map. | `validate-material-side-effect-inventory.sh`, `validate-authorization-boundary-coverage.sh` | coverage proof bundle. |
| Modularize runtime kernel | Split command modules and request builders. | runtime tests + coverage validator | runtime modularity report. |
| Modularize authority engine | Add authorization phases and phase results. | phase tests | phase-result evidence. |
| Enforce generated/effective freshness | Add publication freshness validator. | `validate-generated-effective-freshness.sh` | publication receipt/freshness report. |
| Raise support sufficiency | Update support review contract/dossiers. | `validate-proof-bundle-completeness.sh` | support tuple proof bundle. |
| Add generated maps | Publish architecture/coverage/retirement maps. | publication validator | publication receipts. |
| Retire shims safely | Add retirement metadata. | `validate-compatibility-retirement.sh` | retirement map and evidence. |
| Remove active-doc residue | Edit active docs. | `validate-active-doc-hygiene.sh` | active-doc hygiene report. |
| Close proposal | Retain certification and ADR. | proposal validator + dependency scan | closure certification. |
