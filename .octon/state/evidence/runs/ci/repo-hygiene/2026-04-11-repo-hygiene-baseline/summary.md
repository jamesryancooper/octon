# Repo Hygiene Audit

- Audit id: `2026-04-11-repo-hygiene-baseline`
- Generated at: `2026-04-11T16:42:09Z`
- Active release: `2026-04-11-uec-bounded-recertified-complete`
- Latest build-to-delete packet: `.octon/state/evidence/validation/publication/build-to-delete/2026-04-09-bounded-uec-hardening`
- Current governance review: `.octon/state/evidence/governance/build-to-delete/2026-04-09-bounded-uec-hardening/retirement-claim-review.yml`
- Host tool resolution: `host-tools.yml`
- Total findings: `123`
- Blocking findings: `0`
- Required detector failures: `0`

## Detector Status
- `git-ls-files`: `passed` (required=`true`, log=`.octon/state/evidence/runs/ci/repo-hygiene/2026-04-11-repo-hygiene-baseline/detectors/git-ls-files.log`)
- `find`: `passed` (required=`true`, log=`.octon/state/evidence/runs/ci/repo-hygiene/2026-04-11-repo-hygiene-baseline/detectors/find.log`)
- `reference-scan`: `passed` (required=`true`, log=`.octon/state/evidence/runs/ci/repo-hygiene/2026-04-11-repo-hygiene-baseline/detectors/reference-scan.log`)
- `cargo-check`: `passed` (required=`true`, log=`.octon/state/evidence/runs/ci/repo-hygiene/2026-04-11-repo-hygiene-baseline/detectors/cargo-check.log`)
- `cargo-clippy`: `passed` (required=`true`, log=`.octon/state/evidence/runs/ci/repo-hygiene/2026-04-11-repo-hygiene-baseline/detectors/cargo-clippy.log`)
- `cargo-machete`: `passed` (required=`true`, log=`.octon/state/evidence/runs/ci/repo-hygiene/2026-04-11-repo-hygiene-baseline/detectors/cargo-machete.log`)
  notes: cargo-machete reported candidate unused dependencies
- `cargo-udeps`: `passed` (required=`true`, log=`.octon/state/evidence/runs/ci/repo-hygiene/2026-04-11-repo-hygiene-baseline/detectors/cargo-udeps.log`)
  notes: cargo-udeps reported candidate unused dependencies
- `shellcheck`: `passed` (required=`true`, log=`.octon/state/evidence/runs/ci/repo-hygiene/2026-04-11-repo-hygiene-baseline/detectors/shellcheck.log`)
  notes: shellcheck reported lint findings
- `bash-syntax`: `passed` (required=`true`, log=`.octon/state/evidence/runs/ci/repo-hygiene/2026-04-11-repo-hygiene-baseline/detectors/bash-syntax.log`)
- `sh-syntax`: `passed` (required=`true`, log=`.octon/state/evidence/runs/ci/repo-hygiene/2026-04-11-repo-hygiene-baseline/detectors/sh-syntax.log`)

## Findings
- `rh-clippy-core-src-execution-integrity-rs-871-manually-reimplementing-div-ceil-help-consider-using-div-ceil-prompt-bytes-max-1-div-ceil-4` [class=`rust-static-deadness`, confidence=`low`, action=`needs-ablation-before-delete`, blocking=`false`]: `core/src/execution_integrity.rs:871`
  Rust deadness signal from clippy
- `rh-clippy-core-src-execution-integrity-rs-1026-using-contains-instead-of-iter-any-is-more-efficient-help-try-rule-ports-contains-target-port` [class=`rust-static-deadness`, confidence=`low`, action=`needs-ablation-before-delete`, blocking=`false`]: `core/src/execution_integrity.rs:1026`
  Rust deadness signal from clippy
- `rh-clippy-core-src-jsonlines-rs-20-needless-call-to-as-bytes-help-len-can-be-called-directly-on-strings-line-len` [class=`rust-static-deadness`, confidence=`low`, action=`needs-ablation-before-delete`, blocking=`false`]: `core/src/jsonlines.rs:20`
  Rust deadness signal from clippy
- `rh-clippy-core-src-orchestration-rs-998-this-filter-map-can-be-written-more-simply-using-map` [class=`rust-static-deadness`, confidence=`low`, action=`needs-ablation-before-delete`, blocking=`false`]: `core/src/orchestration.rs:998`
  Rust deadness signal from clippy
