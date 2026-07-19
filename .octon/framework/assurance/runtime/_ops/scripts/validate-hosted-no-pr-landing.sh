#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
OCTON_DIR="$(cd -- "$SCRIPT_DIR/../../../../../" && pwd)"
RECEIPT=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --receipt) shift; RECEIPT="${1:-}" ;;
    --skip-live-remote|--skip-schema) ;;
    -h|--help) echo "Usage: validate-hosted-no-pr-landing.sh [--receipt <json>]"; exit 0 ;;
    *) echo "[ERROR] unknown argument: $1" >&2; exit 2 ;;
  esac
  shift
done

POLICY="$OCTON_DIR/framework/product/contracts/default-work-unit.yml"
LANDER="$OCTON_DIR/framework/execution-roles/_ops/scripts/git/git-branch-land-hosted-no-pr.sh"
AUTHORIZER="$OCTON_DIR/framework/execution-roles/_ops/scripts/git/git-branch-authorize-hosted-no-pr.sh"

yq -e '.hosted_provider_ruleset.branch_no_pr_hosted_landing.mechanism == "disabled" and .hosted_provider_ruleset.branch_no_pr_hosted_landing.no_pr_mutation == false' "$POLICY" >/dev/null
grep -Fq 'RP00_CONTAINMENT_PUBLICATION_DISABLED' "$LANDER"
grep -Fq 'before fetch, push, remote update, or ref mutation' "$LANDER"
grep -Fq 'RP00_CONTAINMENT_PUBLICATION_DISABLED' "$AUTHORIZER"
grep -Fq 'no approval receipt was emitted' "$AUTHORIZER"

if [[ -n "$RECEIPT" ]]; then
  jq -e . "$RECEIPT" >/dev/null
  echo "[ERROR] hosted no-PR landing receipts cannot satisfy a current SI-00 gate" >&2
  exit 1
fi

echo "[OK] hosted no-PR landing and authorization are contained"
