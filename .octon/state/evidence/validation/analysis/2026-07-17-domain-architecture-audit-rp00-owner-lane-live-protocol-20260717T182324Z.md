# Owner-Lane Live Protocol Architecture Audit

- run_id: `rp00-owner-lane-live-protocol-20260717T182324Z`
- target_mode: `observed`
- domain_path: `.octon/framework/engine/runtime/crates/kernel/src/owner_lane.rs`
- evidence_depth: `deep`
- severity_threshold: `medium`
- post_remediation: `false`
- baseline_commit: `66a226b7751822ea8becf431dafeb5b4f5900d99`

## Current Surface Map

| Surface | Responsibility | Evidence |
| --- | --- | --- |
| Immutable input model | Deserialize and cross-bind authorization, issuance, lifecycle, admission, manifest, and attestation artifacts | `.octon/framework/engine/runtime/crates/kernel/src/owner_lane.rs:42`, `:79`, `:97`, `:117`, `:136`, `:159` |
| Pre-capture validation | Validate all six immutable inputs and tool bindings before credential intake | `.octon/framework/engine/runtime/crates/kernel/src/owner_lane.rs:391`, `:506`, `:590` |
| Closed operation executor | Enforce ordered, allowlisted operations with no-resend journaling | `.octon/framework/engine/runtime/crates/kernel/src/owner_lane.rs:617`, `:732`, `:890` |
| Secret transport | Read one inherited FD, use stdin/FIFO transport, and zeroize local memory | `.octon/framework/engine/runtime/crates/kernel/src/owner_lane.rs:378`, `:1265`, `:1356` |
| Runtime receipts | Emit construction, completed-prefix, and retirement evidence | `.octon/framework/engine/runtime/crates/kernel/src/owner_lane.rs:942`, `:1059`, `:1462`, `:1490` |
| CLI authority seam | Prepare the complete plan before authority issuance and execution | `.octon/framework/engine/runtime/crates/kernel/src/commands/mod.rs:1702` |
| External contract | Describe one closed execution boundary and its artifact graph | `.octon/framework/engine/runtime/spec/owner-lane-execution-v1.md` |
| RP-00 consumer contract | Require pre-issuance authority, post-probe admission, complete credential binding, and post-PR typed construction | `.octon/inputs/exploratory/proposals/architecture/octon-architecture-migration-containment/architecture/implementation-plan.md:28`, `:40`, `:381`, `:470`; `.octon/inputs/exploratory/proposals/architecture/octon-architecture-migration-containment/architecture/acceptance-criteria.md:50`, `:107` |

## Critical Gaps

### RP00-OWNER-LANE-TEMPORAL-BINDING-001 — CRITICAL

Impact: no truthful artifact set can enter the live executor. The runtime
requires authorization to bind the manifest and requires an already-passing
admission receipt before credential capture, while RP-00 requires
authorization before issuance and the manifest only after live admission.

Risk: an operator must either fabricate post-event evidence in advance or use
the credential outside the governed boundary. Either path defeats the safety
purpose of the runtime.

Acceptance criteria: pre-issuance authorization is independently sealable;
exact receipt creates the pre-use lifecycle envelope; the runtime performs and
journals admission reads; it then writes the admission receipt; no mutation is
eligible until that receipt validates; manifest and attestation construction
occur after admission without an upstream digest cycle.

### RP00-OWNER-LANE-CREDENTIAL-BINDING-002 — CRITICAL

Impact: the current authorization schema cannot express the resource owner,
sole selected repository, public-read boundary, ordered permissions, issuance
source/time, provider expiry, local deadline, allowed probes, or replacement
lock required by the consuming protocol.

Risk: a broader, longer-lived, or incorrectly scoped credential can satisfy the
runtime's current structural validation.

Acceptance criteria: the pre-issuance and lifecycle schemas carry every
required intended and observed field; exact mismatch or unavailable proof
enters terminalization without repository mutation; tests cover every omitted,
widened, reordered, and expired tuple.

