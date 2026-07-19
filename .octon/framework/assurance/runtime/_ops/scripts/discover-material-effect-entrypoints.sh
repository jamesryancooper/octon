#!/usr/bin/env bash
set -euo pipefail

# Enumerate material writers and launchers from one immutable Git tree.  The
# worktree is intentionally not an input: inventory/coverage contracts are
# read separately and are used only when --check is requested.

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
DEFAULT_ROOT="$(cd -- "$SCRIPT_DIR/../../../../../.." && pwd)"
ROOT_DIR="${OCTON_ROOT_DIR:-$DEFAULT_ROOT}"
TREEISH="HEAD"
INVENTORY="$ROOT_DIR/.octon/framework/engine/runtime/spec/material-side-effect-inventory.yml"
COVERAGE="$ROOT_DIR/.octon/framework/engine/runtime/spec/authorization-boundary-coverage.yml"
FORMAT="keys"
CHECK=0

usage() {
  cat <<'USAGE'
Usage: discover-material-effect-entrypoints.sh [options]

Options:
  --repo <path>          Git repository root (default: inferred root)
  --treeish <commit>     Commit to enumerate (default: HEAD)
  --inventory <path>     Material inventory used by --check
  --coverage <path>      Authorization coverage used by --check
  --format keys|summary  Canonical key stream or YAML summary
  --check                Enforce D_w=M_w and D_l=M_l=A_l
  --help                 Show this help

The canonical key is kind|repo-relative-posix-path|stable-anchor|grammar-id.
Diagnostics are written to stderr; canonical output is written to stdout.
USAGE
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --repo)
      ROOT_DIR="$2"
      shift 2
      ;;
    --treeish)
      TREEISH="$2"
      shift 2
      ;;
    --inventory)
      INVENTORY="$2"
      shift 2
      ;;
    --coverage)
      COVERAGE="$2"
      shift 2
      ;;
    --format)
      FORMAT="$2"
      shift 2
      ;;
    --check)
      CHECK=1
      shift
      ;;
    --help|-h)
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

case "$FORMAT" in
  keys|summary) ;;
  *) echo "[ERROR] --format must be keys or summary" >&2; exit 2 ;;
esac

for command_name in git yq shasum sort uniq grep awk sed wc; do
  command -v "$command_name" >/dev/null 2>&1 || {
    echo "[ERROR] required command unavailable: $command_name" >&2
    exit 2
  }
done

ROOT_DIR="$(cd -- "$ROOT_DIR" && pwd)"
git -C "$ROOT_DIR" rev-parse --is-inside-work-tree >/dev/null 2>&1 || {
  echo "[ERROR] not a Git repository: $ROOT_DIR" >&2
  exit 2
}

COMMIT="$(git -C "$ROOT_DIR" rev-parse --verify "$TREEISH^{commit}")" || {
  echo "[ERROR] treeish does not resolve to a commit: $TREEISH" >&2
  exit 2
}
TREE="$(git -C "$ROOT_DIR" rev-parse --verify "$COMMIT^{tree}")"

TMP_DIR="$(mktemp -d "${TMPDIR:-/tmp}/octon-material-discovery.XXXXXX")"
trap 'rm -rf -- "$TMP_DIR"' EXIT
RAW="$TMP_DIR/candidates.raw"
KEYS="$TMP_DIR/candidates.keys"
WRITERS="$TMP_DIR/writers.keys"
LAUNCHERS="$TMP_DIR/launchers.keys"
AMBIGUOUS="$TMP_DIR/ambiguous.keys"
ACTIVE="$TMP_DIR/active-packs"
ACTIVE_RAW="$TMP_DIR/active-packs.raw"
DESIRED="$TMP_DIR/desired-packs"
ALL_PACKS="$TMP_DIR/all-packs"
INACTIVE="$TMP_DIR/inactive-packs"
: >"$RAW"
: >"$AMBIGUOUS"

hash_file() {
  local file="$1"
  printf 'sha256:%s' "$(shasum -a 256 "$file" | awk '{print $1}')"
}

