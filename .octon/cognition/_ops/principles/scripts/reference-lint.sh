#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../../.." && pwd)"
cd "$ROOT_DIR"

PRINCIPLES_DIR="${PRINCIPLES_DIR_OVERRIDE:-.octon/cognition/governance/principles}"

declare -i failures=0

if [[ ! -d "$PRINCIPLES_DIR" ]]; then
  echo "[missing-dir] principles directory not found: $PRINCIPLES_DIR"
  exit 1
fi

if ! command -v rg >/dev/null 2>&1; then
  rg() {
    local opt_n=0 opt_i=0 opt_q=0 opt_c=0 opt_v=0 opt_x=0 opt_fixed=0
    local pattern=""
    local token=""
    local -a targets=()

    while (($#)); do
      token="$1"
      case "$token" in
        -n) opt_n=1 ;;
        -i) opt_i=1 ;;
        -q) opt_q=1 ;;
        -c) opt_c=1 ;;
        -v) opt_v=1 ;;
        -x) opt_x=1 ;;
        -F) opt_fixed=1 ;;
        --glob)
          shift
          ;;
        --glob=*)
          ;;
        --hidden|--no-ignore|--multiline|--pcre2)
          ;;
        --)
          shift
          break
          ;;
        -*)
          ;;
        *)
          if [[ -z "$pattern" ]]; then
            pattern="$token"
          else
            targets+=("$token")
          fi
          ;;
      esac
      shift
    done

    while (($#)); do
      targets+=("$1")
      shift
    done

    local -a grep_opts=()
    ((opt_n)) && grep_opts+=("-n")
    ((opt_i)) && grep_opts+=("-i")
    ((opt_q)) && grep_opts+=("-q")
    ((opt_c)) && grep_opts+=("-c")
    ((opt_v)) && grep_opts+=("-v")
    ((opt_x)) && grep_opts+=("-x")
    if ((opt_fixed)); then
      grep_opts+=("-F")
    else
      grep_opts+=("-E")
    fi

    if [[ -z "$pattern" ]]; then
      echo "[rg-shim] missing search pattern" >&2
      return 2
    fi

    if ((${#targets[@]} == 0)); then
      grep "${grep_opts[@]}" -- "$pattern"
      return
    fi

    local recurse=0
    local p=""
    for p in "${targets[@]}"; do
      if [[ -d "$p" ]]; then
        recurse=1
        break
      fi
    done

    if ((recurse)); then
      grep "${grep_opts[@]}" -R -- "$pattern" "${targets[@]}"
    else
      grep "${grep_opts[@]}" -- "$pattern" "${targets[@]}"
    fi
  }
fi

slugify() {
  local value="$1"
  value="$(printf '%s' "$value" | tr '[:upper:]' '[:lower:]')"
  value="$(printf '%s' "$value" | sed -E 's/`//g; s/[^a-z0-9 _-]//g; s/[[:space:]]+/-/g; s/-+/-/g; s/^-+//; s/-+$//')"
  printf '%s' "$value"
}

has_anchor() {
  local file="$1"
  local target="$2"
  local in_code=0
  local line=""
  local heading=""
  local slug=""

  while IFS= read -r line; do
    if [[ "$line" =~ ^\`\`\` ]]; then
      if [[ "$in_code" -eq 0 ]]; then
        in_code=1
      else
        in_code=0
      fi
      continue
    fi

    if [[ "$in_code" -eq 1 ]]; then
      continue
    fi

    if [[ "$line" =~ ^#{1,6}[[:space:]]+(.+) ]]; then
      heading="${BASH_REMATCH[1]}"
      slug="$(slugify "$heading")"
      if [[ "$slug" == "$target" ]]; then
        return 0
      fi
    fi
  done < "$file"

  return 1
}

check_links_and_anchors() {
  local file=""
  local token=""
  local raw_target=""
  local target=""
  local target_path=""
  local target_anchor=""
  local resolved=""

  while IFS= read -r file; do
    while IFS= read -r token; do
      raw_target="${token#*](}"
      raw_target="${raw_target%)}"
      target="${raw_target%% *}"

      [[ -z "$target" ]] && continue
      [[ "$target" == http://* || "$target" == https://* || "$target" == mailto:* ]] && continue

      if [[ "$target" == \#* ]]; then
        target_path="$file"
        target_anchor="${target#\#}"
      else
        target_path="${target%%#*}"
        target_anchor=""
        if [[ "$target" == *#* ]]; then
          target_anchor="${target#*#}"
        fi
      fi

      if [[ "$target_path" == /* ]]; then
        resolved=".${target_path}"
      else
        resolved="$(dirname "$file")/${target_path}"
      fi

      if [[ ! -e "$resolved" ]]; then
        echo "[broken-link] $file -> $target (missing: $resolved)"
        failures+=1
        continue
      fi

      if [[ -n "$target_anchor" && -f "$resolved" ]]; then
        if ! has_anchor "$resolved" "$target_anchor"; then
          echo "[broken-anchor] $file -> $target (anchor not found: #$target_anchor)"
          failures+=1
        fi
      fi
    done < <(grep -oE '\[[^]]+\]\([^)]*\)' "$file" || true)
  done < <(find "$PRINCIPLES_DIR" -type f -name '*.md' | sort)
}

check_stale_reference_patterns() {
  local stale=""
  stale="$(rg -n '\.octon/cognition/principles/pillars/' "$PRINCIPLES_DIR" --glob '*.md' || true)"
  if [[ -n "$stale" ]]; then
    echo "[stale-reference] Found stale '/principles/pillars/' references:"
    printf '%s\n' "$stale"
    failures+=1
  fi

  stale="$(rg -n '\[EvalKit\]\(/\.octon/' "$PRINCIPLES_DIR/determinism.md" || true)"
  if [[ -n "$stale" ]]; then
    echo "[stale-reference] Found root-absolute EvalKit markdown link in determinism principle:"
    printf '%s\n' "$stale"
    failures+=1
  fi
}

check_links_and_anchors
check_stale_reference_patterns

if [[ "$failures" -gt 0 ]]; then
  echo "Principles reference lint failed with $failures issue(s)."
  exit 1
fi

echo "Principles reference lint passed."