- `rh-clippy-core-src-orchestration-rs-1758-the-borrowed-expression-implements-the-required-traits-help-change-this-to-missions-dir` [class=`rust-static-deadness`, confidence=`low`, action=`needs-ablation-before-delete`, blocking=`false`]: `core/src/orchestration.rs:1758`
  Rust deadness signal from clippy
- `rh-clippy-core-src-orchestration-rs-1758-this-expression-creates-a-reference-which-is-immediately-dereferenced-by-the-compiler-help-change-this-to-missions-dir` [class=`rust-static-deadness`, confidence=`low`, action=`needs-ablation-before-delete`, blocking=`false`]: `core/src/orchestration.rs:1758`
  Rust deadness signal from clippy
- `rh-clippy-core-src-orchestration-rs-1760-this-expression-creates-a-reference-which-is-immediately-dereferenced-by-the-compiler-help-change-this-to-missions-dir` [class=`rust-static-deadness`, confidence=`low`, action=`needs-ablation-before-delete`, blocking=`false`]: `core/src/orchestration.rs:1760`
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
- `rh-clippy-policy-engine-src-lib-rs-560-this-impl-can-be-derived` [class=`rust-static-deadness`, confidence=`low`, action=`needs-ablation-before-delete`, blocking=`false`]: `policy_engine/src/lib.rs:560`
  Rust deadness signal from clippy
- `rh-clippy-policy-engine-src-lib-rs-2081-this-boolean-expression-can-be-simplified` [class=`rust-static-deadness`, confidence=`low`, action=`needs-ablation-before-delete`, blocking=`false`]: `policy_engine/src/lib.rs:2081`
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
- `rh-clippy-authority-engine-src-implementation-rs-860-field-tuple-id-is-never-read` [class=`rust-static-deadness`, confidence=`low`, action=`needs-ablation-before-delete`, blocking=`false`]: `authority_engine/src/implementation.rs:860`
  Rust deadness signal from clippy
- `rh-clippy-authority-engine-src-implementation-rs-3217-this-function-has-too-many-arguments-8-7` [class=`rust-static-deadness`, confidence=`low`, action=`needs-ablation-before-delete`, blocking=`false`]: `authority_engine/src/implementation.rs:3217`
  Rust deadness signal from clippy
- `rh-clippy-authority-engine-src-implementation-rs-3888-this-function-has-too-many-arguments-13-7` [class=`rust-static-deadness`, confidence=`low`, action=`needs-ablation-before-delete`, blocking=`false`]: `authority_engine/src/implementation.rs:3888`
  Rust deadness signal from clippy
- `rh-clippy-authority-engine-src-implementation-rs-4198-this-if-statement-can-be-collapsed` [class=`rust-static-deadness`, confidence=`low`, action=`needs-ablation-before-delete`, blocking=`false`]: `authority_engine/src/implementation.rs:4198`
  Rust deadness signal from clippy
- `rh-clippy-authority-engine-src-implementation-rs-6146-this-function-has-too-many-arguments-14-7` [class=`rust-static-deadness`, confidence=`low`, action=`needs-ablation-before-delete`, blocking=`false`]: `authority_engine/src/implementation.rs:6146`
  Rust deadness signal from clippy
- `rh-clippy-authority-engine-src-implementation-rs-6523-this-function-has-too-many-arguments-14-7` [class=`rust-static-deadness`, confidence=`low`, action=`needs-ablation-before-delete`, blocking=`false`]: `authority_engine/src/implementation.rs:6523`
  Rust deadness signal from clippy
- `rh-clippy-authority-engine-src-implementation-rs-1915-useless-use-of-vec` [class=`rust-static-deadness`, confidence=`low`, action=`needs-ablation-before-delete`, blocking=`false`]: `authority_engine/src/implementation.rs:1915`
  Rust deadness signal from clippy
- `rh-clippy-wasm-host-src-kv-store-rs-190-used-assert-eq-with-a-literal-bool` [class=`rust-static-deadness`, confidence=`low`, action=`needs-ablation-before-delete`, blocking=`false`]: `wasm_host/src/kv_store.rs:190`
  Rust deadness signal from clippy
