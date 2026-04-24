#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
DEFAULT_ROOT="$(cd -- "$SCRIPT_DIR/../../../../../.." && pwd)"
ROOT_DIR="${OCTON_ROOT_DIR:-$DEFAULT_ROOT}"
CONTRACT_ROOT="${OCTON_CONTRACT_ROOT:-$DEFAULT_ROOT}"
source "$SCRIPT_DIR/validator-result-common.sh"

PACK_PATH=""
RECEIPT_PATH=""
REPLAY_PATH=""
errors=0

usage() {
  cat <<'EOF'
Usage: validate-context-pack-builder.sh --pack <path> --receipt <path> [--root <repo-root>] [--replay <path>]

Validates a context-pack-v1 artifact against a context-pack-builder-v1 receipt.
All relative paths are resolved from --root. No proposal-local paths are assumed.
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --root)
      ROOT_DIR="$2"
      shift 2
      ;;
    --pack)
      PACK_PATH="$2"
      shift 2
      ;;
    --receipt)
      RECEIPT_PATH="$2"
      shift 2
      ;;
    --replay)
      REPLAY_PATH="$2"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "[ERROR] unknown argument: $1" >&2
      usage >&2
      exit 2
      ;;
  esac
done

fail() {
  echo "[ERROR] $1"
  errors=$((errors + 1))
}

pass() {
  echo "[OK] $1"
}

