# 03. Target-state specification

## 3.1 Target-state definition

The target state defined by this packet is:

> **A fully hardened, normalized, evidence-backed Unified Execution Constitution target state that is valid for the admitted live support universe only, with all packet-scope claim-critical and retained-hardening items closed, machine-verifiable authority purity, per-tuple evidence sufficiency, and explicit widening gates for any future expansion.**

## 3.2 Bounded claim rules

### Rule B-01 — active claims are admitted-universe bounded
Every active claim-bearing artifact must express claim extent as:

- **bounded to the admitted live support universe**,
- **finite**, and
- **no broader than the active support-target tuple inventory**.

### Rule B-02 — active machine enums must not imply universality
The following active machine values must be retired from live claim-bearing artifacts:

- `global-complete-finite`
- any `full-attainment` phrasing in active truth labels where “bounded attainment” is meant

Historical artifacts may retain historical phrasing if clearly marked lineage-only.

### Rule B-03 — only active support-target tuples define live support scope
The active live support universe is defined only by:

- `/.octon/instance/governance/support-targets.yml`
- `/.octon/instance/governance/support-target-admissions/**`
- `/.octon/instance/governance/support-dossiers/**`
- the generated effective support-target matrix derived from them

No release artifact, run card, helper file, review packet, or generated report may widen that support scope.

### Rule B-04 — any support widening invalidates review freshness and demands recertification
Any change to admitted:

- tuples,
- adapters,
- locales,
- capability packs,
- workload classes,
- or model/context classes

must invalidate the current widening gate and require:

1. a fresh audit,
2. a fresh build-to-delete review packet,
3. fresh support dossiers,
4. regenerated depth/diversity/hidden-check reports,
5. a new release bundle, and
6. dual-pass recertification.

## 3.3 Authority and non-authority rules

### Rule A-01 — authored authority remains singular
Only `framework/**` and `instance/**` remain authored authority.

### Rule A-02 — generated/effective/operator surfaces are permanently non-authoritative unless explicitly elevated by the constitution
Generated, effective, projected, operator-facing, summary, and compatibility surfaces must be labeled as one of:

- `derived-non-authority`
- `projection-only`
- `historical-mirror`
- `historical-shim`
- `compatibility-shim`
- `historical-release-evidence`

and must include:

- source/canonical successor reference,
- rationale,
- status,
- claim-adjacent flag,
- and review or validation rule.

### Rule A-03 — retained removable surfaces live in the retirement register
Any retained non-canonical surface that is expected to be reviewed for retention or deletion lives in `retirement-register.yml`.

### Rule A-04 — permanent derived roots live in a dedicated non-authority register
Any **permanent** non-authority surface that is not a retirement candidate (for example generated/effective summaries or operator-only projections) must live in a new **non-authority register** rather than being smuggled into prose.

### Rule A-05 — operator-facing projections and host workflows must remain visibly non-authoritative
Generated/effective/operator-facing views and workflow-hosted orchestration surfaces must:

- carry explicit derived/projection labeling where they are user-visible,
- reference or materialize canonical authority and evaluator artifacts rather than silently standing in for them, and
- never become the sole durable definition of approval, evaluator, or closure semantics.

## 3.4 Contract-family normalization rules

### Rule F-01 — every active family README uses one normalized pattern
Every active contract family README must declare, in the same order:

1. status
2. canonical files
3. canonical roots
4. compatibility/historical surfaces (if any)
5. explicit non-authority note for retained mirrors/shims
6. validator obligations

### Rule F-02 — compatibility surfaces must never appear in canonical file lists
Historical compatibility surfaces may be listed only under compatibility/historical sections, never in canonical roots.

### Rule F-03 — family status must agree across registry, README, disclosure, and certification artifacts
No family may be “active” in one place and “historical” or “subordinate” in another without an explicit machine-readable justification.

### Rule F-04 — each live contract family declares an active version set that matches live artifact usage
Objective, runtime, and disclosure families must either:

- converge on one active version per live contract type, or
- declare explicit governed coexistence with one active version and all others marked legacy/compatibility-only.

