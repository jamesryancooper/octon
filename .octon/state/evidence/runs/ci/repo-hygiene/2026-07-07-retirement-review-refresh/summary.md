# Repo Hygiene Audit

- Audit id: `2026-07-07-retirement-review-refresh`
- Generated at: `2026-07-07T22:42:17Z`
- Active release: `2026-04-18-frontier-governance-bounded-complete`
- Latest build-to-delete packet: `.octon/state/evidence/validation/publication/build-to-delete/2026-07-07-retirement-review-refresh`
- Current governance review: `.octon/state/evidence/governance/build-to-delete/2026-07-07-retirement-review-refresh/retirement-claim-review.yml`
- Host tool resolution: `host-tools.yml`
- Total findings: `298`
- Blocking findings: `0`
- Required detector failures: `0`

## Detector Status
- `git-ls-files`: `passed` (required=`true`, log=`.octon/state/evidence/runs/ci/repo-hygiene/2026-07-07-retirement-review-refresh/detectors/git-ls-files.log`)
- `find`: `passed` (required=`true`, log=`.octon/state/evidence/runs/ci/repo-hygiene/2026-07-07-retirement-review-refresh/detectors/find.log`)
- `reference-scan`: `passed` (required=`true`, log=`.octon/state/evidence/runs/ci/repo-hygiene/2026-07-07-retirement-review-refresh/detectors/reference-scan.log`)
- `cargo-check`: `passed` (required=`true`, log=`.octon/state/evidence/runs/ci/repo-hygiene/2026-07-07-retirement-review-refresh/detectors/cargo-check.log`)
- `cargo-clippy`: `passed` (required=`true`, log=`.octon/state/evidence/runs/ci/repo-hygiene/2026-07-07-retirement-review-refresh/detectors/cargo-clippy.log`)
- `cargo-machete`: `passed` (required=`true`, log=`.octon/state/evidence/runs/ci/repo-hygiene/2026-07-07-retirement-review-refresh/detectors/cargo-machete.log`)
  notes: cargo-machete reported candidate unused dependencies
- `cargo-udeps`: `passed` (required=`true`, log=`.octon/state/evidence/runs/ci/repo-hygiene/2026-07-07-retirement-review-refresh/detectors/cargo-udeps.log`)
  notes: cargo-udeps reported candidate unused dependencies
- `shellcheck`: `passed` (required=`true`, log=`.octon/state/evidence/runs/ci/repo-hygiene/2026-07-07-retirement-review-refresh/detectors/shellcheck.log`)
  notes: shellcheck reported lint findings
- `bash-syntax`: `passed` (required=`true`, log=`.octon/state/evidence/runs/ci/repo-hygiene/2026-07-07-retirement-review-refresh/detectors/bash-syntax.log`)
- `sh-syntax`: `passed` (required=`true`, log=`.octon/state/evidence/runs/ci/repo-hygiene/2026-07-07-retirement-review-refresh/detectors/sh-syntax.log`)

## Findings
- `rh-clippy-runtime-bus-src-lib-rs-642-this-function-has-too-many-arguments-10-7` [class=`rust-static-deadness`, confidence=`low`, action=`needs-ablation-before-delete`, blocking=`false`]: `runtime_bus/src/lib.rs:642`
  Rust deadness signal from clippy
- `rh-clippy-runtime-bus-src-lib-rs-793-this-function-has-too-many-arguments-9-7` [class=`rust-static-deadness`, confidence=`low`, action=`needs-ablation-before-delete`, blocking=`false`]: `runtime_bus/src/lib.rs:793`
  Rust deadness signal from clippy
- `rh-clippy-replay-store-src-lib-rs-312-this-impl-can-be-derived` [class=`rust-static-deadness`, confidence=`low`, action=`needs-ablation-before-delete`, blocking=`false`]: `replay_store/src/lib.rs:312`
  Rust deadness signal from clippy
- `rh-clippy-replay-store-src-lib-rs-878-this-function-has-too-many-arguments-8-7` [class=`rust-static-deadness`, confidence=`low`, action=`needs-ablation-before-delete`, blocking=`false`]: `replay_store/src/lib.rs:878`
  Rust deadness signal from clippy
- `rh-clippy-policy-engine-src-lib-rs-962-use-of-deprecated-function-time-format-description-parse-use-parse-borrowed-with-the-appropriate-version-for-clarity` [class=`rust-static-deadness`, confidence=`low`, action=`needs-ablation-before-delete`, blocking=`false`]: `policy_engine/src/lib.rs:962`
  Rust deadness signal from clippy
- `rh-clippy-runtime-resolver-src-handles-rs-207-this-expression-creates-a-reference-which-is-immediately-dereferenced-by-the-compiler-help-change-this-to-receipt-path` [class=`rust-static-deadness`, confidence=`low`, action=`needs-ablation-before-delete`, blocking=`false`]: `runtime_resolver/src/handles.rs:207`
  Rust deadness signal from clippy
- `rh-clippy-runtime-resolver-src-handles-rs-208-this-expression-creates-a-reference-which-is-immediately-dereferenced-by-the-compiler-help-change-this-to-receipt-sha` [class=`rust-static-deadness`, confidence=`low`, action=`needs-ablation-before-delete`, blocking=`false`]: `runtime_resolver/src/handles.rs:208`
  Rust deadness signal from clippy
- `rh-clippy-runtime-resolver-src-handles-rs-209-this-expression-creates-a-reference-which-is-immediately-dereferenced-by-the-compiler-help-change-this-to-generation-id` [class=`rust-static-deadness`, confidence=`low`, action=`needs-ablation-before-delete`, blocking=`false`]: `runtime_resolver/src/handles.rs:209`
  Rust deadness signal from clippy
- `rh-clippy-runtime-resolver-src-handles-rs-210-this-expression-creates-a-reference-which-is-immediately-dereferenced-by-the-compiler-help-change-this-to-publication-status` [class=`rust-static-deadness`, confidence=`low`, action=`needs-ablation-before-delete`, blocking=`false`]: `runtime_resolver/src/handles.rs:210`
  Rust deadness signal from clippy
- `rh-clippy-runtime-resolver-src-handles-rs-216-this-expression-creates-a-reference-which-is-immediately-dereferenced-by-the-compiler` [class=`rust-static-deadness`, confidence=`low`, action=`needs-ablation-before-delete`, blocking=`false`]: `runtime_resolver/src/handles.rs:216`
  Rust deadness signal from clippy
- `rh-clippy-runtime-resolver-src-handles-rs-226-this-expression-creates-a-reference-which-is-immediately-dereferenced-by-the-compiler` [class=`rust-static-deadness`, confidence=`low`, action=`needs-ablation-before-delete`, blocking=`false`]: `runtime_resolver/src/handles.rs:226`
  Rust deadness signal from clippy
- `rh-clippy-runtime-resolver-src-handles-rs-236-this-expression-creates-a-reference-which-is-immediately-dereferenced-by-the-compiler` [class=`rust-static-deadness`, confidence=`low`, action=`needs-ablation-before-delete`, blocking=`false`]: `runtime_resolver/src/handles.rs:236`
  Rust deadness signal from clippy
- `rh-clippy-runtime-resolver-src-handles-rs-246-this-expression-creates-a-reference-which-is-immediately-dereferenced-by-the-compiler` [class=`rust-static-deadness`, confidence=`low`, action=`needs-ablation-before-delete`, blocking=`false`]: `runtime_resolver/src/handles.rs:246`
  Rust deadness signal from clippy
- `rh-clippy-runtime-resolver-src-handles-rs-256-this-expression-creates-a-reference-which-is-immediately-dereferenced-by-the-compiler` [class=`rust-static-deadness`, confidence=`low`, action=`needs-ablation-before-delete`, blocking=`false`]: `runtime_resolver/src/handles.rs:256`
  Rust deadness signal from clippy
- `rh-clippy-runtime-resolver-src-handles-rs-274-this-expression-creates-a-reference-which-is-immediately-dereferenced-by-the-compiler-help-change-this-to-freshness-mode` [class=`rust-static-deadness`, confidence=`low`, action=`needs-ablation-before-delete`, blocking=`false`]: `runtime_resolver/src/handles.rs:274`
  Rust deadness signal from clippy
- `rh-clippy-runtime-resolver-src-handles-rs-284-this-expression-creates-a-reference-which-is-immediately-dereferenced-by-the-compiler-help-change-this-to-non-authority` [class=`rust-static-deadness`, confidence=`low`, action=`needs-ablation-before-delete`, blocking=`false`]: `runtime_resolver/src/handles.rs:284`
  Rust deadness signal from clippy
- `rh-clippy-runtime-resolver-src-handles-rs-351-this-expression-creates-a-reference-which-is-immediately-dereferenced-by-the-compiler-help-change-this-to-source-ref` [class=`rust-static-deadness`, confidence=`low`, action=`needs-ablation-before-delete`, blocking=`false`]: `runtime_resolver/src/handles.rs:351`
  Rust deadness signal from clippy
- `rh-clippy-runtime-resolver-src-handles-rs-414-this-expression-creates-a-reference-which-is-immediately-dereferenced-by-the-compiler-help-change-this-to-receipt-path` [class=`rust-static-deadness`, confidence=`low`, action=`needs-ablation-before-delete`, blocking=`false`]: `runtime_resolver/src/handles.rs:414`
  Rust deadness signal from clippy
- `rh-clippy-runtime-resolver-src-handles-rs-415-this-expression-creates-a-reference-which-is-immediately-dereferenced-by-the-compiler-help-change-this-to-receipt-sha` [class=`rust-static-deadness`, confidence=`low`, action=`needs-ablation-before-delete`, blocking=`false`]: `runtime_resolver/src/handles.rs:415`
  Rust deadness signal from clippy
- `rh-clippy-runtime-resolver-src-handles-rs-416-this-expression-creates-a-reference-which-is-immediately-dereferenced-by-the-compiler-help-change-this-to-generation-id` [class=`rust-static-deadness`, confidence=`low`, action=`needs-ablation-before-delete`, blocking=`false`]: `runtime_resolver/src/handles.rs:416`
  Rust deadness signal from clippy
- `rh-clippy-runtime-resolver-src-handles-rs-417-this-expression-creates-a-reference-which-is-immediately-dereferenced-by-the-compiler-help-change-this-to-publication-status` [class=`rust-static-deadness`, confidence=`low`, action=`needs-ablation-before-delete`, blocking=`false`]: `runtime_resolver/src/handles.rs:417`
  Rust deadness signal from clippy
- `rh-clippy-runtime-resolver-src-handles-rs-423-this-expression-creates-a-reference-which-is-immediately-dereferenced-by-the-compiler` [class=`rust-static-deadness`, confidence=`low`, action=`needs-ablation-before-delete`, blocking=`false`]: `runtime_resolver/src/handles.rs:423`
  Rust deadness signal from clippy
- `rh-clippy-runtime-resolver-src-handles-rs-432-this-expression-creates-a-reference-which-is-immediately-dereferenced-by-the-compiler` [class=`rust-static-deadness`, confidence=`low`, action=`needs-ablation-before-delete`, blocking=`false`]: `runtime_resolver/src/handles.rs:432`
  Rust deadness signal from clippy
- `rh-clippy-runtime-resolver-src-handles-rs-441-this-expression-creates-a-reference-which-is-immediately-dereferenced-by-the-compiler-help-change-this-to-generation-id` [class=`rust-static-deadness`, confidence=`low`, action=`needs-ablation-before-delete`, blocking=`false`]: `runtime_resolver/src/handles.rs:441`
  Rust deadness signal from clippy
- `rh-clippy-runtime-resolver-src-handles-rs-442-this-expression-creates-a-reference-which-is-immediately-dereferenced-by-the-compiler-help-change-this-to-receipt-path` [class=`rust-static-deadness`, confidence=`low`, action=`needs-ablation-before-delete`, blocking=`false`]: `runtime_resolver/src/handles.rs:442`
  Rust deadness signal from clippy
- `rh-clippy-runtime-resolver-src-handles-rs-443-this-expression-creates-a-reference-which-is-immediately-dereferenced-by-the-compiler-help-change-this-to-receipt-sha` [class=`rust-static-deadness`, confidence=`low`, action=`needs-ablation-before-delete`, blocking=`false`]: `runtime_resolver/src/handles.rs:443`
  Rust deadness signal from clippy
- `rh-clippy-runtime-resolver-src-handles-rs-444-this-expression-creates-a-reference-which-is-immediately-dereferenced-by-the-compiler-help-change-this-to-publication-status` [class=`rust-static-deadness`, confidence=`low`, action=`needs-ablation-before-delete`, blocking=`false`]: `runtime_resolver/src/handles.rs:444`
  Rust deadness signal from clippy
- `rh-clippy-runtime-resolver-src-handles-rs-504-this-expression-creates-a-reference-which-is-immediately-dereferenced-by-the-compiler-help-change-this-to-receipt-path` [class=`rust-static-deadness`, confidence=`low`, action=`needs-ablation-before-delete`, blocking=`false`]: `runtime_resolver/src/handles.rs:504`
  Rust deadness signal from clippy
