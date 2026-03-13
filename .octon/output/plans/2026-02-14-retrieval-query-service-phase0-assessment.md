# Assessment: `retrieval/query` Service — Phase 0 Implementation

**Scope:** Phase 0 contract scaffold at `retrieval/query/`
**Plan reference:** `.octon/output/plans/2026-02-14-retrieval-query-service-plan.md`
**Prior assessment:** `.octon/output/plans/2026-02-14-retrieval-query-service-plan-assessment.md`
**Assessment date:** 2026-02-14
**Risk tier:** B (cross-module contract, registry, validation coordination)

---

## Verdict

Phase 0 is substantially complete. The contract scaffold is well-structured, internally consistent, and correctly enforces the native-first architectural boundary. Six findings identified — none are blockers, two are worth addressing before Phase 1.

---

## Rich Contract Completeness

All six required components per `conventions/rich-contracts.md` are present:

| Requirement | Artifact | Status |
|---|---|---|
| schema | `schema/input.schema.json`, `schema/output.schema.json` | Present |
| rules | `rules/rules.yml` | Present (6 rules) |
| fixtures | `fixtures/positive.json`, `fixtures/negative.json`, `fixtures/edge.json` | Present |
| invariants | `contracts/invariants.md` | Present (9 invariants) |
| error_semantics | `contracts/errors.yml` | Present (9 codes) |
| compatibility_profile | `compatibility.yml` | Present |

Phase 0 deliverable count: 13/13 artifacts present.

---

## Strengths

### 1. Native-first enforcement is multi-layered

The architectural boundary isn't just documented — it's structurally enforced at three levels: rule `query.input.adapter-free-core` blocks adapter/provider/model keys from the input schema, invariant 8 declares the policy, and `ProviderTermLeakError` + `NativeInvariantViolation` error codes make violations typed and actionable. Zero provider-specific terms in any core contract file. `guide.md` correctly scoped as design context only (invariant 9).

### 2. Signal vocabulary is consistent end-to-end

`keyword | semantic | graph` appears identically in input schema enums, output schema signal/timing breakdowns, diagnostics, invariants, and fixtures. The rename from `dense` to `semantic` (reflecting agent-interpreted scoring, not embedding infrastructure) is carried through cleanly.

### 3. Determinism boundary is explicit

The output schema's `deterministic_stages` enum (`keyword, graph, fusion, citation`) deliberately excludes `semantic`. Invariants 2-3 codify this split. Positive fixtures assert only deterministic stages — following the plan assessment's recommendation. This prevents model-dependent fixture breakage.

### 4. Error taxonomy is complete and cross-consistent

The 9 error codes in `contracts/errors.yml` match exactly the `error.code` enum in `schema/output.schema.json` and the table in `references/errors.md`. Exit codes follow a logical scheme (4=semantic/policy, 5=structural, 6=dependency). Every code has an `operator_action`.

### 5. Degradation semantics are well-modeled

The `required_signals` field in the input schema distinguishes must-succeed signals from best-effort ones. Invariants 6-7 define the resulting behavior: `status=error` for required signal failure, `status=partial` + `degraded_signals` for optional. The edge fixture validates this exact scenario.

---

## Findings

### F1: Fixture format diverges from convention — Severity: Medium

The fixtures convention (`conventions/fixtures.md`) specifies:
- File naming: `{case-name}.fixture.json`
- Required fields: `input`, `expected_output`, `metadata`

Actual implementation:
- Files named `positive.json`, `negative.json`, `edge.json` (no `.fixture` infix)
- Fields: `id`, `description`, `request`, `expect` (different key names, no `metadata` wrapper)

**Impact:** Tier 2 evaluators expecting canonical fixture format may fail to parse. Any future cross-service fixture runner would need service-specific parsing.

**Recommendation:** Rename and restructure before Phase 1, or document a justified deviation in the compatibility profile.

### F2: Fixture coverage is thin for three command families — Severity: Medium

Query declares three commands (`ask`, `retrieve`, `explain`). The three fixture files contain one test case each, all testing `retrieve`. No positive fixture exercises `ask` or `explain`.

The fixtures convention states: "Minimum coverage applies per behavior family." With three behavioral families, one positive/negative/edge per family would be 9 fixtures minimum.

