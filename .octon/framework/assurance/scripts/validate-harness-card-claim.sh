#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/_validator_common.sh"
release_id="$(resolve_validator_release_id "${1:-}")"
harness_card="$(release_root "$release_id")/harness-card.yml"
coverage="$(release_root "$release_id")/closure/support-universe-coverage.yml"
claim_status="$(yq -r '.claim_status' "$harness_card")"
known_limits_count="$(yq -r '(.known_limits // []) | length' "$harness_card")"
excluded_surfaces_count="$(yq -r '(.excluded_surfaces // []) | length' "$coverage")"

yq -e '.claim_kind == "release"' "$harness_card" >/dev/null 2>&1 || {
  echo "[ERROR] HarnessCard claim_kind must be release" >&2
  exit 1
}

yq -e '.support_universe.model_classes[] | select(. == "frontier-governed")' "$harness_card" >/dev/null 2>&1 || {
  echo "[ERROR] HarnessCard must disclose frontier-governed model support" >&2
  exit 1
}

yq -e '.capability_packs[] | select(. == "browser")' "$harness_card" >/dev/null 2>&1 || {
  echo "[ERROR] HarnessCard must disclose browser capability support" >&2
  exit 1
}

case "$claim_status" in
  complete)
    if [[ "$excluded_surfaces_count" != "0" ]]; then
      echo "[ERROR] complete HarnessCard claims must not retain excluded_surfaces" >&2
      exit 1
    fi

    if [[ "$known_limits_count" == "0" ]]; then
      summary="The active HarnessCard discloses the full target support universe with no in-scope exclusions."
    else
      summary="The active HarnessCard discloses a complete admitted support universe with explicit bounded known limits."
    fi
    ;;
  incomplete)
    if [[ "$known_limits_count" == "0" ]]; then
      echo "[ERROR] incomplete HarnessCard claims must disclose at least one known limit" >&2
      exit 1
    fi

    summary="The active HarnessCard truthfully discloses an incomplete target-state claim with explicit known limits."
    ;;
  *)
    echo "[ERROR] unsupported HarnessCard claim_status: $claim_status" >&2
    exit 1
    ;;
esac

write_validator_report "$release_id" "universal-attainment-proof.yml" "V-DISC-002" "pass" "$summary"