- `rh-clippy-runtime-resolver-src-handles-rs-505-this-expression-creates-a-reference-which-is-immediately-dereferenced-by-the-compiler-help-change-this-to-receipt-sha` [class=`rust-static-deadness`, confidence=`low`, action=`needs-ablation-before-delete`, blocking=`false`]: `runtime_resolver/src/handles.rs:505`
  Rust deadness signal from clippy
- `rh-clippy-runtime-resolver-src-handles-rs-506-this-expression-creates-a-reference-which-is-immediately-dereferenced-by-the-compiler-help-change-this-to-generation-id` [class=`rust-static-deadness`, confidence=`low`, action=`needs-ablation-before-delete`, blocking=`false`]: `runtime_resolver/src/handles.rs:506`
  Rust deadness signal from clippy
- `rh-clippy-runtime-resolver-src-handles-rs-507-this-expression-creates-a-reference-which-is-immediately-dereferenced-by-the-compiler-help-change-this-to-publication-status` [class=`rust-static-deadness`, confidence=`low`, action=`needs-ablation-before-delete`, blocking=`false`]: `runtime_resolver/src/handles.rs:507`
  Rust deadness signal from clippy
- `rh-clippy-runtime-resolver-src-handles-rs-513-this-expression-creates-a-reference-which-is-immediately-dereferenced-by-the-compiler` [class=`rust-static-deadness`, confidence=`low`, action=`needs-ablation-before-delete`, blocking=`false`]: `runtime_resolver/src/handles.rs:513`
  Rust deadness signal from clippy
- `rh-clippy-runtime-resolver-src-handles-rs-522-this-expression-creates-a-reference-which-is-immediately-dereferenced-by-the-compiler` [class=`rust-static-deadness`, confidence=`low`, action=`needs-ablation-before-delete`, blocking=`false`]: `runtime_resolver/src/handles.rs:522`
  Rust deadness signal from clippy
- `rh-clippy-runtime-resolver-src-handles-rs-531-this-expression-creates-a-reference-which-is-immediately-dereferenced-by-the-compiler-help-change-this-to-generation-id` [class=`rust-static-deadness`, confidence=`low`, action=`needs-ablation-before-delete`, blocking=`false`]: `runtime_resolver/src/handles.rs:531`
  Rust deadness signal from clippy
- `rh-clippy-runtime-resolver-src-handles-rs-532-this-expression-creates-a-reference-which-is-immediately-dereferenced-by-the-compiler-help-change-this-to-receipt-path` [class=`rust-static-deadness`, confidence=`low`, action=`needs-ablation-before-delete`, blocking=`false`]: `runtime_resolver/src/handles.rs:532`
  Rust deadness signal from clippy
- `rh-clippy-runtime-resolver-src-handles-rs-533-this-expression-creates-a-reference-which-is-immediately-dereferenced-by-the-compiler-help-change-this-to-receipt-sha` [class=`rust-static-deadness`, confidence=`low`, action=`needs-ablation-before-delete`, blocking=`false`]: `runtime_resolver/src/handles.rs:533`
  Rust deadness signal from clippy
- `rh-clippy-runtime-resolver-src-handles-rs-534-this-expression-creates-a-reference-which-is-immediately-dereferenced-by-the-compiler-help-change-this-to-publication-status` [class=`rust-static-deadness`, confidence=`low`, action=`needs-ablation-before-delete`, blocking=`false`]: `runtime_resolver/src/handles.rs:534`
  Rust deadness signal from clippy
- `rh-clippy-runtime-resolver-src-handles-rs-614-this-expression-creates-a-reference-which-is-immediately-dereferenced-by-the-compiler-help-change-this-to-receipt-path` [class=`rust-static-deadness`, confidence=`low`, action=`needs-ablation-before-delete`, blocking=`false`]: `runtime_resolver/src/handles.rs:614`
  Rust deadness signal from clippy
- `rh-clippy-runtime-resolver-src-handles-rs-615-this-expression-creates-a-reference-which-is-immediately-dereferenced-by-the-compiler-help-change-this-to-receipt-sha` [class=`rust-static-deadness`, confidence=`low`, action=`needs-ablation-before-delete`, blocking=`false`]: `runtime_resolver/src/handles.rs:615`
  Rust deadness signal from clippy
- `rh-clippy-runtime-resolver-src-handles-rs-616-this-expression-creates-a-reference-which-is-immediately-dereferenced-by-the-compiler-help-change-this-to-generation-id` [class=`rust-static-deadness`, confidence=`low`, action=`needs-ablation-before-delete`, blocking=`false`]: `runtime_resolver/src/handles.rs:616`
  Rust deadness signal from clippy
- `rh-clippy-runtime-resolver-src-handles-rs-617-this-expression-creates-a-reference-which-is-immediately-dereferenced-by-the-compiler-help-change-this-to-publication-status` [class=`rust-static-deadness`, confidence=`low`, action=`needs-ablation-before-delete`, blocking=`false`]: `runtime_resolver/src/handles.rs:617`
  Rust deadness signal from clippy
- `rh-clippy-runtime-resolver-src-handles-rs-623-this-expression-creates-a-reference-which-is-immediately-dereferenced-by-the-compiler` [class=`rust-static-deadness`, confidence=`low`, action=`needs-ablation-before-delete`, blocking=`false`]: `runtime_resolver/src/handles.rs:623`
  Rust deadness signal from clippy
- `rh-clippy-runtime-resolver-src-handles-rs-633-this-expression-creates-a-reference-which-is-immediately-dereferenced-by-the-compiler` [class=`rust-static-deadness`, confidence=`low`, action=`needs-ablation-before-delete`, blocking=`false`]: `runtime_resolver/src/handles.rs:633`
  Rust deadness signal from clippy
- `rh-clippy-runtime-resolver-src-handles-rs-643-this-expression-creates-a-reference-which-is-immediately-dereferenced-by-the-compiler` [class=`rust-static-deadness`, confidence=`low`, action=`needs-ablation-before-delete`, blocking=`false`]: `runtime_resolver/src/handles.rs:643`
  Rust deadness signal from clippy
- `rh-clippy-runtime-resolver-src-handles-rs-653-this-expression-creates-a-reference-which-is-immediately-dereferenced-by-the-compiler` [class=`rust-static-deadness`, confidence=`low`, action=`needs-ablation-before-delete`, blocking=`false`]: `runtime_resolver/src/handles.rs:653`
  Rust deadness signal from clippy
- `rh-clippy-runtime-resolver-src-handles-rs-663-this-expression-creates-a-reference-which-is-immediately-dereferenced-by-the-compiler` [class=`rust-static-deadness`, confidence=`low`, action=`needs-ablation-before-delete`, blocking=`false`]: `runtime_resolver/src/handles.rs:663`
  Rust deadness signal from clippy
- `rh-clippy-runtime-resolver-src-lib-rs-731-using-contains-instead-of-iter-any-is-more-efficient-help-try-values-contains-excluded` [class=`rust-static-deadness`, confidence=`low`, action=`needs-ablation-before-delete`, blocking=`false`]: `runtime_resolver/src/lib.rs:731`
  Rust deadness signal from clippy
- `rh-clippy-assurance-tools-src-ci-latency-rs-611-redundant-closure-help-replace-the-closure-with-the-function-itself-workflow-metric-cmp` [class=`rust-static-deadness`, confidence=`low`, action=`needs-ablation-before-delete`, blocking=`false`]: `assurance_tools/src/ci_latency.rs:611`
  Rust deadness signal from clippy
- `rh-clippy-assurance-tools-src-main-rs-2026-derefed-type-is-same-as-origin-help-try-findings` [class=`rust-static-deadness`, confidence=`low`, action=`needs-ablation-before-delete`, blocking=`false`]: `assurance_tools/src/main.rs:2026`
  Rust deadness signal from clippy
- `rh-clippy-assurance-tools-src-main-rs-3521-this-function-has-too-many-arguments-9-7` [class=`rust-static-deadness`, confidence=`low`, action=`needs-ablation-before-delete`, blocking=`false`]: `assurance_tools/src/main.rs:3521`
  Rust deadness signal from clippy
- `rh-clippy-assurance-tools-src-main-rs-3955-this-function-has-too-many-arguments-8-7` [class=`rust-static-deadness`, confidence=`low`, action=`needs-ablation-before-delete`, blocking=`false`]: `assurance_tools/src/main.rs:3955`
  Rust deadness signal from clippy
- `rh-clippy-assurance-tools-src-main-rs-4021-this-function-has-too-many-arguments-8-7` [class=`rust-static-deadness`, confidence=`low`, action=`needs-ablation-before-delete`, blocking=`false`]: `assurance_tools/src/main.rs:4021`
  Rust deadness signal from clippy
- `rh-clippy-lifecycle-executor-src-authorization-rs-44-the-err-variant-returned-from-this-function-is-very-large-the-err-variant-is-at-least-416-bytes` [class=`rust-static-deadness`, confidence=`low`, action=`needs-ablation-before-delete`, blocking=`false`]: `lifecycle_executor/src/authorization.rs:44`
  Rust deadness signal from clippy
- `rh-clippy-lifecycle-executor-src-authorization-rs-156-the-err-variant-returned-from-this-function-is-very-large-the-err-variant-is-at-least-416-bytes` [class=`rust-static-deadness`, confidence=`low`, action=`needs-ablation-before-delete`, blocking=`false`]: `lifecycle_executor/src/authorization.rs:156`
  Rust deadness signal from clippy
- `rh-clippy-lifecycle-executor-src-authorization-rs-364-the-err-variant-returned-from-this-function-is-very-large-the-err-variant-is-at-least-416-bytes` [class=`rust-static-deadness`, confidence=`low`, action=`needs-ablation-before-delete`, blocking=`false`]: `lifecycle_executor/src/authorization.rs:364`
  Rust deadness signal from clippy
- `rh-clippy-lifecycle-executor-src-adapter-rs-429-items-after-a-test-module` [class=`rust-static-deadness`, confidence=`low`, action=`needs-ablation-before-delete`, blocking=`false`]: `lifecycle_executor/src/adapter.rs:429`
  Rust deadness signal from clippy
- `rh-clippy-lifecycle-executor-src-codex-rs-225-this-function-has-too-many-arguments-14-7` [class=`rust-static-deadness`, confidence=`low`, action=`needs-ablation-before-delete`, blocking=`false`]: `lifecycle_executor/src/codex.rs:225`
  Rust deadness signal from clippy
- `rh-clippy-lifecycle-executor-src-codex-rs-577-unneeded-return-statement` [class=`rust-static-deadness`, confidence=`low`, action=`needs-ablation-before-delete`, blocking=`false`]: `lifecycle_executor/src/codex.rs:577`
  Rust deadness signal from clippy
- `rh-clippy-lifecycle-executor-src-codex-rs-701-this-function-has-too-many-arguments-9-7` [class=`rust-static-deadness`, confidence=`low`, action=`needs-ablation-before-delete`, blocking=`false`]: `lifecycle_executor/src/codex.rs:701`
  Rust deadness signal from clippy
- `rh-clippy-lifecycle-executor-src-context-pack-rs-125-unnecessary-closure-used-to-substitute-value-for-option-none` [class=`rust-static-deadness`, confidence=`low`, action=`needs-ablation-before-delete`, blocking=`false`]: `lifecycle_executor/src/context_pack.rs:125`
  Rust deadness signal from clippy
- `rh-clippy-lifecycle-executor-src-codex-rs-960-call-to-set-readonly-with-argument-false` [class=`rust-static-deadness`, confidence=`low`, action=`needs-ablation-before-delete`, blocking=`false`]: `lifecycle_executor/src/codex.rs:960`
  Rust deadness signal from clippy
- `rh-clippy-policy-engine-src-lib-rs-560-this-impl-can-be-derived` [class=`rust-static-deadness`, confidence=`low`, action=`needs-ablation-before-delete`, blocking=`false`]: `policy_engine/src/lib.rs:560`
  Rust deadness signal from clippy
- `rh-clippy-core-src-execution-integrity-rs-871-manually-reimplementing-div-ceil-help-consider-using-div-ceil-prompt-bytes-max-1-div-ceil-4` [class=`rust-static-deadness`, confidence=`low`, action=`needs-ablation-before-delete`, blocking=`false`]: `core/src/execution_integrity.rs:871`
  Rust deadness signal from clippy
- `rh-clippy-core-src-execution-integrity-rs-1026-using-contains-instead-of-iter-any-is-more-efficient-help-try-rule-ports-contains-target-port` [class=`rust-static-deadness`, confidence=`low`, action=`needs-ablation-before-delete`, blocking=`false`]: `core/src/execution_integrity.rs:1026`
  Rust deadness signal from clippy
- `rh-clippy-core-src-jsonlines-rs-20-needless-call-to-as-bytes-help-len-can-be-called-directly-on-strings-line-len` [class=`rust-static-deadness`, confidence=`low`, action=`needs-ablation-before-delete`, blocking=`false`]: `core/src/jsonlines.rs:20`
  Rust deadness signal from clippy
