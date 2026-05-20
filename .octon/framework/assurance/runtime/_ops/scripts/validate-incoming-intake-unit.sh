#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
DEFAULT_OCTON_DIR="$(cd -- "$SCRIPT_DIR/../../../../../" && pwd)"
OCTON_DIR="${OCTON_DIR_OVERRIDE:-$DEFAULT_OCTON_DIR}"
ROOT_DIR="${OCTON_ROOT_DIR:-$(cd -- "$OCTON_DIR/.." && pwd)}"

errors=0
intake_id=""
meaningful_file=""
noise_file=""

fail() {
  echo "[ERROR] $1" >&2
  errors=$((errors + 1))
}

usage() {
  cat <<'EOF'
Usage: validate-incoming-intake-unit.sh --intake-id <intake-id>

Validates one raw additive intake unit and emits deterministic inventory output.
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
  if [[ ! "$id" =~ ^[a-z0-9]+(-[a-z0-9]+)*$ ]]; then
    fail "intake id must be lowercase kebab-case: $id"
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
}

main() {
  parse_args "$@"
  validate_id "$intake_id"

  if [[ $errors -gt 0 ]]; then
    echo "Validation summary: errors=$errors" >&2
    exit 1
  fi

  local incoming_root intake_path incoming_root_abs intake_abs
  incoming_root="$OCTON_DIR/inputs/additive/.incoming"
  intake_path="$incoming_root/$intake_id"

  if [[ ! -d "$incoming_root" ]]; then
    fail "missing additive incoming root: $(rel_to_root "$incoming_root")"
  fi
  if [[ ! -d "$intake_path" ]]; then
    fail "missing intake unit: $(rel_to_root "$intake_path")"
  fi

  if [[ $errors -gt 0 ]]; then
    echo "Validation summary: errors=$errors" >&2
    exit 1
  fi

  incoming_root_abs="$(canonical_path "$incoming_root")"
  intake_abs="$(canonical_path "$intake_path")"

  case "$intake_abs" in
    "$incoming_root_abs"/*) ;;
    *)
      fail "intake unit escapes additive incoming root: $(rel_to_root "$intake_abs")"
      ;;
  esac
  if forbidden_target "$intake_abs"; then
    fail "intake unit resolves to forbidden target: $(rel_to_root "$intake_abs")"
  fi

  local symlink target symlink_rel target_rel
  while IFS= read -r -d '' symlink; do
    [[ -n "$symlink" ]] || continue
    target="$(canonical_path "$symlink")"
    symlink_rel="$(safe_rel_to_root "$(canonical_path "$symlink")")" || true
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
  done < <(find "$intake_path" -type l -print0)

  local file rel sha meaningful_count noise_count
  meaningful_file="$(mktemp "${TMPDIR:-/tmp}/incoming-intake-files.XXXXXX")"
  noise_file="$(mktemp "${TMPDIR:-/tmp}/incoming-intake-noise.XXXXXX")"
  trap '[[ -n "${meaningful_file:-}" ]] && rm -f "$meaningful_file"; [[ -n "${noise_file:-}" ]] && rm -f "$noise_file"' EXIT

  while IFS= read -r -d '' file; do
    [[ -n "$file" ]] || continue
    rel="$(safe_rel_to_root "$(canonical_path "$file")")" || continue
    if is_noise_path "$file"; then
      printf '%s\n' "$rel" >>"$noise_file"
    else
      sha="$(hash_file "$file")"
      printf '%s\t%s\n' "$rel" "$sha" >>"$meaningful_file"
    fi
  done < <(find "$intake_path" -type f -print0)

  LC_ALL=C sort -o "$meaningful_file" "$meaningful_file"
  LC_ALL=C sort -o "$noise_file" "$noise_file"

  meaningful_count="$(awk 'END { print NR + 0 }' "$meaningful_file")"
  noise_count="$(awk 'END { print NR + 0 }' "$noise_file")"
  if [[ "$meaningful_count" -eq 0 ]]; then
    fail "intake unit has no meaningful files after excluding platform noise: $(rel_to_root "$intake_path")"
  fi

  if [[ $errors -gt 0 ]]; then
    echo "Validation summary: errors=$errors" >&2
    exit 1
  fi

  printf 'schema_version: "octon-incoming-intake-inventory-v1"\n'
  printf 'intake_id: "%s"\n' "$intake_id"
  printf 'intake_path: "%s"\n' "$(rel_to_root "$intake_abs")"
  printf 'meaningful_file_count: %s\n' "$meaningful_count"
  printf 'excluded_noise_count: %s\n' "$noise_count"
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
