# 10/10 Gap Map

This map identifies the precise factors that prevent a true 10/10 architecture score and the
proposal mechanism that closes each factor.

| Limiting factor | Why it prevents 10/10 | Required change | Proposal closure mechanism |
|---|---|---|---|
| Runtime enforcement not visibly total | A perfect architecture must make side-effect bypass mechanically impossible | Every material side-effect path listed in inventory must have request builder, authorization call, grant/receipt, and negative-control test | Runtime enforcement hardening workstream; `test-authorization-boundary-negative-controls.sh` |
| Generated/effective freshness not hard-gated everywhere | Runtime-facing generated outputs can become stale or ambiguous if consumed by path | Add runtime `GeneratedEffectiveHandle` and v2 freshness contract | Publication freshness hardening workstream |
| Root manifest carries too much runtime-resolution load | Root manifest should anchor, not become a coordination megafile | Delegate runtime resolution to typed spec + instance selector + compiled effective route bundle | Runtime-resolution workstream |
| Support-path inconsistency | Partitioned support refs and flat visible files undermine proof credibility | Normalize admissions/dossiers into claim-state partitions and retire flat shims | Support path normalization workstream |
| Pack admission can be mistaken for live support | Pack existence/admission can appear to widen support beyond support matrix | Compile pack routes against support matrix and proof bundles; make non-live tuples explicit | Support/pack alignment workstream |
| Extension active state is overexpanded | Mutable control state is bulky and hard to inspect | Compact active state; move dependency closure to generation lock | Extension lifecycle workstream |
| Proof bundles may be manually sufficient but not continuously regenerated | Perfect proof architecture requires current evidence-backed proof, not static declarations | Proof refresh gate and evidence completeness validation | Proof maturity workstream |
| Operator legibility lags architecture depth | A 10/10 system must be inspectable by operators and agents without registry archaeology | Add doctor architecture report and generated read maps | Operator read-model workstream |
| Transitional shims remain live-looking | Compatibility surfaces can become accidental architecture | Register, sunset, or promote shims | Retirement workstream |
| Runtime implementation alignment not fully shown | Contracts, validators, and code must agree | CI and runtime tests must prove declared architecture | Validation and closure certification plan |

## 10/10 claim condition

Octon may claim this target-state architecture is landed only when all closing mechanisms produce
retained evidence outside the proposal workspace, all generated/effective outputs are regenerated
with current publication receipts, and promotion targets do not retain proposal-path dependencies.