- `rh-clippy-lifecycle-executor-src-prompt-bundle-rs-262-this-manual-char-comparison-can-be-written-more-succinctly-help-consider-using-an-array-of-char` [class=`rust-static-deadness`, confidence=`low`, action=`needs-ablation-before-delete`, blocking=`false`]: `lifecycle_executor/src/prompt_bundle.rs:262`
  Rust deadness signal from clippy
- `rh-clippy-lifecycle-executor-src-observer-rs-336-items-after-a-test-module` [class=`rust-static-deadness`, confidence=`low`, action=`needs-ablation-before-delete`, blocking=`false`]: `lifecycle_executor/src/observer.rs:336`
  Rust deadness signal from clippy
- `rh-clippy-core-src-orchestration-rs-998-this-filter-map-can-be-written-more-simply-using-map` [class=`rust-static-deadness`, confidence=`low`, action=`needs-ablation-before-delete`, blocking=`false`]: `core/src/orchestration.rs:998`
  Rust deadness signal from clippy
- `rh-clippy-core-src-orchestration-rs-1758-the-borrowed-expression-implements-the-required-traits-help-change-this-to-missions-dir` [class=`rust-static-deadness`, confidence=`low`, action=`needs-ablation-before-delete`, blocking=`false`]: `core/src/orchestration.rs:1758`
  Rust deadness signal from clippy
- `rh-clippy-core-src-orchestration-rs-1758-this-expression-creates-a-reference-which-is-immediately-dereferenced-by-the-compiler-help-change-this-to-missions-dir` [class=`rust-static-deadness`, confidence=`low`, action=`needs-ablation-before-delete`, blocking=`false`]: `core/src/orchestration.rs:1758`
  Rust deadness signal from clippy
- `rh-clippy-core-src-orchestration-rs-1760-this-expression-creates-a-reference-which-is-immediately-dereferenced-by-the-compiler-help-change-this-to-missions-dir` [class=`rust-static-deadness`, confidence=`low`, action=`needs-ablation-before-delete`, blocking=`false`]: `core/src/orchestration.rs:1760`
  Rust deadness signal from clippy
- `rh-clippy-policy-engine-src-lib-rs-2081-this-boolean-expression-can-be-simplified` [class=`rust-static-deadness`, confidence=`low`, action=`needs-ablation-before-delete`, blocking=`false`]: `policy_engine/src/lib.rs:2081`
  Rust deadness signal from clippy
- `rh-clippy-core-src-orchestration-rs-2326-used-assert-eq-with-a-literal-bool` [class=`rust-static-deadness`, confidence=`low`, action=`needs-ablation-before-delete`, blocking=`false`]: `core/src/orchestration.rs:2326`
  Rust deadness signal from clippy
- `rh-clippy-policy-engine-src-lib-rs-2194-this-function-has-too-many-arguments-9-7` [class=`rust-static-deadness`, confidence=`low`, action=`needs-ablation-before-delete`, blocking=`false`]: `policy_engine/src/lib.rs:2194`
  Rust deadness signal from clippy
- `rh-clippy-policy-engine-src-lib-rs-2205-this-let-else-may-be-rewritten-with-the-operator-help-replace-it-with-let-config-policy-acp-docs-gate-as-ref` [class=`rust-static-deadness`, confidence=`low`, action=`needs-ablation-before-delete`, blocking=`false`]: `policy_engine/src/lib.rs:2205`
  Rust deadness signal from clippy
- `rh-clippy-policy-engine-src-lib-rs-2281-this-function-has-too-many-arguments-9-7` [class=`rust-static-deadness`, confidence=`low`, action=`needs-ablation-before-delete`, blocking=`false`]: `policy_engine/src/lib.rs:2281`
  Rust deadness signal from clippy
- `rh-clippy-policy-engine-src-lib-rs-2292-this-let-else-may-be-rewritten-with-the-operator-help-replace-it-with-let-config-policy-acp-telemetry-gate-as-ref` [class=`rust-static-deadness`, confidence=`low`, action=`needs-ablation-before-delete`, blocking=`false`]: `policy_engine/src/lib.rs:2292`
  Rust deadness signal from clippy
- `rh-clippy-policy-engine-src-lib-rs-2383-this-function-has-too-many-arguments-9-7` [class=`rust-static-deadness`, confidence=`low`, action=`needs-ablation-before-delete`, blocking=`false`]: `policy_engine/src/lib.rs:2383`
  Rust deadness signal from clippy
- `rh-clippy-policy-engine-src-lib-rs-2394-this-let-else-may-be-rewritten-with-the-operator-help-replace-it-with-let-config-policy-acp-flag-metadata-gate-as-ref` [class=`rust-static-deadness`, confidence=`low`, action=`needs-ablation-before-delete`, blocking=`false`]: `policy_engine/src/lib.rs:2394`
  Rust deadness signal from clippy
- `rh-clippy-policy-engine-src-lib-rs-2560-this-map-or-can-be-simplified` [class=`rust-static-deadness`, confidence=`low`, action=`needs-ablation-before-delete`, blocking=`false`]: `policy_engine/src/lib.rs:2560`
  Rust deadness signal from clippy
- `rh-clippy-policy-engine-src-lib-rs-2679-this-let-else-may-be-rewritten-with-the-operator-help-replace-it-with-let-config-policy-attestations-owner-attestation-as-ref` [class=`rust-static-deadness`, confidence=`low`, action=`needs-ablation-before-delete`, blocking=`false`]: `policy_engine/src/lib.rs:2679`
  Rust deadness signal from clippy
- `rh-clippy-lifecycle-executor-src-workflow-leaf-rs-843-this-function-has-too-many-arguments-10-7` [class=`rust-static-deadness`, confidence=`low`, action=`needs-ablation-before-delete`, blocking=`false`]: `lifecycle_executor/src/workflow_leaf.rs:843`
  Rust deadness signal from clippy
- `rh-clippy-policy-engine-src-lib-rs-4506-this-function-has-too-many-arguments-9-7` [class=`rust-static-deadness`, confidence=`low`, action=`needs-ablation-before-delete`, blocking=`false`]: `policy_engine/src/lib.rs:4506`
  Rust deadness signal from clippy
- `rh-clippy-policy-engine-src-lib-rs-4535-this-function-has-too-many-arguments-8-7` [class=`rust-static-deadness`, confidence=`low`, action=`needs-ablation-before-delete`, blocking=`false`]: `policy_engine/src/lib.rs:4535`
  Rust deadness signal from clippy
- `rh-clippy-policy-engine-src-lib-rs-4793-enclosing-ok-and-operator-are-unneeded` [class=`rust-static-deadness`, confidence=`low`, action=`needs-ablation-before-delete`, blocking=`false`]: `policy_engine/src/lib.rs:4793`
  Rust deadness signal from clippy
- `rh-clippy-policy-engine-src-lib-rs-4800-enclosing-ok-and-operator-are-unneeded` [class=`rust-static-deadness`, confidence=`low`, action=`needs-ablation-before-delete`, blocking=`false`]: `policy_engine/src/lib.rs:4800`
  Rust deadness signal from clippy
- `rh-clippy-policy-engine-src-lib-rs-4810-enclosing-ok-and-operator-are-unneeded` [class=`rust-static-deadness`, confidence=`low`, action=`needs-ablation-before-delete`, blocking=`false`]: `policy_engine/src/lib.rs:4810`
  Rust deadness signal from clippy
- `rh-clippy-wasm-host-src-host-api-rs-62-useless-conversion-to-the-same-type-wasmtime-error-help-consider-removing-into-anyhow-anyhow-invalid-input-read-range-max-bytes-too-large` [class=`rust-static-deadness`, confidence=`low`, action=`needs-ablation-before-delete`, blocking=`false`]: `wasm_host/src/host_api.rs:62`
  Rust deadness signal from clippy
- `rh-clippy-wasm-host-src-host-api-rs-70-useless-conversion-to-the-same-type-wasmtime-error-help-consider-removing-into-anyhow-anyhow-invalid-input-write-too-large` [class=`rust-static-deadness`, confidence=`low`, action=`needs-ablation-before-delete`, blocking=`false`]: `wasm_host/src/host_api.rs:70`
  Rust deadness signal from clippy
- `rh-clippy-wasm-host-src-host-api-rs-80-useless-conversion-to-the-same-type-wasmtime-error-help-consider-removing-into-anyhow-anyhow-invalid-input-create-file-exclusive-payload-too-large` [class=`rust-static-deadness`, confidence=`low`, action=`needs-ablation-before-delete`, blocking=`false`]: `wasm_host/src/host_api.rs:80`
  Rust deadness signal from clippy
- `rh-clippy-wasm-host-src-host-api-rs-88-this-operation-has-no-effect-help-consider-reducing-it-to-1024` [class=`rust-static-deadness`, confidence=`low`, action=`needs-ablation-before-delete`, blocking=`false`]: `wasm_host/src/host_api.rs:88`
  Rust deadness signal from clippy
- `rh-clippy-wasm-host-src-host-api-rs-93-this-operation-has-no-effect-help-consider-reducing-it-to-1024` [class=`rust-static-deadness`, confidence=`low`, action=`needs-ablation-before-delete`, blocking=`false`]: `wasm_host/src/host_api.rs:93`
  Rust deadness signal from clippy
- `rh-clippy-wasm-host-src-host-api-rs-244-useless-conversion-to-the-same-type-wasmtime-error-help-consider-removing-into-anyhow-anyhow-http-error-response-too-large` [class=`rust-static-deadness`, confidence=`low`, action=`needs-ablation-before-delete`, blocking=`false`]: `wasm_host/src/host_api.rs:244`
  Rust deadness signal from clippy
- `rh-clippy-wasm-host-src-host-api-rs-288-useless-conversion-to-the-same-type-wasmtime-error-help-consider-removing-into-anyhow-anyhow-http-error-e` [class=`rust-static-deadness`, confidence=`low`, action=`needs-ablation-before-delete`, blocking=`false`]: `wasm_host/src/host_api.rs:288`
  Rust deadness signal from clippy
- `rh-clippy-wasm-host-src-host-api-rs-302-useless-conversion-to-the-same-type-wasmtime-error-help-consider-removing-into-anyhow-anyhow-invalid-input-missing-http-method` [class=`rust-static-deadness`, confidence=`low`, action=`needs-ablation-before-delete`, blocking=`false`]: `wasm_host/src/host_api.rs:302`
  Rust deadness signal from clippy
- `rh-clippy-wasm-host-src-host-api-rs-325-useless-conversion-to-the-same-type-wasmtime-error-help-consider-removing-into-anyhow-anyhow-invalid-input-invalid-http-method-method` [class=`rust-static-deadness`, confidence=`low`, action=`needs-ablation-before-delete`, blocking=`false`]: `wasm_host/src/host_api.rs:325`
  Rust deadness signal from clippy
- `rh-clippy-wasm-host-src-host-api-rs-334-useless-conversion-to-the-same-type-wasmtime-error` [class=`rust-static-deadness`, confidence=`low`, action=`needs-ablation-before-delete`, blocking=`false`]: `wasm_host/src/host_api.rs:334`
  Rust deadness signal from clippy
- `rh-clippy-wasm-host-src-host-api-rs-339-useless-conversion-to-the-same-type-wasmtime-error-help-consider-removing-into-anyhow-anyhow-invalid-input-url-must-start-with-http` [class=`rust-static-deadness`, confidence=`low`, action=`needs-ablation-before-delete`, blocking=`false`]: `wasm_host/src/host_api.rs:339`
  Rust deadness signal from clippy
- `rh-clippy-wasm-host-src-host-api-rs-349-useless-conversion-to-the-same-type-wasmtime-error-help-consider-removing-into-anyhow-anyhow-invalid-input-url-missing-host` [class=`rust-static-deadness`, confidence=`low`, action=`needs-ablation-before-delete`, blocking=`false`]: `wasm_host/src/host_api.rs:349`
  Rust deadness signal from clippy
- `rh-clippy-wasm-host-src-host-api-rs-352-useless-conversion-to-the-same-type-wasmtime-error-help-consider-removing-into-anyhow-anyhow-invalid-input-userinfo-is-not-supported` [class=`rust-static-deadness`, confidence=`low`, action=`needs-ablation-before-delete`, blocking=`false`]: `wasm_host/src/host_api.rs:352`
  Rust deadness signal from clippy
- `rh-clippy-wasm-host-src-host-api-rs-373-useless-conversion-to-the-same-type-wasmtime-error-help-consider-removing-into-anyhow-anyhow-invalid-input-url-path-contains-invalid-characters` [class=`rust-static-deadness`, confidence=`low`, action=`needs-ablation-before-delete`, blocking=`false`]: `wasm_host/src/host_api.rs:373`
  Rust deadness signal from clippy
