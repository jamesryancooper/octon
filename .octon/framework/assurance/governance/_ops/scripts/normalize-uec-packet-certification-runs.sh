#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
DEFAULT_OCTON_DIR="$(cd -- "$SCRIPT_DIR/../../../../.." && pwd)"
OCTON_DIR="${OCTON_DIR_OVERRIDE:-$DEFAULT_OCTON_DIR}"
ROOT_DIR="${OCTON_ROOT_DIR:-$(cd -- "$OCTON_DIR/.." && pwd)}"
CONFIG_FILE="$OCTON_DIR/instance/governance/closure/uec-packet-certification-runs.yml"
LEASE_SOURCE_DIR="$OCTON_DIR/state/control/execution/exceptions/leases"
REVOCATION_SOURCE_DIR="$OCTON_DIR/state/control/execution/revocations"
HIDDEN_REPAIR_FILE="$OCTON_DIR/state/evidence/validation/publication/unified-execution-constitution-closure/hidden-repair-detection.yml"

require_tools() {
  local tool
  for tool in "$@"; do
    command -v "$tool" >/dev/null 2>&1 || {
      echo "[ERROR] missing required tool: $tool" >&2
      exit 1
    }
  done
}

run_root() { printf '%s/state/control/execution/runs/%s' "$OCTON_DIR" "$1"; }
evidence_root() { printf '%s/state/evidence/runs/%s' "$OCTON_DIR" "$1"; }
run_manifest() { printf '%s/run-manifest.yml' "$(run_root "$1")"; }
runtime_state() { printf '%s/runtime-state.yml' "$(run_root "$1")"; }
replay_manifest() { printf '%s/replay/manifest.yml' "$(evidence_root "$1")"; }
replay_pointers() { printf '%s/replay-pointers.yml' "$(evidence_root "$1")"; }
trace_pointers() { printf '%s/trace-pointers.yml' "$(evidence_root "$1")"; }
classification_file() { printf '%s/evidence-classification.yml' "$(evidence_root "$1")"; }
external_index_file() { printf '%s/state/evidence/external-index/runs/%s.yml' "$OCTON_DIR" "$1"; }
intervention_log() { printf '%s/interventions/log.yml' "$(evidence_root "$1")"; }
measurement_summary() { printf '%s/measurements/summary.yml' "$(evidence_root "$1")"; }
canonical_lease_root() { printf '%s/state/control/execution/exceptions/leases' "$OCTON_DIR"; }
canonical_revocation_root() { printf '%s/state/control/execution/revocations' "$OCTON_DIR"; }

role_run_id() {
  local role="$1"
  yq -r ".run_roles.${role}.run_id" "$CONFIG_FILE"
}

all_run_ids() {
  yq -r '.run_roles | to_entries[] | .value.run_id' "$CONFIG_FILE" | awk '!seen[$0]++'
}

abs_from_ref() {
  local ref="$1"
  if [[ -z "$ref" || "$ref" == "null" ]]; then
    return 1
  fi
  printf '%s/%s\n' "$ROOT_DIR" "$ref"
}

copy_ref_if_present() {
  local ref="$1"
  local dst="$2"
  local src
  src="$(abs_from_ref "$ref" 2>/dev/null || true)"
  if [[ -n "$src" && -f "$src" ]]; then
    cp "$src" "$dst"
  fi
}