A family README or registry entry may not list a schema as canonical-active when live authored or retained artifacts have already standardized on a successor version.

## 3.5 Evidence-depth sufficiency rules

### Rule E-01 — every admitted tuple must have dossier-backed depth sufficiency
Each support dossier must carry a machine-readable sufficiency section covering:

- required proof planes,
- required scenario classes,
- retained run count,
- last recertification date,
- evaluator diversity count,
- hidden-check coverage count,
- known exclusions,
- and freshness of representative runs.

### Rule E-02 — minimum retained run counts by workload
The packet proposes the following minimums:

| Workload class | Minimum retained runs per admitted tuple | Required scenario coverage |
|---|---:|---|
| observe-and-read | 3 | baseline, adversarial/hidden-check, drift/recertification |
| repo-consequential | 4 | baseline, governance/approval, adversarial/hidden-check, recovery/replay |
| boundary-sensitive | 5 | baseline, adversarial, recovery/fault, replay/shadow, contamination/retry |

### Rule E-03 — freshness rule
At least one representative run per admitted tuple must be generated or recertified in the current closure release. Historical-only representative runs are insufficient.

### Rule E-04 — consequential tuples require naturalistic representative evidence
For every repo-consequential or boundary-sensitive admitted tuple, at least one current-release retained representative run must be naturalistic rather than only a safe-stage, approval-only, or lease-revocation exercise.

Controlled exercises may supplement consequential certification, but they may not be the sole representative evidence for those tuples.

## 3.6 Evaluator diversity and hidden-check breadth rules

### Rule V-01 — LLM review is never a sole evaluator
For repo-consequential and boundary-sensitive tuples, passing proof requires at least:

1. one deterministic/authored validator or suite,
2. one hidden-check or replay/shadow/differential evaluator, and
3. one secondary reviewer class (LLM judge, human sample, or separate evaluator harness).

Observe-and-read tuples require at least two evaluator classes.

### Rule V-02 — hidden-check breadth is dimensioned, not generic
Each admitted tuple must show explicit hidden-check coverage across the dimensions that matter for that tuple:

- structural
- functional
- governance
- maintainability
- behavioral (where required)
- recovery (where required)
- drift/regression
- contamination/retry
- authority/disclosure purity where claim-adjacent

### Rule V-03 — evaluator and hidden-check reports must be per tuple and rolled up per release
The closure bundle must include:

- `evaluator-diversity-report.yml`
- `hidden-check-breadth-report.yml`

with both tuple-level and release-level summaries.

### Rule V-04 — evaluator execution paths must not collapse to one host workflow surface
For repo-consequential and boundary-sensitive tuples, at least one required evaluator class must run through a repo-local or otherwise non-host-exclusive path that is reproducible from canonical repo artifacts.

Host workflow evaluators may orchestrate or project status, but they may not be the only durable path for evaluator semantics in the certified target state.

## 3.7 Ingress and agency simplification rules

### Rule I-01 — mandatory ingress read set is machine-declared
A new `/.octon/instance/ingress/manifest.yml` must declare:

- mandatory files,
- optional overlays,
- conditional overlays,
- and parity rules for adapter ingress files.

### Rule I-02 — only kernel + workspace + orchestrator are mandatory for default execution
Default mandatory set:

- constitutional kernel
- workspace objective pair
- orchestrator execution contract

`DELEGATION.md` and `MEMORY.md` remain supporting overlays only and are loaded when needed, not as implicit kernel peers.

## 3.8 Disclosure and certification rules

### Rule D-01 — only the active release may speak for current support scope
Historical release bundles remain retained evidence only and must never be used as current truth sources.

### Rule D-02 — review-packet freshness becomes an explicit closure condition
The active closure bundle must prove that the current closeout review packet is fresh enough for the active support universe.

### Rule D-03 — certification is dual-pass and blocker-aware
Certification requires:

- zero open claim-critical findings in scope,
- zero stale review lineage defects,
- complete per-tuple evidence depth,
- complete evaluator/hidden-check reports,
- two consecutive validation passes,
- and no active disclosure drift.


## 3.9 Minimum field sets for new machine-readable artifacts

