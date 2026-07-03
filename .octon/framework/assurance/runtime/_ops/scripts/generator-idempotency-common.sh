#!/usr/bin/env bash

OCTON_CHURN_COMMON_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
OCTON_CHURN_COMMON_REF=".octon/framework/assurance/runtime/_ops/scripts/generator-idempotency-common.sh"

octon_churn_sha256_file() {
  local path="$1"
  if command -v shasum >/dev/null 2>&1; then
    shasum -a 256 "$path" | awk '{print "sha256:" $1}'
  else
    sha256sum "$path" | awk '{print "sha256:" $1}'
  fi
}

octon_churn_sha256_stdin() {
  if command -v shasum >/dev/null 2>&1; then
    shasum -a 256 | awk '{print "sha256:" $1}'
  else
    sha256sum | awk '{print "sha256:" $1}'
  fi
}

octon_churn_file_mode() {
  local path="$1"
  if stat -f '%Lp' "$path" >/dev/null 2>&1; then
    stat -f '%Lp' "$path"
  else
    stat -c '%a' "$path"
  fi
}

octon_churn_stable_sort() {
  LC_ALL=C sort "$@"
}

octon_churn_required_metric_ids() {
  cat <<'EOF'
changed_file_count
generated_noop_rewrite_rate
receipt_fanout_count
dirty_worktree_residue_count
tmp_byte_file_count
process_runtime
token_budget_impact
validation_coverage_retained
freshness_lock_receipt_validation_retained
evidence_retrieval_integrity
EOF
}

octon_churn_is_required_metric_id() {
  local metric_id="$1"
  case "$metric_id" in
    changed_file_count|generated_noop_rewrite_rate|receipt_fanout_count|dirty_worktree_residue_count|tmp_byte_file_count|process_runtime|token_budget_impact|validation_coverage_retained|freshness_lock_receipt_validation_retained|evidence_retrieval_integrity)
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

octon_churn_classify_path_family() {
  local path="$1"
  case "$path" in
    .octon/generated/.tmp/*|/.octon/generated/.tmp/*)
      printf 'local-scratch\n'
      ;;
    .octon/generated/effective/*|/.octon/generated/effective/*)
      printf 'runtime-facing-generated-effective\n'
      ;;
    .octon/generated/*|/.octon/generated/*)
      printf 'generated-derived-output\n'
      ;;
    .octon/state/evidence/*|/.octon/state/evidence/*)
      printf 'retained-evidence\n'
      ;;
    .octon/state/control/*|/.octon/state/control/*|.octon/state/continuity/*|/.octon/state/continuity/*)
      printf 'retained-control-or-continuity\n'
      ;;
    .claude/*|/.claude/*|.codex/*|/.codex/*|.cursor/*|/.cursor/*)
      printf 'host-projection\n'
      ;;
    .octon/framework/*|/.octon/framework/*|.octon/instance/*|/.octon/instance/*|.octon/inputs/*|/.octon/inputs/*)
      printf 'source-framework-input-or-archive-trigger\n'
      ;;
    *)
      printf 'other\n'
      ;;
  esac
}

octon_churn_write_file_if_changed() {
  local target="$1"
  local candidate="$2"
  local mode="${3:-}"
  local target_dir tmp result current_mode

  if [[ -z "$target" || -z "$candidate" ]]; then
    echo "usage: octon_churn_write_file_if_changed <target> <candidate> [mode]" >&2
    return 2
  fi
  if [[ ! -f "$candidate" ]]; then
    echo "candidate file does not exist: $candidate" >&2
    return 2
  fi

  if [[ -f "$target" ]] && cmp -s "$candidate" "$target"; then
    printf 'unchanged\n'
    return 0
  fi

  target_dir="$(dirname -- "$target")"
  mkdir -p "$target_dir"
  tmp="$(mktemp "$target_dir/.octon-write-if-changed.XXXXXX")"
  result=1
  if cp "$candidate" "$tmp"; then
    if [[ -n "$mode" ]]; then
      chmod "$mode" "$tmp"
    elif [[ -f "$target" ]]; then
      current_mode="$(octon_churn_file_mode "$target")"
      chmod "$current_mode" "$tmp"
    fi
    mv "$tmp" "$target"
    result=0
  fi
  [[ -e "$tmp" ]] && rm -f "$tmp"
  [[ "$result" -eq 0 ]] || return "$result"
  printf 'changed\n'
}

octon_churn_write_stdin_if_changed() {
  local target="$1"
  local mode="${2:-}"
  local tmp result

  if [[ -z "$target" ]]; then
    echo "usage: octon_churn_write_stdin_if_changed <target> [mode]" >&2
    return 2
  fi

  tmp="$(mktemp "${TMPDIR:-/tmp}/octon-write-if-changed.XXXXXX")"
  cat >"$tmp"
  result="$(octon_churn_write_file_if_changed "$target" "$tmp" "$mode")"
  rm -f "$tmp"
  printf '%s\n' "$result"
}

octon_churn_normalize_receipt_for_fanout() {
  sed -E \
    -e 's/^([[:space:]]*)receipt_id: "?[^"]*"?.*/\1receipt_id: "__RECEIPT_ID__"/' \
    -e 's/^([[:space:]]*)validated_at: "?[^"]*"?.*/\1validated_at: "__VALIDATED_AT__"/' \
    -e 's/^([[:space:]]*)published_at: "?[^"]*"?.*/\1published_at: "__PUBLISHED_AT__"/' \
    -e 's/^([[:space:]]*)generated_at: "?[^"]*"?.*/\1generated_at: "__GENERATED_AT__"/' \
    -e 's/^([[:space:]]*)created_at: "?[^"]*"?.*/\1created_at: "__CREATED_AT__"/' \
    -e 's/^([[:space:]]*)completed_at: "?[^"]*"?.*/\1completed_at: "__COMPLETED_AT__"/'
}

