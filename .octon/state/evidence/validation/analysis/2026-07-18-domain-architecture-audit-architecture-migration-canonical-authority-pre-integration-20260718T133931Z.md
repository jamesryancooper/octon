# RP-01 Canonical Authority Pre-Integration Architecture Audit

- run_id: `architecture-migration-canonical-authority-pre-integration-20260718T133931Z`
- target_mode: `observed`
- domain_path: `.octon/inputs/exploratory/proposals/architecture/octon-architecture-migration-canonical-authority`
- evidence_depth: `deep`
- severity_threshold: `medium`
- post_remediation: `false`
- reviewed_commit: `7192be7d74a868bec18292ad9fe1b9fd3c311818`
- reviewed_packet_digest: `sha256:7c10ab2255ebeaf3ae2c06d583e3255879f612a7e8f726bf72faf5b65c2a887a`

## Outcome

RP-01 requires revision before acceptance. Its design correctly aims for one
candidate-immutable authority path, typed structural scope, and one exact
at-most-once launch guard. However, its declared implementation boundary omits
the lifecycle and kernel call sites that the packet says must invoke that guard
and remove bypasses. The packet also makes post-implementation UE-001/UE-002
proof a prerequisite for implementation authorization, producing a circular
gate.

These are design and orchestration defects, not evidence that the intended
authority model is unsound. The next route should preserve the semantic owner,
expand or partition exact integration ownership through the parent collision
ledger, and separate design authorization from exact-implementation proof.

## Current Surface Map

| Surface | Responsibility | Path evidence |
| --- | --- | --- |
| Identity and lifecycle | RP-01 identity, atomic profile, parent/dependency, declared targets | `proposal.yml`, `architecture-proposal.yml` |
| Authority target | One evaluator/policy/bin/config/receipt tuple and typed structural scope | `architecture/target-architecture.md`, `resources/packet-contract.yml` |
| Launch dominance | One exact final guard immediately before every candidate spawn | `architecture/acceptance-criteria.md:6`, `architecture/implementation-plan.md:10` |
| Declared scope | Authority engine, policy engine, authorization module, contracts, config, validators, evidence root | `proposal.yml:7`, parent `resources/child-packet-index.yml` |
| Current direct launches | Candidate executors and workflow leaves spawn outside `authorization.rs` | `kernel/src/pipeline.rs:1856`, `lifecycle_executor/src/codex.rs:254`, `lifecycle_executor/src/workflow_leaf.rs:434` |
| Evidence ordering | UE-001/UE-002 dynamic/adversarial proof and implementation authorization | `architecture/acceptance-criteria.md:20`, `support/implementation-grade-completeness-review.md:9` |
| Cross-packet ownership | RP-01 semantics; RP-03 persistence; RP-02 isolation; RP-11 Harness; RP-13 budgets | parent `resources/source-ownership-map.md:6` |
| Discoverability | Reading order, catalog, contract, traceability | `navigation/`, `resources/` |

## External Criteria Evaluation

| Criterion | Result | Evidence-backed assessment |
| --- | --- | --- |
| Modularity | revision required | Semantic ownership is crisp, but invocation ownership is described generically and omitted from exact durable scope. |
| Discoverability | pass | The packet exposes its target, gaps, acceptance criteria, migration, and evidence obligations clearly enough to find the contradictions. |
| Coupling | revision required | Shared launch files require trusted serialization, but neither the child target list nor parent collision ledger assigns RP-01's guard-invocation edits. |
| Operability | revision required | One denial/receipt path is planned, but the design cannot yet guarantee that every current candidate executor crosses it. |
| Change safety | revision required | An incomplete cutover scope can leave a direct legacy spawn while claiming atomic bypass removal. |
| Testability | revision required | The test matrix is strong, but its evidence is placed before authorization of the exact candidate it must exercise. |

## Critical Gaps

### RP01-LAUNCH-DOMINANCE-SCOPE-001 — CRITICAL

Impact: AC-02 and the cutover plan cannot be fulfilled within the declared
RP-01 write boundary. `lifecycle_executor/src/authorization.rs` performs
admission work, but it does not contain or dominate every current spawn. At
least the kernel pipeline executor, lifecycle Codex/Claude executor, and
workflow leaf executor directly spawn from other files.

