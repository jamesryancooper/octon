#!/usr/bin/env bash
set -euo pipefail

TITLE=""
SUMMARY="Autonomy helper: open draft PR."
HOW_TEXT="Uses the local autonomy script to create a draft PR scaffold."
TRADEOFFS_TEXT="n/a"
TESTING_TEXT="Pending; update before marking ready."
ROLLOUT_TEXT="n/a"
ISSUE_NUMBER=""
NO_ISSUE_REASON="autonomy-script"
COMMIT_MESSAGE=""
BASE_BRANCH="main"
DRY_RUN=0
LABELS_CSV=""
STAGE_ALL=0

usage() {
  cat <<'USAGE'
Usage:
  git-pr-open.sh --title "<type(scope): summary>" [options]

Options:
  --summary <text>           Replace default "What" section summary.
  --issue <number>           Add "Closes #<number>" linkage to PR body.
  --no-issue <reason>        Add "No-Issue: <reason>" linkage (default).
  --commit-message <text>    Commit message for staged changes (defaults to --title).
  --base <branch>            Base branch for PR creation (default: main).
  --label <name>             Add label at PR creation (repeatable).
  --stage-all                Stage all tracked/untracked files before commit.
  --dry-run                  Print actions without mutating state.

Behavior:
  - Commits staged changes, or stages all changes with --stage-all.
  - Pushes current branch to origin.
  - Populates canonical PR template sections by heading and always opens a draft PR.
USAGE
}

error() {
  echo "[ERROR] $1" >&2
  exit 1
}

info() {
  echo "[INFO] $1"
}

require_cmd() {
  local cmd="$1"
  command -v "$cmd" >/dev/null 2>&1 || error "Missing required command: $cmd"
}

repo_root() {
  git rev-parse --show-toplevel 2>/dev/null || true
}

replace_markdown_section() {
  local file="$1"
  local heading="$2"
  local replacement="$3"
  local tmp

  tmp="$(mktemp "${TMPDIR:-/tmp}/octon-pr-body-section.XXXXXX")"
  if ! awk -v heading="$heading" -v replacement="$replacement" '
    BEGIN {
      found = 0
      in_section = 0
    }
    $0 == heading {
      found = 1
      in_section = 1
      print
      print ""
      print replacement
      print ""
      next
    }
    /^## / {
      in_section = 0
    }
    !in_section {
      print
    }
    END {
      if (!found) {
        exit 1
      }
    }
  ' "$file" > "$tmp"; then
    rm -f "$tmp"
    error "Canonical PR template is missing expected section heading: $heading"
  fi

  mv "$tmp" "$file"
}

