# Octon Weighted Quality Model Specification
Version: `0.1.0-proposed`
Status: `proposed`
Owner: `octon-platform`
Date: `2026-02-18`

## 1. Goals
1. Provide one deterministic way to prioritize quality attributes across Octon contexts.
2. Make trade-offs explicit, versioned, and auditable.
3. Let weights vary by run mode, subsystem, maturity, and repo without forking policy.
4. Ensure active weights directly drive planning, prioritization, and gate behavior.
5. Keep the model portable across repos, OSs, and toolchains.

## 2. Non-Goals
1. Replace domain-specific engineering judgment.
2. Encode every team preference as a new profile.
3. Force one static weight set for all repositories.
4. Depend on any single runtime, language, or CI provider.

## 3. Canonical Attribute Set (Stable IDs)
| ID | Attribute |
|---|---|
| `performance` | Performance |
| `scalability` | Scalability |
| `reliability` | Reliability |
| `availability` | Availability |
| `robustness` | Robustness |
| `recoverability` | Recoverability |
| `dependability` | Dependability |
| `safety` | Safety |
| `security` | Security |
| `simplicity` | Simplicity |
| `evolvability` | Evolvability |
| `maintainability` | Long-term Maintainability |
| `portability` | Portability |
| `functional_suitability` | Functional Suitability |
| `completeness` | Completeness |
| `operability` | Operability |
| `observability` | Observability |
| `testability` | Testability |
| `auditability` | Auditability |
| `deployability` | Deployability/Installability |
| `usability` | Usability |
| `accessibility` | Accessibility |
| `interoperability` | Interoperability |
| `compatibility` | Compatibility/Co-existence |
| `configurability` | Configurability |
| `sustainability` | Sustainability |

## 4. Weight Semantics
- Weight scale: `1..5`.
- `5`: mandatory/high-assurance focus; missing evidence blocks in strict contexts.
- `4`: strong focus; regressions need mitigation and owner follow-up.
- `3`: important but explicitly tradeable.
- `2`: opportunistic focus.
- `1`: currently deprioritized.

## 5. Data Model

### 5.1 Weights Registry (`weights.yml`)
Required top-level fields:
- `meta`: `version`, `updated_at`, `owner`, `status`.
- `attribute_catalog`: stable ID registry.
- `profiles`: named baseline profiles.
- `overrides`: layer-specific overrides.
- `maturity_defaults`: profile mapping by stage.
- `deprecation_policy`: profile lifecycle controls.
- `changelog`: append-only update history.

### 5.2 Human Contract (`weights.md`)
- Mirrors machine data.
- Includes rationale and trade-off notes.
- Links to ADRs for significant changes.

### 5.3 Score Inputs (`subsystem-scores.yml`)
Per subsystem and attribute:
- measured score (`0..5`),
- acceptance criteria text,
- evidence references (files, reports, checks),
- optional conflict records (attribute A vs B) with ADR links.

### 5.4 Score Outputs (`scorecards`)
Generated artifacts per run:
- effective weights snapshot,
- weighted scores,
- deltas vs baseline,
- top drivers list,
- gate decisions (pass/warn/fail).

## 6. Override Precedence
Effective weights are computed by applying layers in this exact order:
`global -> run-mode -> subsystem -> maturity -> repo`

If multiple layers set the same attribute, the right-most layer wins.
This precedence is deterministic and mandatory.

## 7. Active Weight Selection Rules
1. Resolve `active_profile` from CLI flag, env, or repo default.
2. Load baseline weights from selected profile.
3. Apply layer overrides using runtime context:
   - run mode (`local|ci|release|prod-runtime`),
   - subsystem (`runtime|quality|...`),
   - maturity (`prototype|alpha|beta|prod|critical`),
   - repo ID.
4. Validate all final weights are integers in `1..5` and all attributes exist.
5. Persist effective snapshot artifact for audit.

## 8. Scoring Algorithm
For each subsystem `s` and attribute `a`:
- `w[a]` = effective weight in `1..5`
- `m[s,a]` = measured score in `0..5`

Weighted subsystem score:
`score[s] = sum_a(w[a] * m[s,a]) / sum_a(w[a] * 5)`

System score:
`system_score = average(score[s] across scored subsystems)`

Attribute delta (vs baseline run):
`delta[s,a] = m_now[s,a] - m_prev[s,a]`

Weighted impact driver:
`impact[s,a] = w[a] * delta[s,a]`

Top drivers are sorted by `abs(impact)` descending.

## 9. How Weights Drive Engineering Decisions

### 9.1 Planning
- Planning templates must include explicit acceptance criteria for all effective weight `>=4` attributes.
- For effective weight `5` attributes, evidence source must be predeclared before implementation.

### 9.2 Prioritization
- Backlog ordering uses weighted risk:
  `priority = abs(negative_impact) * weight * blast_radius_factor`
- Highest priority items are regressions in weight `5` attributes.

### 9.3 Gates
- Gate strictness derives from effective weights + maturity stage.
- High-weight regressions fail earlier and with lower tolerated variance.

## 10. Enforcement Policy (Hard vs Soft)
Hard fail:
1. Missing acceptance criteria for any effective weight `5` attribute.
2. Missing evidence for any effective weight `5` attribute in `ci/release/prod-runtime`.
3. Regression beyond threshold for effective weight `>=4` attributes.
4. Missing ADR for unresolved `5 vs 5` trade-off conflict.

Soft warn:
1. Missing criteria/evidence for effective weight `4` attributes in `local` or `prototype`.
2. Regressions below hard threshold but above warning threshold.
3. Profile deprecation nearing sunset date.

## 11. Change Management

### 11.1 Who Can Change Weights
- Proposed by: subsystem owner or platform owner.
- Approved by: repo owner + architecture approver.
- Additional approval: security approver when changing `security`, `safety`, or `auditability` at `>=4`.

### 11.2 Required Change Artifacts
1. `weights.yml` + `weights.md` update.
2. Changelog entry with rationale and impact scope.
3. ADR when:
   - any weight moves by `>=2`,
   - any profile default changes,
   - a `5 vs 5` conflict boundary changes.

### 11.3 Review Cadence
- Monthly baseline review.
- Immediate review after Sev-1/Sev-2 incidents.
- Quarterly profile pruning to prevent profile sprawl.

## 12. Failure Modes and Mitigations
| Failure mode | Mitigation |
|---|---|
| Score gaming (inflated measured scores) | Require objective evidence links; random audits on high-impact changes |
| Weight drift without accountability | Append-only changelog + required ADR for high-impact moves |
| Profile sprawl | Hard cap on active profiles; deprecation SLA; reject near-duplicate profiles |
| Overfitting to one subsystem | Require subsystem-specific scorecards + system-level aggregation |
| Ambiguous conflict handling | Mandatory ADR for `5 vs 5`; gate blocks unresolved conflict |
| Non-portable implementation | Restrict model to YAML/Markdown + shell/WASM-compatible algorithms |

## 13. Portability and Auditability Guarantees
1. All core artifacts are plain text (`.md`, `.yml`).
2. No OS- or vendor-specific semantics are required in the model.
3. Every weight and score change is attributable (author, timestamp, rationale, ADR/evidence links).
4. Effective weight snapshots are immutable per run and stored with scorecards.