- `rh-clippy-wasm-host-src-host-api-rs-396-useless-conversion-to-the-same-type-wasmtime-error-help-consider-removing-into-anyhow-anyhow-invalid-input-empty-ipv6-host` [class=`rust-static-deadness`, confidence=`low`, action=`needs-ablation-before-delete`, blocking=`false`]: `wasm_host/src/host_api.rs:396`
  Rust deadness signal from clippy
- `rh-clippy-wasm-host-src-host-api-rs-404-useless-conversion-to-the-same-type-wasmtime-error-help-consider-removing-into-anyhow-anyhow-invalid-input-malformed-authority` [class=`rust-static-deadness`, confidence=`low`, action=`needs-ablation-before-delete`, blocking=`false`]: `wasm_host/src/host_api.rs:404`
  Rust deadness signal from clippy
- `rh-clippy-wasm-host-src-host-api-rs-412-useless-conversion-to-the-same-type-wasmtime-error-help-consider-removing-into-anyhow-anyhow-invalid-input-empty-host` [class=`rust-static-deadness`, confidence=`low`, action=`needs-ablation-before-delete`, blocking=`false`]: `wasm_host/src/host_api.rs:412`
  Rust deadness signal from clippy
- `rh-clippy-wasm-host-src-host-api-rs-415-useless-conversion-to-the-same-type-wasmtime-error-help-consider-removing-into-anyhow-anyhow-invalid-input-ipv6-hosts-must-use-brackets` [class=`rust-static-deadness`, confidence=`low`, action=`needs-ablation-before-delete`, blocking=`false`]: `wasm_host/src/host_api.rs:415`
  Rust deadness signal from clippy
- `rh-clippy-wasm-host-src-host-api-rs-418-useless-conversion-to-the-same-type-wasmtime-error-help-consider-removing-into-anyhow-anyhow-invalid-input-malformed-host` [class=`rust-static-deadness`, confidence=`low`, action=`needs-ablation-before-delete`, blocking=`false`]: `wasm_host/src/host_api.rs:418`
  Rust deadness signal from clippy
- `rh-clippy-wasm-host-src-host-api-rs-431-useless-conversion-to-the-same-type-wasmtime-error-help-consider-removing-into-anyhow-anyhow-invalid-input-missing-url-port` [class=`rust-static-deadness`, confidence=`low`, action=`needs-ablation-before-delete`, blocking=`false`]: `wasm_host/src/host_api.rs:431`
  Rust deadness signal from clippy
- `rh-clippy-wasm-host-src-host-api-rs-435-useless-conversion-to-the-same-type-wasmtime-error-help-consider-removing-into-anyhow-anyhow-invalid-input-invalid-url-port-port-text` [class=`rust-static-deadness`, confidence=`low`, action=`needs-ablation-before-delete`, blocking=`false`]: `wasm_host/src/host_api.rs:435`
  Rust deadness signal from clippy
- `rh-clippy-wasm-host-src-host-api-rs-449-useless-conversion-to-the-same-type-wasmtime-error-help-consider-removing-into-anyhow-anyhow-timeout-http-request-timed-out` [class=`rust-static-deadness`, confidence=`low`, action=`needs-ablation-before-delete`, blocking=`false`]: `wasm_host/src/host_api.rs:449`
  Rust deadness signal from clippy
- `rh-clippy-wasm-host-src-host-api-rs-459-useless-conversion-to-the-same-type-wasmtime-error-help-consider-removing-into-anyhow-anyhow-http-error-no-resolved-address-for-authority` [class=`rust-static-deadness`, confidence=`low`, action=`needs-ablation-before-delete`, blocking=`false`]: `wasm_host/src/host_api.rs:459`
  Rust deadness signal from clippy
- `rh-clippy-wasm-host-src-host-api-rs-509-useless-conversion-to-the-same-type-wasmtime-error-help-consider-removing-into-anyhow-anyhow-invalid-input-http-header-name-cannot-be-empty` [class=`rust-static-deadness`, confidence=`low`, action=`needs-ablation-before-delete`, blocking=`false`]: `wasm_host/src/host_api.rs:509`
  Rust deadness signal from clippy
- `rh-clippy-wasm-host-src-host-api-rs-531-useless-conversion-to-the-same-type-wasmtime-error-help-consider-removing-into-anyhow-anyhow-invalid-input-invalid-http-header-name-name` [class=`rust-static-deadness`, confidence=`low`, action=`needs-ablation-before-delete`, blocking=`false`]: `wasm_host/src/host_api.rs:531`
  Rust deadness signal from clippy
- `rh-clippy-wasm-host-src-host-api-rs-538-useless-conversion-to-the-same-type-wasmtime-error-help-consider-removing-into-anyhow-anyhow-invalid-input-invalid-http-header-value` [class=`rust-static-deadness`, confidence=`low`, action=`needs-ablation-before-delete`, blocking=`false`]: `wasm_host/src/host_api.rs:538`
  Rust deadness signal from clippy
- `rh-clippy-wasm-host-src-host-api-rs-592-useless-conversion-to-the-same-type-wasmtime-error-help-consider-removing-into-anyhow-anyhow-http-error-truncated-response-body` [class=`rust-static-deadness`, confidence=`low`, action=`needs-ablation-before-delete`, blocking=`false`]: `wasm_host/src/host_api.rs:592`
  Rust deadness signal from clippy
- `rh-clippy-wasm-host-src-host-api-rs-600-useless-conversion-to-the-same-type-wasmtime-error-help-consider-removing-into-anyhow-anyhow-http-error-response-body-too-large` [class=`rust-static-deadness`, confidence=`low`, action=`needs-ablation-before-delete`, blocking=`false`]: `wasm_host/src/host_api.rs:600`
  Rust deadness signal from clippy
- `rh-clippy-wasm-host-src-host-api-rs-610-useless-conversion-to-the-same-type-wasmtime-error-help-consider-removing-into-anyhow-anyhow-http-error-invalid-status-line` [class=`rust-static-deadness`, confidence=`low`, action=`needs-ablation-before-delete`, blocking=`false`]: `wasm_host/src/host_api.rs:610`
  Rust deadness signal from clippy
- `rh-clippy-wasm-host-src-host-api-rs-616-useless-conversion-to-the-same-type-wasmtime-error-help-consider-removing-into-anyhow-anyhow-http-error-invalid-status-code` [class=`rust-static-deadness`, confidence=`low`, action=`needs-ablation-before-delete`, blocking=`false`]: `wasm_host/src/host_api.rs:616`
  Rust deadness signal from clippy
- `rh-clippy-wasm-host-src-host-api-rs-646-useless-conversion-to-the-same-type-wasmtime-error-help-consider-removing-into-anyhow-anyhow-http-error-truncated-chunked-response` [class=`rust-static-deadness`, confidence=`low`, action=`needs-ablation-before-delete`, blocking=`false`]: `wasm_host/src/host_api.rs:646`
  Rust deadness signal from clippy
- `rh-clippy-wasm-host-src-host-api-rs-650-useless-conversion-to-the-same-type-wasmtime-error-help-consider-removing-into-anyhow-anyhow-http-error-response-body-too-large` [class=`rust-static-deadness`, confidence=`low`, action=`needs-ablation-before-delete`, blocking=`false`]: `wasm_host/src/host_api.rs:650`
  Rust deadness signal from clippy
- `rh-clippy-wasm-host-src-host-api-rs-654-useless-conversion-to-the-same-type-wasmtime-error-help-consider-removing-into-anyhow-anyhow-http-error-malformed-chunk-terminator` [class=`rust-static-deadness`, confidence=`low`, action=`needs-ablation-before-delete`, blocking=`false`]: `wasm_host/src/host_api.rs:654`
  Rust deadness signal from clippy
- `rh-clippy-wasm-host-src-host-api-rs-671-useless-conversion-to-the-same-type-wasmtime-error-help-consider-removing-into-anyhow-anyhow-http-error-err` [class=`rust-static-deadness`, confidence=`low`, action=`needs-ablation-before-delete`, blocking=`false`]: `wasm_host/src/host_api.rs:671`
  Rust deadness signal from clippy
- `rh-clippy-wasm-host-src-host-api-rs-677-useless-conversion-to-the-same-type-wasmtime-error-help-consider-removing-into-anyhow-anyhow-timeout-http-request-timed-out` [class=`rust-static-deadness`, confidence=`low`, action=`needs-ablation-before-delete`, blocking=`false`]: `wasm_host/src/host_api.rs:677`
  Rust deadness signal from clippy
- `rh-clippy-wasm-host-src-host-api-rs-679-useless-conversion-to-the-same-type-wasmtime-error-help-consider-removing-into-anyhow-anyhow-http-error-err` [class=`rust-static-deadness`, confidence=`low`, action=`needs-ablation-before-delete`, blocking=`false`]: `wasm_host/src/host_api.rs:679`
  Rust deadness signal from clippy
- `rh-clippy-wasm-host-src-invoke-rs-42-this-function-has-too-many-arguments-10-7` [class=`rust-static-deadness`, confidence=`low`, action=`needs-ablation-before-delete`, blocking=`false`]: `wasm_host/src/invoke.rs:42`
  Rust deadness signal from clippy
- `rh-clippy-wasm-host-src-invoke-rs-89-needless-call-to-as-bytes-help-len-can-be-called-directly-on-strings-input-json-len` [class=`rust-static-deadness`, confidence=`low`, action=`needs-ablation-before-delete`, blocking=`false`]: `wasm_host/src/invoke.rs:89`
  Rust deadness signal from clippy
- `rh-clippy-wasm-host-src-invoke-rs-96-needless-call-to-as-bytes-help-len-can-be-called-directly-on-strings-input-json-len` [class=`rust-static-deadness`, confidence=`low`, action=`needs-ablation-before-delete`, blocking=`false`]: `wasm_host/src/invoke.rs:96`
  Rust deadness signal from clippy
- `rh-clippy-wasm-host-src-invoke-rs-186-needless-call-to-as-bytes-help-len-can-be-called-directly-on-strings-out-json-len` [class=`rust-static-deadness`, confidence=`low`, action=`needs-ablation-before-delete`, blocking=`false`]: `wasm_host/src/invoke.rs:186`
  Rust deadness signal from clippy
- `rh-clippy-wasm-host-src-invoke-rs-193-needless-call-to-as-bytes-help-len-can-be-called-directly-on-strings-out-json-len` [class=`rust-static-deadness`, confidence=`low`, action=`needs-ablation-before-delete`, blocking=`false`]: `wasm_host/src/invoke.rs:193`
  Rust deadness signal from clippy
- `rh-clippy-wasm-host-src-kv-store-rs-62-struct-kvstore-has-a-public-len-method-but-no-is-empty-method` [class=`rust-static-deadness`, confidence=`low`, action=`needs-ablation-before-delete`, blocking=`false`]: `wasm_host/src/kv_store.rs:62`
  Rust deadness signal from clippy
- `rh-clippy-wasm-host-src-kv-store-rs-169-this-can-be-std-io-error-other` [class=`rust-static-deadness`, confidence=`low`, action=`needs-ablation-before-delete`, blocking=`false`]: `wasm_host/src/kv_store.rs:169`
  Rust deadness signal from clippy
- `rh-clippy-wasm-host-src-kv-store-rs-190-used-assert-eq-with-a-literal-bool` [class=`rust-static-deadness`, confidence=`low`, action=`needs-ablation-before-delete`, blocking=`false`]: `wasm_host/src/kv_store.rs:190`
  Rust deadness signal from clippy
- `rh-clippy-wasm-host-src-policy-rs-31-useless-conversion-to-the-same-type-wasmtime-error-help-consider-removing-into-anyhow-anyhow-capability-denied-missing-cap` [class=`rust-static-deadness`, confidence=`low`, action=`needs-ablation-before-delete`, blocking=`false`]: `wasm_host/src/policy.rs:31`
  Rust deadness signal from clippy
- `rh-clippy-wasm-host-src-run-component-rs-9-this-function-has-too-many-arguments-8-7` [class=`rust-static-deadness`, confidence=`low`, action=`needs-ablation-before-delete`, blocking=`false`]: `wasm_host/src/run_component.rs:9`
  Rust deadness signal from clippy
- `rh-clippy-wasm-host-src-run-component-rs-43-manually-reimplementing-div-ceil-help-consider-using-div-ceil-timeout-ms-div-ceil-tick-ms` [class=`rust-static-deadness`, confidence=`low`, action=`needs-ablation-before-delete`, blocking=`false`]: `wasm_host/src/run_component.rs:43`
  Rust deadness signal from clippy
- `rh-clippy-wasm-host-src-scoped-fs-rs-125-needless-call-to-as-bytes-help-len-can-be-called-directly-on-strings-text-len` [class=`rust-static-deadness`, confidence=`low`, action=`needs-ablation-before-delete`, blocking=`false`]: `wasm_host/src/scoped_fs.rs:125`
  Rust deadness signal from clippy