replace_literal_line() {
  local file="$1"
  local needle="$2"
  local replacement="$3"
  local tmp

  tmp="$(mktemp "${TMPDIR:-/tmp}/octon-pr-body-line.XXXXXX")"
  if ! awk -v needle="$needle" -v replacement="$replacement" '
    BEGIN {
      found = 0
    }
    {
      if ($0 == needle) {
        print replacement
        found = 1
        next
      }
      print
    }
    END {
      if (!found) {
        exit 1
      }
    }
  ' "$file" > "$tmp"; then
    rm -f "$tmp"
    error "Canonical PR template is missing expected line: $needle"
  fi

  mv "$tmp" "$file"
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --title)
      shift
      [[ $# -gt 0 ]] || error "--title requires a value"
      TITLE="$1"
      ;;
    --summary)
      shift
      [[ $# -gt 0 ]] || error "--summary requires a value"
      SUMMARY="$1"
      ;;
    --issue)
      shift
      [[ $# -gt 0 ]] || error "--issue requires a value"
      ISSUE_NUMBER="$1"
      ;;
    --no-issue)
      shift
      [[ $# -gt 0 ]] || error "--no-issue requires a value"
      NO_ISSUE_REASON="$1"
      ;;
    --commit-message)
      shift
      [[ $# -gt 0 ]] || error "--commit-message requires a value"
      COMMIT_MESSAGE="$1"
      ;;
    --base)
      shift
      [[ $# -gt 0 ]] || error "--base requires a value"
      BASE_BRANCH="$1"
      ;;
    --ready)
      error "git-pr-open.sh is draft-only. Use git-pr-ship.sh --request-ready once author action items are closed."
      ;;
    --label)
      shift
      [[ $# -gt 0 ]] || error "--label requires a value"
      if [[ -z "$LABELS_CSV" ]]; then
        LABELS_CSV="$1"
      else
        LABELS_CSV="${LABELS_CSV},$1"
      fi
      ;;
    --stage-all)
      STAGE_ALL=1
      ;;
    --dry-run)
      DRY_RUN=1
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      error "Unknown argument: $1"
      ;;
  esac
  shift
done

require_cmd git
require_cmd gh
require_cmd jq

REPO_ROOT="$(repo_root)"
[[ -n "$REPO_ROOT" ]] || error "Run this command from inside a git repository."

STANDARDS_FILE="$REPO_ROOT/.octon/framework/execution-roles/practices/standards/commit-pr-standards.json"
TEMPLATE_FILE="$REPO_ROOT/.github/PULL_REQUEST_TEMPLATE.md"

[[ -f "$STANDARDS_FILE" ]] || error "Missing standards file: $STANDARDS_FILE"
[[ -f "$TEMPLATE_FILE" ]] || error "Missing PR template file: $TEMPLATE_FILE"
[[ -n "$TITLE" ]] || error "--title is required."

if [[ -n "$ISSUE_NUMBER" && "$NO_ISSUE_REASON" != "autonomy-script" ]]; then
  error "Use either --issue or --no-issue, not both."
fi

if [[ -z "$COMMIT_MESSAGE" ]]; then
  COMMIT_MESSAGE="$TITLE"
fi

ALLOWED_TYPES_REGEX="$(jq -r '.commit.allowed_types | join("|")' "$STANDARDS_FILE")"
SCOPE_PATTERN="$(jq -r '.commit.scope_pattern' "$STANDARDS_FILE")"
COMMIT_HEADER_MAX="$(jq -r '.commit.header_max_length' "$STANDARDS_FILE")"
SUMMARY_LOWERCASE="$(jq -r '.commit.summary_must_be_lowercase' "$STANDARDS_FILE")"
SUMMARY_NO_PERIOD="$(jq -r '.commit.summary_must_not_end_with_period' "$STANDARDS_FILE")"

TITLE_REGEX="^(${ALLOWED_TYPES_REGEX})\\(${SCOPE_PATTERN}\\)!?: .+"
COMMIT_REGEX="^(${ALLOWED_TYPES_REGEX})\\(${SCOPE_PATTERN}\\): (.+)$"

[[ "$TITLE" =~ $TITLE_REGEX ]] || error "PR title must match conventional format: <type>(<scope>): <summary>"

if [[ ${#COMMIT_MESSAGE} -gt "$COMMIT_HEADER_MAX" ]]; then
  error "Commit message header exceeds ${COMMIT_HEADER_MAX} characters."
fi

if [[ ! "$COMMIT_MESSAGE" =~ $COMMIT_REGEX ]]; then
  error "Commit message must match contract: <type>(<scope>): <summary>"
fi

COMMIT_SUMMARY="${BASH_REMATCH[2]}"
if [[ "$SUMMARY_LOWERCASE" == "true" ]]; then
  COMMIT_SUMMARY_LOWER="$(printf '%s' "$COMMIT_SUMMARY" | tr '[:upper:]' '[:lower:]')"
  if [[ "$COMMIT_SUMMARY" != "$COMMIT_SUMMARY_LOWER" ]]; then
    error "Commit summary must be lowercase."
  fi
fi
if [[ "$SUMMARY_NO_PERIOD" == "true" && "$COMMIT_SUMMARY" == *"." ]]; then
  error "Commit summary must not end with a period."
fi

CURRENT_BRANCH="$(git -C "$REPO_ROOT" rev-parse --abbrev-ref HEAD)"
[[ "$CURRENT_BRANCH" != "HEAD" ]] || error "Detached HEAD is not supported."
[[ "$CURRENT_BRANCH" != "main" ]] || error "Refusing to open PR from main. Create a feature branch first."

HAS_STAGED=1
git -C "$REPO_ROOT" diff --cached --quiet && HAS_STAGED=0 || true
HAS_DIRTY=0
[[ -n "$(git -C "$REPO_ROOT" status --porcelain)" ]] && HAS_DIRTY=1 || true

if [[ "$HAS_STAGED" -eq 0 && "$HAS_DIRTY" -eq 1 && "$STAGE_ALL" -eq 1 ]]; then
  info "Staging all working tree changes."
  if [[ "$DRY_RUN" -eq 1 ]]; then
    echo "[DRY] git -C \"$REPO_ROOT\" add -A"
  else
    git -C "$REPO_ROOT" add -A
  fi
  HAS_STAGED=1
fi

if [[ "$HAS_STAGED" -eq 1 ]]; then
  info "Committing staged changes."
  if [[ "$DRY_RUN" -eq 1 ]]; then
    echo "[DRY] git -C \"$REPO_ROOT\" commit -m \"$COMMIT_MESSAGE\""
  else
    git -C "$REPO_ROOT" commit -m "$COMMIT_MESSAGE"
  fi
elif [[ "$HAS_DIRTY" -eq 1 ]]; then
  error "Working tree has unstaged changes. Stage intended files or use --stage-all."
else
  info "No local changes to commit."
fi

if git -C "$REPO_ROOT" rev-parse --abbrev-ref --symbolic-full-name "@{u}" >/dev/null 2>&1; then
  if [[ "$DRY_RUN" -eq 1 ]]; then
    echo "[DRY] git -C \"$REPO_ROOT\" push"
  else
    git -C "$REPO_ROOT" push
  fi
else
  if [[ "$DRY_RUN" -eq 1 ]]; then
    echo "[DRY] git -C \"$REPO_ROOT\" push -u origin \"$CURRENT_BRANCH\""
  else
    git -C "$REPO_ROOT" push -u origin "$CURRENT_BRANCH"
  fi
fi

if [[ -n "$ISSUE_NUMBER" ]]; then
  ISSUE_LINK="Closes #${ISSUE_NUMBER}"
else
  ISSUE_LINK="No-Issue: ${NO_ISSUE_REASON}"
fi

WHY_TEXT="${SUMMARY} ${ISSUE_LINK}"

BODY_TMP="$(mktemp "${TMPDIR:-/tmp}/octon-pr-body.XXXXXX")"
cp "$TEMPLATE_FILE" "$BODY_TMP"
replace_markdown_section "$BODY_TMP" "## What" "$SUMMARY"
replace_markdown_section "$BODY_TMP" "## Why" "$WHY_TEXT"
replace_markdown_section "$BODY_TMP" "## How" "$HOW_TEXT"
replace_markdown_section "$BODY_TMP" "## Tradeoffs" "$TRADEOFFS_TEXT"
replace_markdown_section "$BODY_TMP" "## Testing" "$TESTING_TEXT"
replace_markdown_section "$BODY_TMP" "## Rollout" "$ROLLOUT_TEXT"
replace_literal_line "$BODY_TMP" "- Risk class: [ ] Trivial [ ] Low [ ] Medium [ ] High" "- Risk class: [ ] Trivial [x] Low [ ] Medium [ ] High"
replace_literal_line "$BODY_TMP" "- Rollback plan:" "- Rollback plan: revert the squash commit if needed."
replace_literal_line "$BODY_TMP" "- Flags changed (name, owner, expiry, rollout):" "- Flags changed (name, owner, expiry, rollout): none."

PR_ARGS=(pr create --base "$BASE_BRANCH" --head "$CURRENT_BRANCH" --title "$TITLE" --body-file "$BODY_TMP" --draft)
if [[ -n "$LABELS_CSV" ]]; then
  PR_ARGS+=(--label "$LABELS_CSV")
fi

if [[ "$DRY_RUN" -eq 1 ]]; then
  echo "[DRY] gh ${PR_ARGS[*]}"
  rm -f "$BODY_TMP"
  exit 0
fi

gh "${PR_ARGS[@]}"
rm -f "$BODY_TMP"