### `current-audit-crosswalk.yml`
Each entry must include at least:

- `finding_id`
- `source_audit_bundle_ref`
- `severity`
- `current_disposition` (`closed`, `closed_by_supersession`, `retained_for_future_widening`, `reopened`)
- `disposition_reason`
- `closed_by_refs`
- `validator_refs`
- `certificate_blocker` (`yes` / `no`)
- `future_widening_blocker` (`yes` / `no`)

### `non-authority-register.yml`
Each entry must include at least:

- `surface_id`
- `surface_class`
- `paths`
- `canonical_source_ref`
- `authority_mode`
- `generation_or_projection_mechanism`
- `claim_adjacent`
- `validator_ref`
- `retained_forever` / `review_due`
- `rationale`

### `instance/ingress/manifest.yml`
The manifest must include at least:

- `mandatory_read_set`
- `optional_overlays`
- `conditional_overlays`
- `adapter_parity_targets`
- `branch_closeout_prompt`
- `change_profile_rule`
- `human_led_blocked_roots`

### support dossier sufficiency block
Each admitted tuple dossier must carry a `sufficiency` block with at least:

- `required_proof_planes`
- `required_scenario_classes`
- `minimum_retained_runs`
- `current_retained_runs`
- `evaluator_classes_required`
- `evaluator_classes_present`
- `hidden_check_dimensions_required`
- `hidden_check_dimensions_present`
- `representative_run_classes_present`
- `naturalistic_representative_run_present`
- `last_current_release_run_ref`
- `status`

### `evaluator-diversity-report.yml`
Must summarize both:

- `per_tuple` evaluator classes, and
- `release_rollup` class counts, execution_path_classes, host_exclusive_dependency, gaps, and pass/fail.

### `hidden-check-breadth-report.yml`
Must summarize both:

- `per_tuple` hidden-check dimensions, and
- `release_rollup` breadth coverage and gaps.

### `contract-version-coherence-report.yml`
Must summarize:

- `per_family` active versions,
- `legacy_versions_retained`,
- `explicit_coexistence_rules`,
- `stale_reference_gaps`,
- and overall pass/fail.

### `projection-shell-boundary-report.yml`
Must summarize:

- `workflow_surfaces_in_scope`,
- `canonical_logic_anchors`,
- `host_exclusive_behaviors_remaining`,
- `materialized_authority_or_evaluator_artifacts`,
- and overall pass/fail.

## 3.10 Family-specific normalization rules

### Objective family

Target state:

- active objective authority stays in the workspace / mission / run / stage stack;
- the active objective contract declarations match the live `run-contract` and `stage-attempt` versions actually used by retained artifacts, or governed coexistence is declared explicitly;
- `/.octon/instance/bootstrap/OBJECTIVE.md` and `/.octon/instance/cognition/context/shared/intent.contract.yml` remain archived non-authoritative compatibility surfaces only;
- no active claim-bearing artifact cites those compatibility files as current authority.

### Authority family

Target state:

- authority continues to resolve through constitutional kernel + instance-owned authority artifacts;
- host adapters remain projection-only / non-authoritative;
- workflow-hosted approval and evaluator flows remain thin shells over canonically defined repo-local logic;
- no operator- or host-projected state may mint authority outside canonical surfaces.

### Runtime family

Target state:

- canonical runtime truth continues through run roots, stage attempts, checkpoints, ledgers, continuity, and replay-backed artifacts;
- runtime family version declarations match the live run-root artifacts or explicitly demote retained legacy schemas to compatibility-only;
- run-local disclosure mirrors remain historical mirrors only;
- runtime family reports must evidence replay, continuity, and checkpoint integrity.

### Disclosure family

Target state:

- active disclosure resolves only from `instance/governance/disclosure/**` and the active release under `state/evidence/disclosure/releases/**`;
- disclosure family version declarations match the live `run-card` and `harness-card` versions used by retained disclosure artifacts;
- superseded release bundles remain historical evidence only;
- lab-local HarnessCard mirrors remain historical mirrors only;
- generated effective closure projections stay derived and non-authoritative.