- `rh-clippy-wasm-host-src-scoped-fs-rs-162-this-can-be-std-io-error-other` [class=`rust-static-deadness`, confidence=`low`, action=`needs-ablation-before-delete`, blocking=`false`]: `wasm_host/src/scoped_fs.rs:162`
  Rust deadness signal from clippy
- `rh-clippy-wasm-host-src-scoped-fs-rs-192-this-can-be-std-io-error-other` [class=`rust-static-deadness`, confidence=`low`, action=`needs-ablation-before-delete`, blocking=`false`]: `wasm_host/src/scoped_fs.rs:192`
  Rust deadness signal from clippy
- `rh-clippy-wasm-host-src-scoped-fs-rs-209-this-can-be-std-io-error-other` [class=`rust-static-deadness`, confidence=`low`, action=`needs-ablation-before-delete`, blocking=`false`]: `wasm_host/src/scoped_fs.rs:209`
  Rust deadness signal from clippy
- `rh-clippy-wasm-host-src-scoped-fs-rs-280-this-can-be-std-io-error-other` [class=`rust-static-deadness`, confidence=`low`, action=`needs-ablation-before-delete`, blocking=`false`]: `wasm_host/src/scoped_fs.rs:280`
  Rust deadness signal from clippy
- `rh-clippy-wasm-host-src-scoped-fs-rs-308-this-can-be-std-io-error-other` [class=`rust-static-deadness`, confidence=`low`, action=`needs-ablation-before-delete`, blocking=`false`]: `wasm_host/src/scoped_fs.rs:308`
  Rust deadness signal from clippy
- `rh-clippy-wasm-host-src-scoped-fs-rs-523-this-can-be-std-io-error-other` [class=`rust-static-deadness`, confidence=`low`, action=`needs-ablation-before-delete`, blocking=`false`]: `wasm_host/src/scoped_fs.rs:523`
  Rust deadness signal from clippy
- `rh-clippy-wasm-host-src-scoped-fs-rs-594-this-can-be-std-io-error-other` [class=`rust-static-deadness`, confidence=`low`, action=`needs-ablation-before-delete`, blocking=`false`]: `wasm_host/src/scoped_fs.rs:594`
  Rust deadness signal from clippy
- `rh-clippy-studio-src-app-state-rs-103-all-variants-have-the-same-postfix-id` [class=`rust-static-deadness`, confidence=`low`, action=`needs-ablation-before-delete`, blocking=`false`]: `studio/src/app_state.rs:103`
  Rust deadness signal from clippy
- `rh-clippy-studio-src-app-state-rs-1462-unneeded-return-statement` [class=`rust-static-deadness`, confidence=`low`, action=`needs-ablation-before-delete`, blocking=`false`]: `studio/src/app_state.rs:1462`
  Rust deadness signal from clippy
- `rh-clippy-studio-src-app-state-rs-1540-unneeded-return-statement` [class=`rust-static-deadness`, confidence=`low`, action=`needs-ablation-before-delete`, blocking=`false`]: `studio/src/app_state.rs:1540`
  Rust deadness signal from clippy
- `rh-clippy-authority-engine-src-implementation-authority-rs-98-used-consecutive-str-replace-call-help-replace-with-replace` [class=`rust-static-deadness`, confidence=`low`, action=`needs-ablation-before-delete`, blocking=`false`]: `authority_engine/src/implementation/authority.rs:98`
  Rust deadness signal from clippy
- `rh-clippy-authority-engine-src-implementation-authority-rs-172-this-function-has-too-many-arguments-9-7` [class=`rust-static-deadness`, confidence=`low`, action=`needs-ablation-before-delete`, blocking=`false`]: `authority_engine/src/implementation/authority.rs:172`
  Rust deadness signal from clippy
- `rh-clippy-authority-engine-src-implementation-authority-rs-363-this-function-has-too-many-arguments-13-7` [class=`rust-static-deadness`, confidence=`low`, action=`needs-ablation-before-delete`, blocking=`false`]: `authority_engine/src/implementation/authority.rs:363`
  Rust deadness signal from clippy
- `rh-clippy-authority-engine-src-implementation-autonomy-rs-217-this-if-statement-can-be-collapsed` [class=`rust-static-deadness`, confidence=`low`, action=`needs-ablation-before-delete`, blocking=`false`]: `authority_engine/src/implementation/autonomy.rs:217`
  Rust deadness signal from clippy
- `rh-clippy-authority-engine-src-implementation-effects-rs-1179-this-function-has-too-many-arguments-12-7` [class=`rust-static-deadness`, confidence=`low`, action=`needs-ablation-before-delete`, blocking=`false`]: `authority_engine/src/implementation/effects.rs:1179`
  Rust deadness signal from clippy
- `rh-clippy-authority-engine-src-implementation-execution-rs-944-this-if-statement-can-be-collapsed` [class=`rust-static-deadness`, confidence=`low`, action=`needs-ablation-before-delete`, blocking=`false`]: `authority_engine/src/implementation/execution.rs:944`
  Rust deadness signal from clippy
- `rh-clippy-authority-engine-src-implementation-execution-rs-1048-this-expression-creates-a-reference-which-is-immediately-dereferenced-by-the-compiler-help-change-this-to-path` [class=`rust-static-deadness`, confidence=`low`, action=`needs-ablation-before-delete`, blocking=`false`]: `authority_engine/src/implementation/execution.rs:1048`
  Rust deadness signal from clippy
- `rh-clippy-authority-engine-src-implementation-execution-rs-3276-this-if-has-identical-blocks` [class=`rust-static-deadness`, confidence=`low`, action=`needs-ablation-before-delete`, blocking=`false`]: `authority_engine/src/implementation/execution.rs:3276`
  Rust deadness signal from clippy
- `rh-clippy-authority-engine-src-implementation-execution-rs-3321-this-function-has-too-many-arguments-13-7` [class=`rust-static-deadness`, confidence=`low`, action=`needs-ablation-before-delete`, blocking=`false`]: `authority_engine/src/implementation/execution.rs:3321`
  Rust deadness signal from clippy
- `rh-clippy-authority-engine-src-implementation-execution-rs-3608-this-function-has-too-many-arguments-8-7` [class=`rust-static-deadness`, confidence=`low`, action=`needs-ablation-before-delete`, blocking=`false`]: `authority_engine/src/implementation/execution.rs:3608`
  Rust deadness signal from clippy
- `rh-clippy-authority-engine-src-implementation-policy-rs-281-this-function-has-too-many-arguments-14-7` [class=`rust-static-deadness`, confidence=`low`, action=`needs-ablation-before-delete`, blocking=`false`]: `authority_engine/src/implementation/policy.rs:281`
  Rust deadness signal from clippy
- `rh-clippy-authority-engine-src-implementation-policy-rs-675-this-function-has-too-many-arguments-14-7` [class=`rust-static-deadness`, confidence=`low`, action=`needs-ablation-before-delete`, blocking=`false`]: `authority_engine/src/implementation/policy.rs:675`
  Rust deadness signal from clippy
- `rh-clippy-authority-engine-src-implementation-effects-rs-1765-items-after-a-test-module` [class=`rust-static-deadness`, confidence=`low`, action=`needs-ablation-before-delete`, blocking=`false`]: `authority_engine/src/implementation/effects.rs:1765`
  Rust deadness signal from clippy
- `rh-clippy-authority-engine-src-implementation-runtime-state-rs-2087-this-function-has-too-many-arguments-12-7` [class=`rust-static-deadness`, confidence=`low`, action=`needs-ablation-before-delete`, blocking=`false`]: `authority_engine/src/implementation/runtime_state.rs:2087`
  Rust deadness signal from clippy
- `rh-clippy-authority-engine-src-implementation-support-rs-485-this-function-has-too-many-arguments-8-7` [class=`rust-static-deadness`, confidence=`low`, action=`needs-ablation-before-delete`, blocking=`false`]: `authority_engine/src/implementation/support.rs:485`
  Rust deadness signal from clippy
- `rh-clippy-authority-engine-src-implementation-runtime-state-rs-1671-useless-use-of-vec` [class=`rust-static-deadness`, confidence=`low`, action=`needs-ablation-before-delete`, blocking=`false`]: `authority_engine/src/implementation/runtime_state.rs:1671`
  Rust deadness signal from clippy
- `rh-clippy-authority-engine-src-implementation-runtime-state-rs-1189-items-after-a-test-module` [class=`rust-static-deadness`, confidence=`low`, action=`needs-ablation-before-delete`, blocking=`false`]: `authority_engine/src/implementation/runtime_state.rs:1189`
  Rust deadness signal from clippy
- `rh-clippy-authority-engine-src-implementation-tests-rs-214-redundant-redefinition-of-a-binding-receipt-rel` [class=`rust-static-deadness`, confidence=`low`, action=`needs-ablation-before-delete`, blocking=`false`]: `authority_engine/src/implementation/tests.rs:214`
  Rust deadness signal from clippy
- `rh-clippy-kernel-src-pipeline-rs-1870-use-of-deprecated-function-time-format-description-parse-use-parse-borrowed-with-the-appropriate-version-for-clarity` [class=`rust-static-deadness`, confidence=`low`, action=`needs-ablation-before-delete`, blocking=`false`]: `kernel/src/pipeline.rs:1870`
  Rust deadness signal from clippy
- `rh-clippy-kernel-src-workflow-rs-9856-use-of-deprecated-function-time-format-description-parse-use-parse-borrowed-with-the-appropriate-version-for-clarity` [class=`rust-static-deadness`, confidence=`low`, action=`needs-ablation-before-delete`, blocking=`false`]: `kernel/src/workflow.rs:9856`
  Rust deadness signal from clippy
- `rh-clippy-kernel-src-commands-engagement-rs-1608-this-function-has-too-many-arguments-9-7` [class=`rust-static-deadness`, confidence=`low`, action=`needs-ablation-before-delete`, blocking=`false`]: `kernel/src/commands/engagement.rs:1608`
  Rust deadness signal from clippy
- `rh-clippy-kernel-src-commands-engagement-rs-1804-enclosing-ok-and-operator-are-unneeded` [class=`rust-static-deadness`, confidence=`low`, action=`needs-ablation-before-delete`, blocking=`false`]: `kernel/src/commands/engagement.rs:1804`
  Rust deadness signal from clippy
- `rh-clippy-kernel-src-commands-evolution-rs-1176-enclosing-ok-and-operator-are-unneeded` [class=`rust-static-deadness`, confidence=`low`, action=`needs-ablation-before-delete`, blocking=`false`]: `kernel/src/commands/evolution.rs:1176`
  Rust deadness signal from clippy
- `rh-clippy-kernel-src-commands-evolution-rs-1200-this-function-has-too-many-arguments-8-7` [class=`rust-static-deadness`, confidence=`low`, action=`needs-ablation-before-delete`, blocking=`false`]: `kernel/src/commands/evolution.rs:1200`
  Rust deadness signal from clippy
- `rh-clippy-kernel-src-commands-mission-rs-139-matching-on-some-with-ok-is-redundant` [class=`rust-static-deadness`, confidence=`low`, action=`needs-ablation-before-delete`, blocking=`false`]: `kernel/src/commands/mission.rs:139`
  Rust deadness signal from clippy
- `rh-clippy-kernel-src-commands-mission-rs-2019-this-function-has-too-many-arguments-9-7` [class=`rust-static-deadness`, confidence=`low`, action=`needs-ablation-before-delete`, blocking=`false`]: `kernel/src/commands/mission.rs:2019`
  Rust deadness signal from clippy
- `rh-clippy-kernel-src-commands-mission-rs-3040-this-function-has-too-many-arguments-9-7` [class=`rust-static-deadness`, confidence=`low`, action=`needs-ablation-before-delete`, blocking=`false`]: `kernel/src/commands/mission.rs:3040`
  Rust deadness signal from clippy
- `rh-clippy-kernel-src-commands-mission-rs-3975-enclosing-ok-and-operator-are-unneeded` [class=`rust-static-deadness`, confidence=`low`, action=`needs-ablation-before-delete`, blocking=`false`]: `kernel/src/commands/mission.rs:3975`
  Rust deadness signal from clippy
- `rh-clippy-kernel-src-commands-stewardship-rs-1461-this-function-has-too-many-arguments-8-7` [class=`rust-static-deadness`, confidence=`low`, action=`needs-ablation-before-delete`, blocking=`false`]: `kernel/src/commands/stewardship.rs:1461`
  Rust deadness signal from clippy
- `rh-clippy-kernel-src-commands-stewardship-rs-2194-enclosing-ok-and-operator-are-unneeded` [class=`rust-static-deadness`, confidence=`low`, action=`needs-ablation-before-delete`, blocking=`false`]: `kernel/src/commands/stewardship.rs:2194`
  Rust deadness signal from clippy
- `rh-clippy-kernel-src-commands-stewardship-rs-2240-this-function-has-too-many-arguments-8-7` [class=`rust-static-deadness`, confidence=`low`, action=`needs-ablation-before-delete`, blocking=`false`]: `kernel/src/commands/stewardship.rs:2240`
  Rust deadness signal from clippy
