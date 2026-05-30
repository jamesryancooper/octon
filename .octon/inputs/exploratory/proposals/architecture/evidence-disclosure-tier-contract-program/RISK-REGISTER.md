# Risk Register

_Status: In-review parent-program risk register_

| Risk | Severity | Mitigation |
| --- | ---: | --- |
| Raw local evidence is accidentally published | High | Local evidence root child must define ignore rules and validator gates must reject tracked local-only evidence. |
| Publishable receipts are too vague to prove claims | High | Receipt schema child must require claim scope, validation summary, outcome, redactions, limitations, and rollback/discard posture. |
| Existing retained evidence obligations are weakened | High | Tier contract child must preserve `.octon/state/evidence/runs/**` as retained publishable evidence and update obligations explicitly. |
| Hosted closeout depends on local-only evidence | High | Validator child must include negative controls for hosted/shared closeout using local-only refs. |
| Generated read models become evidence authority | High | Disclosure/read-model child must preserve generated non-authority rules and validator checks. |
| Git ignore change violates active proposal target-family rules | Medium | Resolved by scoping the ignore rule to `.octon/state/evidence/.gitignore`, keeping the child inside `.octon/**` promotion targets. |
| Multiple evidence roots confuse agents | Medium | Tier contract child keeps exactly four tiers and path names that communicate authority. |
| Local evidence references leak machine detail | Medium | Receipt schema child must support redaction and path/digest reference decisions. |
| Oversized publishable evidence recreates raw-log publication | Medium | Validator child must define size or concision thresholds before acceptance. |
| Residue migration deletes useful evidence | High | Migration child runs last and requires inventory, local archive, rollback posture, and explicit resolving evidence. |
| Parent evidence satisfies child receipts | High | Child contract and program closeout plan prohibit parent-owned child truth. |
| Proposal packet is mistaken for live policy | Medium | Every artifact states proposal-local non-authority and promotion targets must stand alone after implementation. |
