# Coverage Traceability Matrix

| Concept | Current coverage | Gap type | Selected disposition | Implementation motion | Closure proof |
|---|---|---|---|---|---|
| Evolution Program | Not currently present as a canonical runtime/control family | Greenfield + extension needed | Adopt | Add framework schema plus instance policy/program placement | Program validates and cannot mutate authority directly |
| Evolution Candidate | Not currently present | Greenfield | Adopt | Add control/evidence schema and CLI/status flow | Candidate requires evidence refs, authority impact, disposition |
| Evolution Proposal Compiler | Partially covered by proposal standards and source-to-packet prompts | Extension needed | Adapt | Formalize compiler contract and runtime/CLI flow | Candidate can compile review-ready packet without making it authority |
| Governance Impact Simulator | Not currently present as canonical self-evolution surface | Greenfield | Adopt as MVP-light | Add simulation schema and minimum historical-policy impact report | Simulation evidence blocks authority-impacting candidates when absent |
| Constitutional Amendment Request | Not currently present as elevated self-evolution request | Greenfield | Adopt | Add request schema and approval/impact requirements | Constitutional-impact changes fail closed without request |
| Promotion Runtime | Partially implied by proposal standards | Missing control/evidence materialization | Adapt | Add promotion contract, control roots, receipts, validation gates | Accepted proposal promotes only declared durable targets with receipts |
| Recertification Runtime | Partially covered by validators/evidence obligations | Consolidation + extension needed | Adapt | Add recertification contract and checklist over root/support/runtime/doc health | Promotion incomplete until recertification passes |
| Evolution Ledger | Not currently present | Greenfield | Adopt | Add append-only index in state/control with evidence refs | Ledger indexes but does not replace manifests/evidence/ADRs |