### RP00-OWNER-LANE-POST-PR-CONSTRUCTION-003 — CRITICAL

Impact: the fixed manifest requires numeric marker and merge paths before the
provider assigns the PR number. Completed-prefix evidence is written but cannot
bind or construct later operations.

Risk: live execution must predict an external identifier, mutate a sealed
manifest, or issue a request outside the executor.

Acceptance criteria: the manifest contains strict typed templates; exactly one
reconciled PR response/read produces a sealed completed-prefix receipt; only
declared bindings resolve the remaining operations; normalization reproduces
the committed template digest; unknown create outcome never resends.

## Recommended Changes

1. **P0 — Split preparation into durable stages.** Introduce explicit
   `preauthorize`, `capture`, `admit`, `seal-manifest`, and `execute-suffix`
   transitions behind the same kernel command family. Benefit: artifact truth
   follows event time and every restart is bounded by durable phase evidence.
   Tradeoff: more state-machine code and recovery fixtures.
2. **P0 — Move expected credential constraints upstream.** Put the complete
   intended token tuple in pre-issuance authorization and record observed or
   unavailable fields in the lifecycle/admission evidence. Benefit: admission
   can compare live facts against sealed intent. Tradeoff: some provider facts
   may require explicitly trusted issuance evidence because GitHub does not
   expose a complete token-introspection API.
3. **P0 — Add typed post-prefix construction.** Represent post-PR paths and
   bodies as closed templates with explicit binding positions and a canonical
   normalization check. Benefit: provider-assigned PR identity can be used
   without mutating upstream authority. Tradeoff: canonicalization and replay
   tests become more extensive.
4. **P1 — Preserve one authority scope across stages.** Bind every phase to the
   same run, review, base, candidate, tree, repository, and one-attempt lock,
   and consume the provider-mutation effect only when the first mutation is
   eligible. Benefit: admission failures can terminalize without granting
   repository mutation. Tradeoff: authority issuance must distinguish
   credential lifecycle effects from repository mutation effects.

## Keep As-Is Decisions

- Keep the inherited-FD credential intake and rejection of argv, environment,
  URL, file, `gh`, SSH, and ambient-helper transport.
- Keep canonical tool-path/digest verification before capture and before each
  launch.
- Keep append-and-fsync pre-send journaling and permanent no-resend behavior for
  unknown outcomes.
- Keep the fixed GitHub origin/operation allowlist and same-token retirement
  requirements.

These surfaces are independently useful and directly tested; replacing them
would add risk without addressing the three temporal and construction gaps.

## Open Questions / Unknowns

- GitHub's API does not appear to expose a complete fine-grained PAT selection,
  permission, and expiration introspection record. The correction must name the
  exact trusted issuance evidence used for facts that cannot be independently
  read; it must not infer them from endpoint success.
- The current RP-00 provider snapshot predates a live credential. A later
  separately authorized run must establish the exact workflow, ruleset, and
  competing-writer tuple before credential issuance.
- The best durable state location is expected to be the existing run-bound
  evidence/control root, but the correction design must prove crash-safe
  ownership and no cross-run artifact substitution.

## Assumptions And Self-Challenge

- The audit treats RP-00 documents and runtime contracts as analyzable evidence,
  not as intrinsically correct doctrine.
- A counter-interpretation that the admission receipt is merely a predeclared
  expectation was rejected because its schema asserts observed `200`, admitted,
  pagination-complete, prior-authenticated-200, and `recorded_at` facts, while
  the executor has not yet read the credential.
- A counter-interpretation that the future PR number can be predicted was
  rejected because provider allocation is external and the accepted protocol
  explicitly requires authoritative reconciliation.

## Done Gate

Discovery-mode audit complete. Three open CRITICAL findings intentionally route
to packet revision and implementation; remediation convergence is not claimed.