- `rh-clippy-kernel-src-commands-trust-rs-1394-enclosing-ok-and-operator-are-unneeded` [class=`rust-static-deadness`, confidence=`low`, action=`needs-ablation-before-delete`, blocking=`false`]: `kernel/src/commands/trust.rs:1394`
  Rust deadness signal from clippy
- `rh-clippy-kernel-src-commands-mod-rs-61-this-function-has-too-many-arguments-9-7` [class=`rust-static-deadness`, confidence=`low`, action=`needs-ablation-before-delete`, blocking=`false`]: `kernel/src/commands/mod.rs:61`
  Rust deadness signal from clippy
- `rh-clippy-kernel-src-lifecycle-program-rs-3843-this-function-has-too-many-arguments-10-7` [class=`rust-static-deadness`, confidence=`low`, action=`needs-ablation-before-delete`, blocking=`false`]: `kernel/src/lifecycle_program.rs:3843`
  Rust deadness signal from clippy
- `rh-clippy-kernel-src-lifecycle-program-rs-4955-this-expression-creates-a-reference-which-is-immediately-dereferenced-by-the-compiler-help-change-this-to-repo-root` [class=`rust-static-deadness`, confidence=`low`, action=`needs-ablation-before-delete`, blocking=`false`]: `kernel/src/lifecycle_program.rs:4955`
  Rust deadness signal from clippy
- `rh-clippy-kernel-src-lifecycle-program-rs-4971-this-expression-creates-a-reference-which-is-immediately-dereferenced-by-the-compiler-help-change-this-to-repo-root` [class=`rust-static-deadness`, confidence=`low`, action=`needs-ablation-before-delete`, blocking=`false`]: `kernel/src/lifecycle_program.rs:4971`
  Rust deadness signal from clippy
- `rh-clippy-kernel-src-lifecycle-program-rs-4996-this-expression-creates-a-reference-which-is-immediately-dereferenced-by-the-compiler-help-change-this-to-repo-root` [class=`rust-static-deadness`, confidence=`low`, action=`needs-ablation-before-delete`, blocking=`false`]: `kernel/src/lifecycle_program.rs:4996`
  Rust deadness signal from clippy
- `rh-clippy-kernel-src-lifecycle-program-rs-4996-this-expression-creates-a-reference-which-is-immediately-dereferenced-by-the-compiler-help-change-this-to-evidence-root` [class=`rust-static-deadness`, confidence=`low`, action=`needs-ablation-before-delete`, blocking=`false`]: `kernel/src/lifecycle_program.rs:4996`
  Rust deadness signal from clippy
- `rh-clippy-kernel-src-lifecycle-program-rs-4997-this-expression-creates-a-reference-which-is-immediately-dereferenced-by-the-compiler-help-change-this-to-repo-root` [class=`rust-static-deadness`, confidence=`low`, action=`needs-ablation-before-delete`, blocking=`false`]: `kernel/src/lifecycle_program.rs:4997`
  Rust deadness signal from clippy
- `rh-clippy-kernel-src-lifecycle-program-rs-4998-this-expression-creates-a-reference-which-is-immediately-dereferenced-by-the-compiler-help-change-this-to-repo-root` [class=`rust-static-deadness`, confidence=`low`, action=`needs-ablation-before-delete`, blocking=`false`]: `kernel/src/lifecycle_program.rs:4998`
  Rust deadness signal from clippy
- `rh-clippy-kernel-src-lifecycle-program-rs-4998-this-expression-creates-a-reference-which-is-immediately-dereferenced-by-the-compiler-help-change-this-to-control-root` [class=`rust-static-deadness`, confidence=`low`, action=`needs-ablation-before-delete`, blocking=`false`]: `kernel/src/lifecycle_program.rs:4998`
  Rust deadness signal from clippy
- `rh-clippy-kernel-src-lifecycle-program-rs-5345-this-function-has-too-many-arguments-12-7` [class=`rust-static-deadness`, confidence=`low`, action=`needs-ablation-before-delete`, blocking=`false`]: `kernel/src/lifecycle_program.rs:5345`
  Rust deadness signal from clippy
- `rh-clippy-kernel-src-lifecycle-program-rs-5704-unnecessary-closure-used-to-substitute-value-for-option-none` [class=`rust-static-deadness`, confidence=`low`, action=`needs-ablation-before-delete`, blocking=`false`]: `kernel/src/lifecycle_program.rs:5704`
  Rust deadness signal from clippy
- `rh-clippy-kernel-src-lifecycle-program-rs-6611-this-function-has-too-many-arguments-8-7` [class=`rust-static-deadness`, confidence=`low`, action=`needs-ablation-before-delete`, blocking=`false`]: `kernel/src/lifecycle_program.rs:6611`
  Rust deadness signal from clippy
- `rh-clippy-kernel-src-lifecycle-program-rs-7802-this-map-or-can-be-simplified` [class=`rust-static-deadness`, confidence=`low`, action=`needs-ablation-before-delete`, blocking=`false`]: `kernel/src/lifecycle_program.rs:7802`
  Rust deadness signal from clippy
- `rh-clippy-kernel-src-lifecycle-program-rs-10162-this-function-has-too-many-arguments-9-7` [class=`rust-static-deadness`, confidence=`low`, action=`needs-ablation-before-delete`, blocking=`false`]: `kernel/src/lifecycle_program.rs:10162`
  Rust deadness signal from clippy
- `rh-clippy-kernel-src-lifecycle-program-rs-10424-this-function-has-too-many-arguments-9-7` [class=`rust-static-deadness`, confidence=`low`, action=`needs-ablation-before-delete`, blocking=`false`]: `kernel/src/lifecycle_program.rs:10424`
  Rust deadness signal from clippy
- `rh-clippy-kernel-src-lifecycle-program-rs-10454-this-function-has-too-many-arguments-11-7` [class=`rust-static-deadness`, confidence=`low`, action=`needs-ablation-before-delete`, blocking=`false`]: `kernel/src/lifecycle_program.rs:10454`
  Rust deadness signal from clippy
- `rh-clippy-kernel-src-lifecycle-program-rs-10579-this-function-has-too-many-arguments-8-7` [class=`rust-static-deadness`, confidence=`low`, action=`needs-ablation-before-delete`, blocking=`false`]: `kernel/src/lifecycle_program.rs:10579`
  Rust deadness signal from clippy
- `rh-clippy-kernel-src-lifecycle-program-rs-10695-this-function-has-too-many-arguments-10-7` [class=`rust-static-deadness`, confidence=`low`, action=`needs-ablation-before-delete`, blocking=`false`]: `kernel/src/lifecycle_program.rs:10695`
  Rust deadness signal from clippy
- `rh-clippy-kernel-src-lifecycle-program-rs-11909-this-if-has-identical-blocks` [class=`rust-static-deadness`, confidence=`low`, action=`needs-ablation-before-delete`, blocking=`false`]: `kernel/src/lifecycle_program.rs:11909`
  Rust deadness signal from clippy
- `rh-clippy-kernel-src-lifecycle-program-rs-12307-this-boolean-expression-can-be-simplified` [class=`rust-static-deadness`, confidence=`low`, action=`needs-ablation-before-delete`, blocking=`false`]: `kernel/src/lifecycle_program.rs:12307`
  Rust deadness signal from clippy
- `rh-clippy-kernel-src-lifecycle-program-rs-12386-writing-mut-vec-instead-of-mut-involves-a-new-object-where-a-slice-will-do-help-change-this-to-mut-programblocker` [class=`rust-static-deadness`, confidence=`low`, action=`needs-ablation-before-delete`, blocking=`false`]: `kernel/src/lifecycle_program.rs:12386`
  Rust deadness signal from clippy
- `rh-clippy-kernel-src-lifecycle-program-rs-12505-this-boolean-expression-can-be-simplified` [class=`rust-static-deadness`, confidence=`low`, action=`needs-ablation-before-delete`, blocking=`false`]: `kernel/src/lifecycle_program.rs:12505`
  Rust deadness signal from clippy
- `rh-clippy-kernel-src-lifecycle-program-rs-12543-writing-mut-vec-instead-of-mut-involves-a-new-object-where-a-slice-will-do-help-change-this-to-mut-programblocker` [class=`rust-static-deadness`, confidence=`low`, action=`needs-ablation-before-delete`, blocking=`false`]: `kernel/src/lifecycle_program.rs:12543`
  Rust deadness signal from clippy
- `rh-clippy-kernel-src-lifecycle-program-rs-13075-usage-of-bool-then-in-filter-map-help-use-filter-then-map-instead-filter-child-id-runnable-child-program-child-states-child-id-map-child-id-child-id-clone` [class=`rust-static-deadness`, confidence=`low`, action=`needs-ablation-before-delete`, blocking=`false`]: `kernel/src/lifecycle_program.rs:13075`
  Rust deadness signal from clippy
- `rh-clippy-kernel-src-lifecycle-program-rs-13087-usage-of-bool-then-in-filter-map-help-use-filter-then-map-instead-filter-child-id-runnable-child-program-child-states-child-id-map-child-id-child-id-clone` [class=`rust-static-deadness`, confidence=`low`, action=`needs-ablation-before-delete`, blocking=`false`]: `kernel/src/lifecycle_program.rs:13087`
  Rust deadness signal from clippy
- `rh-clippy-kernel-src-lifecycle-program-rs-13271-this-boolean-expression-can-be-simplified` [class=`rust-static-deadness`, confidence=`low`, action=`needs-ablation-before-delete`, blocking=`false`]: `kernel/src/lifecycle_program.rs:13271`
  Rust deadness signal from clippy
- `rh-clippy-kernel-src-lifecycle-program-rs-13794-this-function-has-too-many-arguments-11-7` [class=`rust-static-deadness`, confidence=`low`, action=`needs-ablation-before-delete`, blocking=`false`]: `kernel/src/lifecycle_program.rs:13794`
  Rust deadness signal from clippy
- `rh-clippy-kernel-src-lifecycle-program-rs-13917-this-function-has-too-many-arguments-9-7` [class=`rust-static-deadness`, confidence=`low`, action=`needs-ablation-before-delete`, blocking=`false`]: `kernel/src/lifecycle_program.rs:13917`
  Rust deadness signal from clippy
- `rh-clippy-kernel-src-lifecycle-program-rs-14146-this-function-has-too-many-arguments-9-7` [class=`rust-static-deadness`, confidence=`low`, action=`needs-ablation-before-delete`, blocking=`false`]: `kernel/src/lifecycle_program.rs:14146`
  Rust deadness signal from clippy
- `rh-clippy-kernel-src-lifecycle-program-rs-14494-this-function-has-too-many-arguments-11-7` [class=`rust-static-deadness`, confidence=`low`, action=`needs-ablation-before-delete`, blocking=`false`]: `kernel/src/lifecycle_program.rs:14494`
  Rust deadness signal from clippy
- `rh-clippy-kernel-src-lifecycle-program-rs-14626-equality-checks-against-false-can-be-replaced-by-a-negation` [class=`rust-static-deadness`, confidence=`low`, action=`needs-ablation-before-delete`, blocking=`false`]: `kernel/src/lifecycle_program.rs:14626`
  Rust deadness signal from clippy
- `rh-clippy-kernel-src-lifecycle-program-rs-14639-equality-checks-against-false-can-be-replaced-by-a-negation` [class=`rust-static-deadness`, confidence=`low`, action=`needs-ablation-before-delete`, blocking=`false`]: `kernel/src/lifecycle_program.rs:14639`
  Rust deadness signal from clippy
- `rh-clippy-kernel-src-lifecycle-program-rs-14668-this-function-has-too-many-arguments-8-7` [class=`rust-static-deadness`, confidence=`low`, action=`needs-ablation-before-delete`, blocking=`false`]: `kernel/src/lifecycle_program.rs:14668`
  Rust deadness signal from clippy
- `rh-clippy-kernel-src-lifecycle-program-rs-14713-this-function-has-too-many-arguments-8-7` [class=`rust-static-deadness`, confidence=`low`, action=`needs-ablation-before-delete`, blocking=`false`]: `kernel/src/lifecycle_program.rs:14713`
  Rust deadness signal from clippy
- `rh-clippy-kernel-src-lifecycle-program-rs-15542-this-function-has-too-many-arguments-9-7` [class=`rust-static-deadness`, confidence=`low`, action=`needs-ablation-before-delete`, blocking=`false`]: `kernel/src/lifecycle_program.rs:15542`
  Rust deadness signal from clippy
- `rh-clippy-kernel-src-lifecycle-program-rs-15637-this-function-has-too-many-arguments-11-7` [class=`rust-static-deadness`, confidence=`low`, action=`needs-ablation-before-delete`, blocking=`false`]: `kernel/src/lifecycle_program.rs:15637`
  Rust deadness signal from clippy
- `rh-clippy-kernel-src-lifecycle-program-rs-15706-this-function-has-too-many-arguments-8-7` [class=`rust-static-deadness`, confidence=`low`, action=`needs-ablation-before-delete`, blocking=`false`]: `kernel/src/lifecycle_program.rs:15706`
  Rust deadness signal from clippy