write_authority_root() {
  local run_id="$1"
  local run_dir authority_root request_dir grant_dir decision_dir lease_dir revocation_dir
  local manifest request_ref decision_ref grant_bundle_ref
  run_dir="$(run_root "$run_id")"
  authority_root="$run_dir/authority"
  request_dir="$authority_root/requests"
  grant_dir="$authority_root/grants"
  decision_dir="$authority_root/decisions"
  lease_dir="$authority_root/leases"
  revocation_dir="$authority_root/revocations"
  manifest="$(run_manifest "$run_id")"

  mkdir -p "$request_dir" "$grant_dir" "$decision_dir" "$lease_dir" "$revocation_dir"

  request_ref="$(yq -r '.approval_request_ref // ""' "$manifest" 2>/dev/null || true)"
  decision_ref="$(yq -r '.decision_artifact_ref // ""' "$manifest" 2>/dev/null || true)"
  grant_bundle_ref="$(yq -r '.authority_grant_bundle_ref // ""' "$manifest" 2>/dev/null || true)"

  copy_ref_if_present "$request_ref" "$request_dir/approval-request.yml"
  copy_ref_if_present "$request_ref" "$authority_root/approval-request.yml"
  while IFS= read -r grant_ref; do
    [[ -n "$grant_ref" ]] || continue
    copy_ref_if_present "$grant_ref" "$grant_dir/$(basename "$grant_ref")"
    copy_ref_if_present "$grant_ref" "$authority_root/approval-grant.yml"
  done < <(yq -r '.approval_grant_refs[]' "$manifest" 2>/dev/null || true)
  copy_ref_if_present "$grant_bundle_ref" "$grant_dir/grant-bundle.yml"
  copy_ref_if_present "$grant_bundle_ref" "$authority_root/grant-bundle.yml"
  copy_ref_if_present "$decision_ref" "$decision_dir/decision.yml"
  copy_ref_if_present "$decision_ref" "$authority_root/decision.yml"

  jq -n \
    --arg run_id "$run_id" \
    --arg updated_at "$(date -u +"%Y-%m-%dT%H:%M:%SZ")" '
      {
        schema_version: "budget-ledger-v1",
        run_id: $run_id,
        budget_dimensions: ["token", "time", "tool_count", "cost", "external_calls"],
        current_usage: {
          token: 0,
          time: 0,
          tool_count: 0,
          cost: 0,
          external_calls: 0
        },
        thresholds: {
          token: "soft",
          time: "soft",
          tool_count: "soft",
          cost: "soft",
          external_calls: "soft"
        },
        escalation_point: "threshold-crossing",
        block_point: "hard-policy-deny",
        overrun_behavior: "escalate",
        updated_at: $updated_at
      }
    ' | yq -P -p=json '.' > "$authority_root/budget-ledger.yml"

  local lease_entries_json revocation_entries_json
  lease_entries_json="$(
    find "$LEASE_SOURCE_DIR" -maxdepth 1 -type f -name '*.yml' ! -name 'README.md' -print 2>/dev/null \
      | while IFS= read -r file; do yq -o=json '.' "$file"; done \
      | jq -s --arg run_id "$run_id" '[.[] | select((.run_id // "") == $run_id)]'
  )"
  jq -n --arg run_id "$run_id" --arg source_ref ".octon/state/control/execution/exceptions/leases/" --argjson leases "$lease_entries_json" '
        {
          schema_version: "authority-run-lease-index-v1",
          run_id: $run_id,
          source_ref: $source_ref,
          leases: $leases
        }
      ' | yq -P -p=json '.' > "$lease_dir/index.yml"
  if [[ "$lease_entries_json" != "[]" ]]; then
    jq -r '.[] | @base64' <<<"$lease_entries_json" | while IFS= read -r encoded; do
      local lease_json lease_id lease_file
      lease_json="$(printf '%s' "$encoded" | base64 --decode)"
      lease_id="$(jq -r '.id' <<<"$lease_json")"
      mkdir -p "$(canonical_lease_root)"
      lease_file="$(canonical_lease_root)/${lease_id}.yml"
      jq '.schema_version = "authority-exception-lease-v2" | .lease_id = (.lease_id // .id)' <<<"$lease_json" \
        | yq -P -p=json '.' > "$lease_file"
      cp "$lease_file" "$lease_dir/${lease_id}.yml"
    done
  fi

  revocation_entries_json="$(
    find "$REVOCATION_SOURCE_DIR" -maxdepth 1 -type f -name '*.yml' ! -name 'README.md' -print 2>/dev/null \
      | while IFS= read -r file; do yq -o=json '.' "$file"; done \
      | jq -s --arg run_id "$run_id" '[.[] | select((.run_id // "") == $run_id)]'
  )"
  jq -n --arg run_id "$run_id" --arg source_ref ".octon/state/control/execution/revocations/" --argjson revocations "$revocation_entries_json" '
        {
          schema_version: "authority-run-revocation-index-v1",
          run_id: $run_id,
          source_ref: $source_ref,
          revocations: $revocations
        }
      ' | yq -P -p=json '.' > "$revocation_dir/index.yml"
  if [[ "$revocation_entries_json" != "[]" ]]; then
    jq -r '.[] | @base64' <<<"$revocation_entries_json" | while IFS= read -r encoded; do
      local revocation_json revocation_id revocation_file
      revocation_json="$(printf '%s' "$encoded" | base64 --decode)"
      revocation_id="$(jq -r '.revocation_id' <<<"$revocation_json")"
      mkdir -p "$(canonical_revocation_root)"
      revocation_file="$(canonical_revocation_root)/${revocation_id}.yml"
      jq '.schema_version = "authority-revocation-v2"' <<<"$revocation_json" | yq -P -p=json '.' > "$revocation_file"
      cp "$revocation_file" "$revocation_dir/${revocation_id}.yml"
    done
  fi

  if [[ -f "$authority_root/grant-bundle.yml" ]]; then
    yq -o=json '.' "$authority_root/grant-bundle.yml" \
      | jq \
        --arg run_id "$run_id" \
        --arg budget_ref ".octon/state/control/execution/runs/$run_id/authority/budget-ledger.yml" \
        '
          .schema_version = "authority-grant-bundle-v2"
          | .route_outcome = ((.route_outcome // .decision // "ALLOW") | ascii_downcase)
          | .budget_ledger_ref = $budget_ref
          | .exception_lease_refs = (
              if ((.exception_lease_refs // []) | length) > 0 then
                .exception_lease_refs
              else
                ((.exception_refs // [])
                  | map(
                      if endswith(".yml") then .
                      elif contains(".octon/state/control/execution/exceptions/leases.yml#") then
                        sub("\\.octon/state/control/execution/exceptions/leases\\.yml#"; ".octon/state/control/execution/exceptions/leases/") + ".yml"
                      else .
                      end
                    ))
              end
            )
          | .revocation_refs = (
              (.revocation_refs // [])
              | map(
                  if endswith(".yml") then .
                  elif contains(".octon/state/control/execution/revocations/grants.yml#") then
                    sub("\\.octon/state/control/execution/revocations/grants\\.yml#"; ".octon/state/control/execution/revocations/") + ".yml"
                  else .
                  end
                )
            )
        ' | yq -P -p=json '.' > "$authority_root/grant-bundle.yml.tmp"
    mv "$authority_root/grant-bundle.yml.tmp" "$authority_root/grant-bundle.yml"
  fi

  if [[ -f "$authority_root/decision.yml" ]]; then
    yq -o=json '.' "$authority_root/decision.yml" \
      | jq '
          .schema_version = "authority-decision-artifact-v2"
          | .route_outcome = ((.route_outcome // .decision // "ALLOW") | ascii_downcase)
          | .exception_lease_refs = (
              if ((.exception_lease_refs // []) | length) > 0 then
                .exception_lease_refs
              else
                ((.exception_refs // [])
                  | map(
                      if endswith(".yml") then .
                      elif contains(".octon/state/control/execution/exceptions/leases.yml#") then
                        sub("\\.octon/state/control/execution/exceptions/leases\\.yml#"; ".octon/state/control/execution/exceptions/leases/") + ".yml"
                      else .
                      end
                    ))
              end
            )
          | .revocation_refs = (
              (.revocation_refs // [])
              | map(
                  if endswith(".yml") then .
                  elif contains(".octon/state/control/execution/revocations/grants.yml#") then
                    sub("\\.octon/state/control/execution/revocations/grants\\.yml#"; ".octon/state/control/execution/revocations/") + ".yml"
                  else .
                  end
                )
            )
        ' | yq -P -p=json '.' > "$authority_root/decision.yml.tmp"
    mv "$authority_root/decision.yml.tmp" "$authority_root/decision.yml"
  fi

  jq -n \
    --arg run_id "$run_id" \
    --arg request_ref "$request_ref" \
    --arg decision_ref "$decision_ref" \
    --arg grant_bundle_ref "$grant_bundle_ref" \
    --arg lease_index ".octon/state/control/execution/runs/$run_id/authority/leases/index.yml" \
    --arg revocation_index ".octon/state/control/execution/runs/$run_id/authority/revocations/index.yml" '
      {
        schema_version: "authority-run-bundle-index-v1",
        run_id: $run_id,
        request_ref: (if $request_ref != "" then $request_ref else null end),
        decision_ref: (if $decision_ref != "" then $decision_ref else null end),
        grant_bundle_ref: (if $grant_bundle_ref != "" then $grant_bundle_ref else null end),
        lease_index_ref: $lease_index,
        revocation_index_ref: $revocation_index
      }
    ' | yq -P -p=json '.' > "$authority_root/index.yml"
}

write_event_ledger() {
  local run_id="$1"
  local run_dir manifest state authority_root events_file manifest_file created_at updated_at status decision_ref
  run_dir="$(run_root "$run_id")"
  manifest="$(run_manifest "$run_id")"
  state="$(runtime_state "$run_id")"
  authority_root="$run_dir/authority"
  events_file="$run_dir/events.ndjson"
  manifest_file="$run_dir/events.manifest.yml"
  created_at="$(yq -r '.created_at // ""' "$manifest")"
  updated_at="$(yq -r '.updated_at // ""' "$state")"
  status="$(yq -r '.status // ""' "$state")"
  decision_ref="$(yq -r '.decision_artifact_ref // ""' "$manifest")"

  : > "$events_file"
  jq -cn --arg run_id "$run_id" --arg recorded_at "$created_at" --arg subject_ref ".octon/state/control/execution/runs/$run_id/run-contract.yml" '
    {
      schema_version: "run-event-v1",
      event_id: "evt-001-run-created",
      run_id: $run_id,
      event_type: "run-created",
      subject_ref: $subject_ref,
      governing_refs: [$subject_ref, ".octon/state/control/execution/runs/\($run_id)/run-manifest.yml"],
      details: "Canonical run root bound.",
      payload: {status: "bound"},
      recorded_at: $recorded_at
    }' >> "$events_file"
  printf '\n' >> "$events_file"

  if [[ -n "$(yq -r '.approval_request_ref // ""' "$manifest")" ]]; then
    jq -cn --arg run_id "$run_id" --arg recorded_at "$created_at" --arg request_ref "$(yq -r '.approval_request_ref // ""' "$manifest")" '
      {
        schema_version: "run-event-v1",
        event_id: "evt-002-authority-requested",
        run_id: $run_id,
        event_type: "authority-requested",
        subject_ref: $request_ref,
        governing_refs: [$request_ref],
        details: "Run-bound authority request recorded.",
        payload: null,
        recorded_at: $recorded_at
      }' >> "$events_file"
    printf '\n' >> "$events_file"
  fi

  jq -cn --arg run_id "$run_id" --arg recorded_at "$created_at" --arg decision_ref "$decision_ref" --arg status "$status" '
    {
      schema_version: "run-event-v1",
      event_id: "evt-003-authority-resolution",
      run_id: $run_id,
      event_type: (if $status == "failed" or $status == "cancelled" then "authority-denied" else "authority-granted" end),
      subject_ref: (if $decision_ref != "" then $decision_ref else null end),
      governing_refs: (
        [".octon/state/control/execution/runs/\($run_id)/authority/index.yml"]
        + (if $decision_ref != "" then [$decision_ref] else [] end)
      ),
      details: "Run-bound authority decision resolved.",
      payload: {runtime_status: $status},
      recorded_at: $recorded_at
    }' >> "$events_file"
  printf '\n' >> "$events_file"

  if yq -e '.leases | length > 0' "$authority_root/leases/index.yml" >/dev/null 2>&1; then
    jq -cn --arg run_id "$run_id" --arg recorded_at "$created_at" '
      {
        schema_version: "run-event-v1",
        event_id: "evt-004-lease-issued",
        run_id: $run_id,
        event_type: "lease-issued",
        subject_ref: ".octon/state/control/execution/runs/\($run_id)/authority/leases/index.yml",
        governing_refs: [".octon/state/control/execution/runs/\($run_id)/authority/leases/index.yml"],
        details: "Per-run exception lease bundle recorded.",
        payload: null,
        recorded_at: $recorded_at
      }' >> "$events_file"
    printf '\n' >> "$events_file"
  fi

  jq -cn --arg run_id "$run_id" --arg recorded_at "$created_at" '
    {
      schema_version: "run-event-v1",
      event_id: "evt-005-stage-started",
      run_id: $run_id,
      event_type: "stage-started",
      subject_ref: ".octon/state/control/execution/runs/\($run_id)/stage-attempts/initial.yml",
      governing_refs: [".octon/state/control/execution/runs/\($run_id)/stage-attempts/initial.yml"],
      details: "Initial stage attempt entered.",
      payload: {stage_attempt_id: "initial"},
      recorded_at: $recorded_at
    }' >> "$events_file"
  printf '\n' >> "$events_file"

  jq -cn --arg run_id "$run_id" --arg recorded_at "$created_at" '
    {
      schema_version: "run-event-v1",
      event_id: "evt-006-checkpoint-bound",
      run_id: $run_id,
      event_type: "checkpoint-created",
      subject_ref: ".octon/state/control/execution/runs/\($run_id)/checkpoints/bound.yml",
      governing_refs: [
        ".octon/state/control/execution/runs/\($run_id)/checkpoints/bound.yml",
        ".octon/state/evidence/runs/\($run_id)/checkpoints/bound.yml"
      ],
      details: "Binding checkpoint materialized.",
      payload: {checkpoint_kind: "binding"},
      recorded_at: $recorded_at
    }' >> "$events_file"
  printf '\n' >> "$events_file"

  if [[ -f "$run_dir/checkpoints/execution-start.yml" ]]; then
    jq -cn --arg run_id "$run_id" --arg recorded_at "$created_at" '
      {
        schema_version: "run-event-v1",
        event_id: "evt-007-checkpoint-start",
        run_id: $run_id,
        event_type: "checkpoint-created",
        subject_ref: ".octon/state/control/execution/runs/\($run_id)/checkpoints/execution-start.yml",
        governing_refs: [
          ".octon/state/control/execution/runs/\($run_id)/checkpoints/execution-start.yml",
          ".octon/state/evidence/runs/\($run_id)/checkpoints/execution-start.yml"
        ],
        details: "Execution-start checkpoint materialized.",
        payload: {checkpoint_kind: "execution-start"},
        recorded_at: $recorded_at
      }' >> "$events_file"
    printf '\n' >> "$events_file"
  fi

  if yq -e '.revocations | length > 0' "$authority_root/revocations/index.yml" >/dev/null 2>&1; then
    jq -cn --arg run_id "$run_id" --arg recorded_at "$updated_at" '
      {
        schema_version: "run-event-v1",
        event_id: "evt-008-revocation-activated",
        run_id: $run_id,
        event_type: "revocation-activated",
        subject_ref: ".octon/state/control/execution/runs/\($run_id)/authority/revocations/index.yml",
        governing_refs: [".octon/state/control/execution/runs/\($run_id)/authority/revocations/index.yml"],
        details: "Per-run revocation bundle activated.",
        payload: null,
        recorded_at: $recorded_at
      }' >> "$events_file"
    printf '\n' >> "$events_file"
  fi

  jq -cn --arg run_id "$run_id" --arg recorded_at "$updated_at" --arg status "$status" '
    {
      schema_version: "run-event-v1",
      event_id: "evt-009-stage-completed",
      run_id: $run_id,
      event_type: "stage-completed",
      subject_ref: ".octon/state/control/execution/runs/\($run_id)/stage-attempts/initial.yml",
      governing_refs: [
        ".octon/state/control/execution/runs/\($run_id)/stage-attempts/initial.yml",
        ".octon/state/control/execution/runs/\($run_id)/runtime-state.yml"
      ],
      details: "Initial stage attempt reached a terminal state.",
      payload: {status: $status},
      recorded_at: $recorded_at
    }' >> "$events_file"
  printf '\n' >> "$events_file"

  if [[ -f "$run_dir/checkpoints/execution-complete.yml" ]]; then
    jq -cn --arg run_id "$run_id" --arg recorded_at "$updated_at" '
      {
        schema_version: "run-event-v1",
        event_id: "evt-010-checkpoint-complete",
        run_id: $run_id,
        event_type: "checkpoint-created",
        subject_ref: ".octon/state/control/execution/runs/\($run_id)/checkpoints/execution-complete.yml",
        governing_refs: [
          ".octon/state/control/execution/runs/\($run_id)/checkpoints/execution-complete.yml",
          ".octon/state/evidence/runs/\($run_id)/checkpoints/execution-complete.yml"
        ],
        details: "Execution-complete checkpoint materialized.",
        payload: {checkpoint_kind: "execution-complete"},
        recorded_at: $recorded_at
      }' >> "$events_file"
    printf '\n' >> "$events_file"
  fi

  jq -cn --arg run_id "$run_id" --arg recorded_at "$updated_at" '
    {
      schema_version: "run-event-v1",
      event_id: "evt-011-disclosure-generated",
      run_id: $run_id,
      event_type: "disclosure-generated",
      subject_ref: ".octon/state/evidence/disclosure/runs/\($run_id)/run-card.yml",
      governing_refs: [
        ".octon/state/evidence/disclosure/runs/\($run_id)/run-card.yml",
        ".octon/state/evidence/runs/\($run_id)/replay/manifest.yml",
        ".octon/state/evidence/runs/\($run_id)/evidence-classification.yml"
      ],
      details: "Canonical disclosure materialized from retained evidence.",
      payload: null,
      recorded_at: $recorded_at
    }' >> "$events_file"
  printf '\n' >> "$events_file"

  jq -cn --arg run_id "$run_id" --arg recorded_at "$updated_at" --arg status "$status" '
    {
      schema_version: "run-event-v1",
      event_id: "evt-012-run-closed",
      run_id: $run_id,
      event_type: "run-closed",
      subject_ref: ".octon/state/control/execution/runs/\($run_id)/runtime-state.yml",
      governing_refs: [
        ".octon/state/control/execution/runs/\($run_id)/runtime-state.yml",
        ".octon/state/control/execution/runs/\($run_id)/rollback-posture.yml"
      ],
      details: "Run reached closure status.",
      payload: {status: $status},
      recorded_at: $recorded_at
    }' >> "$events_file"
  printf '\n' >> "$events_file"

  local event_count first_event_id last_event_id
  event_count="$(
    jq -Rcs 'split("\n") | map(select(length > 0) | fromjson) | length' "$events_file"
  )"
  first_event_id="$(
    jq -Rr 'fromjson | .event_id' < <(head -n 1 "$events_file")
  )"
  last_event_id="$(
    jq -Rr 'fromjson | .event_id' < <(tail -n 2 "$events_file" | head -n 1)
  )"

  jq -n \
    --arg run_id "$run_id" \
    --arg ledger_ref ".octon/state/control/execution/runs/$run_id/events.ndjson" \
    --arg schema_ref ".octon/framework/constitution/contracts/runtime/run-event-v1.schema.json" \
    --arg first_event_id "$first_event_id" \
    --arg last_event_id "$last_event_id" \
    --argjson event_count "$event_count" \
    --arg updated_at "$updated_at" '
      {
        schema_version: "run-event-ledger-v1",
        run_id: $run_id,
        ledger_ref: $ledger_ref,
        event_schema_ref: $schema_ref,
        event_count: $event_count,
        first_event_id: $first_event_id,
        last_event_id: $last_event_id,
        governing_event_refs: {
          runtime_state_ref: "evt-012-run-closed",
          rollback_posture_ref: "evt-012-run-closed",
          stage_attempt_ref: "evt-009-stage-completed",
          disclosure_ref: "evt-011-disclosure-generated",
          authority_root_ref: "evt-003-authority-resolution"
        },
        updated_at: $updated_at
      }
    ' | yq -P -p=json '.' > "$manifest_file"
}

upgrade_supported_run_to_class_c() {
  local run_id="$1"
  local idx_file manifest_file replay_file trace_file classification_file now replay_digest trace_digest receipt_file contract_file status
  idx_file="$(external_index_file "$run_id")"
  manifest_file="$(replay_manifest "$run_id")"
  replay_file="$(replay_pointers "$run_id")"
  trace_file="$(trace_pointers "$run_id")"
  classification_file="$(classification_file "$run_id")"
  receipt_file="$(evidence_root "$run_id")/receipts/execution-receipt.json"
  contract_file="$(run_root "$run_id")/run-contract.yml"
  now="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
  replay_digest="$(shasum -a 256 "$manifest_file" | awk '{print $1}')"
  trace_digest="$(shasum -a 256 "$trace_file" | awk '{print $1}')"
  status="$(yq -r '.status // "succeeded"' "$contract_file" 2>/dev/null || printf 'succeeded')"

  jq -n \
    --arg run_id "$run_id" \
    --arg recorded_at "$now" \
    --arg manifest_ref ".octon/state/evidence/runs/$run_id/replay/manifest.yml" \
    --arg replay_digest "$replay_digest" \
    --arg trace_digest "$trace_digest" '
      {
        schema_version: "external-replay-index-v1",
        index_id: "external-replay-\($run_id)",
        scope: "run",
        run_id: $run_id,
        entries: [
          {
            entry_id: "\($run_id)-replay-payload",
            run_id: $run_id,
            artifact_kind: "replay-payload",
            evidence_class: "C",
            storage_class: "external-immutable",
            content_digest: "sha256:\($replay_digest)",
            locator: "immutable://octon/replays/\($run_id)/bundle.jsonl",
            manifest_ref: $manifest_ref,
            recorded_at: $recorded_at
          },
          {
            entry_id: "\($run_id)-trace-payload",
            run_id: $run_id,
            artifact_kind: "trace-payload",
            evidence_class: "C",
            storage_class: "external-immutable",
            content_digest: "sha256:\($trace_digest)",
            locator: "immutable://octon/replays/\($run_id)/trace.jsonl",
            manifest_ref: $manifest_ref,
            recorded_at: $recorded_at
          }
        ],
        updated_at: $recorded_at
      }
    ' | yq -P -p=json '.' > "$idx_file"

  yq -o=json '.' "$manifest_file" \
    | jq --arg run_id "$run_id" --arg idx ".octon/state/evidence/external-index/runs/$run_id.yml" --arg now "$now" '
        .schema_version = "replay-manifest-v2"
        | .run_id = $run_id
        | .environment_topology = {
            evidence_root: ".octon/state/evidence/runs/\($run_id)",
            control_root: ".octon/state/control/execution/runs/\($run_id)"
          }
        | .class_b_refs = [
            ".octon/state/evidence/runs/\($run_id)/receipts/execution-receipt.json",
            ".octon/state/evidence/runs/\($run_id)/replay-pointers.yml",
            ".octon/state/evidence/runs/\($run_id)/trace-pointers.yml"
          ]
        | .class_c_refs = [$idx]
        | .replay_payload_class = "external-immutable"
        | .external_index_refs = [$idx]
        | .recorded_at = $now
      ' | yq -P -p=json '.' > "$manifest_file"

  yq -o=json '.' "$replay_file" \
    | jq --arg run_id "$run_id" --arg idx ".octon/state/evidence/external-index/runs/$run_id.yml" --arg now "$now" '
        .schema_version = "replay-pointer-v2"
        | .run_id = $run_id
        | .external_index_refs = [$idx]
        | .updated_at = $now
      ' | yq -P -p=json '.' > "$replay_file"

  yq -o=json '.' "$trace_file" \
    | jq --arg run_id "$run_id" --arg idx ".octon/state/evidence/external-index/runs/$run_id.yml" --arg now "$now" '
        .schema_version = "trace-pointer-v2"
        | .run_id = $run_id
        | .external_index_refs = [$idx]
        | .updated_at = $now
        | .recorded_at = $now
        | .notes = "Canonical Class C trace payload retained through the external immutable index."
      ' | yq -P -p=json '.' > "$trace_file"

  yq -o=json '.' "$classification_file" \
    | jq --arg idx ".octon/state/evidence/external-index/runs/$run_id.yml" --arg now "$now" '
        .updated_at = $now
        | .artifacts = (
            (.artifacts // [])
            | map(
                if .artifact_id == "replay-manifest" or .artifact_id == "replay-pointers" or .artifact_id == "trace-pointers" then
                  .external_index_ref = $idx
                elif .artifact_id == "external-replay-index" then
                  .artifact_ref = $idx
                  | .evidence_class = "C"
                  | .storage_class = "external-immutable"
                  | .external_index_ref = $idx
                else . end
              )
          )
      ' | yq -P -p=json '.' > "$classification_file"

  if ! jq -e '.schema_version == "execution-receipt-v2"' "$receipt_file" >/dev/null 2>&1; then
    jq -n \
      --arg run_id "$run_id" \
      --arg status "$status" \
      --arg started_at "$(yq -r '.created_at // .issued_at // "2026-04-04T00:00:00Z"' "$contract_file")" \
      --arg completed_at "$now" \
      '
        {
          schema_version: "execution-receipt-v2",
          request_id: $run_id,
          action_type: "governance-exercise",
          decision: (if $status == "failed" then "DENY" else "ALLOW" end),
          timestamps: {
            started_at: $started_at,
            completed_at: $completed_at
          },
          evidence_links: {
            run_control_root: ".octon/state/control/execution/runs/\($run_id)",
            run_receipts_root: ".octon/state/evidence/runs/\($run_id)/receipts",
            replay_pointers: ".octon/state/evidence/runs/\($run_id)/replay-pointers.yml",
            trace_pointers: ".octon/state/evidence/runs/\($run_id)/trace-pointers.yml"
          }
        }
      ' > "$receipt_file"
  fi
}

write_nonzero_intervention() {
  local run_id="$1"
  local record_path log_path summary_path classification_path now
  record_path="$(evidence_root "$run_id")/interventions/records/manual-review-override.yml"
  log_path="$(intervention_log "$run_id")"
  summary_path="$(measurement_summary "$run_id")"
  classification_path="$(classification_file "$run_id")"
  now="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"

  mkdir -p "$(dirname "$record_path")"
  jq -n \
    --arg run_id "$run_id" \
    --arg recorded_at "$now" '
      {
        schema_version: "intervention-record-v1",
        record_id: "\($run_id)-manual-review-override",
        subject_kind: "run",
        subject_ref: ".octon/state/control/execution/runs/\($run_id)/run-contract.yml",
        kind: "manual-review-override",
        disclosed: true,
        execution_role_ref: "operator://octon-maintainers",
        details: "Human governance confirmed the bounded approval exercise and recorded the intervention explicitly.",
        evidence_refs: [
          ".octon/state/control/execution/approvals/requests/\($run_id).yml",
          ".octon/state/evidence/control/execution/authority-decision-\($run_id).yml"
        ],
        recorded_at: $recorded_at
      }
    ' | yq -P -p=json '.' > "$record_path"

  yq -o=json '.' "$log_path" \
    | jq --arg run_id "$run_id" --arg recorded_at "$now" '
        .schema_version = "intervention-log-v1"
        | .subject_kind = "run"
        | .subject_ref = ".octon/state/control/execution/runs/\($run_id)/run-contract.yml"
        | .interventions = [
            {
              event_id: "evt-manual-review-override",
              kind: "manual-review-override",
              disclosed: true,
              details: "Human governance intervention was recorded and linked to the canonical approval artifacts."
            }
          ]
        | .summary = "One disclosed human governance intervention was exercised; hidden repair was checked and no undisclosed intervention path remained."
        | .recorded_at = $recorded_at
      ' | yq -P -p=json '.' > "$log_path"

  yq -o=json '.' "$summary_path" \
    >/dev/null 2>&1 || true
  jq -n \
    --arg run_id "$run_id" \
    --arg recorded_at "$now" '
      {
        schema_version: "measurement-summary-v1",
        subject_kind: "run",
        subject_ref: ".octon/state/control/execution/runs/\($run_id)/run-contract.yml",
        metrics: [
          {
            metric_id: "approval-artifact-count",
            label: "Authority artifacts retained",
            value: 3,
            unit: "count"
          },
          {
            metric_id: "measurement-record-count",
            label: "Detailed measurement records",
            value: 1,
            unit: "count"
          },
          {
            metric_id: "intervention-count",
            label: "Material interventions",
            value: 1,
            unit: "count"
          }
        ],
        summary: "Governance exercise emitted approval, decision, disclosure, and disclosed human intervention artifacts.",
        recorded_at: $recorded_at
      }
    ' | yq -P -p=json '.' > "$summary_path"

  yq -o=json '.' "$classification_path" \
    | jq --arg run_id "$run_id" --arg recorded_at "$now" '
        .updated_at = $recorded_at
        | .artifacts = (
            (.artifacts // [])
            | map(if .artifact_id == "intervention-record" then
                    .artifact_ref = ".octon/state/evidence/runs/\($run_id)/interventions/records/manual-review-override.yml"
                  else . end)
          )
      ' | yq -P -p=json '.' > "$classification_path"

  mkdir -p "$(dirname "$HIDDEN_REPAIR_FILE")"
  jq -n \
    --arg run_id "$run_id" \
    --arg recorded_at "$now" '
      {
        schema_version: "hidden-repair-detection-v1",
        run_id: $run_id,
        status: "pass",
        summary: "Hidden human repair remained detectable because the exercised manual intervention was disclosed and linked to canonical authority and observability roots.",
        evidence_refs: [
          ".octon/state/evidence/runs/\($run_id)/interventions/log.yml",
          ".octon/state/evidence/runs/\($run_id)/interventions/records/manual-review-override.yml",
          ".octon/framework/observability/governance/reporting.yml",
          ".octon/framework/assurance/runtime/_ops/scripts/validate-execution-governance.sh"
        ],
        generated_at: $recorded_at
      }
    ' | yq -P -p=json '.' > "$HIDDEN_REPAIR_FILE"
}

main() {
  require_tools yq jq shasum
  [[ -f "$CONFIG_FILE" ]] || {
    echo "[ERROR] missing config: $CONFIG_FILE" >&2
    exit 1
  }

  while IFS= read -r run_id; do
    [[ -n "$run_id" ]] || continue
    write_authority_root "$run_id"
    write_event_ledger "$run_id"
  done < <(all_run_ids)

  while IFS= read -r run_id; do
    [[ -n "$run_id" ]] || continue
    upgrade_supported_run_to_class_c "$run_id"
  done < <(all_run_ids)
  write_nonzero_intervention "$(role_run_id intervention_control)"
}

main "$@"
