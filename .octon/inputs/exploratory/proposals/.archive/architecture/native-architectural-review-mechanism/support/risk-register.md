# Risk Register

| Risk | Impact | Mitigation |
| --- | --- | --- |
| Architectural review becomes a second control plane. | Workflow and lifecycle authority fragment. | Workflows remain canonical and skills/commands stay thin invocation surfaces. |
| Extension assets are promoted wholesale. | Raw intake and packetization become confused with native gates. | Child split keeps extension ownership limited to intake, synthesis, and packetization helpers. |
| Receipt schemas remain prose-only. | Missing or stale evidence could satisfy gates. | Schema and validator child lands before lifecycle gate wiring. |
| `architecture-readiness-audit` remains as a permanent alias. | Canonical naming confusion persists. | Migration child defines bounded retirement and validator-enforced removal. |
| Post-integration review becomes an accidental closeout gate. | Existing conformance and drift/churn gates are weakened. | Closeout child preserves hard gates and records post-integration review as evidence-only unless later policy selects it. |
| Program scope is too broad for one implementation. | Rollout becomes unreviewable. | Ten child packets isolate implementation tracks and dependencies. |
| Generated projections are edited by hand. | Derived outputs could become stale or falsely authoritative. | Publication child requires scripts and projection validation. |
