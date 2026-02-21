#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../../.." && pwd)"
cd "$ROOT_DIR"

PRINCIPLES_DIR="${PRINCIPLES_DIR_OVERRIDE:-.harmony/cognition/governance/principles}"

declare -i failures=0

if [[ ! -d "$PRINCIPLES_DIR" ]]; then
  echo "[missing-dir] principles directory not found: $PRINCIPLES_DIR"
  exit 1
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
  stale="$(rg -n '\.harmony/cognition/principles/pillars/' "$PRINCIPLES_DIR" --glob '*.md' || true)"
  if [[ -n "$stale" ]]; then
    echo "[stale-reference] Found stale '/principles/pillars/' references:"
    printf '%s\n' "$stale"
    failures+=1
  fi

  stale="$(rg -n '\[EvalKit\]\(/\.harmony/' "$PRINCIPLES_DIR/determinism.md" || true)"
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
