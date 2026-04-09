# Target-State Constitutional Remediation Spec

## 1. End-State Invariants
The cutover is complete only when the following end-state invariants hold:

1. **Canonical support-target model is single-sourced.**
   - `/.octon/instance/governance/support-targets.yml` remains authoritative for the live support universe, tier taxonomy, tuple inventory, and top-level support claim mode.
   - `/.octon/instance/governance/support-target-admissions/**` becomes the sole canonical source for tuple-specific operational semantics (`route`, `requires_mission`, capability packs, proof planes, authority artifacts, claim effect, review window).
   - `/.octon/instance/governance/support-dossiers/**` are evidence dossiers only; they do not introduce independent tuple semantics.
   - `/.octon/generated/effective/governance/support-target-matrix.yml` is projection-only and generated exclusively from the canonical authored surfaces.

2. **No duplicate authored matrix truth.**
   - Any authored `compatibility_matrix` or equivalent duplicate tuple-semantic matrix is removed from `support-targets.yml`.
   - `support-targets.yml` may hold tuple inventory references, but not independently authored copies of tuple semantics.

3. **Run binding is tuple-first.**
   - Every consequential or admitted live run binds `support_target_tuple_id` and `support_target_admission_ref`.
   - `requires_mission` in the run contract must equal the canonical admission value.
   - RunCards may summarize support status, but cannot redefine it.

4. **Authority purity is absolute.**
   - The canonical authority consumers are directory-family artifacts under:
     - `/.octon/state/control/execution/approvals/**`
     - `/.octon/state/control/execution/exceptions/**`
     - `/.octon/state/control/execution/revocations/**`
   - Flat compatibility aggregates are removed from live control roots.
   - Any surviving aggregate views are generated projections outside live authority roots.

5. **Runtime operations do not carry release-envelope language.**
   - `stage-attempts/*.yml`, `evidence-classification.yml`, and analogous operational artifacts must not encode active-release claim-envelope statements such as “stage-only” or “excluded from the live claim envelope” for admitted live tuples.
   - Claim-scope language is confined to disclosure artifacts (RunCards, HarnessCards, release summaries).

6. **Single canonical stage-attempt family.**
   - All in-scope active claim-bearing runs use `stage-attempt-v2`.
   - Any older retained stage-attempt family is either migrated to v2 or retired out of the active claim set.

7. **Generated surfaces are never authority.**
   - `/.octon/generated/effective/**` remains projection-only.
   - Generated closure or governance surfaces may mirror canonical truth but never override it.

8. **Computed claim publication.**
   - `claim_status: complete` is a computed outcome of a zero-blocker, two-pass clean certification state.
   - It is not hand-authored independently of closure evidence.

9. **Known-limits discipline is mandatory.**
   - HarnessCard `known_limits` is derived from the blocker ledger, exclusions, and bounded support realities.
   - `known_limits: []` is allowed only when blocker ledger is zero and the release truly has no live boundedness or unresolved caveats requiring disclosure.

10. **Two-pass idempotent certification is constitutional, not optional.**
    - Pass 1 proves semantic and structural correctness.
    - Pass 2 proves reproducibility, idempotence, and projection parity from the newly generated state.

## 2. Authority Boundary Model
### Canonical
- `/.octon/framework/constitution/**`
- `/.octon/instance/charter/**`
- `/.octon/instance/orchestration/missions/**`
- `/.octon/instance/governance/support-targets.yml`
- `/.octon/instance/governance/support-target-admissions/**`
- `/.octon/state/control/execution/runs/**`
- `/.octon/state/control/execution/approvals/**`
- `/.octon/state/control/execution/exceptions/**` (directory family only)
- `/.octon/state/control/execution/revocations/**` (directory family only)
- `/.octon/state/evidence/**`
- `/.octon/instance/governance/disclosure/release-lineage.yml`

### Projection-only
- `/.octon/generated/effective/**`
- governance/disclosure mirrors generated from active release evidence
- any aggregate support-target or authority views generated for convenience

### Historical shim or mirror
- repo-root `AGENTS.md`, `CLAUDE.md`, `.octon/AGENTS.md`
- bootstrap-era `OBJECTIVE.md` and intent-contract lineage files
- any superseded release disclosure bundles

## 3. Runtime / Evidence / Disclosure Expectations
- Runtime artifacts tell the execution truth.
- Disclosure artifacts tell the claim truth.
- Generated projections tell the convenience truth.
- Historical shims tell the lineage truth.
- No surface may be used outside its role.

## 4. Minimum Clean Target State Required for Unqualified Completion
The minimum acceptable end-state is not “mostly fixed.” It is:
- zero open blocker ledger,
- zero support-target semantic mismatches,
- zero live authority references to demoted compatibility surfaces,
- zero stale claim-envelope phrases in active claim-bearing artifacts,
- zero mixed stage-attempt family/version in the active claim-bearing run set,
- zero green closure gates masking contradictory source artifacts.