- `rh-clippy-core-src-orchestration-rs-2326-used-assert-eq-with-a-literal-bool` [class=`rust-static-deadness`, confidence=`low`, action=`needs-ablation-before-delete`, blocking=`false`]: `core/src/orchestration.rs:2326`
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
- `rh-clippy-kernel-src-pipeline-rs-845-needless-call-to-as-bytes-help-len-can-be-called-directly-on-strings-rendered-len` [class=`rust-static-deadness`, confidence=`low`, action=`needs-ablation-before-delete`, blocking=`false`]: `kernel/src/pipeline.rs:845`
  Rust deadness signal from clippy
- `rh-clippy-kernel-src-workflow-rs-608-this-function-has-too-many-arguments-15-7` [class=`rust-static-deadness`, confidence=`low`, action=`needs-ablation-before-delete`, blocking=`false`]: `kernel/src/workflow.rs:608`
  Rust deadness signal from clippy
- `rh-clippy-kernel-src-workflow-rs-3646-needless-call-to-as-bytes-help-len-can-be-called-directly-on-strings-prompt-markdown-len` [class=`rust-static-deadness`, confidence=`low`, action=`needs-ablation-before-delete`, blocking=`false`]: `kernel/src/workflow.rs:3646`
  Rust deadness signal from clippy
- `rh-clippy-kernel-src-workflow-rs-3726-field-assignment-outside-of-initializer-for-an-instance-created-with-default-default` [class=`rust-static-deadness`, confidence=`low`, action=`needs-ablation-before-delete`, blocking=`false`]: `kernel/src/workflow.rs:3726`
  Rust deadness signal from clippy
- `rh-clippy-kernel-src-workflow-rs-5095-this-function-has-too-many-arguments-10-7` [class=`rust-static-deadness`, confidence=`low`, action=`needs-ablation-before-delete`, blocking=`false`]: `kernel/src/workflow.rs:5095`
  Rust deadness signal from clippy
- `rh-clippy-studio-src-app-state-rs-103-all-variants-have-the-same-postfix-id` [class=`rust-static-deadness`, confidence=`low`, action=`needs-ablation-before-delete`, blocking=`false`]: `studio/src/app_state.rs:103`
  Rust deadness signal from clippy
- `rh-clippy-studio-src-app-state-rs-1462-unneeded-return-statement` [class=`rust-static-deadness`, confidence=`low`, action=`needs-ablation-before-delete`, blocking=`false`]: `studio/src/app_state.rs:1462`
  Rust deadness signal from clippy
- `rh-clippy-studio-src-app-state-rs-1540-unneeded-return-statement` [class=`rust-static-deadness`, confidence=`low`, action=`needs-ablation-before-delete`, blocking=`false`]: `studio/src/app_state.rs:1540`
  Rust deadness signal from clippy
- `rh-machete-analyzing-dependencies-of-crates-in-this-directory` [class=`rust-dependency-deadness`, confidence=`medium`, action=`needs-ablation-before-delete`, blocking=`false`]: `.octon/framework/engine/runtime/crates/Cargo.toml`
  Rust dependency deadness candidate
- `rh-machete-cargo-machete-found-the-following-unused-dependencies-in-this-directory` [class=`rust-dependency-deadness`, confidence=`medium`, action=`needs-ablation-before-delete`, blocking=`false`]: `.octon/framework/engine/runtime/crates/Cargo.toml`
  Rust dependency deadness candidate
- `rh-machete-octon-studio-studio-cargo-toml` [class=`rust-dependency-deadness`, confidence=`medium`, action=`needs-ablation-before-delete`, blocking=`false`]: `.octon/framework/engine/runtime/crates/Cargo.toml`
  Rust dependency deadness candidate
- `rh-machete-walkdir` [class=`rust-dependency-deadness`, confidence=`medium`, action=`needs-ablation-before-delete`, blocking=`false`]: `.octon/framework/engine/runtime/crates/Cargo.toml`
  Rust dependency deadness candidate
- `rh-machete-octon-authority-engine-authority-engine-cargo-toml` [class=`rust-dependency-deadness`, confidence=`medium`, action=`needs-ablation-before-delete`, blocking=`false`]: `.octon/framework/engine/runtime/crates/Cargo.toml`
  Rust dependency deadness candidate
- `rh-machete-octon-wasm-host` [class=`rust-dependency-deadness`, confidence=`medium`, action=`needs-ablation-before-delete`, blocking=`false`]: `.octon/framework/engine/runtime/crates/Cargo.toml`
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
