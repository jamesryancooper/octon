# Current-to-Target Crosswalk (reverified at HEAD)

> Non-authoritative. Corrects and re-grounds the intake crosswalk against commit
> `c5b1f5760c78ff521cca6b054e4e8fef5300505b`. Each row cites Phase 1 findings.

| Area | Verified current state (@HEAD) | Target state | Change | Required proof | Findings |
|---|---|---|---|---|---|
| Authorization | Strong canonical plane for kernel paths; **separate self-attesting lifecycle plane** with no authority_engine dependency | One canonical authority for all agent launches | Extend (reuse primitive) | Agent spawn denied without a verified canonical grant | A-01, A-07, J-01 |
| Launch guard | One-shot ExecutorLaunch guards only `octon studio` dev app | One-shot guard on every agent/child launch | Extend | Concurrent consume succeeds ≤ once; revoked/expired guard blocks spawn | A-02 |
| Candidate isolation | Runs in canonical repo (`--cd repo_root`), no OS sandbox, no isolated Git | Disposable OS-sandboxed env, isolated Git state | Add/replace | Filesystem/network/credential/Git-state escape tests pass | B-04, B-05 |
| Credentials | Ambient env inherited at spawn; no broker | Credentialless agents; one local broker holds secrets | Add | `gh auth status` fails inside child; brokered effect succeeds | B-01, B-02, B-06, J-02 |
| Runtime state | Loose YAML/NDJSON; non-atomic `fs::write` | One SQLite/WAL authoritative store | Replace | Kill-point + concurrency: no torn state, no double-consume | D-01, D-03 |
| Durable effects | Mixed shell helpers, agent-run git, PAT CI | Broker + typed adapters | Replace | Raw push/merge/deploy from candidate fails | B-02, C-004 |
| Git | Unsanitized config; **hooks actively installed** | Sanitized broker-owned git; hooks cannot execute | Replace/retire | Hook/include/filter/helper/submodule negative suite | C-001, C-002, C-007 |
| Publication | `route_selection_order` puts **direct-main before branch-no-pr** | Verified branch-no-PR default; PR escalation; no direct-main agents | Modify/retire | Race/SHA-mismatch/missing-evidence force deny or PR | C-005, J-03 |
| Verification | Required checks in candidate-editable workflow; exact-SHA passes trivially | Candidate-immutable out-of-tree exact-SHA verifier | Replace | Candidate diff to verifier cannot alter its own verdict | C-003, C-006 |
| Evidence | Unkeyed hash chain; "signature" = unkeyed hash; quorum presence-counts | Signed (or explicitly git-anchored) bounded checkpoints | Add or reword | Rechaining breaks verification (if signed); claims match proof | E-01, E-02, E-03, E-06 |
| Recovery | No unknown-outcome reconciliation; in-memory dedup only | Transactional reserve→consume→outcome→terminal + reconcile | Add | Fault injection at every transition never duplicates/loses | D-05, D-06, J-04 |
| Capacity | No reservation; standalone route-write-lease files | Capacity reserved in the operation transaction | Add/retire | Near-full storage still records terminal evidence | D-04, E-04, E-05 |
| Self-development | Evolution CLI advisory, unwired; PR-head self-cert | Class B for ordinary; trust-root inert + separate activation | Add/modify | A change modifying its own gate cannot certify/activate itself | F-017-1, F-017-2, F-017-3 |
| Trust activation | No staged/prev-verified/rollback activation; unsigned release; presence-only approval | Operator-preauthorized, prev-version-verified, staged, rollback-capable | Add | Every activation fault → old, healthy-new, or auto-rollback | F-018-1, F-018-2, J-06 |
| Projects | Singleton mutable Profile; no durable identity | Minimal Workspace Project (never authority) | Add | Project metadata cannot widen a run or mint authority | G-01, G-02, H-06 |
| Harness Factory | **Deterministic, digest-bound, resolver-enforced** | Same | Preserve | Stale/self-widened manifest denied (execute the deny path) | G-03, G-04 |
| Extensions | Provenance packs, pinned catalog, quarantine, no marketplace | Same + enforce bundled digests + rollback-to-generation | Preserve/extend | Unsigned/modified/revoked pack rejected | G-05, G-06 |
| Adapters | **Non-authoritative, replaceable, Octon-owned interface** | Same | Preserve | Provider replacement doesn't change authority/evidence/recovery | G-07, G-08 |
| Multi-agent | Children inherit creds; no depth bound; advisory scope | Bounded credentialless mission-scoped children | Modify/add | Children cannot widen scope/persist/gain creds/exceed depth | A-03, A-04, A-05 |
| Scope | Federation/Trust-Compact multi-party breadth in solo product | Solo vertical; multi-party demoted | Modify | Solo dogfood completes with federation disabled | H-04 |
| Governance model | "Class A/B/C" collides with retention taxonomy; ACP-2 escalation for ordinary commits | FD-002 consequence classes mapped onto ACP model | Modify | Routine reversible change: zero prompts; verifier is 2nd quorum member | H-01, H-08 |
| UX | CLI exists; no cross-project inbox; doctor is a self-dev linter | Mission inbox + operator doctor | Extend | Fresh-install-to-first-mission bounded; inbox spans projects | H-05, H-09, H-07 |