line_count() {
  local file="$1"
  awk 'END { print NR + 0 }' "$file"
}

emit_candidate() {
  local kind="$1" path="$2" grammar="$3"
  printf '%s|%s|file-scope|%s\n' "$kind" "$path" "$grammar" >>"$RAW"
}

emit_ambiguous() {
  local path="$1" grammar="$2"
  local key="launcher|$path|file-scope|$grammar"
  printf '%s\n' "$key" >>"$RAW"
  printf '%s\n' "$key" >>"$AMBIGUOUS"
}

# Bind additive selection to control truth from the same immutable commit.
if ! git -C "$ROOT_DIR" cat-file -e "$COMMIT:.octon/state/control/extensions/active.yml" 2>/dev/null; then
  echo "[ERROR] exact-tree additive selection authority is missing" >&2
  exit 1
fi
git -C "$ROOT_DIR" show "$COMMIT:.octon/state/control/extensions/active.yml" \
  | yq -r '.published_active_packs[]?.pack_id // ""' - \
  | sed '/^$/d' >"$ACTIVE_RAW"
LC_ALL=C sort -u "$ACTIVE_RAW" >"$ACTIVE"
if [[ "$(line_count "$ACTIVE_RAW")" != "$(line_count "$ACTIVE")" ]]; then
  echo "[ERROR] duplicate published-active additive pack selection" >&2
  exit 1
fi
git -C "$ROOT_DIR" show "$COMMIT:.octon/state/control/extensions/active.yml" \
  | yq -r '.desired_selected_packs[]?.pack_id // ""' - \
  | sed '/^$/d' \
  | LC_ALL=C sort -u >"$DESIRED"
if ! cmp -s "$ACTIVE" "$DESIRED"; then
  echo "[ERROR] desired and published additive selections differ in the exact tree" >&2
  exit 1
fi

git -C "$ROOT_DIR" ls-tree -d --name-only "$COMMIT:.octon/inputs/additive/extensions" \
  | awk -F/ 'NF == 1 { print $1 }' \
  | sed '/^$/d' \
  | LC_ALL=C sort -u >"$ALL_PACKS"
if [[ -s "$ACTIVE" ]] && [[ -n "$(comm -23 "$ACTIVE" "$ALL_PACKS")" ]]; then
  echo "[ERROR] active additive selection names a missing pack" >&2
  comm -23 "$ACTIVE" "$ALL_PACKS" >&2
  exit 1
fi
comm -23 "$ALL_PACKS" "$ACTIVE" >"$INACTIVE"

