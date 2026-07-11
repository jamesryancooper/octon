# Concept Verification and Constraint Map

## Current-Reality Map

| Lens | Verified current reality |
| --- | --- |
| Logical structure | The authority engine defines `authorize_execution` and typed effect issuance/verification; lifecycle executor has a separate pre-dispatch authorization module |
| Runtime behavior | Lifecycle executor validates caller-carried fields, writes a delegation proof, then directly spawns Codex/Claude/workflow child processes |
| Data and state | Authored authority, mutable control, retained evidence, generated outputs, and inputs have distinct roots |
| Project model | One singleton Project Profile is written under `instance/locality` and contains an absolute local repo path |
| Harness model | Task-Specific Execution Harness v1 is explicitly a compilation/validation record and not authority |
| Provider | An active main ruleset requires four GitHub Actions checks; current PR auto-merge executes PR-head runtime code with a provider write credential |
| Evidence | Runtime bus validates ordered SHA-256 event chains but has no independent signature/anchor or transactional concurrent append |
| Self-development | Human/quorum approval, promotion receipt, and recertification concepts exist; previous-verifier and separate activation ownership are not fully specified |

## Steelman of the Current Architecture

The broad material-effect inventory and duplicate pre-dispatch gates were
reasonable compensating controls while Octon lacked a hard process,
credential, and broker boundary. They reduce accidental unmediated mutation,
make missing evidence visible, and support detailed negative controls. The
local journal hash chain is valuable for corruption detection and deterministic
replay. GitHub's exact-SHA-oriented checks and self-evolution receipts are
useful foundations.

Revision 2 preserves those safety properties while replacing compensating
per-action governance with stronger isolation and credential separation.

## Chesterton's Fence

| Surface | Disposition | Reason |
| --- | --- | --- |
| Engine-owned authorization | Keep and make exclusive | Correct owner of allow/deny/grant semantics |
| Run Contract | Keep, clarify | Governing maximum/request input; never a minting credential |
| Typed effect tokens | Keep, strengthen | Correct least-authority transport, needs atomic capability-ledger reservation requested by the broker |
| Context, support, rollback, revocation checks | Keep | Necessary inputs to consequential decisions |
| Run Journal | Keep, harden | Useful replay/control spine; needs transaction, signer, and anchor |
| Lifecycle delegation contract | Keep as precondition input | Can narrow dispatch but cannot authorize |
| `authorize_before_dispatch` semantics | Merge/rename | Current name and output compete with canonical authority |
| Broad token-per-write model | Split | Appropriate for durable roots, excessive inside disposable sandbox |
| Project Profile | Keep as observed profile | Valuable discovery, not durable project identity |
| Task harness | Extend through a factory | Already has the correct non-authority invariant |
| GitHub Actions required checks | Keep for ordinary CI | Necessary but insufficient for independent provenance |
| PR-head privileged merge execution | Retire | Violates proposer/credential separation and exact-head safety |
| Self-evolution gates | Keep and strengthen | Add previous-version and activation separation |

## Constraint Ledger

| ID | Constraint | Status | Design consequence |
| --- | --- | --- | --- |
| C-01 | Only canonical authority may authorize material effects | Valid | All downstream gates are deny/narrow/precondition only |
| C-02 | Generated and input surfaces are non-authority | Valid | Harness outputs bind by digest but never mint |
| C-03 | Live support remains finite and admitted | Valid | Unsupported broker adapters block only their transition |
| C-04 | Proposal is non-authoritative | Valid | Durable implementation cannot depend on this path |
| C-05 | Current provider rules are route-neutral | Valid external fact | Revision 2 intentionally standardizes durable merge on the fully defined PR-backed verifier route; no-PR remains unsupported pending a separate equally protected design |
| C-06 | One mandatory second human | Stale as a default solo assumption | Use two identities/authorities; require second person only by profile |
| C-07 | Every filesystem write is material | Overbroad implementation assumption | Candidate sandbox writes become Class A |
| C-08 | Hooks can mediate Git/provider effects | Insufficient | Hooks remain advisory; credentials and broker are decisive |

## Complexity Ledger

| Type | Examples | Treatment |
| --- | --- | --- |
| Essential | authorization, revocation, exact effects, credential custody, recovery | Retain in small typed components |
| Accidental | duplicate authorization vocabulary, per-file tokens, request-carried authority strings | Remove |
| Compensating | hooks, repo scripts, broad high-risk classification | Retain only until broker coverage proves replacement |
| Operational | host adapters, provider latency, offline queues, key rotation | Make profile-specific and observable |
| Migration | dual observation, shadow receipts, inactive trust slots | Time-bound with retirement gates |

## Bottlenecks and Leverage

The primary bottleneck is not policy evaluation; it is the absence of an
unavoidable isolation/credential boundary. Once the agent cannot directly
perform durable effects, Class A governance can be simplified safely.

The highest-leverage changes are:

1. canonical `ExecutorLaunch` capability integration;
2. a broker outside the sandbox backed by transactional capability-ledger and evidence-store gates;
3. separate independent GitHub verifier and effect App identities;
4. signed externally anchored broker evidence; and
5. project/harness digest binding.

## Option Comparison

| Option | Security | Velocity | Migration | Verdict |
| --- | --- | --- | --- | --- |
| Keep current architecture | Medium; duplicate semantics and ambient paths remain | Low-medium | Low | Reject |
| Improve wrappers and hooks | Medium-low; still bypassable by same user/repo | Medium | Low | Reject as target |
| Refactor authority only | High for semantics, incomplete mediation | High | Medium | Necessary but insufficient |
| Wrap/isolate current runtime | High local isolation, incomplete provider provenance | High | Medium | Useful stage |
| Partial replacement with sandbox + broker + App | High and proportional | High | Medium-high | **Recommended** |
| Full redesign | Potentially high, large regression and delay risk | Low during migration | Very high | Reject |
| Remote-only broker | High provider isolation, weak offline/local experience | Low-medium | High | Higher-assurance option only |

## Verification Conclusion

The selected hybrid refactor is the narrowest design that resolves the
assignment without discarding current strengths or weakening the
constitutional kernel. No unresolved product-semantic question remains.
