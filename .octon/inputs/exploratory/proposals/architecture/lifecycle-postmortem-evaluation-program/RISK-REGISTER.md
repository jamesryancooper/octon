# Risk Register

| Risk | Impact | Mitigation |
| --- | --- | --- |
| Postmortem output becomes a hidden closeout gate | Creates a second control plane | Make workflow read-only except evidence writes and keep any blocking semantics behind separate review dispositions. |
| Evaluator reconstructs from chat or generated summaries | Weak factual basis | Bind to run control, retained evidence, RunCard, closeout refs, and lifecycle traces. |
| Parent program appears to satisfy child evidence | Child authority leak | Keep children as sibling packets and require child-owned receipts for closeout. |
| Validator checks only report shape | False confidence | Include negative controls for authority roots, unresolved refs, missing final judgment, and generated/input authority drift. |
| The evaluator adds process burden without decisions improving | Governance theater | Require every recommendation to tie to decision quality, risk exposure, evidence, reversibility, or lifecycle architecture fit. |
| Invariant validity review becomes a shortcut to weaken guardrails | Constitutional drift | Treat validity/evolution recommendations as evidence-only and require separate high-bar governance for relaxation, removal, downgrade, or addition. |