Risk: an implementation can produce a valid guard API and receipt while a
candidate process still launches through an unedited legacy path. That violates
the packet's central bypass-free authority claim and makes atomic cutover
unverifiable.

Acceptance criteria: enumerate every candidate-launch call site; classify
non-candidate utility subprocesses separately; assign exact file/module/symbol
scope to RP-01 or an explicitly ordered integration owner; synchronize the
parent registry and collision ledger; require static and dynamic proof that
every candidate launch reaches exactly one final guard immediately before
spawn.

### RP01-IMPLEMENTATION-EVIDENCE-CYCLE-002 — HIGH

Impact: the current completeness receipt cannot pass and AC-07 forbids
implementation authorization until UE-001/UE-002 exist, while those records
require an exact implementation commit and dynamic/concurrent execution.

Risk: the lifecycle either deadlocks or someone weakens the gate by treating
planned, parent, or pre-authorization evidence as proof of implemented
behavior.

Acceptance criteria: make proposal completeness and implementation-prompt
authorization depend on a complete design, accepted decisions, exact scope,
and executable proof plan; make UE-001/UE-002 mandatory after candidate
implementation and before implementation completion, conformance, or
promotion; retain exact-commit and evidence-class binding.

## Recommended Changes

| Priority | Recommendation | Expected benefit | Tradeoff |
| --- | --- | --- | --- |
| P0 | Add an exhaustive candidate-launch census and exact invocation ownership to RP-01 and the parent registry/collision ledger. | Makes guard dominance implementable and independently reviewable. | More shared-file serialization and possibly a broader child diff. |
| P0 | Rewrite AC-07 and the completeness receipt to separate candidate authorization from post-implementation proof. | Removes the lifecycle cycle without weakening promotion gates. | Requires explicit evidence stages and terminology. |
| P1 | Name a single structural guard invocation API and prohibit raw candidate-executor `Command::spawn` outside its implementation. | Creates a mechanically checkable fitness function. | Utility subprocesses need an explicit non-candidate classification to avoid false positives. |
| P1 | Preserve RP-03/RP-02/RP-04/RP-11/RP-13 semantic exclusions while assigning shared call-site edits. | Prevents scope correction from absorbing downstream ownership. | The ownership map becomes more detailed. |

## Keep As-Is Decisions

- Keep one candidate-immutable evaluator/policy/bin/config/receipt identity.
- Keep structural path/ref/URI/repository/capability comparison and fail-closed
  denial for stale, widened, substituted, revoked, or consumed authority.
- Keep one-shot at-most-once consumption under concurrency and crash testing.
- Keep RP-01 semantic ownership separate from RP-03 persistence, RP-02
  isolation, RP-04 credentials/effects, RP-11 Harness, and RP-13 budgets.
- Keep the atomic clean-break posture and prohibition on a legacy authority
  bridge or candidate-tree fallback.

## Open Questions / Unknowns

- The full candidate-versus-utility subprocess census remains to be authored by
  the revision; this audit proves representative omitted candidate launch sites,
  not the final enumerated inventory.
- Exact shared ownership may add RP-01 targets or designate a parent integration
  owner, but either choice must be explicit and collision-ledger-backed.
- RP-00 implementation and current containment proof remain later RP-01
  implementation-entry prerequisites.

## Self-Challenge

- Exact child/parent target equality does not close the scope issue because both
  surfaces carry the same omission.
- Pre-spawn `authorize_execution` in the kernel pipeline does not establish the
  stated exact final guard or one-shot consumption immediately before spawn.
- Calling the launch sites a future shared integration lane does not authorize
  edits absent exact target and collision ownership.
- UE-001/UE-002 cannot honestly predate the authorized exact implementation
  whose concurrency and crash behavior they test.

## Done Gate

All 22 packet files are accounted, three structural passes converge on zero
errors and the same expected future-evidence-root warning, and exact target
equality is confirmed. Two open findings remain at or above medium. Done gate:
`revision-required`.
