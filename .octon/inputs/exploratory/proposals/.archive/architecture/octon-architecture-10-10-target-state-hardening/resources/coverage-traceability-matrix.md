# Coverage Traceability Matrix

| Requirement | Source/current surface | Target artifact | Validator/evidence |
| --- | --- | --- | --- |
| Class roots preserved | `.octon/README.md`, contract registry | Registry updates | Architecture health report |
| Generated non-authority | architecture spec, fail-closed FCR-002 | Freshness gates, generated maps | Publication freshness validator |
| Raw inputs non-authority | fail-closed FCR-001 | Extension publication plan | Pack/extension validator |
| Authorization boundary | execution authorization spec | Expanded coverage map | Authorization coverage report |
| Material inventory | material-side-effect inventory | Expanded inventory | Negative-control tests |
| Run-first lifecycle | run lifecycle spec | Lifecycle transition validator | Run lifecycle report |
| Mission continuity | mission registry/policy | Mission support audit | Mission validator |
| Support boundedness | support-targets.yml | Partitioned admissions/dossiers | Support-pack alignment report |
| Pack admission | capability pack registries | Normalized lifecycle | Pack graph report |
| Extension activation | instance extensions + state/control | Grouped locks and freshness | Extension publication report |
| Proof completeness | evidence obligations | Proof bundles/cards | Proof-plane report |
| Operator boot | ingress manifest/bootstrap | Boot split | Operator boot validator |
| Compatibility retirement | retirement register | Updated shim inventory | Retirement report |
| Deployment practicality | runtime CLI | Doctor/first-run path | First-run fixture output |
