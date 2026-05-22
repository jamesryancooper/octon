#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
DEFAULT_OCTON_DIR="$(cd -- "$SCRIPT_DIR/../../../../../" && pwd)"
OCTON_DIR="${OCTON_DIR_OVERRIDE:-$DEFAULT_OCTON_DIR}"
ROOT_DIR="${OCTON_ROOT_DIR:-$(cd -- "$OCTON_DIR/.." && pwd)}"

SCHEMA_VERSION="octon-additive-incoming-intake-unit-v1"
errors=0
intake_id=""
explicit_path=""
meaningful_file=""
noise_file=""
findings_file=""

fail() {
  echo "[ERROR] $1" >&2
  errors=$((errors + 1))
}

usage() {
  cat <<'EOF'
Usage:
  validate-incoming-intake-unit.sh --intake-id <intake-id>
  validate-incoming-intake-unit.sh --path <path>

Validates one raw additive intake unit envelope and emits deterministic
inventory output. Validation does not classify, normalize, install, activate,
publish, archive, migrate, or process the intake unit.
EOF
}

hash_file() {
  local file="$1"
  if command -v shasum >/dev/null 2>&1; then
    shasum -a 256 "$file" | awk '{print $1}'
  else
    sha256sum "$file" | awk '{print $1}'
  fi
}

canonical_path() {
  local path="$1"
  if command -v realpath >/dev/null 2>&1; then
    realpath "$path"
  elif command -v python3 >/dev/null 2>&1; then
    python3 -c 'import os, sys; print(os.path.realpath(sys.argv[1]))' "$path"
  else
    (cd -P -- "$(dirname -- "$path")" && printf '%s/%s\n' "$(pwd)" "$(basename -- "$path")")
  fi
}

