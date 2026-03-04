#!/usr/bin/env bash
set -euo pipefail

failures=()

add_failure() {
  failures+=("$1")
}

is_pr_triggered() {
  local file="$1"
  rg -q '^[[:space:]]{2}(pull_request|pull_request_target):' "$file"
}

has_push_and_pr() {
  local file="$1"
  rg -q '^[[:space:]]{2}push:' "$file" && rg -q '^[[:space:]]{2}(pull_request|pull_request_target):' "$file"
}

push_is_scoped() {
  local file="$1"
  # Require explicit branch or tag scoping specifically under `on.push`.
  awk '
    BEGIN {
      in_push = 0
      scoped = 0
    }

    # Inline map form: `push: { branches: [main] }`
    /^[[:space:]]{2}push:[[:space:]]*\{.*(branches|branches-ignore|tags|tags-ignore)[[:space:]]*:/ {
      scoped = 1
      next
    }

    /^[[:space:]]{2}push:[[:space:]]*$/ {
      in_push = 1
      next
    }

    in_push && /^[[:space:]]{2}[A-Za-z0-9_-]+:[[:space:]]*$/ {
      in_push = 0
    }

    in_push && /^[[:space:]]{4}(branches|branches-ignore|tags|tags-ignore):/ {
      scoped = 1
      next
    }

    END {
      exit scoped ? 0 : 1
    }
  ' "$file"
}

has_concurrency() {
  local file="$1"
  rg -q '^concurrency:' "$file"
}

has_timeout_minutes() {
  local file="$1"
  rg -q 'timeout-minutes:' "$file"
}

schedule_is_too_frequent() {
  local file="$1"
  local hit="0"

  while IFS= read -r line; do
    if [[ "$line" =~ cron:[[:space:]]*\'\*/([0-9]+)[[:space:]]+\*[[:space:]]+\*[[:space:]]+\*[[:space:]]+\*\' ]]; then
      interval="${BASH_REMATCH[1]}"
      if [[ "$interval" -lt 60 ]]; then
        hit="1"
      fi
    fi
  done < "$file"

  [[ "$hit" == "1" ]]
}

collect_files() {
  local files=()

  if [[ "${GITHUB_EVENT_NAME:-}" == "pull_request" && -n "${GITHUB_BASE_REF:-}" ]]; then
    local script_changed="0"

    git fetch --no-tags --depth=1 origin "${GITHUB_BASE_REF}" >/dev/null 2>&1 || true
    while IFS= read -r file; do
      [[ -z "$file" ]] && continue

      if [[ "$file" == ".github/scripts/ci-efficiency-guard.sh" ]]; then
        script_changed="1"
        continue
      fi

      files+=("$file")
    done < <(git diff --name-only "origin/${GITHUB_BASE_REF}...HEAD" -- .github/workflows/*.yml .github/workflows/*.yaml .github/scripts/ci-efficiency-guard.sh 2>/dev/null || true)

    if [[ "$script_changed" == "1" ]]; then
      while IFS= read -r file; do
        files+=("$file")
      done < <(find .github/workflows -maxdepth 1 -type f \( -name '*.yml' -o -name '*.yaml' \) | sort)
    fi
  else
    while IFS= read -r file; do
      files+=("$file")
    done < <(find .github/workflows -maxdepth 1 -type f \( -name '*.yml' -o -name '*.yaml' \) | sort)
  fi

  printf '%s\n' "${files[@]}"
}

mapfile -t workflow_files < <(collect_files)

if [[ "${#workflow_files[@]}" -eq 0 ]]; then
  echo "No workflow files detected; nothing to validate."
  exit 0
fi

for wf in "${workflow_files[@]}"; do
  [[ -f "$wf" ]] || continue

  if is_pr_triggered "$wf"; then
    if ! has_concurrency "$wf"; then
      add_failure "$wf: PR-triggered workflow missing top-level concurrency block"
    fi

    if ! has_timeout_minutes "$wf"; then
      add_failure "$wf: PR-triggered workflow missing timeout-minutes discipline"
    fi
  fi

  if has_push_and_pr "$wf"; then
    if ! push_is_scoped "$wf"; then
      add_failure "$wf: workflow with both push and PR triggers must scope push branches/tags"
    fi
  fi

  if rg -q '^[[:space:]]{2}schedule:' "$wf"; then
    if schedule_is_too_frequent "$wf"; then
      add_failure "$wf: schedule interval under 60 minutes is disallowed unless allowlisted"
    fi
  fi

done

if [[ "${#failures[@]}" -gt 0 ]]; then
  echo "CI efficiency policy violations detected:"
  for item in "${failures[@]}"; do
    echo "- $item"
  done
  exit 1
fi

echo "CI efficiency policy check passed for ${#workflow_files[@]} workflow file(s)."