octon_churn_receipt_normalized_digest_file() {
  local receipt="$1"
  octon_churn_normalize_receipt_for_fanout <"$receipt" | octon_churn_sha256_stdin
}

octon_churn_safe_receipt_component() {
  printf '%s' "$1" | tr -c 'A-Za-z0-9._-' '-'
}

octon_churn_receipt_ref_is_compacted() {
  local receipt_ref="$1"
  case "$receipt_ref" in
    .octon/state/evidence/validation/*/by-digest/*/*.yml)
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

octon_churn_publish_compacted_receipt() {
  local root_dir="$1"
  local receipt_family_rel="$2"
  local producer_id="$3"
  local generation_id="$4"
  local candidate_receipt="$5"
  local safe_producer safe_generation normalized_digest digest_hex receipt_rel receipt_abs
  local existing_digest receipt_sha pointer_rel pointer_abs pointer_tmp existing_pointer_digest write_status pointer_status

  if [[ -z "$root_dir" || -z "$receipt_family_rel" || -z "$producer_id" || -z "$generation_id" || -z "$candidate_receipt" ]]; then
    echo "usage: octon_churn_publish_compacted_receipt <root-dir> <receipt-family-rel> <producer-id> <generation-id> <candidate-receipt>" >&2
    return 2
  fi
  if [[ ! -f "$candidate_receipt" ]]; then
    echo "candidate receipt does not exist: $candidate_receipt" >&2
    return 2
  fi

  safe_producer="$(octon_churn_safe_receipt_component "$producer_id")"
  safe_generation="$(octon_churn_safe_receipt_component "$generation_id")"
  normalized_digest="$(octon_churn_receipt_normalized_digest_file "$candidate_receipt")"
  digest_hex="${normalized_digest#sha256:}"
  receipt_rel="${receipt_family_rel%/}/by-digest/$safe_producer/$digest_hex.yml"
  receipt_abs="$root_dir/$receipt_rel"

  if [[ -f "$receipt_abs" ]]; then
    existing_digest="$(octon_churn_receipt_normalized_digest_file "$receipt_abs")"
    if [[ "$existing_digest" != "$normalized_digest" ]]; then
      echo "compacted receipt digest collision or drift: $receipt_rel" >&2
      return 1
    fi
    write_status="unchanged"
  else
    write_status="$(octon_churn_write_file_if_changed "$receipt_abs" "$candidate_receipt")"
  fi

  receipt_sha="$(octon_churn_sha256_file "$receipt_abs")"
  pointer_rel="${receipt_family_rel%/}/latest/$safe_producer-$safe_generation.yml"
  pointer_abs="$root_dir/$pointer_rel"
  pointer_tmp="$(mktemp "${TMPDIR:-/tmp}/octon-compact-receipt-pointer.XXXXXX")"
  {
    printf 'schema_version: "octon-compact-receipt-pointer-v1"\n'
    printf 'producer_id: "%s"\n' "$producer_id"
    printf 'generation_id: "%s"\n' "$generation_id"
    printf 'receipt_content_sha256: "%s"\n' "$normalized_digest"
    printf 'receipt_path: "%s"\n' "$receipt_rel"
    printf 'receipt_sha256: "%s"\n' "$receipt_sha"
    printf 'retained_full_receipt: true\n'
    printf 'non_authority_classification: "retained-evidence-index"\n'
    printf 'authority_boundaries:\n'
    printf '  replaces_full_receipt: false\n'
    printf '  authorizes_cleanup: false\n'
    printf '  satisfies_freshness_without_receipt: false\n'
    printf '  generated_output_authority: false\n'
  } >"$pointer_tmp"
  if [[ -f "$pointer_abs" ]]; then
    existing_pointer_digest="$(octon_churn_sha256_file "$pointer_abs")"
  else
    existing_pointer_digest=""
  fi
  pointer_status="$(octon_churn_write_file_if_changed "$pointer_abs" "$pointer_tmp")"
  rm -f "$pointer_tmp"

  printf 'receipt_path\t%s\n' "$receipt_rel"
  printf 'receipt_sha256\t%s\n' "$receipt_sha"
  printf 'receipt_content_sha256\t%s\n' "$normalized_digest"
  printf 'pointer_path\t%s\n' "$pointer_rel"
  printf 'receipt_write_status\t%s\n' "$write_status"
  printf 'pointer_write_status\t%s\n' "$pointer_status"
  [[ -z "$existing_pointer_digest" ]] || printf 'previous_pointer_sha256\t%s\n' "$existing_pointer_digest"
}

octon_churn_git_changed_file_count() {
  local root="$1"
  shift || true
  git -C "$root" status --short -- "$@" | awk 'NF { count += 1 } END { print count + 0 }'
}

octon_churn_path_file_count() {
  local path="$1"
  if [[ ! -e "$path" ]]; then
    printf '0\n'
    return 0
  fi
  find "$path" -type f | wc -l | tr -d '[:space:]'
}

octon_churn_path_byte_count() {
  local path="$1"
  if [[ ! -e "$path" ]]; then
    printf '0\n'
    return 0
  fi
  if du -sk "$path" >/dev/null 2>&1; then
    du -sk "$path" | awk '{ print $1 * 1024 }'
  else
    find "$path" -type f -exec wc -c {} + | awk 'END { print $1 + 0 }'
  fi
}
