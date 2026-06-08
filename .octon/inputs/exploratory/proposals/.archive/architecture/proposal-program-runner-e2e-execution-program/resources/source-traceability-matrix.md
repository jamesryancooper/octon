# Source Traceability Matrix

Profile selection receipt: `release_state: pre-1.0`, `change_profile: atomic`.

| ID | Material Source Requirement | Owner | Status |
| --- | --- | --- | --- |
| R001 | Drive full proposal-program lifecycle end to end under --execute-routes while preserving route ownership, handoff, delegation, workflow, recovery, cancellation, replay, checkpoint, lock, phase-loop, disclosure-tier, and authority boundaries. | parent plus all children | mapped |
| R002 | Audit current proposal-program architecture first and close only gaps needed for durable end-to-end execution. | proposal-program-runner-current-state-gap-map | mapped |
| R003 | Preserve existing owned behavior and add tests instead of reimplementing behavior already owned elsewhere. | proposal-program-runner-current-state-gap-map; proposal-program-runner-tests-fixtures | mapped |
| R004 | Runner remains an orchestrator that plans from live state, selects parent route or child batch, emits handoff evidence, delegates through adapter, validates receipts/gates, checkpoints, and replans. | proposal-program-runner-planning-replan-loop | mapped |
| R005 | Default lifecycle run remains handoff-only and stops after planned program-route-handoff. | proposal-program-runner-planning-replan-loop; proposal-program-runner-tests-fixtures | mapped |
| R006 | Full execution is allowed only with --execute-routes, valid invocation authority, retained delegation proof, route delegation_contract, and any required typed human exception grant. | proposal-program-runner-executor-delegation-gates | mapped |
| R007 | Use repo-local launcher when octon is absent or stale. | proposal-program-runner-executor-delegation-gates; proposal-program-runner-tests-fixtures | mapped |
| R008 | Runtime lifecycle discovery uses generated effective projections; authored additive extension sources are edit source and must be republished canonically. | proposal-program-runner-generated-state-publication | mapped |
| R009 | Preserve authored packet and program lifecycle contract paths and treat packet phase ids as lifecycle context only. | proposal-program-runner-current-state-gap-map; proposal-program-runner-tests-fixtures | mapped |
| R010 | Program lifecycle is an orchestrated replan loop; packet lifecycle remains phase-loop. | proposal-program-runner-planning-replan-loop | mapped |
| R011 | --max-steps and --max-child-concurrency semantics must be preserved. | proposal-program-runner-child-scheduling-recovery | mapped |
| R012 | Extension and workflow routes both delegate through shared executor adapter; no runner-local workflow shortcuts or route-id special cases. | proposal-program-runner-executor-delegation-gates | mapped |
| R013 | Durable routes execute only after proof-gated delegation succeeds and routes satisfy their own delegation_contract. | proposal-program-runner-executor-delegation-gates | mapped |
| R014 | Parent receipts may summarize child outcomes but never satisfy child-owned receipts. | parent program; proposal-program-runner-evidence-run-control; proposal-program-runner-closeout-archive-policy | mapped |
| R015 | Program routes coordinate child packets but do not own child manifest truth, promotion targets, validation verdicts, archive metadata, or terminal outcomes. | parent program; proposal-program-runner-closeout-archive-policy | mapped |
| R016 | Scheduler route inventory comes from authored lifecycle contracts and generated effective projections, not skills or prompt bundles. | proposal-program-runner-planning-replan-loop; proposal-program-runner-generated-state-publication; proposal-program-runner-tests-fixtures | mapped |
| R017 | Packet verification/correction is owned by run-packet-verification-and-correction-loop; support bundles are not scheduled unless declared as routes. | proposal-program-runner-verification-correction-routing | mapped |
| R018 | Do not introduce new proposal manifest statuses; runtime states remain runtime/result states or receipts. | proposal-program-runner-planning-replan-loop; proposal-program-runner-tests-fixtures | mapped |
| R019 | Child run-packet-implementation writes evidence; child promote-proposal owns implemented status transition. | proposal-program-runner-closeout-archive-policy; proposal-program-runner-tests-fixtures | mapped |
| R020 | Program promote-proposal owns parent implemented status transition after fresh review, orchestration prompt evidence, and passing orchestration run evidence. | proposal-program-runner-closeout-archive-policy | mapped |
| R021 | promote-proposal and archive-proposal are workflow routes and must remain workflow-owned. | proposal-program-runner-executor-delegation-gates; proposal-program-runner-closeout-archive-policy | mapped |
| R022 | closeout-program and closeout-packet write closeout evidence only and do not own Git cleanup, repo hygiene deletion, branch cleanup, hosted landing, Change closeout, archive mutation, or generated-state mutation outside route boundary. | proposal-program-runner-cleanup-hygiene; proposal-program-runner-closeout-archive-policy | mapped |
| R023 | Program closeout reads active closeout policy; current authored policy requires non-deferred children archived or rejected. | proposal-program-runner-closeout-archive-policy | mapped |
| R024 | Archived and rejected child terminal outcomes enforce receipt-level requirements. | proposal-program-runner-closeout-archive-policy; proposal-program-runner-tests-fixtures | mapped |
| R025 | Human-readable closeout prompts do not override enforceable active program.closeout_policy. | proposal-program-runner-closeout-archive-policy | mapped |
| R026 | Do not hard-code child archival for policies that accept implemented children, while not loosening current policy. | proposal-program-runner-closeout-archive-policy | mapped |
| R027 | Program controller evidence explains parent run only and never rewrites child lifecycle authority. | proposal-program-runner-evidence-run-control | mapped |
| R028 | Evidence disclosure tiers are normative: local raw, retained publishable, disclosure, generated non-authority. | proposal-program-runner-evidence-run-control | mapped |
| R029 | Raw local evidence promotion requires redacted/summarized publishable receipt with metadata, limitations, redactions, and digest/path refs. | proposal-program-runner-evidence-run-control | mapped |
| R030 | Typed human exception grants unblock only named route in named program run. | proposal-program-runner-executor-delegation-gates; proposal-program-runner-evidence-run-control | mapped |
| R031 | Cancellation, resume, replay verification, event/checkpoint convergence, and lock release preserve run lifecycle invariants. | proposal-program-runner-evidence-run-control | mapped |
| R032 | Program and child creation use create-program/create-packet or governed intake/admission with valid bindings; missing or unsupported inputs fail closed. | proposal-program-runner-planning-replan-loop | mapped |
| R033 | Review and revision run through existing routes, revise only blocking findings, repeat within budgets, and fail closed on exhaustion. | proposal-program-runner-planning-replan-loop; proposal-program-runner-tests-fixtures | mapped |
| R034 | Prompt generation delegates child implementation prompts and parent orchestration prompt only when contract-eligible and gates pass. | proposal-program-runner-planning-replan-loop; parent program | mapped |
| R035 | Schedule runnable children by dependency order and mode; parent maintenance routes must not starve runnable child routes. | proposal-program-runner-child-scheduling-recovery | mapped |
| R036 | Classify child failures/timeouts/stale or missing evidence, use configured recovery safely, and continue independent children where allowed. | proposal-program-runner-child-scheduling-recovery | mapped |
| R037 | Verification sweep delegates existing program and packet verification/correction routes and validators only. | proposal-program-runner-verification-correction-routing | mapped |
| R038 | Packet verification covers standard validation, implementation conformance, post-implementation drift/churn, and packet-kind validators through route ownership. | proposal-program-runner-verification-correction-routing | mapped |
| R039 | Program verification covers declared program validators and only declared domain/publication validators. | proposal-program-runner-verification-correction-routing | mapped |
| R040 | Use strict review authorization only before accepted implementation routes; implemented-state parent validation uses declared implemented-state gates and baseline review validation. | proposal-program-runner-verification-correction-routing | mapped |
| R041 | Use repo-declared or harness-supported shell/toolchain through shared command, validator, or executor boundary and fail closed if unsupported. | proposal-program-runner-executor-delegation-gates | mapped |
| R042 | Targeted correction runs only for failed, stale, or missing findings and supplies finding_id or other route-declared inputs. | proposal-program-runner-verification-correction-routing | mapped |
| R043 | After correction, rerun affected validators plus required aggregate parent validators, bounded by retry budgets. | proposal-program-runner-verification-correction-routing | mapped |
| R044 | Generated state updates start from authored sources and refresh only through canonical publication or registry scripts. | proposal-program-runner-generated-state-publication | mapped |
| R045 | Use canonical publish-extension-state, publish-capability-routing, publish-host-projections, and generate-proposal-registry scripts when relevant. | proposal-program-runner-generated-state-publication | mapped |
| R046 | Treat generated projection drift as refreshable only when generated/non-authority and regenerable. | proposal-program-runner-generated-state-publication | mapped |
| R047 | Distinguish implementation hygiene from publication/archive hygiene. | proposal-program-runner-cleanup-hygiene | mapped |
| R048 | Cleanup-safe current-run residue routes through repo-hygiene cleanup or canonical helper after dry-run, summary, authorization, and active-work proof. | proposal-program-runner-cleanup-hygiene | mapped |
| R049 | Foreign, ambiguous, manual-review, or user-authored residue must not be deleted automatically. | proposal-program-runner-cleanup-hygiene | mapped |
| R050 | No-op or blocked-retained cleanup with implementation_blocking false must not block child implementation; closeout/archive blockers are terminal-phase scoped. | proposal-program-runner-cleanup-hygiene | mapped |
| R051 | Scheduler evaluates cleanup predicates from explicit route-evaluation context and fails closed on unknown or stale cleanup context. | proposal-program-runner-cleanup-hygiene | mapped |
| R052 | After verification/correction, delegate child closeout routes and enforce active policy rather than universal archival. | proposal-program-runner-closeout-archive-policy | mapped |
| R053 | If child closeout authorizes archive and active policy requires archived terminal outcomes, delegate child archive workflow before parent terminal closeout. | proposal-program-runner-closeout-archive-policy | mapped |
| R054 | Parent closeout and blocked closeout receipts include required fields and route guidance. | proposal-program-runner-closeout-archive-policy | mapped |
| R055 | Archive only through workflow-owned archive-proposal after policy, freshness, hygiene, generated refresh, and explicit authorization pass. | proposal-program-runner-closeout-archive-policy | mapped |
| R056 | If archive is blocked, preserve evidence and emit machine-readable blocked archive or closeout receipt at route boundary. | proposal-program-runner-closeout-archive-policy | mapped |
| R057 | Cancelled program run must not dispatch selected parent or child routes after cancellation observed. | proposal-program-runner-evidence-run-control | mapped |
| R058 | Resume reconstructs from canonical run evidence, checkpoints, and live proposal state; unsafe resume conditions fail closed. | proposal-program-runner-evidence-run-control | mapped |
| R059 | Every lock is released or explicitly recorded stale/unsafe on all exit paths. | proposal-program-runner-evidence-run-control | mapped |
| R060 | Edge cases for recoverable blockers, stale receipts, missing prompts, validator failures/timeouts, generated drift, cleanup fingerprints, local evidence refs, raw log publication attempts, implemented-state review mismatch, route-resolution timeout, cancellation, resume, stale locks, replay divergence, active closeout policy variations, and no forced child archival are covered safely. | proposal-program-runner-tests-fixtures | mapped |
| R061 | Fail closed with receipts and route guidance for authority ambiguity, unsafe cleanup, foreign residue, unsupported modes, exhausted budgets, missing authority-zone evidence, unregenerable stale receipts, unsupported blocker classes, unknown predicates, unsafe resume, lock ambiguity, closeout/archive hygiene blockers, and local-only hosted evidence attempts. | proposal-program-runner-tests-fixtures; proposal-program-runner-evidence-run-control; proposal-program-runner-cleanup-hygiene; proposal-program-runner-closeout-archive-policy | mapped |
| R062 | Acceptance criteria test coverage is mandatory for handoff default, execute delegation, route inventory, phase non-authority, promotion ownership, recovery budgets, verification/correction, hygiene, evidence tiers, generated refresh, timeout, implemented-state gate behavior, cancellation, resume/replay, locks, no-new-status, closeout/archive policy, and blocked receipts. | proposal-program-runner-tests-fixtures | mapped |
| R063 | Current task must not implement runner changes or execute durable implementation routes. | parent program; all child executable prompts | mapped |

## Out Of Scope

- Durable runner implementation in this creation task: out of scope by user instruction.
- `--execute-routes` dispatch in this creation task: out of scope by user instruction.
- Hand edits to `.octon/generated/**`: forbidden; any later generated refresh must use canonical scripts.
- New proposal manifest statuses: forbidden and mapped to test coverage.