rel_to_root() {
  local abs="$1"
  case "$abs" in
    "$ROOT_DIR"/*) printf '%s\n' "${abs#$ROOT_DIR/}" ;;
    *) printf '%s\n' "$abs" ;;
  esac
}

is_noise_path() {
  local base
  base="$(basename -- "$1")"
  case "$base" in
    .DS_Store|.gitkeep|Thumbs.db|Desktop.ini|Icon?|._*)
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

path_has_unsafe_chars() {
  local rel="$1"
  if [[ "$rel" == *$'\n'* || "$rel" == *$'\t'* || "$rel" == *\"* || "$rel" == *\\* ]]; then
    return 0
  fi
  if printf '%s' "$rel" | LC_ALL=C grep -q '[[:cntrl:]]'; then
    return 0
  fi
  return 1
}

path_has_unsafe_segments() {
  local rel="$1"
  local old_ifs segment
  old_ifs="$IFS"
  IFS='/'
  for segment in $rel; do
    case "$segment" in
      ""|"."|".."|".incoming"|".archive")
        IFS="$old_ifs"
        return 0
        ;;
    esac
  done
  IFS="$old_ifs"
  return 1
}

safe_rel_to_root() {
  local abs="$1"
  local rel
  rel="$(rel_to_root "$abs")"
  if path_has_unsafe_chars "$rel"; then
    fail "unsafe path characters in intake inventory path: $rel"
    return 1
  fi
  printf '%s\n' "$rel"
}

reserved_intake_id() {
  case "$1" in
    .incoming|.archive|payload|generated|state|runtime|extensions|extension|archive|incoming|policy|publication|evidence)
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

validate_id() {
  local id="$1"
  if [[ -z "$id" ]]; then
    fail "missing intake id"
    return
  fi
  if [[ ${#id} -gt 128 ]]; then
    fail "intake id is longer than 128 characters: $id"
  fi
  if [[ "$id" == *"/"* || "$id" == *"\\"* || "$id" == "." || "$id" == ".." || "$id" == *".."* ]]; then
    fail "intake id must not contain path separators or dot segments: $id"
  fi
  if [[ ! "$id" =~ ^[a-z][a-z0-9]*(-[a-z0-9]+)*$ ]]; then
    fail "intake id must be lowercase kebab-case beginning with a letter: $id"
  fi
  if reserved_intake_id "$id"; then
    fail "intake id is reserved: $id"
  fi
}

forbidden_target() {
  local abs="$1"
  case "$abs" in
    "$ROOT_DIR/.archive"|"$ROOT_DIR/.archive"/*) return 0 ;;
    "$HOME/Downloads"|"$HOME/Downloads"/*) return 0 ;;
    "$ROOT_DIR/.codex/skills"|"$ROOT_DIR/.codex/skills"/*) return 0 ;;
    "$ROOT_DIR/.claude/skills"|"$ROOT_DIR/.claude/skills"/*) return 0 ;;
    "$ROOT_DIR/.cursor/skills"|"$ROOT_DIR/.cursor/skills"/*) return 0 ;;
    "$OCTON_DIR/generated"|"$OCTON_DIR/generated"/*) return 0 ;;
    "$OCTON_DIR/state/control"|"$OCTON_DIR/state/control"/*) return 0 ;;
    "$OCTON_DIR/state/evidence"|"$OCTON_DIR/state/evidence"/*) return 0 ;;
    "$OCTON_DIR/framework"|"$OCTON_DIR/framework"/*) return 0 ;;
    "$OCTON_DIR/instance"|"$OCTON_DIR/instance"/*) return 0 ;;
    "$OCTON_DIR/inputs/additive/.archive"|"$OCTON_DIR/inputs/additive/.archive"/*) return 0 ;;
    "$OCTON_DIR/inputs/additive/extensions"|"$OCTON_DIR/inputs/additive/extensions"/*) return 0 ;;
    *) return 1 ;;
  esac
}

parse_args() {
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --intake-id)
        [[ $# -ge 2 ]] || { fail "--intake-id requires a value"; return; }
        intake_id="$2"
        shift 2
        ;;
      --path)
        [[ $# -ge 2 ]] || { fail "--path requires a value"; return; }
        explicit_path="$2"
        shift 2
        ;;
      --help|-h)
        usage
        exit 0
        ;;
      *)
        fail "unknown argument: $1"
        shift
        ;;
    esac
  done

  if [[ -n "$intake_id" && -n "$explicit_path" ]]; then
    fail "use only one of --intake-id or --path"
  elif [[ -z "$intake_id" && -z "$explicit_path" ]]; then
    fail "missing --intake-id or --path"
  fi
}

yq_value() {
  local expr="$1"
  local file="$2"
  yq -r "$expr // \"\"" "$file"
}

yq_has_path() {
  local expr="$1"
  local file="$2"
  yq -e "$expr" "$file" >/dev/null 2>&1
}

require_present() {
  local label="$1"
  local expr="$2"
  local file="$3"
  if yq_has_path "$expr" "$file"; then
    return 0
  fi
  fail "intake.yml missing required field: $label"
}

require_nonempty() {
  local label="$1"
  local expr="$2"
  local file="$3"
  local value
  value="$(yq_value "$expr" "$file")"
  if [[ -n "$value" && "$value" != "null" ]]; then
    return 0
  fi
  fail "intake.yml field must be non-empty: $label"
}

require_equals() {
  local label="$1"
  local actual="$2"
  local expected="$3"
  [[ "$actual" == "$expected" ]] || fail "intake.yml $label must be $expected"
}

require_enum() {
  local label="$1"
  local actual="$2"
  shift 2
  local allowed
  for allowed in "$@"; do
    if [[ "$actual" == "$allowed" ]]; then
      return 0
    fi
  done
  fail "intake.yml $label has invalid value: ${actual:-<empty>}"
}

add_finding() {
  local finding="$1"
  printf '%s\n' "$finding" >>"$findings_file"
}

stat_nlink() {
  local file="$1"
  if stat -f '%l' "$file" >/dev/null 2>&1; then
    stat -f '%l' "$file"
  else
    stat -c '%h' "$file"
  fi
}

validate_top_level_layout() {
  local intake_path="$1"
  local entry base
  while IFS= read -r entry; do
    [[ -n "$entry" ]] || continue
    base="$(basename -- "$entry")"
    case "$base" in
      intake.yml|README.md|payload)
        ;;
      *)
        fail "unexpected top-level entry in intake unit: $(rel_to_root "$entry")"
        ;;
    esac
  done < <(find "$intake_path" -mindepth 1 -maxdepth 1 -print | sort)
}

validate_envelope() {
  local envelope="$1"
  local expected_id="$2"

  if [[ ! -f "$envelope" ]]; then
    fail "missing required intake.yml: $(rel_to_root "$envelope")"
    return
  fi
  if [[ -L "$envelope" ]]; then
    fail "intake.yml must not be a symlink: $(rel_to_root "$envelope")"
    return
  fi
  if ! command -v yq >/dev/null 2>&1; then
    fail "yq is required for intake.yml validation"
    return
  fi
  if ! yq -e '.' "$envelope" >/dev/null 2>&1; then
    fail "intake.yml is malformed YAML: $(rel_to_root "$envelope")"
    return
  fi

  require_present "schema_version" 'has("schema_version")' "$envelope"
  require_present "intake_id" 'has("intake_id")' "$envelope"
  require_present "authority_mode" 'has("authority_mode")' "$envelope"
  require_present "status" 'has("status")' "$envelope"
  require_present "staged_at" 'has("staged_at")' "$envelope"
  require_present "submitted_by.type" 'has("submitted_by") and (.submitted_by | has("type"))' "$envelope"
  require_present "submitted_by.name" 'has("submitted_by") and (.submitted_by | has("name"))' "$envelope"
  require_present "reason" 'has("reason")' "$envelope"
  require_present "next_step" 'has("next_step")' "$envelope"
  require_present "route_hint" 'has("route_hint")' "$envelope"
  require_present "payload.root" 'has("payload") and (.payload | has("root"))' "$envelope"
  require_present "payload.form" 'has("payload") and (.payload | has("form"))' "$envelope"
  require_present "provenance.status" 'has("provenance") and (.provenance | has("status"))' "$envelope"
  require_present "provenance.origin_class" 'has("provenance") and (.provenance | has("origin_class"))' "$envelope"
  require_present "provenance.imported_from" 'has("provenance") and (.provenance | has("imported_from"))' "$envelope"
  require_present "provenance.origin_uri" 'has("provenance") and (.provenance | has("origin_uri"))' "$envelope"
  require_present "provenance.source_digest_sha256" 'has("provenance") and (.provenance | has("source_digest_sha256"))' "$envelope"
  require_present "provenance.attestation_refs" 'has("provenance") and (.provenance | has("attestation_refs"))' "$envelope"
  require_present "risk.contains_executable" 'has("risk") and (.risk | has("contains_executable"))' "$envelope"
  require_present "risk.contains_binary" 'has("risk") and (.risk | has("contains_binary"))' "$envelope"
  require_present "risk.contains_secret_or_private_data" 'has("risk") and (.risk | has("contains_secret_or_private_data"))' "$envelope"
  require_present "risk.redistribution_risk" 'has("risk") and (.risk | has("redistribution_risk"))' "$envelope"
  require_present "risk.size_class" 'has("risk") and (.risk | has("size_class"))' "$envelope"

  require_nonempty "staged_at" '.staged_at' "$envelope"
  require_nonempty "submitted_by.name" '.submitted_by.name' "$envelope"
  require_nonempty "reason" '.reason' "$envelope"
  require_nonempty "next_step" '.next_step' "$envelope"
  require_nonempty "provenance.imported_from" '.provenance.imported_from' "$envelope"

  local schema actual_id authority_mode status submitted_by_type route_hint payload_root payload_form
  local provenance_status origin_class digest attestation_type contains_executable contains_binary contains_secret redistribution size_class
  schema="$(yq_value '.schema_version' "$envelope")"
  actual_id="$(yq_value '.intake_id' "$envelope")"
  authority_mode="$(yq_value '.authority_mode' "$envelope")"
  status="$(yq_value '.status' "$envelope")"
  submitted_by_type="$(yq_value '.submitted_by.type' "$envelope")"
  route_hint="$(yq_value '.route_hint' "$envelope")"
  payload_root="$(yq_value '.payload.root' "$envelope")"
  payload_form="$(yq_value '.payload.form' "$envelope")"
  provenance_status="$(yq_value '.provenance.status' "$envelope")"
  origin_class="$(yq_value '.provenance.origin_class' "$envelope")"
  digest="$(yq_value '.provenance.source_digest_sha256' "$envelope")"
  attestation_type="$(yq -r '.provenance.attestation_refs | type // ""' "$envelope")"
  contains_executable="$(yq_value '.risk.contains_executable' "$envelope")"
  contains_binary="$(yq_value '.risk.contains_binary' "$envelope")"
  contains_secret="$(yq_value '.risk.contains_secret_or_private_data' "$envelope")"
  redistribution="$(yq_value '.risk.redistribution_risk' "$envelope")"
  size_class="$(yq_value '.risk.size_class' "$envelope")"

  require_equals "schema_version" "$schema" "$SCHEMA_VERSION"
  require_equals "intake_id" "$actual_id" "$expected_id"
  require_equals "authority_mode" "$authority_mode" "non_authoritative"
  validate_id "$actual_id"
  require_enum "status" "$status" unclassified classified-pending-normalization rejected-pending-archive blocked intentionally-retained-temporarily
  require_enum "submitted_by.type" "$submitted_by_type" human agent-assisted unknown
  require_enum "route_hint" "$route_hint" unknown additive-extension-pack core-octon-skill blocked-proposal-required
  require_equals "payload.root" "$payload_root" "payload/"
  require_enum "payload.form" "$payload_form" directory archive-expanded archive-unexpanded mixed unknown
  require_enum "provenance.status" "$provenance_status" declared partial missing unverified
  require_enum "provenance.origin_class" "$origin_class" first_party_bundled first_party_external third_party unknown
  if [[ -n "$digest" && "$digest" != "null" && ! "$digest" =~ ^[0-9a-f]{64}$ ]]; then
    fail "intake.yml provenance.source_digest_sha256 must be null or 64 lowercase hex characters"
  fi
  [[ "$attestation_type" == "!!seq" ]] || fail "intake.yml provenance.attestation_refs must be a list"
  require_enum "risk.contains_executable" "$contains_executable" yes no unknown
  require_enum "risk.contains_binary" "$contains_binary" yes no unknown
  require_enum "risk.contains_secret_or_private_data" "$contains_secret" yes no unknown
  require_enum "risk.redistribution_risk" "$redistribution" yes no unknown
  require_enum "risk.size_class" "$size_class" small medium large oversized unknown

  case "$provenance_status" in
    partial|missing|unverified)
      add_finding "provenance-$provenance_status"
      ;;
  esac
  [[ "$route_hint" == "unknown" ]] && add_finding "route-hint-unknown"
  [[ "$contains_executable" != "no" ]] && add_finding "risk-executable-$contains_executable"
  [[ "$contains_binary" != "no" ]] && add_finding "risk-binary-$contains_binary"
  [[ "$contains_secret" != "no" ]] && add_finding "risk-secret-or-private-data-$contains_secret"
  [[ "$redistribution" != "no" ]] && add_finding "risk-redistribution-$redistribution"
  [[ "$size_class" == "oversized" || "$size_class" == "unknown" ]] && add_finding "risk-size-$size_class"

  return 0
}

validate_payload_tree() {
  local intake_abs="$1"
  local payload_path="$2"

  if [[ ! -d "$payload_path" ]]; then
    fail "missing required payload directory: $(rel_to_root "$payload_path")"
    return
  fi
  if [[ -L "$payload_path" ]]; then
    fail "payload/ must not be a symlink: $(rel_to_root "$payload_path")"
    return
  fi

  local symlink target symlink_rel target_rel
  while IFS= read -r -d '' symlink; do
    [[ -n "$symlink" ]] || continue
    target="$(canonical_path "$symlink")"
    symlink_rel="$(rel_to_root "$symlink")"
    if path_has_unsafe_chars "$symlink_rel"; then
      fail "unsafe path characters in intake inventory path: $symlink_rel"
      symlink_rel=""
    fi
    target_rel="$(rel_to_root "$target")"
    case "$target" in
      "$intake_abs"|"$intake_abs"/*) ;;
      *)
        fail "symlink escapes intake unit: ${symlink_rel:-$(rel_to_root "$symlink")} -> $target_rel"
        ;;
    esac
    if forbidden_target "$target"; then
      fail "symlink resolves to forbidden target: ${symlink_rel:-$(rel_to_root "$symlink")} -> $target_rel"
    fi
  done < <(find "$payload_path" -type l -print0)

  local path rel rel_payload nlink file base sha meaningful_count noise_count
  while IFS= read -r -d '' path; do
    [[ -n "$path" ]] || continue
    rel="$(rel_to_root "$(canonical_path "$path")")"
    if path_has_unsafe_chars "$rel"; then
      fail "unsafe path characters in intake inventory path: $rel"
      continue
    fi
    rel_payload="${rel#$(rel_to_root "$payload_path")/}"
    if path_has_unsafe_segments "$rel_payload"; then
      fail "nested staging root or unsafe path segment in payload: $rel"
    fi
  done < <(find "$payload_path" -mindepth 1 -print0)

  while IFS= read -r -d '' file; do
    [[ -n "$file" ]] || continue
    rel="$(rel_to_root "$(canonical_path "$file")")"
    if path_has_unsafe_chars "$rel"; then
      fail "unsafe path characters in intake inventory path: $rel"
      continue
    fi
    base="$(basename -- "$file")"
    if is_noise_path "$file"; then
      printf '%s\n' "$rel" >>"$noise_file"
      continue
    fi
    nlink="$(stat_nlink "$file")"
    if [[ "$nlink" =~ ^[0-9]+$ && "$nlink" -gt 1 ]]; then
      fail "hardlinked payload file is not allowed: $rel"
    fi
    case "$base" in
      pack.yml)
        add_finding "candidate-extension-pack"
        ;;
      SKILL.md)
        add_finding "candidate-core-skill"
        ;;
    esac
    sha="$(hash_file "$file")"
    printf '%s\t%s\n' "$rel" "$sha" >>"$meaningful_file"
  done < <(find "$payload_path" -type f -print0)

  LC_ALL=C sort -u -o "$meaningful_file" "$meaningful_file"
  LC_ALL=C sort -u -o "$noise_file" "$noise_file"
  LC_ALL=C sort -u -o "$findings_file" "$findings_file"

  meaningful_count="$(awk 'END { print NR + 0 }' "$meaningful_file")"
  noise_count="$(awk 'END { print NR + 0 }' "$noise_file")"
  if [[ "$meaningful_count" -eq 0 ]]; then
    fail "payload has no meaningful files after excluding platform noise: $(rel_to_root "$payload_path")"
  fi
}

main() {
  parse_args "$@"

  if [[ $errors -gt 0 ]]; then
    echo "Validation summary: errors=$errors" >&2
    exit 1
  fi

  local incoming_root incoming_root_abs intake_path intake_abs envelope payload_path
  incoming_root="$OCTON_DIR/inputs/additive/.incoming"

  if [[ -n "$explicit_path" ]]; then
    case "$explicit_path" in
      /*) intake_path="$explicit_path" ;;
      *) intake_path="$ROOT_DIR/$explicit_path" ;;
    esac
    intake_id="$(basename -- "$intake_path")"
  else
    intake_path="$incoming_root/$intake_id"
  fi

  validate_id "$intake_id"

  if [[ ! -d "$incoming_root" ]]; then
    fail "missing additive incoming root: $(rel_to_root "$incoming_root")"
  fi
  if [[ ! -d "$intake_path" ]]; then
    fail "missing intake unit: $(rel_to_root "$intake_path")"
  fi
  if [[ -L "$intake_path" ]]; then
    fail "intake unit path must not be a symlink: $(rel_to_root "$intake_path")"
  fi

  if [[ $errors -gt 0 ]]; then
    echo "Validation summary: errors=$errors" >&2
    exit 1
  fi

  incoming_root_abs="$(canonical_path "$incoming_root")"
  intake_abs="$(canonical_path "$intake_path")"
  payload_path="$intake_abs/payload"
  envelope="$intake_abs/intake.yml"

  case "$intake_abs" in
    "$incoming_root_abs"/*) ;;
    *)
      fail "intake unit escapes additive incoming root: $(rel_to_root "$intake_abs")"
      ;;
  esac
  if forbidden_target "$intake_abs"; then
    fail "intake unit resolves to forbidden target: $(rel_to_root "$intake_abs")"
  fi

  meaningful_file="$(mktemp "${TMPDIR:-/tmp}/incoming-intake-files.XXXXXX")"
  noise_file="$(mktemp "${TMPDIR:-/tmp}/incoming-intake-noise.XXXXXX")"
  findings_file="$(mktemp "${TMPDIR:-/tmp}/incoming-intake-findings.XXXXXX")"
  trap '[[ -n "${meaningful_file:-}" ]] && rm -f "$meaningful_file"; [[ -n "${noise_file:-}" ]] && rm -f "$noise_file"; [[ -n "${findings_file:-}" ]] && rm -f "$findings_file"' EXIT

  validate_top_level_layout "$intake_abs"
  validate_envelope "$envelope" "$intake_id"
  validate_payload_tree "$intake_abs" "$payload_path"

  if [[ $errors -gt 0 ]]; then
    echo "Validation summary: errors=$errors" >&2
    exit 1
  fi

  local meaningful_count noise_count finding_count rel sha
  meaningful_count="$(awk 'END { print NR + 0 }' "$meaningful_file")"
  noise_count="$(awk 'END { print NR + 0 }' "$noise_file")"
  finding_count="$(awk 'END { print NR + 0 }' "$findings_file")"

  printf 'schema_version: "octon-incoming-intake-inventory-v2"\n'
  printf 'intake_schema_version: "%s"\n' "$SCHEMA_VERSION"
  printf 'intake_id: "%s"\n' "$intake_id"
  printf 'intake_path: "%s"\n' "$(rel_to_root "$intake_abs")"
  printf 'payload_root: "%s"\n' "$(rel_to_root "$payload_path")"
  printf 'meaningful_file_count: %s\n' "$meaningful_count"
  printf 'excluded_noise_count: %s\n' "$noise_count"
  printf 'classification_finding_count: %s\n' "$finding_count"
  printf 'classification_findings:\n'
  if [[ "$finding_count" -eq 0 ]]; then
    printf '  []\n'
  else
    while IFS= read -r rel; do
      [[ -n "$rel" ]] || continue
      printf '  - "%s"\n' "$rel"
    done <"$findings_file"
  fi
  printf 'files:\n'
  while IFS=$'\t' read -r rel sha; do
    [[ -n "$rel" ]] || continue
    printf '  - path: "%s"\n' "$rel"
    printf '    sha256: "%s"\n' "$sha"
  done <"$meaningful_file"
  printf 'excluded_noise:\n'
  if [[ "$noise_count" -eq 0 ]]; then
    printf '  []\n'
  else
    while IFS= read -r rel; do
      [[ -n "$rel" ]] || continue
      printf '  - path: "%s"\n' "$rel"
    done <"$noise_file"
  fi
}

main "$@"