- `rh-clippy-kernel-src-lifecycle-program-rs-16577-this-function-has-too-many-arguments-14-7` [class=`rust-static-deadness`, confidence=`low`, action=`needs-ablation-before-delete`, blocking=`false`]: `kernel/src/lifecycle_program.rs:16577`
  Rust deadness signal from clippy
- `rh-clippy-kernel-src-lifecycle-program-rs-16624-this-function-has-too-many-arguments-10-7` [class=`rust-static-deadness`, confidence=`low`, action=`needs-ablation-before-delete`, blocking=`false`]: `kernel/src/lifecycle_program.rs:16624`
  Rust deadness signal from clippy
- `rh-clippy-kernel-src-lifecycle-program-rs-17378-this-function-has-too-many-arguments-8-7` [class=`rust-static-deadness`, confidence=`low`, action=`needs-ablation-before-delete`, blocking=`false`]: `kernel/src/lifecycle_program.rs:17378`
  Rust deadness signal from clippy
- `rh-clippy-kernel-src-lifecycle-program-rs-17874-this-boolean-expression-can-be-simplified` [class=`rust-static-deadness`, confidence=`low`, action=`needs-ablation-before-delete`, blocking=`false`]: `kernel/src/lifecycle_program.rs:17874`
  Rust deadness signal from clippy
- `rh-clippy-kernel-src-lifecycle-program-rs-17962-redundant-closure-help-replace-the-closure-with-the-function-itself-is-safe-repo-relative` [class=`rust-static-deadness`, confidence=`low`, action=`needs-ablation-before-delete`, blocking=`false`]: `kernel/src/lifecycle_program.rs:17962`
  Rust deadness signal from clippy
- `rh-clippy-kernel-src-lifecycle-program-rs-18133-this-function-has-too-many-arguments-8-7` [class=`rust-static-deadness`, confidence=`low`, action=`needs-ablation-before-delete`, blocking=`false`]: `kernel/src/lifecycle_program.rs:18133`
  Rust deadness signal from clippy
- `rh-clippy-kernel-src-lifecycle-program-rs-18716-this-function-has-too-many-arguments-8-7` [class=`rust-static-deadness`, confidence=`low`, action=`needs-ablation-before-delete`, blocking=`false`]: `kernel/src/lifecycle_program.rs:18716`
  Rust deadness signal from clippy
- `rh-clippy-kernel-src-lifecycle-program-rs-20808-this-function-has-too-many-arguments-9-7` [class=`rust-static-deadness`, confidence=`low`, action=`needs-ablation-before-delete`, blocking=`false`]: `kernel/src/lifecycle_program.rs:20808`
  Rust deadness signal from clippy
- `rh-clippy-kernel-src-lifecycle-program-rs-20978-this-function-has-too-many-arguments-8-7` [class=`rust-static-deadness`, confidence=`low`, action=`needs-ablation-before-delete`, blocking=`false`]: `kernel/src/lifecycle_program.rs:20978`
  Rust deadness signal from clippy
- `rh-clippy-kernel-src-lifecycle-program-rs-21055-this-function-has-too-many-arguments-9-7` [class=`rust-static-deadness`, confidence=`low`, action=`needs-ablation-before-delete`, blocking=`false`]: `kernel/src/lifecycle_program.rs:21055`
  Rust deadness signal from clippy
- `rh-clippy-kernel-src-lifecycle-program-rs-21250-very-complex-type-used-consider-factoring-parts-into-type-definitions` [class=`rust-static-deadness`, confidence=`low`, action=`needs-ablation-before-delete`, blocking=`false`]: `kernel/src/lifecycle_program.rs:21250`
  Rust deadness signal from clippy
- `rh-clippy-kernel-src-lifecycle-program-rs-21712-this-function-has-too-many-arguments-9-7` [class=`rust-static-deadness`, confidence=`low`, action=`needs-ablation-before-delete`, blocking=`false`]: `kernel/src/lifecycle_program.rs:21712`
  Rust deadness signal from clippy
- `rh-clippy-kernel-src-lifecycle-program-rs-22076-this-function-has-too-many-arguments-11-7` [class=`rust-static-deadness`, confidence=`low`, action=`needs-ablation-before-delete`, blocking=`false`]: `kernel/src/lifecycle_program.rs:22076`
  Rust deadness signal from clippy
- `rh-clippy-kernel-src-lifecycle-program-rs-22269-this-function-has-too-many-arguments-12-7` [class=`rust-static-deadness`, confidence=`low`, action=`needs-ablation-before-delete`, blocking=`false`]: `kernel/src/lifecycle_program.rs:22269`
  Rust deadness signal from clippy
- `rh-clippy-kernel-src-lifecycle-program-rs-22649-unnecessary-closure-used-to-substitute-value-for-option-none` [class=`rust-static-deadness`, confidence=`low`, action=`needs-ablation-before-delete`, blocking=`false`]: `kernel/src/lifecycle_program.rs:22649`
  Rust deadness signal from clippy
- `rh-clippy-kernel-src-lifecycle-program-rs-23085-this-function-has-too-many-arguments-9-7` [class=`rust-static-deadness`, confidence=`low`, action=`needs-ablation-before-delete`, blocking=`false`]: `kernel/src/lifecycle_program.rs:23085`
  Rust deadness signal from clippy
- `rh-clippy-kernel-src-lifecycle-program-rs-23205-this-function-has-too-many-arguments-8-7` [class=`rust-static-deadness`, confidence=`low`, action=`needs-ablation-before-delete`, blocking=`false`]: `kernel/src/lifecycle_program.rs:23205`
  Rust deadness signal from clippy
- `rh-clippy-kernel-src-lifecycle-program-rs-25203-this-function-has-too-many-arguments-16-7` [class=`rust-static-deadness`, confidence=`low`, action=`needs-ablation-before-delete`, blocking=`false`]: `kernel/src/lifecycle_program.rs:25203`
  Rust deadness signal from clippy
- `rh-clippy-kernel-src-lifecycle-program-rs-25349-this-function-has-too-many-arguments-16-7` [class=`rust-static-deadness`, confidence=`low`, action=`needs-ablation-before-delete`, blocking=`false`]: `kernel/src/lifecycle_program.rs:25349`
  Rust deadness signal from clippy
- `rh-clippy-kernel-src-lifecycle-program-rs-25812-this-function-has-too-many-arguments-9-7` [class=`rust-static-deadness`, confidence=`low`, action=`needs-ablation-before-delete`, blocking=`false`]: `kernel/src/lifecycle_program.rs:25812`
  Rust deadness signal from clippy
- `rh-clippy-kernel-src-lifecycle-program-rs-25953-this-function-has-too-many-arguments-9-7` [class=`rust-static-deadness`, confidence=`low`, action=`needs-ablation-before-delete`, blocking=`false`]: `kernel/src/lifecycle_program.rs:25953`
  Rust deadness signal from clippy
- `rh-clippy-kernel-src-lifecycle-program-rs-26317-this-function-has-too-many-arguments-9-7` [class=`rust-static-deadness`, confidence=`low`, action=`needs-ablation-before-delete`, blocking=`false`]: `kernel/src/lifecycle_program.rs:26317`
  Rust deadness signal from clippy
- `rh-clippy-kernel-src-lifecycle-program-rs-27348-this-function-has-too-many-arguments-10-7` [class=`rust-static-deadness`, confidence=`low`, action=`needs-ablation-before-delete`, blocking=`false`]: `kernel/src/lifecycle_program.rs:27348`
  Rust deadness signal from clippy
- `rh-clippy-kernel-src-lifecycle-program-rs-27444-this-function-has-too-many-arguments-12-7` [class=`rust-static-deadness`, confidence=`low`, action=`needs-ablation-before-delete`, blocking=`false`]: `kernel/src/lifecycle_program.rs:27444`
  Rust deadness signal from clippy
- `rh-clippy-kernel-src-lifecycle-program-rs-28875-this-function-has-too-many-arguments-8-7` [class=`rust-static-deadness`, confidence=`low`, action=`needs-ablation-before-delete`, blocking=`false`]: `kernel/src/lifecycle_program.rs:28875`
  Rust deadness signal from clippy
- `rh-clippy-kernel-src-lifecycle-program-rs-29146-this-if-statement-can-be-collapsed` [class=`rust-static-deadness`, confidence=`low`, action=`needs-ablation-before-delete`, blocking=`false`]: `kernel/src/lifecycle_program.rs:29146`
  Rust deadness signal from clippy
- `rh-clippy-kernel-src-lifecycle-program-rs-29292-this-function-has-too-many-arguments-10-7` [class=`rust-static-deadness`, confidence=`low`, action=`needs-ablation-before-delete`, blocking=`false`]: `kernel/src/lifecycle_program.rs:29292`
  Rust deadness signal from clippy
- `rh-clippy-kernel-src-lifecycle-program-rs-30008-taken-reference-of-right-operand` [class=`rust-static-deadness`, confidence=`low`, action=`needs-ablation-before-delete`, blocking=`false`]: `kernel/src/lifecycle_program.rs:30008`
  Rust deadness signal from clippy
- `rh-clippy-kernel-src-lifecycle-rs-2143-this-expression-creates-a-reference-which-is-immediately-dereferenced-by-the-compiler-help-change-this-to-right-0` [class=`rust-static-deadness`, confidence=`low`, action=`needs-ablation-before-delete`, blocking=`false`]: `kernel/src/lifecycle.rs:2143`
  Rust deadness signal from clippy
- `rh-clippy-kernel-src-lifecycle-rs-2279-this-function-has-too-many-arguments-13-7` [class=`rust-static-deadness`, confidence=`low`, action=`needs-ablation-before-delete`, blocking=`false`]: `kernel/src/lifecycle.rs:2279`
  Rust deadness signal from clippy
- `rh-clippy-kernel-src-lifecycle-rs-3584-this-boolean-expression-can-be-simplified-help-try-value-as-bool-unwrap-or-false-target-state-target-exists` [class=`rust-static-deadness`, confidence=`low`, action=`needs-ablation-before-delete`, blocking=`false`]: `kernel/src/lifecycle.rs:3584`
  Rust deadness signal from clippy
- `rh-clippy-kernel-src-lifecycle-rs-4130-this-function-has-too-many-arguments-16-7` [class=`rust-static-deadness`, confidence=`low`, action=`needs-ablation-before-delete`, blocking=`false`]: `kernel/src/lifecycle.rs:4130`
  Rust deadness signal from clippy
- `rh-clippy-kernel-src-lifecycle-rs-4746-the-borrowed-expression-implements-the-required-traits-help-change-this-to-value-string-field-to-string` [class=`rust-static-deadness`, confidence=`low`, action=`needs-ablation-before-delete`, blocking=`false`]: `kernel/src/lifecycle.rs:4746`
  Rust deadness signal from clippy
- `rh-clippy-kernel-src-pipeline-rs-1106-needless-call-to-as-bytes-help-len-can-be-called-directly-on-strings-rendered-len` [class=`rust-static-deadness`, confidence=`low`, action=`needs-ablation-before-delete`, blocking=`false`]: `kernel/src/pipeline.rs:1106`
  Rust deadness signal from clippy
- `rh-clippy-kernel-src-workflow-rs-714-this-function-has-too-many-arguments-16-7` [class=`rust-static-deadness`, confidence=`low`, action=`needs-ablation-before-delete`, blocking=`false`]: `kernel/src/workflow.rs:714`
  Rust deadness signal from clippy
- `rh-clippy-kernel-src-workflow-rs-4744-this-function-has-too-many-arguments-12-7` [class=`rust-static-deadness`, confidence=`low`, action=`needs-ablation-before-delete`, blocking=`false`]: `kernel/src/workflow.rs:4744`
  Rust deadness signal from clippy
- `rh-clippy-kernel-src-workflow-rs-5327-this-if-statement-can-be-collapsed` [class=`rust-static-deadness`, confidence=`low`, action=`needs-ablation-before-delete`, blocking=`false`]: `kernel/src/workflow.rs:5327`
  Rust deadness signal from clippy
- `rh-clippy-kernel-src-workflow-rs-5799-this-function-has-too-many-arguments-11-7` [class=`rust-static-deadness`, confidence=`low`, action=`needs-ablation-before-delete`, blocking=`false`]: `kernel/src/workflow.rs:5799`
  Rust deadness signal from clippy
- `rh-clippy-kernel-src-workflow-rs-5870-this-function-has-too-many-arguments-17-7` [class=`rust-static-deadness`, confidence=`low`, action=`needs-ablation-before-delete`, blocking=`false`]: `kernel/src/workflow.rs:5870`
  Rust deadness signal from clippy
- `rh-clippy-kernel-src-workflow-rs-6004-this-function-has-too-many-arguments-11-7` [class=`rust-static-deadness`, confidence=`low`, action=`needs-ablation-before-delete`, blocking=`false`]: `kernel/src/workflow.rs:6004`
  Rust deadness signal from clippy
