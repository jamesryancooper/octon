# Final Integrated Review — Octon Architecture and Migration

> **Non-authoritative research and decision input.** Independent review at commit
> `c5b1f5760c78ff521cca6b054e4e8fef5300505b` (branch `main`, clean tree), macOS
> 26.5.2 arm64, 2026-07-12 UTC. Produced without reading any sibling review.
> Intake integrity verified (94/94 sha256 OK). 106 findings across three phases
> (66 Phase 1 + 40 Phase 3); highest-severity findings independently re-verified by
> the lead against source.

## Readiness verdict

> ## READY_WITH_BLOCKING_DECISIONS

The repository and this review contain enough to **author** the formal migration
proposal program — the packet structure, boundaries, dependencies, gaps, and
acceptance tests are all defined and evidence-grounded. But privileged
implementation may **not** begin until (a) a small set of **blocking operator
decisions** (OD-01 signing-vs-reword, OD-06 federation scope, OD-08 trust-root
inventory + epoch-0 bootstrap) are made, and (b) the **PP-00 blocker corrections**
(G-B1…G-B5: honest claims, a pinned authority decision function, disabled
candidate-write/direct-main, a full git-extension allowlist, and fail-closed
override env) are completed. The architecture is sound and the direction is
confirmed; the blockers are corrections *within* the program, not reasons the
program cannot be written. This is neither "ready to build now" nor "broken" —
it is "ready to formalize, with named decisions to settle first."

## The 14 questions

**1. What is true about current Octon?**
It is a large file-native constitutional governance system (~53k tracked `.octon`
files, ~157k Rust LOC across 13 crates, 42 CI workflows) wrapping frontier coding
agents. It has a genuinely strong single-use effect-token verifier
(`verify_authorized_effect`) applied across the kernel command/workflow/pipeline
paths, a deterministic digest-bound Harness Factory enforced in-kernel (FD-020
SATISFIED), non-authoritative provider adapters (FD-023 SATISFIED), and a
provenance-carrying extension catalog (FD-021). But the effect that matters most —
launching a credentialed autonomous agent — runs on a **separate self-attesting
plane** (`lifecycle_executor`, no dependency on the authority engine), the agent
inherits ambient credentials in the canonical repo with no OS sandbox, state is
loose non-atomic YAML/NDJSON, there is no broker, no signing, and route selection
prefers `direct-main`. **And** — the deepest correction — even the "strong"
authority engine computes its Allow/Deny by shelling out to a candidate-editable
policy file and bash runner (L1-01, lead-verified). So today the security boundary
is fully permeable to a misbehaving candidate (threat vectors T1–T7).

**2. Which inherited findings remain valid?** All eight intake current-state
findings were reverified at HEAD and **confirmed** (two-plane authority, credential
inheritance, git-protection need, candidate-controlled checks, file-state
insufficiency, hash-chaining ≠ authenticity, self-cert risk, direct-main ordering).

**3. Which were corrected/superseded?** Two were **strengthened**: (a) the lifecycle
plane has *no linkage at all* to the authority engine (not merely "self-attesting"),
and (b) there is *no signing primitive of any kind* (sharper than "hash chaining
doesn't prove authenticity"), with one layer mislabeling unkeyed hashes as
"signatures" that quorum never verifies. Phase 3 added the material correction that
the authority *decision function itself* is candidate-editable — qualifying Phase
1's "strong for kernel paths."

**4. Which final decisions are already satisfied?** FD-020 (Harness Factory) and
FD-023 (provider adapters). FD-021 (extension catalog) and the "never-authority"
half of FD-019 are nearly there.

**5. Partially satisfied?** FD-001, FD-003, FD-012, FD-013, FD-015, FD-016, FD-019,
FD-021, FD-024.

**6. Which require migration?** CONTRADICTED/ABSENT: FD-002, FD-004, FD-005, FD-006,
FD-007, FD-008, FD-009, FD-010, FD-011, FD-014, FD-017, FD-018, FD-022.

**7. Smallest safe migration?** Route the one ungated effect through the existing
verifier (extend, don't rebuild); add **one** broker process that owns the
transactional store + sanitized git + credentials (Phase 3 simplification: merge
the plan's three components into one); isolate the candidate (macOS sandbox +
disposable worktree); delegate the exact-SHA verifier to a GitHub App; invert the
route order; correct claims; wire the existing `promotion_blockers()` reader onto a
base-ref gate; add inert trust-root landing. Net-new essential components: **~3**,
not ~6. Full design in `phase-2/migration-architecture.md` with Phase 3 refinements.

**8. What must be removed before privileged implementation?** (G-B1…G-B5) Overstated
"signed/complete-mediation" claims; the candidate-editable authority decision path
(pin the policy file + runner; scrub override env); autonomous direct-main + managed
git hooks; the incomplete git-sanitization list; the fail-open `OCTON_*` override
family.

**9. Proof required before autonomous Class B publication?** The proof-of-architecture
integration test (spawn-guard → credentialless sandbox → brokered exact-SHA no-PR
land → transactional reconcile) with fault sub-assertions F1/F3/F5/F9/F13/F14/F16, a
candidate-immutable verifier, removal of the second CI credential plane, and the
L1-07 red-team (candidate denied across all six vectors).

**10. Proof required before autonomous trust-root activation?** Base-ref (not
PR-head) verifiers, `promotion_blockers()` on the enforced path, inert landing, a
pinned out-of-tree trust-root inventory, an operator-anchored epoch-0 bootstrap, and
staged prev-version-verified rollback-capable activation (F8/F12). This is the
strictest gate and depends on OD-08.

**11. Unnecessary complexity to remove?** Committed per-run state exhaust
(40k/53k tracked files — SR-10); the multi-party federation/trust-compact surface
(~1.5k LOC — SR-11, gate off, PERMANENTLY_OUT_OF_SCOPE for solo); the 7×5 ACP matrix
routine-commit ceremony + Class-A/B/C name collision (SR-12); and un-trimmed CI gates
(SR-13). Plus plan simplifications: merge broker+store+git (SR-03), delegate the
verifier (SR-04), defer full SQLite and signing (SR-05/06), defer workspace-project
registry (SR-08).

**12. Operator decisions remaining?** Nine (OD-01…OD-09); the blocking three are
OD-01 (signing vs git-anchored — recommend git-anchored), OD-06 (federation off),
OD-08 (trust-root inventory + epoch-0).

**13. Proposal program to create?** PP-00…PP-12 as mapped, with the Phase 3
corrections folded in: PP-00 also pins the decision function + FD-002 crosswalk +
run-exhaust; PP-01 gates *every* spawn; PP-03 is atomic-write + narrow CAS (not full
migration); the verifier is provider-delegated; doctor pulled forward to PP-04.

**14. Is the repository ready for that program?** Yes to author it; not yet to
implement privileged parts of it — hence READY_WITH_BLOCKING_DECISIONS.

## The one-paragraph truth

Octon is a strong, over-large governance system whose *compile-time* surfaces are
excellent and whose *runtime effect boundary* is not yet real: the authority engine
is well-structured but its decision is candidate-editable and it is bypassed by the
agent-launch path, agents run credentialed in the canonical repo with no isolation,
and there is no broker, store, signing, or safe activation. The migration to fix this
is additive around a strong core — not a rewrite — and the smallest safe version adds
about three new components and corrects a handful of claims and route decisions. The
work is well-scoped and provable; what stands between here and a formal program is a
few operator decisions and the PP-00 corrections, all of which this review specifies.