is_selected_additive_path() {
  local path="$1" pack
  case "$path" in
    .octon/inputs/additive/extensions/*)
      pack="${path#.octon/inputs/additive/extensions/}"
      pack="${pack%%/*}"
      grep -Fxq -- "$pack" "$ACTIVE"
      ;;
    *) return 0 ;;
  esac
}

is_excluded_path() {
  local path="$1"

  is_selected_additive_path "$path" || return 0

  case "/$path/" in
    */tests/*|*/test/*|*/fixtures/*|*/fixture/*|*/golden/*|*/examples/*|*/vendor/*|*/vendored/*|*/node_modules/*|*/target/*|*/build/*|*/dist/*)
      return 0
      ;;
  esac
  case "$path" in
    *.lock|*.lock.yml|*.lock.yaml|*.png|*.jpg|*.jpeg|*.gif|*.pdf|*.zip|*.gz|*.tar|*.wasm|*.so|*.dylib|*.a)
      return 0
      ;;
    *.schema.json)
      return 0
      ;;
  esac
  return 1
}

classify_shell() {
  local path="$1" file="$2"
  if ! bash -n "$file" >/dev/null 2>&1; then
    emit_ambiguous "$path" "shell-parse-failed"
    return
  fi

  grep -Eq '(^|[;&|()[:space:]])(rm|rmdir|mv|cp|install|mkdir|touch|ln|chmod|chown|truncate)([[:space:]]|$)|(^|[^<])>>?[[:space:]]*[^&]' "$file" \
    && emit_candidate writer "$path" "shell-filesystem-writer"
  grep -Eq 'git[[:space:]]+(add|commit|push|merge|rebase|cherry-pick|update-ref|checkout|switch|tag|branch[[:space:]]+(-d|-D|--delete)|worktree[[:space:]]+(add|move|remove|prune))([[:space:]]|$)' "$file" \
    && emit_candidate writer "$path" "shell-git-writer"
  grep -Eqi '(gh[[:space:]]+api|curl[^\n]*)([^\n]*)(--method|-X)[=[:space:]]*(POST|PUT|PATCH|DELETE)|gh[[:space:]]+(pr[[:space:]]+(create|merge|close|edit)|workflow[[:space:]]+(run|disable|enable)|variable[[:space:]]+(set|delete)|secret[[:space:]]+(set|delete))' "$file" \
    && emit_candidate writer "$path" "shell-provider-writer"
  grep -Eq '(^|[;&|()[:space:]])(exec|bash|sh|zsh|python|python3|ruby|node|npm|npx|cargo|rustc|docker|gh|curl|osascript)([[:space:]]|$)' "$file" \
    && emit_candidate launcher "$path" "shell-process-launcher"
  grep -Eq '(^|[;&|()[:space:]])eval([[:space:]]|$)|(^|[;&|()[:space:]])(bash|sh|zsh)[[:space:]]+-c[[:space:]].*\$|(^|[;&|()[:space:]])exec[[:space:]].*\$' "$file" \
    && emit_ambiguous "$path" "shell-dynamic-launcher"
  return 0
}

classify_rust() {
  local path="$1" file="$2"
  grep -Eq '(std::)?fs::(write|remove_file|remove_dir|remove_dir_all|rename|copy|create_dir|create_dir_all|set_permissions)|File::create|OpenOptions|\.write_all\(' "$file" \
    && emit_candidate writer "$path" "rust-filesystem-writer"
  grep -Eq '(sqlx|rusqlite|reqwest|octocrab|ureq).*(execute|query|post|put|patch|delete)|Command::new\([^)]*(git|gh|curl)' "$file" \
    && emit_candidate writer "$path" "rust-database-provider-writer"
  grep -Eq '(std::process::)?Command::new\(|thread::spawn\(|tokio::spawn[!(]|spawn_blocking\(' "$file" \
    && emit_candidate launcher "$path" "rust-process-task-launcher"
  grep -Eq 'Command::new\([[:space:]]*[A-Za-z_][A-Za-z0-9_:.]*[[:space:]]*\)' "$file" \
    && emit_ambiguous "$path" "rust-dynamic-process-launcher"
  return 0
}

classify_python() {
  local path="$1" file="$2"
  if command -v python3 >/dev/null 2>&1; then
    PYTHONDONTWRITEBYTECODE=1 python3 -m py_compile "$file" >/dev/null 2>&1 || {
      emit_ambiguous "$path" "python-parse-failed"
      return
    }
  else
    emit_ambiguous "$path" "python-parser-unavailable"
    return
  fi

  grep -Eq '\.(write_text|write_bytes|unlink|rename|replace|mkdir|rmdir)\(|open\([^\n]*(mode[[:space:]]*=[[:space:]]*)?[^,)]*[wax+]|(os|shutil)\.(remove|unlink|rename|replace|mkdir|makedirs|rmdir|copy|copy2|copytree|move)\(' "$file" \
    && emit_candidate writer "$path" "python-filesystem-writer"
  grep -Eq '(requests|httpx)\.(post|put|patch|delete)\(|Request\([^\n]*method[[:space:]]*=[[:space:]]*[^,)]*(POST|PUT|PATCH|DELETE)' "$file" \
    && emit_candidate writer "$path" "python-http-writer"
  grep -Eq 'subprocess\.(run|Popen|call|check_call|check_output)\(|os\.(exec|spawn|system)|multiprocessing\.' "$file" \
    && emit_candidate launcher "$path" "python-process-launcher"
  grep -Eq 'subprocess\.[A-Za-z_]+\([^\n]*shell[[:space:]]*=[[:space:]]*True' "$file" \
    && emit_ambiguous "$path" "python-dynamic-shell-launcher"
  return 0
}

classify_yaml() {
  local path="$1" file="$2"
  yq -e '.' "$file" >/dev/null 2>&1 || {
    emit_ambiguous "$path" "yaml-parse-failed"
    return
  }

  case "$path" in
    .github/workflows/*.yml|.github/workflows/*.yaml|.github/actions/*/action.yml|.github/actions/*/action.yaml)
      grep -Eq '^[[:space:]]*(runs-on|uses|run):' "$file" \
        && emit_candidate launcher "$path" "github-workflow-action-launcher"
      grep -Eqi '^[[:space:]]*[a-z-]+:[[:space:]]*write([[:space:]]|$)|secrets\.|github\.token|GH_TOKEN|GITHUB_TOKEN|gh[[:space:]]+api[^\n]*(POST|PUT|PATCH|DELETE)' "$file" \
        && emit_candidate writer "$path" "github-provider-writer"
      ;;
    *.yml|*.yaml)
      case "$path" in
        */workflows/*|*/services/*|*/commands/*|*/manifests/*)
          grep -Eq '^[[:space:]-]*(run|command|script|tool|service|entrypoint|side_effects?|execution):' "$file" \
            && emit_candidate launcher "$path" "octon-workflow-command-service-launcher"
          ;;
      esac
      ;;
  esac
  return 0
}

classify_markdown_entrypoint() {
  local path="$1" file="$2"
  case "$path" in
    */commands/*.md|*/skills/*/SKILL.md)
      grep -Eq '^---$|^#|(^|[^A-Za-z])(bash|sh|python|cargo|git|gh|curl|tool|command|workflow|service)([^A-Za-z]|$)' "$file" \
        && emit_candidate launcher "$path" "octon-skill-command-entrypoint"
      ;;
  esac
  return 0
}

while IFS= read -r -d '' record; do
  meta="${record%%$'\t'*}"
  path="${record#*$'\t'}"
  read -r mode object_type object_id <<<"$meta"
  [[ "$object_type" == "blob" ]] || continue
  is_excluded_path "$path" && continue

  blob="$TMP_DIR/blob"
  git -C "$ROOT_DIR" cat-file blob "$object_id" >"$blob"
  if [[ "$mode" == "120000" ]]; then
    link_target="$(sed -n '1p' "$blob")"
    case "$link_target" in
      /*|..|../*|*/../*|*/..) emit_ambiguous "$path" "tree-escape-symlink" ;;
      *) emit_ambiguous "$path" "symlink-runtime-candidate" ;;
    esac
    continue
  fi
  if [[ -s "$blob" ]] && ! LC_ALL=C grep -Iq . "$blob" 2>/dev/null; then
    case "$path" in
      *.sh|*.bash|*.zsh|*.rs|*.py|*.yml|*.yaml|*/commands/*.md|*/skills/*/SKILL.md)
        emit_ambiguous "$path" "text-candidate-contains-nul"
        ;;
    esac
    continue
  fi

  case "$path" in
    *.sh|*.bash|*.zsh) classify_shell "$path" "$blob" ;;
    *.rs) classify_rust "$path" "$blob" ;;
    *.py) classify_python "$path" "$blob" ;;
    *.yml|*.yaml) classify_yaml "$path" "$blob" ;;
    *.md) classify_markdown_entrypoint "$path" "$blob" ;;
    *)
      if [[ "$mode" == "100755" ]]; then
        first_line="$(sed -n '1p' "$blob")"
        case "$first_line" in
          '#!'*sh*) classify_shell "$path" "$blob" ;;
          '#!'*python*) classify_python "$path" "$blob" ;;
          *) emit_ambiguous "$path" "unsupported-executable-parser" ;;
        esac
      fi
      ;;
  esac
done < <(
  git -C "$ROOT_DIR" ls-tree -rz --full-tree "$COMMIT" -- \
    .octon/framework \
    .octon/instance \
    .octon/inputs/additive \
    .github/actions \
    .github/workflows
)

LC_ALL=C sort "$RAW" >"$TMP_DIR/candidates.sorted"
LC_ALL=C sort -u "$RAW" >"$KEYS"
LC_ALL=C sort -u "$AMBIGUOUS" -o "$AMBIGUOUS"
if ! cmp -s "$TMP_DIR/candidates.sorted" "$KEYS"; then
  echo "[ERROR] discovery emitted duplicate normalized keys" >&2
  comm -23 "$TMP_DIR/candidates.sorted" "$KEYS" >&2 || true
  exit 1
fi

awk -F'|' '$1 == "writer"' "$KEYS" >"$WRITERS"
awk -F'|' '$1 == "launcher"' "$KEYS" >"$LAUNCHERS"

WRITER_COUNT="$(line_count "$WRITERS")"
LAUNCHER_COUNT="$(line_count "$LAUNCHERS")"
AMBIGUOUS_COUNT="$(line_count "$AMBIGUOUS")"
WRITER_DIGEST="$(hash_file "$WRITERS")"
LAUNCHER_DIGEST="$(hash_file "$LAUNCHERS")"
AMBIGUOUS_DIGEST="$(hash_file "$AMBIGUOUS")"
ACTIVE_COUNT="$(line_count "$ACTIVE")"
INACTIVE_COUNT="$(line_count "$INACTIVE")"
ACTIVE_DIGEST="$(hash_file "$ACTIVE")"
INACTIVE_DIGEST="$(hash_file "$INACTIVE")"

check_equal() {
  local label="$1" actual="$2" expected="$3"
  if [[ -n "$expected" && "$expected" != "null" && "$actual" == "$expected" ]]; then
    echo "[OK] $label: $actual" >&2
  else
    echo "[ERROR] $label: actual=$actual expected=${expected:-<missing>}" >&2
    return 1
  fi
}

if [[ $CHECK -eq 1 ]]; then
  [[ -f "$INVENTORY" ]] || { echo "[ERROR] inventory missing: $INVENTORY" >&2; exit 1; }
  [[ -f "$COVERAGE" ]] || { echo "[ERROR] coverage missing: $COVERAGE" >&2; exit 1; }

  check_errors=0
  check_equal "D_w=M_w count" "$WRITER_COUNT" "$(yq -r '.closed_world_discovery.material_sets.writers.count // ""' "$INVENTORY")" || check_errors=$((check_errors + 1))
  check_equal "D_w=M_w digest" "$WRITER_DIGEST" "$(yq -r '.closed_world_discovery.material_sets.writers.sha256 // ""' "$INVENTORY")" || check_errors=$((check_errors + 1))
  check_equal "D_l=M_l count" "$LAUNCHER_COUNT" "$(yq -r '.closed_world_discovery.material_sets.launchers.count // ""' "$INVENTORY")" || check_errors=$((check_errors + 1))
  check_equal "D_l=M_l digest" "$LAUNCHER_DIGEST" "$(yq -r '.closed_world_discovery.material_sets.launchers.sha256 // ""' "$INVENTORY")" || check_errors=$((check_errors + 1))
  check_equal "D_l=A_l count" "$LAUNCHER_COUNT" "$(yq -r '.closed_world_discovery.launcher_authorization_set.count // ""' "$COVERAGE")" || check_errors=$((check_errors + 1))
  check_equal "D_l=A_l digest" "$LAUNCHER_DIGEST" "$(yq -r '.closed_world_discovery.launcher_authorization_set.sha256 // ""' "$COVERAGE")" || check_errors=$((check_errors + 1))
  check_equal "active additive selection count" "$ACTIVE_COUNT" "$(yq -r '.closed_world_discovery.additive_selection.selected.count // ""' "$INVENTORY")" || check_errors=$((check_errors + 1))
  check_equal "active additive selection digest" "$ACTIVE_DIGEST" "$(yq -r '.closed_world_discovery.additive_selection.selected.sha256 // ""' "$INVENTORY")" || check_errors=$((check_errors + 1))
  check_equal "inactive additive disposition count" "$INACTIVE_COUNT" "$(yq -r '.closed_world_discovery.additive_selection.inactive_or_quarantined.count // ""' "$INVENTORY")" || check_errors=$((check_errors + 1))
  check_equal "inactive additive disposition digest" "$INACTIVE_DIGEST" "$(yq -r '.closed_world_discovery.additive_selection.inactive_or_quarantined.sha256 // ""' "$INVENTORY")" || check_errors=$((check_errors + 1))

  declared_ambiguous="$TMP_DIR/declared-ambiguous.keys"
  declared_ambiguous_raw="$TMP_DIR/declared-ambiguous.raw"
  yq -r '.closed_world_discovery.ambiguity_exceptions[]?.key // ""' "$INVENTORY" | sed '/^$/d' >"$declared_ambiguous_raw"
  LC_ALL=C sort -u "$declared_ambiguous_raw" >"$declared_ambiguous"
  if [[ "$(line_count "$declared_ambiguous_raw")" != "$(line_count "$declared_ambiguous")" ]]; then
    echo "[ERROR] duplicate ambiguity exception key" >&2
    check_errors=$((check_errors + 1))
  fi
  if ! cmp -s "$AMBIGUOUS" "$declared_ambiguous"; then
    echo "[ERROR] ambiguous/parser-failed candidate set does not equal declared exceptions" >&2
    echo "[ERROR] undeclared ambiguous candidates:" >&2
    comm -23 "$AMBIGUOUS" "$declared_ambiguous" >&2 || true
    echo "[ERROR] stale ambiguous exceptions:" >&2
    comm -13 "$AMBIGUOUS" "$declared_ambiguous" >&2 || true
    check_errors=$((check_errors + 1))
  fi
  while IFS= read -r exception_key; do
    [[ -n "$exception_key" ]] || continue
    exception_count="$(OCTON_EXCEPTION_KEY="$exception_key" yq -r '[.closed_world_discovery.ambiguity_exceptions[]? | select(.key == strenv(OCTON_EXCEPTION_KEY)) | select((.owner // "") != "" and (.disposition // "") != "" and (.expires // "") != "")] | length' "$INVENTORY")"
    [[ "$exception_count" == "1" ]] || {
      echo "[ERROR] ambiguity exception must have one owner/disposition/expiry: $exception_key" >&2
      check_errors=$((check_errors + 1))
    }
  done <"$declared_ambiguous"

  [[ $check_errors -eq 0 ]] || exit 1
fi

if [[ "$FORMAT" == "keys" ]]; then
  cat "$KEYS"
else
  cat <<SUMMARY
schema_version: octon-material-effect-discovery-v1
commit: "$COMMIT"
tree: "$TREE"
enumerator: "git ls-tree -rz --full-tree <commit>"
ambient_worktree_scan: false
ordering: "LC_ALL=C sorted unique canonical LF"
normalized_key: "kind|repo-relative-posix-path|stable-anchor|grammar-id"
writers:
  count: $WRITER_COUNT
  sha256: "$WRITER_DIGEST"
launchers:
  count: $LAUNCHER_COUNT
  sha256: "$LAUNCHER_DIGEST"
ambiguous_or_parse_failed:
  count: $AMBIGUOUS_COUNT
  sha256: "$AMBIGUOUS_DIGEST"
additive_selection:
  active_count: $ACTIVE_COUNT
  active_sha256: "$ACTIVE_DIGEST"
  inactive_or_quarantined_count: $INACTIVE_COUNT
  inactive_or_quarantined_sha256: "$INACTIVE_DIGEST"
SUMMARY
fi