- `rh-clippy-kernel-src-workflow-rs-6037-this-function-has-too-many-arguments-8-7` [class=`rust-static-deadness`, confidence=`low`, action=`needs-ablation-before-delete`, blocking=`false`]: `kernel/src/workflow.rs:6037`
  Rust deadness signal from clippy
- `rh-clippy-kernel-src-workflow-rs-6087-this-function-has-too-many-arguments-21-7` [class=`rust-static-deadness`, confidence=`low`, action=`needs-ablation-before-delete`, blocking=`false`]: `kernel/src/workflow.rs:6087`
  Rust deadness signal from clippy
- `rh-clippy-kernel-src-workflow-rs-7144-needless-call-to-as-bytes-help-len-can-be-called-directly-on-strings-prompt-markdown-len` [class=`rust-static-deadness`, confidence=`low`, action=`needs-ablation-before-delete`, blocking=`false`]: `kernel/src/workflow.rs:7144`
  Rust deadness signal from clippy
- `rh-clippy-kernel-src-workflow-rs-7300-field-assignment-outside-of-initializer-for-an-instance-created-with-default-default` [class=`rust-static-deadness`, confidence=`low`, action=`needs-ablation-before-delete`, blocking=`false`]: `kernel/src/workflow.rs:7300`
  Rust deadness signal from clippy
- `rh-clippy-kernel-src-workflow-rs-7430-this-function-has-too-many-arguments-10-7` [class=`rust-static-deadness`, confidence=`low`, action=`needs-ablation-before-delete`, blocking=`false`]: `kernel/src/workflow.rs:7430`
  Rust deadness signal from clippy
- `rh-clippy-kernel-src-workflow-rs-7499-this-function-has-too-many-arguments-11-7` [class=`rust-static-deadness`, confidence=`low`, action=`needs-ablation-before-delete`, blocking=`false`]: `kernel/src/workflow.rs:7499`
  Rust deadness signal from clippy
- `rh-clippy-kernel-src-workflow-rs-7569-this-function-has-too-many-arguments-11-7` [class=`rust-static-deadness`, confidence=`low`, action=`needs-ablation-before-delete`, blocking=`false`]: `kernel/src/workflow.rs:7569`
  Rust deadness signal from clippy
- `rh-clippy-kernel-src-workflow-rs-7641-this-function-has-too-many-arguments-10-7` [class=`rust-static-deadness`, confidence=`low`, action=`needs-ablation-before-delete`, blocking=`false`]: `kernel/src/workflow.rs:7641`
  Rust deadness signal from clippy
- `rh-clippy-kernel-src-workflow-rs-7708-this-function-has-too-many-arguments-9-7` [class=`rust-static-deadness`, confidence=`low`, action=`needs-ablation-before-delete`, blocking=`false`]: `kernel/src/workflow.rs:7708`
  Rust deadness signal from clippy
- `rh-clippy-kernel-src-workflow-rs-8986-this-function-has-too-many-arguments-10-7` [class=`rust-static-deadness`, confidence=`low`, action=`needs-ablation-before-delete`, blocking=`false`]: `kernel/src/workflow.rs:8986`
  Rust deadness signal from clippy
- `rh-clippy-kernel-src-lifecycle-program-rs-7502-useless-use-of-vec` [class=`rust-static-deadness`, confidence=`low`, action=`needs-ablation-before-delete`, blocking=`false`]: `kernel/src/lifecycle_program.rs:7502`
  Rust deadness signal from clippy
- `rh-clippy-kernel-src-lifecycle-program-rs-39431-this-call-to-clone-can-be-replaced-with-std-slice-from-ref-help-try-std-slice-from-ref-material-blocker` [class=`rust-static-deadness`, confidence=`low`, action=`needs-ablation-before-delete`, blocking=`false`]: `kernel/src/lifecycle_program.rs:39431`
  Rust deadness signal from clippy
- `rh-clippy-kernel-src-lifecycle-program-rs-42640-this-if-has-identical-blocks` [class=`rust-static-deadness`, confidence=`low`, action=`needs-ablation-before-delete`, blocking=`false`]: `kernel/src/lifecycle_program.rs:42640`
  Rust deadness signal from clippy
- `rh-clippy-kernel-src-lifecycle-program-rs-43506-used-assert-eq-with-a-literal-bool` [class=`rust-static-deadness`, confidence=`low`, action=`needs-ablation-before-delete`, blocking=`false`]: `kernel/src/lifecycle_program.rs:43506`
  Rust deadness signal from clippy
- `rh-clippy-kernel-src-lifecycle-program-rs-35759-useless-use-of-vec-help-you-can-use-an-array-directly-index-ref-published-health-pruned-health` [class=`rust-static-deadness`, confidence=`low`, action=`needs-ablation-before-delete`, blocking=`false`]: `kernel/src/lifecycle_program.rs:35759`
  Rust deadness signal from clippy
- `rh-machete-analyzing-dependencies-of-crates-in-this-directory` [class=`rust-dependency-deadness`, confidence=`medium`, action=`needs-ablation-before-delete`, blocking=`false`]: `.octon/framework/engine/runtime/crates/Cargo.toml`
  Rust dependency deadness candidate
- `rh-machete-cargo-machete-found-the-following-unused-dependencies-in-this-directory` [class=`rust-dependency-deadness`, confidence=`medium`, action=`needs-ablation-before-delete`, blocking=`false`]: `.octon/framework/engine/runtime/crates/Cargo.toml`
  Rust dependency deadness candidate
- `rh-machete-octon-studio-studio-cargo-toml` [class=`rust-dependency-deadness`, confidence=`medium`, action=`needs-ablation-before-delete`, blocking=`false`]: `.octon/framework/engine/runtime/crates/Cargo.toml`
  Rust dependency deadness candidate
- `rh-machete-walkdir` [class=`rust-dependency-deadness`, confidence=`medium`, action=`needs-ablation-before-delete`, blocking=`false`]: `.octon/framework/engine/runtime/crates/Cargo.toml`
  Rust dependency deadness candidate
- `rh-machete-octon-telemetry-sink-telemetry-sink-cargo-toml` [class=`rust-dependency-deadness`, confidence=`medium`, action=`needs-ablation-before-delete`, blocking=`false`]: `.octon/framework/engine/runtime/crates/Cargo.toml`
  Rust dependency deadness candidate
- `rh-machete-thiserror` [class=`rust-dependency-deadness`, confidence=`medium`, action=`needs-ablation-before-delete`, blocking=`false`]: `.octon/framework/engine/runtime/crates/Cargo.toml`
  Rust dependency deadness candidate
- `rh-machete-octon-authority-engine-authority-engine-cargo-toml` [class=`rust-dependency-deadness`, confidence=`medium`, action=`needs-ablation-before-delete`, blocking=`false`]: `.octon/framework/engine/runtime/crates/Cargo.toml`
  Rust dependency deadness candidate
- `rh-machete-octon-wasm-host` [class=`rust-dependency-deadness`, confidence=`medium`, action=`needs-ablation-before-delete`, blocking=`false`]: `.octon/framework/engine/runtime/crates/Cargo.toml`
  Rust dependency deadness candidate
- `rh-machete-octon-runtime-resolver-runtime-resolver-cargo-toml` [class=`rust-dependency-deadness`, confidence=`medium`, action=`needs-ablation-before-delete`, blocking=`false`]: `.octon/framework/engine/runtime/crates/Cargo.toml`
  Rust dependency deadness candidate
- `rh-machete-serde-json` [class=`rust-dependency-deadness`, confidence=`medium`, action=`needs-ablation-before-delete`, blocking=`false`]: `.octon/framework/engine/runtime/crates/Cargo.toml`
  Rust dependency deadness candidate
- `rh-machete-octon-wasm-host-wasm-host-cargo-toml` [class=`rust-dependency-deadness`, confidence=`medium`, action=`needs-ablation-before-delete`, blocking=`false`]: `.octon/framework/engine/runtime/crates/Cargo.toml`
  Rust dependency deadness candidate
- `rh-machete-serde` [class=`rust-dependency-deadness`, confidence=`medium`, action=`needs-ablation-before-delete`, blocking=`false`]: `.octon/framework/engine/runtime/crates/Cargo.toml`
  Rust dependency deadness candidate
- `rh-machete-wit-bindgen` [class=`rust-dependency-deadness`, confidence=`medium`, action=`needs-ablation-before-delete`, blocking=`false`]: `.octon/framework/engine/runtime/crates/Cargo.toml`
  Rust dependency deadness candidate
- `rh-machete-wit-bindgen-rt` [class=`rust-dependency-deadness`, confidence=`medium`, action=`needs-ablation-before-delete`, blocking=`false`]: `.octon/framework/engine/runtime/crates/Cargo.toml`
  Rust dependency deadness candidate
- `rh-machete-policy-engine-policy-engine-cargo-toml` [class=`rust-dependency-deadness`, confidence=`medium`, action=`needs-ablation-before-delete`, blocking=`false`]: `.octon/framework/engine/runtime/crates/Cargo.toml`
  Rust dependency deadness candidate
- `rh-machete-thiserror` [class=`rust-dependency-deadness`, confidence=`medium`, action=`needs-ablation-before-delete`, blocking=`false`]: `.octon/framework/engine/runtime/crates/Cargo.toml`
  Rust dependency deadness candidate
- `rh-machete-octon-kernel-kernel-cargo-toml` [class=`rust-dependency-deadness`, confidence=`medium`, action=`needs-ablation-before-delete`, blocking=`false`]: `.octon/framework/engine/runtime/crates/Cargo.toml`
  Rust dependency deadness candidate
- `rh-machete-thiserror` [class=`rust-dependency-deadness`, confidence=`medium`, action=`needs-ablation-before-delete`, blocking=`false`]: `.octon/framework/engine/runtime/crates/Cargo.toml`
  Rust dependency deadness candidate
- `rh-machete-if-you-believe-cargo-machete-has-detected-an-unused-dependency-incorrectly` [class=`rust-dependency-deadness`, confidence=`medium`, action=`needs-ablation-before-delete`, blocking=`false`]: `.octon/framework/engine/runtime/crates/Cargo.toml`
  Rust dependency deadness candidate
- `rh-machete-you-can-add-the-dependency-to-the-list-of-dependencies-to-ignore-in-the` [class=`rust-dependency-deadness`, confidence=`medium`, action=`needs-ablation-before-delete`, blocking=`false`]: `.octon/framework/engine/runtime/crates/Cargo.toml`
  Rust dependency deadness candidate
- `rh-machete-package-metadata-cargo-machete-section-of-the-appropriate-cargo-toml` [class=`rust-dependency-deadness`, confidence=`medium`, action=`needs-ablation-before-delete`, blocking=`false`]: `.octon/framework/engine/runtime/crates/Cargo.toml`
  Rust dependency deadness candidate
- `rh-machete-for-example` [class=`rust-dependency-deadness`, confidence=`medium`, action=`needs-ablation-before-delete`, blocking=`false`]: `.octon/framework/engine/runtime/crates/Cargo.toml`
  Rust dependency deadness candidate
- `rh-machete-package-metadata-cargo-machete` [class=`rust-dependency-deadness`, confidence=`medium`, action=`needs-ablation-before-delete`, blocking=`false`]: `.octon/framework/engine/runtime/crates/Cargo.toml`
  Rust dependency deadness candidate
- `rh-machete-ignored-prost` [class=`rust-dependency-deadness`, confidence=`medium`, action=`needs-ablation-before-delete`, blocking=`false`]: `.octon/framework/engine/runtime/crates/Cargo.toml`
  Rust dependency deadness candidate
- `rh-machete-you-can-also-try-running-it-with-the-with-metadata-flag-for-better-accuracy` [class=`rust-dependency-deadness`, confidence=`medium`, action=`needs-ablation-before-delete`, blocking=`false`]: `.octon/framework/engine/runtime/crates/Cargo.toml`
  Rust dependency deadness candidate
- `rh-machete-though-this-may-modify-your-cargo-lock-files` [class=`rust-dependency-deadness`, confidence=`medium`, action=`needs-ablation-before-delete`, blocking=`false`]: `.octon/framework/engine/runtime/crates/Cargo.toml`
  Rust dependency deadness candidate
- `rh-machete-done` [class=`rust-dependency-deadness`, confidence=`medium`, action=`needs-ablation-before-delete`, blocking=`false`]: `.octon/framework/engine/runtime/crates/Cargo.toml`
  Rust dependency deadness candidate
- `rh-udeps-unused-dependencies` [class=`rust-dependency-deadness`, confidence=`medium`, action=`needs-ablation-before-delete`, blocking=`false`]: `.octon/framework/engine/runtime/crates/Cargo.toml`
  Rust dependency deadness candidate
- `rh-generated-materialized-rebuild-root` [class=`artifact-bloat`, confidence=`low`, action=`needs-ablation-before-delete`, blocking=`false`]: `.octon/generated/cognition/projections/materialized/**`
  Rebuild-by-default materialized projections remain tracked
