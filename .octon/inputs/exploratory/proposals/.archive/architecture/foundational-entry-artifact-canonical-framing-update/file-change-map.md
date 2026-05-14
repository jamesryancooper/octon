# File Change Map

_Status: In-review proposal packet artifact_


| Target file | Change type | Proposed change | Rationale | Authority impact | Validation gate |
|---|---|---|---|---|---|
| `README.md` | linked repo-local companion | Open with governed workflow/runtime framing and one product line | Primary audience-facing artifact currently agent-first, but active proposals may not mix target families | Root overview; not runtime authority | linked repo-local proposal validation |
| `AGENTS.md` | linked repo-local companion | Reframe adapter to bounded agent participation inside workflows | Root adapter is non-.octon companion scope for this octon-internal packet | Adapter only; no policy text | linked repo-local proposal validation |
| `.octon/AGENTS.md` | modify now | Maintain adapter parity posture through octon-internal ingress framing | Current parity rule | Adapter only | adapter parity validation |
| `.octon/README.md` | modify now | Add governed workflow runtime and execution harness orientation | Super-root orientation should align with target framing | Authored orientation, registry-backed | architecture/doc validation |
| `.octon/instance/ingress/AGENTS.md` | modify now | Add workflow-state control rule and bounded agent rule | Canonical ingress should guide agents correctly | Instance ingress authority | ingress manifest/read-order validation |
| `.octon/instance/bootstrap/START.md` | modify now | Add concise workflow runtime framing | Bootstrap users need same mental model | Instance orientation | bootstrap doc validation |
| `.octon/framework/cognition/_meta/terminology/glossary.md` | modify now | Add Governed Workflow Runtime, task-specific execution harness, bounded agent node | Canonical term clarity | Portable authored authority | terminology validation |
| `.octon/framework/cognition/_meta/architecture/specification.md` | modify now | Add target framing companion paragraph | Architecture readers need framing alignment | Portable authored companion | architecture conformance validation |
| `.octon/framework/cognition/_meta/architecture/contract-registry.yml` | inspect now / possible future | Only update if doc-target metadata requires new terminology anchors | Avoid unnecessary registry churn | Machine-readable authority if changed | registry validation |
| `.octon/instance/governance/support-targets.yml` | inspect only | No change | Support claims not affected | No impact | support-target validation |
| runtime specs | inspect only | No change | Runtime packets later | No impact | scope discipline |
| `generated/**` | no change | No generated projection in this packet | Avoid authority confusion | No impact | generated non-authority validation |
| `inputs/**` proposal packet | create now | Temporary proposal lineage | Packet workspace only | Non-authoritative input | proposal validators |