**Impact:** `ask` and `explain` behavior is unanchored by fixtures, leaving Phase 1 implementation without calibration targets for two of three commands.

**Recommendation:** Add at least `positive-ask.fixture.json` and `positive-explain.fixture.json` before Phase 1 implementation begins, even if expectations are initially minimal.

### F3: `fail_closed_policy` stricter than plan — Severity: Low (positive)

The plan's compatibility profile specified `fail_closed_policy: false`. The implementation chose `true`, consistent with `SERVICE.md` frontmatter (`fail_closed: true`) and rule `query.policy.fail-closed`. The stricter choice is correct. This is a plan-to-implementation delta, not a defect.

### F4: No conditional validation for `strategy.weights` vs `fuse` — Severity: Low

The input schema allows `weights` when `fuse=rrf` (meaningless) and doesn't require `weights` when `fuse=weighted` (incomplete). JSON Schema 2020-12 can express this via `if/then`, but it adds complexity for marginal benefit.

**Recommendation:** Defer. Handle at runtime in Phase 1 — emit a warning in `diagnostics.warnings` when `fuse=weighted` and `weights` is absent.

### F5: `answer` field not conditionally required for `ask` — Severity: Low

Output schema makes `answer` optional regardless of `command`. For `ask`, a missing `answer` would be a broken response. JSON Schema conditional constraints could enforce this, but runtime validation is simpler and sufficient.

**Recommendation:** Defer. Enforce in Phase 1 runtime and document in invariants as: "`ask` command MUST produce `answer` unless `status=error`."

### F6: `guide.md` vocabulary drift — Severity: Low, informational

`guide.md` uses `dense` throughout as a signal name and extensively references external libraries (FAISS, ColBERT, pgvector, networkx, etc.). Core contracts use `semantic`. This is by design (invariant 9 clarifies the relationship), but the divergence could confuse new contributors reading both files.

**Recommendation:** No action needed now. Consider a brief editor's note at the top of `guide.md` post-Phase 1 linking to SERVICE.md as the authoritative contract.

---

## Cross-Reference Integrity

| Cross-reference | Status |
|---|---|
| Error codes: errors.yml ↔ output schema enum ↔ errors.md table | Consistent (9/9/9) |
| Signal vocabulary: input schema ↔ output schema ↔ invariants ↔ fixtures | Consistent |
| Command vocabulary: input schema ↔ invariants ↔ examples ↔ errors | Consistent |
| Required output fields: rules.yml rule 5 ↔ output schema `required` | Consistent |
| Adapter-disallowed keys: rules.yml rule 6 ↔ input schema (absent) | Consistent |
| Compatibility tools: compatibility.yml ↔ SERVICE.md `allowed-tools` | Consistent |
| Service not in manifest.yml | Correct (Phase 2) |
| generated.manifest.json is stub | Correct (Phase 0) |

---

## Phase 0 Exit Gate Check

Per the plan:
> Contract completeness meets rich-contract requirements. Fixture inputs validate against input schema; fixture expected outputs validate against output schema.

- Rich contract completeness: **Pass** (all 6 components present and parseable)
- Fixture input validation: **Pass** (positive and edge fixture `request` objects conform to input schema; negative fixture intentionally fails validation with `"dense"` signal)
- Fixture output validation: **Qualified** — fixture `expect` blocks are assertion specs (e.g., `minimumCandidates`, `deterministicStages`), not full output schema instances. This is reasonable for Phase 0 but means schema-level output validation hasn't been exercised yet.

---

## Summary

| Dimension | Verdict |
|---|---|
| Rich contract completeness | Pass |
| Native-first enforcement | Strong |
| Signal/command vocabulary consistency | Pass |
| Error taxonomy consistency | Pass |
| Determinism boundary | Correctly modeled |
| Degradation semantics | Well-modeled |
| Fixture format conformance | Deviation (F1) |
| Fixture behavioral coverage | Thin (F2) |
| Plan alignment | Aligned, one positive delta (F3) |
| Provider-term cleanliness | Clean |

**Recommended action before Phase 1:** Address F1 (fixture format) and F2 (fixture coverage). The remaining findings are low-severity and can be resolved during Phase 1 implementation.