resolve_path() {
  local path="$1"
  if [[ "$path" = /* ]]; then
    printf '%s\n' "$path"
  else
    printf '%s/%s\n' "$ROOT_DIR" "$path"
  fi
}

contract_path() {
  printf '%s/%s\n' "$CONTRACT_ROOT" "$1"
}

repo_rel() {
  local path="$1"
  if [[ "$path" = "$ROOT_DIR/"* ]]; then
    printf '%s\n' "${path#"$ROOT_DIR/"}"
  else
    printf '%s\n' "$path"
  fi
}

sha256_file() {
  shasum -a 256 "$1" | awk '{print "sha256:" $1}'
}

sha256_lines() {
  shasum -a 256 | awk '{print "sha256:" $1}'
}

now_rfc3339() {
  date -u '+%Y-%m-%dT%H:%M:%SZ'
}

source_class() {
  case "$1" in
    .octon/framework/*|.octon/instance/*|.octon/state/*) printf 'authority\n' ;;
    .octon/generated/cognition/projections/materialized/*) printf 'generated_read_model\n' ;;
    .octon/generated/*) printf 'generated\n' ;;
    .octon/inputs/*) printf 'raw_input\n' ;;
    *) printf 'other\n' ;;
  esac
}

canonical_input_sha() {
  local receipt="$1"
  yq -r '.input_refs[]? // ""' "$receipt" | sed '/^$/d' | LC_ALL=C sort -u | sha256_lines
}

input_count() {
  yq -r '.input_refs[]? // ""' "$1" | sed '/^$/d' | wc -l | tr -d ' '
}

unique_input_count() {
  yq -r '.input_refs[]? // ""' "$1" | sed '/^$/d' | LC_ALL=C sort -u | wc -l | tr -d ' '
}

check_durable_surfaces() {
  local path target
  for path in \
    ".octon/framework/constitution/contracts/runtime/context-pack-v1.schema.json" \
    ".octon/framework/constitution/contracts/runtime/instruction-layer-manifest-v2.schema.json" \
    ".octon/framework/engine/runtime/spec/context-pack-builder-v1.md" \
    ".octon/framework/engine/runtime/spec/context-pack-receipt-v1.schema.json" \
    ".octon/framework/engine/runtime/spec/execution-request-v3.schema.json" \
    ".octon/framework/engine/runtime/spec/execution-grant-v1.schema.json" \
    ".octon/framework/engine/runtime/spec/execution-receipt-v3.schema.json" \
    ".octon/framework/engine/runtime/spec/runtime-event-v1.schema.json" \
    ".octon/framework/constitution/contracts/runtime/run-event-v2.schema.json" \
    ".octon/instance/governance/policies/context-packing.yml"; do
    target="$(contract_path "$path")"
    [[ -f "$target" ]] && pass "durable context authority exists: $path" || fail "durable context authority missing: $path"
  done

  require_contains_contract ".octon/framework/constitution/contracts/runtime/context-pack-v1.schema.json" "model_visible_context_sha256" "context-pack schema binds model-visible hash"
  require_contains_contract ".octon/framework/constitution/contracts/runtime/context-pack-v1.schema.json" "model_visible_context_ref" "context-pack schema binds model-visible serialization ref"
  require_contains_contract ".octon/framework/constitution/contracts/runtime/context-pack-v1.schema.json" "omissions" "context-pack schema records omissions"
  require_contains_contract ".octon/framework/constitution/contracts/runtime/context-pack-v1.schema.json" "redactions" "context-pack schema records redactions"
  require_contains_contract ".octon/framework/constitution/contracts/runtime/context-pack-v1.schema.json" "validity_state" "context-pack schema records validity state"
  require_contains_contract ".octon/framework/constitution/contracts/runtime/instruction-layer-manifest-v2.schema.json" "context_pack_receipt_ref" "instruction manifest binds context receipt"
  require_contains_contract ".octon/framework/constitution/contracts/runtime/instruction-layer-manifest-v2.schema.json" "model_visible_context_ref" "instruction manifest binds model-visible serialization ref"
  require_contains_contract ".octon/framework/constitution/contracts/runtime/instruction-layer-manifest-v2.schema.json" "model_visible_context_sha256" "instruction manifest binds model-visible hash"
  require_contains_contract ".octon/framework/engine/runtime/spec/execution-request-v3.schema.json" "context_pack_receipt_ref" "execution request binds context receipt"
  require_contains_contract ".octon/framework/engine/runtime/spec/execution-request-v3.schema.json" "model_visible_context_ref" "execution request binds model-visible serialization ref"
  require_contains_contract ".octon/framework/engine/runtime/spec/execution-grant-v1.schema.json" "context_pack_receipt_ref" "execution grant binds context receipt"
  require_contains_contract ".octon/framework/engine/runtime/spec/execution-grant-v1.schema.json" "model_visible_context_ref" "execution grant binds model-visible serialization ref"
  require_contains_contract ".octon/framework/engine/runtime/spec/execution-receipt-v3.schema.json" "context_pack_receipt_ref" "execution receipt binds context receipt"
  require_contains_contract ".octon/framework/engine/runtime/spec/execution-receipt-v3.schema.json" "model_visible_context_ref" "execution receipt binds model-visible serialization ref"
  require_contains_contract ".octon/framework/engine/runtime/spec/runtime-event-v1.schema.json" "run.context_pack_requested" "runtime events include context pack requested"
  require_contains_contract ".octon/framework/engine/runtime/spec/runtime-event-v1.schema.json" "run.context_pack_built" "runtime events include context pack built"
  require_contains_contract ".octon/framework/engine/runtime/spec/runtime-event-v1.schema.json" "run.context_pack_bound" "runtime events include context pack bound"
  require_contains_contract ".octon/framework/engine/runtime/spec/runtime-event-v1.schema.json" "run.context_pack_invalidated" "runtime events include context pack invalidated"
  require_contains_contract ".octon/framework/constitution/contracts/runtime/run-event-v2.schema.json" "context-pack-requested" "canonical run events include context-pack-requested"
  require_contains_contract ".octon/framework/constitution/contracts/runtime/run-event-v2.schema.json" "context-pack-built" "canonical run events include context-pack-built"
  require_contains_contract ".octon/framework/constitution/contracts/runtime/run-event-v2.schema.json" "context-pack-bound" "canonical run events include context-pack-bound"
  require_contains_contract ".octon/framework/constitution/contracts/runtime/run-event-v2.schema.json" "context-pack-rejected" "canonical run events include context-pack-rejected"
  require_contains_contract ".octon/framework/constitution/contracts/runtime/run-event-v2.schema.json" "context-pack-compacted" "canonical run events include context-pack-compacted"
  require_contains_contract ".octon/framework/constitution/contracts/runtime/run-event-v2.schema.json" "context-pack-invalidated" "canonical run events include context-pack-invalidated"
  require_contains_contract ".octon/framework/constitution/contracts/runtime/run-event-v2.schema.json" "context-pack-rebuilt" "canonical run events include context-pack-rebuilt"
  require_contains_contract ".octon/instance/governance/support-targets.yml" "context-pack-receipt" "support-target evidence includes context pack receipt"

  for path in \
    ".octon/framework/constitution/contracts/runtime/context-pack-v1.schema.json" \
    ".octon/framework/constitution/contracts/runtime/instruction-layer-manifest-v2.schema.json" \
    ".octon/framework/engine/runtime/spec/context-pack-builder-v1.md" \
    ".octon/framework/engine/runtime/spec/context-pack-receipt-v1.schema.json" \
    ".octon/framework/engine/runtime/spec/execution-request-v3.schema.json" \
    ".octon/framework/engine/runtime/spec/execution-grant-v1.schema.json" \
    ".octon/framework/engine/runtime/spec/execution-receipt-v3.schema.json" \
    ".octon/framework/engine/runtime/spec/runtime-event-v1.schema.json" \
    ".octon/framework/constitution/contracts/runtime/run-event-v2.schema.json" \
    ".octon/framework/engine/runtime/README.md"; do
    target="$(contract_path "$path")"
    if [[ -f "$target" ]] && grep -Fq '.octon/inputs/exploratory' "$target"; then
      fail "durable runtime surface depends on proposal-local path: $path"
    else
      pass "durable runtime surface has no proposal-local dependency: $path"
    fi
  done
  require_contains_contract ".octon/instance/governance/policies/context-packing.yml" ".octon/inputs/exploratory/**" "context policy classifies exploratory inputs"
  require_contains_contract ".octon/instance/governance/policies/context-packing.yml" "never use as support, runtime, or policy authority" "context policy denies exploratory runtime dependency"

  if grep -R 'run\.context_pack_' "$CONTRACT_ROOT/.octon/framework/engine/runtime/crates/authority_engine/src/implementation/execution.rs" >/dev/null 2>&1; then
    fail "authority engine canonical journal writer emits dot-named context-pack events"
  else
    pass "authority engine journal writer uses canonical context-pack event names"
  fi
}

require_contains_contract() {
  local rel="$1"
  local needle="$2"
  local label="$3"
  local target
  target="$(contract_path "$rel")"
  if [[ -f "$target" ]] && grep -Fq "$needle" "$target"; then
    pass "$label"
  else
    fail "$label"
  fi
}

check_required_files() {
  [[ -n "$PACK_PATH" ]] || fail "missing --pack"
  [[ -n "$RECEIPT_PATH" ]] || fail "missing --receipt"

  [[ -n "$PACK_PATH" && -f "$(resolve_path "$PACK_PATH")" ]] \
    && pass "context pack present" \
    || fail "context pack missing"
  [[ -n "$RECEIPT_PATH" && -f "$(resolve_path "$RECEIPT_PATH")" ]] \
    && pass "builder receipt present" \
    || fail "builder receipt missing"
}

check_pack_schema_and_authority() {
  local pack="$1"
  [[ "$(yq -r '.schema_version // ""' "$pack")" == "context-pack-v1" ]] \
    && pass "context pack schema version valid" \
    || fail "context pack schema version invalid"

  local path label class inclusion_mode bytes_included has_model_visible_content
  while IFS=$'\t' read -r path label inclusion_mode bytes_included has_model_visible_content; do
    [[ -n "$path" ]] || continue
    class="$(source_class "$path")"
    [[ "$label" == "authoritative" ]] \
      || fail "authority source must carry authoritative label: $path"
    if [[ "$inclusion_mode" == "full" && "$has_model_visible_content" != "true" ]]; then
      fail "authority source marked full without retained model-visible content: $path"
    elif [[ "$inclusion_mode" == "digest-only" && "$bytes_included" != "0" ]]; then
      fail "digest-only authority source must not claim included body bytes: $path"
    else
      pass "authority source inclusion mode is replayable: $path"
    fi
    case "$class" in
      authority)
        pass "authority source class allowed: $path"
        ;;
      generated_read_model)
        fail "generated read model cannot be an authority source: $path"
        ;;
      generated)
        fail "generated source class cannot be authority: $path"
        ;;
      raw_input)
        fail "raw input cannot be an authority source: $path"
        ;;
      *)
        fail "unknown source class cannot be authority: $path"
        ;;
    esac
  done < <(yq -r '.authority_sources[]? | [(.path // ""), (.authority_label // ""), (.inclusion_mode // ""), ((.bytes_included // 0) | tostring), (has("model_visible_content") | tostring)] | @tsv' "$pack")

  while IFS=$'\t' read -r path label; do
    [[ -n "$path" ]] || continue
    [[ "$label" == "derived" ]] \
      && pass "derived source label valid: $path" \
      || fail "derived source must carry derived label: $path"
  done < <(yq -r '.derived_sources[]? | [(.path // ""), (.authority_label // "")] | @tsv' "$pack")

  while IFS=$'\t' read -r path label; do
    [[ -n "$path" ]] || continue
    [[ "$label" == "non_authoritative" ]] \
      && pass "non-authoritative input label valid: $path" \
      || fail "raw input must carry non_authoritative label: $path"
  done < <(yq -r '.non_authoritative_inputs[]? | [(.path // ""), (.authority_label // "")] | @tsv' "$pack")
}

check_receipt() {
  local pack="$1"
  local receipt="$2"
  local pack_ref expected_pack_ref status invalidated schema

  schema="$(yq -r '.schema_version // ""' "$receipt")"
  [[ "$schema" == "context-pack-receipt-v1" || "$schema" == "context-pack-builder-receipt-v1" ]] \
    && pass "builder receipt schema version valid" \
    || fail "builder receipt schema version invalid: $schema"
  [[ "$(yq -r '.builder_version // ""' "$receipt")" == "context-pack-builder-v1" ]] \
    && pass "builder version valid" \
    || fail "builder version invalid"

  expected_pack_ref="$(repo_rel "$pack")"
  pack_ref="$(yq -r '.context_pack_ref // ""' "$receipt")"
  [[ "$pack_ref" == "$expected_pack_ref" ]] \
    && pass "receipt points at validated pack" \
    || fail "receipt context_pack_ref does not match pack path"

  if [[ "$schema" == "context-pack-receipt-v1" ]]; then
    local pack_run_id receipt_run_id request_id request_binding_id
    pack_run_id="$(yq -r '.run_id // ""' "$pack")"
    receipt_run_id="$(yq -r '.run_id // ""' "$receipt")"
    request_id="$(yq -r '.request_id // ""' "$receipt")"
    request_binding_id="$(yq -r '.request_binding.request_id // ""' "$receipt")"
    [[ -n "$pack_run_id" && "$receipt_run_id" == "$pack_run_id" && "$request_id" == "$pack_run_id" && "$request_binding_id" == "$pack_run_id" ]] \
      && pass "durable receipt binds the pack run/request identity" \
      || fail "durable receipt run/request binding mismatch"

    local receipt_policy pack_policy model_policy
    receipt_policy="$(yq -r '.context_policy_ref // ""' "$receipt")"
    pack_policy="$(yq -r '.context_policy_ref // ""' "$pack")"
    [[ -n "$receipt_policy" && "$pack_policy" == "$receipt_policy" ]] \
      && pass "durable receipt and pack bind the same context policy" \
      || fail "durable receipt policy ref mismatch"

    [[ "$(yq -r '.builder_spec_ref // ""' "$receipt")" == ".octon/framework/engine/runtime/spec/context-pack-builder-v1.md" ]] \
      && pass "durable receipt binds builder spec ref" \
      || fail "durable receipt builder spec ref mismatch"
    [[ "$(yq -r '.verification_status // ""' "$receipt")" == "valid" ]] \
      && pass "durable receipt verification status is valid" \
      || fail "durable receipt verification status is not valid"
    [[ "$(yq -r '.freshness.freshness_status // ""' "$receipt")" == "valid" ]] \
      && pass "durable receipt freshness status is valid" \
      || fail "durable receipt freshness status is not valid"
    local valid_until
    valid_until="$(yq -r '.freshness.valid_until // ""' "$receipt")"
    [[ -n "$valid_until" && "$valid_until" > "$(now_rfc3339)" ]] \
      && pass "durable receipt freshness window is current" \
      || fail "durable receipt freshness window expired"
    [[ "$(yq -r '.validity_state // ""' "$receipt")" == "valid" ]] \
      && pass "durable receipt validity state is valid" \
      || fail "durable receipt validity state is not valid"
    [[ "$(yq -r '.invalidation_state // ""' "$receipt")" == "not_invalidated" ]] \
      && pass "durable receipt is not invalidated" \
      || fail "durable receipt is invalidated"

    local total unique
    total="$(yq -r '.sources[]?.source_ref // ""' "$receipt" | sed '/^$/d' | wc -l | tr -d ' ')"
    unique="$(yq -r '.sources[]?.source_ref // ""' "$receipt" | sed '/^$/d' | LC_ALL=C sort -u | wc -l | tr -d ' ')"
    [[ "$total" -gt 0 ]] \
      && pass "durable receipt declares sources" \
      || fail "durable receipt declares no sources"
    [[ "$total" == "$unique" ]] \
      && pass "durable receipt sources are unique" \
      || fail "durable receipt contains duplicate sources"

    local expected_pack_sha actual_pack_sha
    expected_pack_sha="$(sha256_file "$pack")"
    actual_pack_sha="$(yq -r '.context_pack_sha256 // ""' "$receipt")"
    [[ "$actual_pack_sha" == "$expected_pack_sha" ]] \
      && pass "context pack digest matches durable receipt" \
      || fail "context pack digest mismatch"

    local pack_model_ref receipt_model_ref model_path model_hash_path declared_model_hash actual_model_hash retained_model_hash
    pack_model_ref="$(yq -r '.model_visible_context_ref // ""' "$pack")"
    receipt_model_ref="$(yq -r '.model_visible_context_ref // ""' "$receipt")"
    [[ -n "$receipt_model_ref" && "$receipt_model_ref" == "$pack_model_ref" ]] \
      && pass "durable pack and receipt bind the same model-visible serialization ref" \
      || fail "durable model-visible serialization ref mismatch"
    model_path="$(resolve_path "$receipt_model_ref")"
    [[ -f "$model_path" ]] \
      && pass "retained model-visible serialization exists" \
      || fail "retained model-visible serialization missing"
    if [[ -f "$model_path" ]]; then
      actual_model_hash="$(sha256_file "$model_path")"
      declared_model_hash="$(yq -r '.model_visible_context_sha256 // ""' "$receipt")"
      [[ "$declared_model_hash" =~ ^sha256:[a-fA-F0-9]{64}$ ]] \
        && pass "durable receipt binds model-visible context hash" \
        || fail "durable receipt model-visible context hash missing"
      [[ "$(yq -r '.model_visible_context_sha256 // ""' "$pack")" == "$actual_model_hash" ]] \
        && pass "pack model-visible hash matches retained serialization" \
        || fail "pack model-visible hash mismatch"
      [[ "$declared_model_hash" == "$actual_model_hash" ]] \
        && pass "receipt model-visible hash matches retained serialization" \
        || fail "receipt model-visible hash mismatch"
      model_hash_path="$(dirname "$model_path")/model-visible-context.sha256"
      if [[ -f "$model_hash_path" ]]; then
        retained_model_hash="$(tr -d '[:space:]' < "$model_hash_path")"
        [[ "$retained_model_hash" == "$actual_model_hash" ]] \
          && pass "retained model-visible hash file matches serialization" \
          || fail "retained model-visible hash file mismatch"
      else
        fail "retained model-visible hash file missing"
      fi
      [[ "$(yq -r '.schema_version // ""' "$model_path")" == "model-visible-context-v1" ]] \
        && pass "model-visible serialization schema valid" \
        || fail "model-visible serialization schema invalid"
      [[ "$(yq -r '.serialization_format // ""' "$model_path")" == "context-pack-builder-v1/model-visible-context-json" ]] \
        && pass "model-visible serialization format valid" \
        || fail "model-visible serialization format invalid"
      [[ "$(yq -r '.run_id // ""' "$model_path")" == "$pack_run_id" ]] \
        && pass "model-visible serialization binds run id" \
        || fail "model-visible serialization run id mismatch"
      model_policy="$(yq -r '.context_policy_ref // ""' "$model_path")"
      [[ "$model_policy" == "$receipt_policy" ]] \
        && pass "model-visible serialization binds context policy" \
        || fail "model-visible serialization policy mismatch"
    fi

    local ref_path
    for ref_key in source_manifest_ref omissions_ref redactions_ref invalidation_events_ref; do
      ref_path="$(yq -r ".${ref_key} // \"\"" "$receipt")"
      [[ -n "$ref_path" && -f "$(resolve_path "$ref_path")" ]] \
        && pass "durable receipt retained $ref_key exists" \
        || fail "durable receipt retained $ref_key missing"
    done

    local failed_required
    failed_required="$(yq -r '.source_summary.failed_required_source_count // "0"' "$receipt")"
    [[ "$failed_required" == "0" ]] \
      && pass "durable receipt has no failed required sources" \
      || fail "durable receipt has failed required sources"

    local path declared_sha actual_sha source_file required verification_status freshness_status
    while IFS=$'\t' read -r path declared_sha required verification_status freshness_status; do
      [[ -n "$path" ]] || continue
      if [[ "$required" == "true" && ( "$verification_status" != "valid" || "$freshness_status" != "valid" ) ]]; then
        fail "required durable receipt source is not valid and fresh: $path"
      fi
      source_file="$(resolve_path "$path")"
      if [[ ! -f "$source_file" ]]; then
        fail "durable receipt source missing: $path"
        continue
      fi
      actual_sha="$(sha256_file "$source_file")"
      [[ "$declared_sha" == "$actual_sha" ]] \
        && pass "durable receipt source digest current: $path" \
        || fail "durable receipt source digest stale: $path"
    done < <(yq -r '.sources[]? | [(.source_ref // ""), (.sha256 // ""), ((.required // false) | tostring), (.verification_status // ""), (.freshness_status // "")] | @tsv' "$receipt")
  else
    status="$(yq -r '.status // ""' "$receipt")"
    invalidated="$(yq -r '.invalidated // "false"' "$receipt")"
    [[ "$status" == "current" ]] \
      && pass "builder receipt status is current" \
      || fail "builder receipt is not current: $status"
    [[ "$invalidated" == "false" ]] \
      && pass "builder receipt is not invalidated" \
      || fail "builder receipt is invalidated"

    local total unique
    total="$(input_count "$receipt")"
    unique="$(unique_input_count "$receipt")"
    [[ "$total" -gt 0 ]] \
      && pass "builder receipt declares inputs" \
      || fail "builder receipt declares no inputs"
    [[ "$total" == "$unique" ]] \
      && pass "builder receipt inputs are unique" \
      || fail "builder receipt contains duplicate inputs"

    local expected_canonical actual_canonical
    expected_canonical="$(canonical_input_sha "$receipt")"
    actual_canonical="$(yq -r '.canonical_input_sha256 // ""' "$receipt")"
    [[ "$actual_canonical" == "$expected_canonical" ]] \
      && pass "canonical input digest is deterministic" \
      || fail "canonical input digest mismatch"

    local expected_pack_sha actual_pack_sha
    expected_pack_sha="$(sha256_file "$pack")"
    actual_pack_sha="$(yq -r '.output_context_pack_sha256 // ""' "$receipt")"
    [[ "$actual_pack_sha" == "$expected_pack_sha" ]] \
      && pass "output context pack digest matches receipt" \
      || fail "output context pack digest mismatch"

    local path declared_sha actual_sha source_file
    while IFS=$'\t' read -r path declared_sha; do
      [[ -n "$path" ]] || continue
      source_file="$(resolve_path "$path")"
      if [[ ! -f "$source_file" ]]; then
        fail "receipt source missing: $path"
        continue
      fi
      actual_sha="$(sha256_file "$source_file")"
      [[ "$declared_sha" == "$actual_sha" ]] \
        && pass "source digest current: $path" \
        || fail "source digest stale: $path"
    done < <(yq -r '.source_digests[]? | [(.path // ""), (.sha256 // "")] | @tsv' "$receipt")
  fi
}

check_replay() {
  local pack="$1"
  local receipt="$2"
  local replay="$3"
  local expected_pack_ref expected_pack_sha expected_canonical schema

  if [[ -z "$replay" ]]; then
    replay="$(yq -r '.replay_ref // ""' "$receipt")"
  fi
  schema="$(yq -r '.schema_version // ""' "$receipt")"
  if [[ "$schema" == "context-pack-receipt-v1" ]]; then
    local model_ref model_hash_ref model_path expected_model_visible actual_model_visible expected_pack_sha expected_pack_ref
    model_ref="$(yq -r '.model_visible_context_ref // ""' "$receipt")"
    model_hash_ref="$(dirname "$model_ref")/model-visible-context.sha256"
    model_path="$(resolve_path "$model_ref")"
    expected_model_visible="$(yq -r '.model_visible_context_sha256 // ""' "$receipt")"
    expected_pack_ref="$(repo_rel "$pack")"
    expected_pack_sha="$(sha256_file "$pack")"

    yq -r '.replay_reconstruction_refs[]? // ""' "$receipt" | grep -Fx "$model_ref" >/dev/null \
      && pass "durable replay refs include model-visible serialization" \
      || fail "durable replay refs missing model-visible serialization"
    yq -r '.replay_reconstruction_refs[]? // ""' "$receipt" | grep -Fx "$model_hash_ref" >/dev/null \
      && pass "durable replay refs include model-visible hash file" \
      || fail "durable replay refs missing model-visible hash file"

    if [[ -f "$model_path" ]]; then
      actual_model_visible="$(sha256_file "$model_path")"
      [[ "$actual_model_visible" == "$expected_model_visible" ]] \
        && pass "retained model-visible serialization reconstructs model-visible context hash" \
        || fail "retained model-visible serialization hash mismatch"
    else
      fail "durable replay model-visible serialization missing"
    fi

    [[ -n "$replay" ]] || {
      pass "durable receipt replayable from retained model-visible serialization without event fixture"
      return 0
    }

    replay="$(resolve_path "$replay")"
    [[ -f "$replay" ]] || {
      fail "builder replay missing"
      return 0
    }

    if jq -r '.event_type // empty' "$replay" | grep -q '^run\.context_pack_'; then
      fail "canonical replay contains dot-named context-pack event"
    else
      pass "canonical replay contains no dot-named context-pack events"
    fi
    jq -e 'select(.event_type == "context-pack-requested")' "$replay" >/dev/null \
      && pass "replay includes context-pack-requested" \
      || fail "replay missing context-pack-requested"
    jq -e 'select(.event_type == "context-pack-built")' "$replay" >/dev/null \
      && pass "replay includes context-pack-built" \
      || fail "replay missing context-pack-built"
    jq -e 'select(.event_type == "context-pack-bound")' "$replay" >/dev/null \
      && pass "replay includes context-pack-bound" \
      || fail "replay missing context-pack-bound"

    local replay_pack_ref replay_pack_sha replay_model_hash
    replay_pack_ref="$(jq -r 'select(.event_type == "context-pack-built") | .payload.context_pack_ref // ""' "$replay" | tail -1)"
    replay_pack_sha="$(jq -r 'select(.event_type == "context-pack-bound") | .payload.context_pack_sha256 // ""' "$replay" | tail -1)"
    replay_model_hash="$(jq -r 'select(.event_type == "context-pack-built") | .payload.model_visible_context_sha256 // ""' "$replay" | tail -1)"
    [[ "$replay_pack_ref" == "$expected_pack_ref" ]] \
      && pass "replay reconstructs durable context pack ref" \
      || fail "replay durable context pack ref mismatch"
    [[ "$replay_pack_sha" == "$expected_pack_sha" ]] \
      && pass "replay reconstructs durable context pack digest" \
      || fail "replay durable context pack digest mismatch"
    [[ "$replay_model_hash" == "$expected_model_visible" ]] \
      && pass "replay reconstructs durable model-visible hash" \
      || fail "replay durable model-visible hash mismatch"
    return 0
  fi
  [[ -n "$replay" ]] || {
    fail "builder replay reference missing"
    return 0
  }

  replay="$(resolve_path "$replay")"
  [[ -f "$replay" ]] || {
    fail "builder replay missing"
    return 0
  }

  expected_pack_ref="$(repo_rel "$pack")"
  expected_pack_sha="$(sha256_file "$pack")"
  expected_canonical="$(canonical_input_sha "$receipt")"

  jq -e 'select(.event_type == "context-pack-requested")' "$replay" >/dev/null \
    && pass "replay includes context-pack-requested" \
    || fail "replay missing context-pack-requested"
  jq -e 'select(.event_type == "context-pack-built")' "$replay" >/dev/null \
    && pass "replay includes context-pack-built" \
    || fail "replay missing context-pack-built"
  jq -e 'select(.event_type == "context-pack-bound")' "$replay" >/dev/null \
    && pass "replay includes context-pack-bound" \
    || fail "replay missing context-pack-bound"

  local replay_pack_ref replay_pack_sha replay_canonical
  replay_pack_ref="$(jq -r 'select(.event_type == "context-pack-built") | .payload.context_pack_ref // ""' "$replay" | tail -1)"
  replay_pack_sha="$(jq -r 'select(.event_type == "context-pack-bound") | .payload.context_pack_sha256 // ""' "$replay" | tail -1)"
  replay_canonical="$(jq -r 'select(.event_type == "context-pack-built") | .payload.source_refs[]? // empty' "$replay" | LC_ALL=C sort -u | sha256_lines)"

  [[ "$replay_pack_ref" == "$expected_pack_ref" ]] \
    && pass "replay reconstructs context pack ref" \
    || fail "replay context pack ref mismatch"
  [[ "$replay_pack_sha" == "$expected_pack_sha" ]] \
    && pass "replay reconstructs context pack digest" \
    || fail "replay context pack digest mismatch"
  [[ "$replay_canonical" == "$expected_canonical" ]] \
    && pass "replay reconstructs canonical inputs" \
    || fail "replay canonical input mismatch"
}

reset_validator_result_metadata
validator_result_add_contract ".octon/framework/constitution/contracts/runtime/context-pack-v1.schema.json"
validator_result_add_contract ".octon/framework/engine/runtime/spec/context-pack-receipt-v1.schema.json"
validator_result_add_schema_version "context-pack-v1" "context-pack-receipt-v1" "context-pack-builder-receipt-v1"
validator_result_add_runtime_test ".octon/framework/assurance/runtime/_ops/tests/test-context-pack-builder.sh"
validator_result_add_negative_control \
  "duplicate-inputs-deny" \
  "forbidden-source-class-deny" \
  "generated-read-model-authority-deny" \
  "raw-input-authority-deny" \
  "model-hash-mismatch-deny" \
  "request-id-mismatch-deny" \
  "policy-ref-mismatch-deny" \
  "source-digest-mismatch-deny" \
  "dot-named-journal-event-deny" \
  "stale-pack-deny" \
  "invalidated-pack-deny" \
  "missing-receipt-deny" \
  "replay-reconstruction-required"

echo "== Context Pack Builder Validation =="
check_durable_surfaces
check_required_files

if [[ $errors -eq 0 ]]; then
  PACK_ABS="$(resolve_path "$PACK_PATH")"
  RECEIPT_ABS="$(resolve_path "$RECEIPT_PATH")"
  validator_result_add_evidence "$(repo_rel "$PACK_ABS")" "$(repo_rel "$RECEIPT_ABS")"
  check_pack_schema_and_authority "$PACK_ABS"
  check_receipt "$PACK_ABS" "$RECEIPT_ABS"
  check_replay "$PACK_ABS" "$RECEIPT_ABS" "$REPLAY_PATH"
fi

echo "Validation summary: errors=$errors"
if [[ $errors -eq 0 ]]; then
  emit_validator_result "validate-context-pack-builder.sh" "context_pack_builder" "runtime" "runtime" "pass"
else
  emit_validator_result "validate-context-pack-builder.sh" "context_pack_builder" "runtime" "semantic" "fail"
fi
[[ $errors -eq 0 ]]
