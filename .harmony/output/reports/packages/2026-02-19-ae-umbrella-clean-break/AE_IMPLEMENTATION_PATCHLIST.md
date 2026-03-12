# AE Implementation Patchlist

## Scope

Exact surfaces that must change for clean-break umbrella-chain migration.

## A) Priority/Chain Definitions and Evaluation Logic

### 1. `.harmony/assurance/CHARTER.md`

Change:
- Replace old five-step chain with `Assurance > Productivity > Integration`.
- Replace section definitions and trade-off rules accordingly.
- Keep autonomy policy, but classify autonomy under Productivity.

Pseudo-diff:

```diff
-1. **Trust**
-2. **Speed of development**
-3. **Ease of use**
-4. **Portability**
-5. **Interoperability**
+1. **Assurance**
+2. **Productivity**
+3. **Integration**
```

### 2. `.harmony/assurance/standards/weights/weights.yml`

Change:
- Update `charter.priority_chain`.
- Replace old-chain `tradeoff_rules`.
- Replace legacy `charter.attribute_outcome_map` with `charter.attribute_umbrella_map`.
- Bump version/changelog.

Pseudo-diff:

```diff
 charter:
   priority_chain:
-    - id: trust
-    - id: speed_of_development
-    - id: ease_of_use
-    - id: portability
-    - id: interoperability
+    - id: assurance
+    - id: productivity
+    - id: integration
   attribute_umbrella_map:
-    observability: trust
-    deployability: speed_of_development
-    portability: portability
-    interoperability: interoperability
+    observability: assurance
+    deployability: productivity
+    portability: integration
+    interoperability: integration
```

### 3. `.harmony/runtime/crates/assurance_tools/src/main.rs`

Change:
- Rename internal output semantics from `charter_outcome`/`charter_rank` to umbrella terms.
- Keep deterministic tie-break using umbrella rank.
- Replace header titles that still say "Quality".

Pseudo-diff:

```diff
-m.insert("charter_outcome", ...)
-m.insert("charter_rank", ...)
+m.insert("umbrella", ...)
+m.insert("umbrella_rank", ...)

-"# Quality Weight Scorecard"
+"# Assurance Engine Scorecard"

-"# Weighted Quality Results"
+"# Assurance Engine Results"

-"# Weighted Quality Gate Summary"
+"# Assurance Engine Gate Summary"
```

## B) Weight Computation and Rollups

### 4. `.harmony/runtime/crates/assurance_tools/src/main.rs`

Change:
- Add umbrella rollup computation from attribute-level values.
- Persist at top-level `umbrellas` and include in markdown outputs.
- Assurance rollup uses hybrid formula defined in `AE_MAPPING.md`.

Pseudo-diff:

```diff
+let umbrella_rollups = compute_umbrella_rollups(&subsystems_out, &effective_weights_all, ...);
+scorecard.insert("umbrellas".to_string(), umbrella_rollups_json(umbrella_rollups));
```

## C) Reporting Output Formats

### 5. `.harmony/runtime/crates/assurance_tools/src/main.rs`

Change:
- Update renderers:
  - `render_scorecard_md`
  - `render_results_md`
  - `render_regressions_md`
  - `render_gate_summary`
- Add umbrella summary table and umbrella-ranked tie-break explanations.

Before/after sample:

```diff
-Priority chain: Trust (trust) > Speed of development (...) > Ease of use (...)
+Priority chain: Assurance (assurance) > Productivity (productivity) > Integration (integration)
```

## D) Gates and Thresholds

### 6. `.harmony/runtime/crates/assurance_tools/src/main.rs`

Change:
- Keep current `weight>=4/5` hard/warn thresholds.
- Add umbrella-priority guardrails for rank-1 `weight=3` attributes (criteria/evidence + regression warning).
- Drive "high-priority" determination through umbrella rank and weight.
- Ensure top-driver ordering and tie-break findings use umbrella chain IDs.

Pseudo-diff:

```diff
-let charter_priority_deviation = matches!(charter_rank, Some(1)) && new_value < old_value;
+let umbrella_priority_deviation = matches!(umbrella_rank, Some(1)) && new_value < old_value;
```

## E) Docs and Governance

### 7. `.harmony/assurance/README.md`
### 8. `.harmony/assurance/DOCTRINE.md`
### 9. `.harmony/assurance/governance/SUBSYSTEM_OVERRIDE_POLICY.md`
### 10. `.harmony/assurance/standards/weights/weights.md`
### 11. `.harmony/assurance/complete.md`
### 12. `.harmony/assurance/session-exit.md`

Change:
- Replace old chain language and trust-first-only phrasing with umbrella contract language.
- Clarify that attribute-level remains source of truth.
- Update checklist wording to "AE umbrella-chain alignment".

## F) CI and Command Surfaces

### 13. `.github/workflows/assurance-weight-gates.yml`

Change:
- Rename user-facing strings from "weighted quality" to "assurance engine".
- Keep file triggers, but ensure artifact names no longer use quality terms.

Pseudo-diff:

```diff
-name: Assurance Weight Gates
+name: Assurance Engine Gates

-name: Compute weighted assurance scorecard
+name: Compute assurance engine scorecard

-name: assurance-weight-scorecard
+name: assurance-engine-scorecard
```

### 14. `.harmony/assurance/_ops/scripts/alignment-check.sh`

Change:
- Update step labels that still include "weighted assurance" to "assurance engine".

## G) QGE -> AE Repo Rename Sweep

### 15. Active-surface rename pass

Command (dry-run first):

```bash
rg -n "QGE|legacy QGE label" .harmony .github
```

Required updates:
- any active docs or commands still naming QGE
- report templates that are intended to be copied forward

### 16. Historical reports strategy

If strict repo-wide rename is required, include:
- `.harmony/output/reports/packages/2026-02-18-quality-charter-qge-integration/` rename and content edits

If preserving historical provenance is preferred, keep historical files immutable and add:
- a migration note stating historical references are pre-AE artifacts

## H) Regenerated Artifacts

### 17. `.harmony/output/assurance/`

Regenerate:
- scorecards
- results
- effective weights matrix
- deviations and gate summary

Reason:
Existing generated outputs embed old chain IDs (`trust`, `speed_of_development`, `ease_of_use`).
