#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
if [[ -n "${COGNITION_DIR_OVERRIDE:-}" ]]; then
  COGNITION_DIR="$(cd -- "$COGNITION_DIR_OVERRIDE" && pwd)"
else
  COGNITION_DIR="$(cd -- "$SCRIPT_DIR/../../.." && pwd)"
fi
STANDALONE_FIXTURE_MODE=0
if [[ -n "${COGNITION_DIR_OVERRIDE:-}" ]] && [[ -d "$COGNITION_DIR/runtime" ]] && [[ ! -d "$COGNITION_DIR/../../instance/cognition" ]]; then
  STANDALONE_FIXTURE_MODE=1
fi

if [[ "$STANDALONE_FIXTURE_MODE" -eq 1 ]]; then
  OCTON_DIR="$COGNITION_DIR"
  ROOT_DIR="$(cd -- "$COGNITION_DIR/.." && pwd)"
  INSTANCE_COGNITION_DIR="$COGNITION_DIR/runtime"
  INSTANCE_COGNITION_SHARED_DIR="$COGNITION_DIR/runtime"
  GENERATED_COGNITION_DIR="$COGNITION_DIR/runtime"
else
  OCTON_DIR="$(cd -- "$COGNITION_DIR/../.." && pwd)"
  ROOT_DIR="$(cd -- "$OCTON_DIR/.." && pwd)"
  INSTANCE_COGNITION_DIR="$OCTON_DIR/instance/cognition"
  INSTANCE_COGNITION_SHARED_DIR="$INSTANCE_COGNITION_DIR/context/shared"
  GENERATED_COGNITION_DIR="$OCTON_DIR/generated/cognition"
fi

if [[ "$STANDALONE_FIXTURE_MODE" -eq 1 ]]; then
  CONTEXT_INDEX_PATH="$COGNITION_DIR/runtime/context/index.yml"
  DECISIONS_INDEX_PATH="$COGNITION_DIR/runtime/decisions/index.yml"
  DECISIONS_SUMMARY_PATH="$COGNITION_DIR/runtime/summaries/decisions.md"
  MIGRATIONS_INDEX_PATH="$COGNITION_DIR/runtime/migrations/index.yml"
  ANALYSES_INDEX_PATH="$COGNITION_DIR/runtime/analyses/index.yml"
  KNOWLEDGE_INDEX_PATH="$COGNITION_DIR/runtime/knowledge/index.yml"
  EVIDENCE_INDEX_PATH="$COGNITION_DIR/runtime/evidence/index.yml"
  EVALUATIONS_INDEX_PATH="$COGNITION_DIR/runtime/evaluations/index.yml"
  DIGESTS_INDEX_PATH="$COGNITION_DIR/runtime/evaluations/digests/index.yml"
  DIGESTS_DIR="$COGNITION_DIR/runtime/evaluations/digests"
  OPEN_ACTIONS_PATH="$COGNITION_DIR/runtime/evaluations/actions/open-actions.yml"
  PROJECTION_DEFINITION_PATH="$COGNITION_DIR/runtime/projections/definitions/cognition-runtime-surface-map.yml"
  PROJECTION_MATERIALIZED_PATH="$COGNITION_DIR/runtime/projections/materialized/cognition-runtime-surface-map.latest.yml"
  PROJECTIONS_INDEX_PATH="$COGNITION_DIR/runtime/projections/index.yml"
  GRAPH_NODES_PATH="$COGNITION_DIR/runtime/knowledge/graph/nodes.yml"
  GRAPH_EDGES_PATH="$COGNITION_DIR/runtime/knowledge/graph/edges.yml"
  INGESTION_RECEIPTS_PATH="$COGNITION_DIR/runtime/knowledge/sources/ingestion-receipts.yml"
else
  CONTEXT_INDEX_PATH="$INSTANCE_COGNITION_DIR/context/index.yml"
  DECISIONS_INDEX_PATH="$INSTANCE_COGNITION_DIR/decisions/index.yml"
  DECISIONS_SUMMARY_PATH="$GENERATED_COGNITION_DIR/summaries/decisions.md"
  MIGRATIONS_INDEX_PATH="$INSTANCE_COGNITION_SHARED_DIR/migrations/index.yml"
  ANALYSES_INDEX_PATH="$INSTANCE_COGNITION_SHARED_DIR/analyses/index.yml"
  KNOWLEDGE_INDEX_PATH="$INSTANCE_COGNITION_SHARED_DIR/knowledge/index.yml"
  EVIDENCE_INDEX_PATH="$INSTANCE_COGNITION_SHARED_DIR/evidence/index.yml"
  EVALUATIONS_INDEX_PATH="$INSTANCE_COGNITION_SHARED_DIR/evaluations/index.yml"
  DIGESTS_INDEX_PATH="$INSTANCE_COGNITION_SHARED_DIR/evaluations/digests/index.yml"
  DIGESTS_DIR="$INSTANCE_COGNITION_SHARED_DIR/evaluations/digests"
  OPEN_ACTIONS_PATH="$INSTANCE_COGNITION_SHARED_DIR/evaluations/actions/open-actions.yml"
  PROJECTION_DEFINITION_PATH="$GENERATED_COGNITION_DIR/projections/definitions/cognition-runtime-surface-map.yml"
  PROJECTION_MATERIALIZED_PATH="$GENERATED_COGNITION_DIR/projections/materialized/cognition-runtime-surface-map.latest.yml"
  PROJECTIONS_INDEX_PATH="$GENERATED_COGNITION_DIR/projections/index.yml"
  GRAPH_NODES_PATH="$GENERATED_COGNITION_DIR/graph/nodes.yml"
  GRAPH_EDGES_PATH="$GENERATED_COGNITION_DIR/graph/edges.yml"
  INGESTION_RECEIPTS_PATH="$INSTANCE_COGNITION_SHARED_DIR/knowledge/sources/ingestion-receipts.yml"
  MISSION_REGISTRY_PATH="$OCTON_DIR/instance/orchestration/missions/registry.yml"
  MISSION_AUTHORITY_ROOT="$OCTON_DIR/instance/orchestration/missions"
  MISSION_CONTROL_ROOT="$OCTON_DIR/state/control/execution/missions"
  RUN_CONTROL_ROOT="$OCTON_DIR/state/control/execution/runs"
  RUN_EVIDENCE_ROOT="$OCTON_DIR/state/evidence/runs"
  MISSION_CONTINUITY_ROOT="$OCTON_DIR/state/continuity/repo/missions"
  MISSION_EFFECTIVE_ROUTE_ROOT="$OCTON_DIR/generated/effective/orchestration/missions"
  MISSION_SUMMARIES_ROOT="$GENERATED_COGNITION_DIR/summaries/missions"
  OPERATOR_DIGESTS_ROOT="$GENERATED_COGNITION_DIR/summaries/operators"
  MISSION_PROJECTION_ROOT="$GENERATED_COGNITION_DIR/projections/materialized/missions"
  MISSION_EFFECTIVE_ROUTE_PUBLISHER="$OCTON_DIR/framework/orchestration/runtime/_ops/scripts/publish-mission-effective-route.sh"
fi
RUNTIME_DIR="$COGNITION_DIR/runtime"
if [[ -n "${OUTPUT_DIR_OVERRIDE:-}" ]]; then
  EVIDENCE_DIR="$(cd -- "$OUTPUT_DIR_OVERRIDE/state/evidence" && pwd)"
else
  EVIDENCE_DIR="$(cd -- "$COGNITION_DIR/../../state/evidence" && pwd)"
fi
ROOT_MANIFEST_PATH="$OCTON_DIR/octon.yml"
GENERATOR_VERSION="${GENERATOR_VERSION_OVERRIDE:-}"
if [[ -z "$GENERATOR_VERSION" ]]; then
  if [[ -f "$ROOT_MANIFEST_PATH" ]]; then
    GENERATOR_VERSION="$(yq -r '.versioning.harness.release_version // ""' "$ROOT_MANIFEST_PATH" 2>/dev/null || true)"
  else
    GENERATOR_VERSION="fixture"
  fi
fi

MODE="apply"
declare -a REQUESTED_TARGETS=()

usage() {
  cat <<'USAGE'
Usage: sync-runtime-artifacts.sh [--check] [--target <name> ...]

Generates deterministic cognition runtime derived artifacts:
- generated/cognition/summaries/decisions.md
- generated/cognition/summaries/missions/<mission-id>/{now,next,recent,recover}.md
- generated/cognition/summaries/operators/<operator-id>/*.md
- generated/cognition/projections/materialized/cognition-runtime-surface-map.latest.yml
- generated/cognition/projections/materialized/missions/<mission-id>/mission-view.yml
- instance/cognition/context/shared/evidence/index.yml
- instance/cognition/context/shared/evaluations/digests/index.yml
- instance/cognition/context/shared/evaluations/actions/open-actions.yml
- generated/cognition/graph/nodes.yml
- generated/cognition/graph/edges.yml
- instance/cognition/context/shared/knowledge/sources/ingestion-receipts.yml

Options:
  --check   Validate generated artifacts are up to date without writing files.
  --target  Generate only specific artifact target(s). Repeatable.
            Targets:
              decisions
              missions
              projections
              evidence
              evaluations-digests
              evaluations-actions
              evaluations
              knowledge-nodes
              knowledge-edges
              knowledge-receipts
              knowledge
  -h, --help  Show this message.
USAGE
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --check)
      MODE="check"
      shift
      ;;
    --target)
      if [[ $# -lt 2 ]]; then
        echo "Missing value for --target" >&2
        usage >&2
        exit 2
      fi
      REQUESTED_TARGETS+=("$2")
      shift 2
      ;;
    --target=*)
      REQUESTED_TARGETS+=("${1#--target=}")
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown argument: $1" >&2
      usage >&2
      exit 2
      ;;
  esac
done

TMP_ROOT="$(mktemp -d)"
STAGE_DIR="$TMP_ROOT/stage"
mkdir -p "$STAGE_DIR"
trap 'rm -rf "$TMP_ROOT"' EXIT

declare -a GENERATED_TARGETS=()

today_utc() {
  date -u +"%Y-%m-%d"
}

timestamp_utc() {
  date -u +"%Y-%m-%dT%H:%M:%SZ"
}

trim_line() {
  local value="$1"
  value="${value#${value%%[![:space:]]*}}"
  value="${value%${value##*[![:space:]]}}"
  printf '%s' "$value"
}

strip_quotes() {
  local value
  value="$(trim_line "$1")"
  value="${value%\"}"
  value="${value#\"}"
  value="${value%\'}"
  value="${value#\'}"
  printf '%s' "$value"
}

yaml_escape() {
  printf '%s' "$1" | sed -e 's/\\/\\\\/g' -e 's/"/\\"/g'
}

markdown_escape() {
  printf '%s' "$1" | sed -e 's/|/\\|/g'
}

yaml_quote() {
  local value="$1"
  value="${value//\\/\\\\}"
  value="${value//\"/\\\"}"
  printf '"%s"' "$value"
}

stage_path_for_target() {
  local target="$1"
  local rel=""
  if [[ "$target" == "$COGNITION_DIR/"* ]]; then
    rel="${target#$COGNITION_DIR/}"
  elif [[ "$target" == "$ROOT_DIR/"* ]]; then
    rel="${target#$ROOT_DIR/}"
  else
    rel="${target#/}"
  fi
  printf '%s/%s' "$STAGE_DIR" "$rel"
}

register_target() {
  local target="$1"
  local existing
  for existing in "${GENERATED_TARGETS[@]}"; do
    if [[ "$existing" == "$target" ]]; then
      return
    fi
  done
  GENERATED_TARGETS+=("$target")
}

normalize_dynamic_value() {
  local file="$1"
  local key="$2"
  local placeholder="$3"
  sed -E \
    -e "s#^(${key}:[[:space:]]*)\"?[^\"[:space:]]+\"?#\\1\"${placeholder}\"#" \
    -e "s#^([[:space:]]*ingested_at:[[:space:]]*)\"?[^\"[:space:]]+\"?#\\1\"${placeholder}\"#" \
    "$file"
}

extract_yaml_scalar() {
  local file="$1"
  local key="$2"
  awk -v key="$key" '
    $0 ~ "^[[:space:]]*" key ":[[:space:]]*" {
      line=$0
      sub("^[[:space:]]*" key ":[[:space:]]*", "", line)
      sub(/[[:space:]]+#.*/, "", line)
      gsub(/^"/, "", line)
      gsub(/"$/, "", line)
      print line
      exit
    }
  ' "$file"
}

extract_active_mission_ids() {
  local file="$1"
  awk '
    /^active:[[:space:]]*\[[[:space:]]*\][[:space:]]*$/ { exit }
    /^active:[[:space:]]*$/ { in_active=1; next }
    in_active && /^[^[:space:]]/ { in_active=0 }
    in_active && /^[[:space:]]*-[[:space:]]*/ {
      line=$0
      sub(/^[[:space:]]*-[[:space:]]*/, "", line)
      gsub(/^"/, "", line)
      gsub(/"$/, "", line)
      print line
    }
  ' "$file"
}

collect_mission_run_ids() {
  local mission_id="$1"
  [[ -d "$RUN_CONTROL_ROOT" ]] || return 0
  while IFS= read -r contract_file; do
    [[ -n "$contract_file" ]] || continue
    if [[ "$(yq -r '.objective_refs.mission_id // ""' "$contract_file" 2>/dev/null || true)" == "$mission_id" ]]; then
      basename "$(dirname "$contract_file")"
    fi
  done < <(find "$RUN_CONTROL_ROOT" -mindepth 2 -maxdepth 2 -type f -name 'run-contract.yml' | sort)
}

operator_slug() {
  local value="$1"
  value="${value#operator://}"
  value="${value#repo://}"
  printf '%s' "$value" | tr '/:@' '---'
}

finalize_candidate() {
  local target="$1"
  local raw_file="$2"
  local dynamic_key="${3:-}"
  local dynamic_format="${4:-}"
  local stage_file

  stage_file="$(stage_path_for_target "$target")"
  mkdir -p "$(dirname -- "$stage_file")"

  if [[ -z "$dynamic_key" ]]; then
    cp "$raw_file" "$stage_file"
    register_target "$target"
    return
  fi

  local placeholder
  placeholder="__$(printf '%s' "$dynamic_key" | tr '[:lower:]-' '[:upper:]_')__"

  local resolved_value
  if [[ "$dynamic_format" == "date" ]]; then
    resolved_value="$(today_utc)"
  else
    resolved_value="$(timestamp_utc)"
  fi

  if [[ -f "$target" ]]; then
    local existing_norm candidate_norm existing_value
    existing_norm="$(normalize_dynamic_value "$target" "$dynamic_key" "$placeholder")"
    candidate_norm="$(normalize_dynamic_value "$raw_file" "$dynamic_key" "$placeholder")"
    if [[ "$existing_norm" == "$candidate_norm" ]]; then
      existing_value="$(extract_yaml_scalar "$target" "$dynamic_key" || true)"
      if [[ -n "$existing_value" ]]; then
        resolved_value="$existing_value"
      fi
    fi
  fi

  local escaped
  escaped="$(printf '%s' "$resolved_value" | sed -e 's/[\\&]/\\\\&/g')"
  sed "s#${placeholder}#${escaped}#g" "$raw_file" > "$stage_file"
  register_target "$target"
}

resolve_cognition_source() {
  local rel="$1"
  local staged="$STAGE_DIR/$rel"
  if [[ -f "$staged" ]]; then
    printf '%s' "$staged"
  else
    printf '%s/%s' "$COGNITION_DIR" "$rel"
  fi
}

resolve_target_source() {
  local target="$1"
  local staged
  staged="$(stage_path_for_target "$target")"
  if [[ -f "$staged" ]]; then
    printf '%s' "$staged"
  else
    printf '%s' "$target"
  fi
}

frontmatter_value() {
  local file="$1"
  local key="$2"
  awk -v key="$key" '
    /^---[[:space:]]*$/ {
      delim++
      if (delim == 2) exit
      next
    }
    delim == 1 && $0 ~ "^[[:space:]]*" key ":[[:space:]]*" {
      line=$0
      sub("^[[:space:]]*" key ":[[:space:]]*", "", line)
      sub(/[[:space:]]+#.*/, "", line)
      gsub(/^"/, "", line)
      gsub(/"$/, "", line)
      print line
      exit
    }
  ' "$file"
}

extract_adr_title() {
  local file="$1"
  local value
  value="$(frontmatter_value "$file" "title" || true)"
  if [[ -n "$value" ]]; then
    printf '%s' "$value"
    return
  fi
  awk '
    /^# / {
      line=$0
      sub(/^# /, "", line)
      print line
      exit
    }
  ' "$file"
}

extract_adr_date() {
  local file="$1"
  local value
  value="$(frontmatter_value "$file" "date" || true)"
  if [[ -n "$value" ]]; then
    printf '%s' "$value"
    return
  fi
  awk '
    /^- Date:[[:space:]]*/ {
      line=$0
      sub(/^- Date:[[:space:]]*/, "", line)
      print line
      exit
    }
  ' "$file"
}

extract_adr_status() {
  local file="$1"
  local value
  value="$(frontmatter_value "$file" "status" || true)"
  if [[ -n "$value" ]]; then
    printf '%s' "$value"
    return
  fi
  awk '
    /^- Status:[[:space:]]*/ {
      line=$0
      sub(/^- Status:[[:space:]]*/, "", line)
      print line
      exit
    }
    /^## Status[[:space:]]*$/ {
      in_status=1
      next
    }
    in_status == 1 {
      if ($0 ~ /^[[:space:]]*$/) next
      line=$0
      gsub(/^[[:space:]]+/, "", line)
      gsub(/[[:space:]]+$/, "", line)
      print line
      exit
    }
  ' "$file"
}

extract_index_id_path() {
  local index_file="$1"
  awk '
    /^[[:space:]]+- id:[[:space:]]*/ {
      id=$0
      sub(/^[[:space:]]+- id:[[:space:]]*/, "", id)
      gsub(/"/, "", id)
    }
    /^[[:space:]]+path:[[:space:]]*/ {
      path=$0
      sub(/^[[:space:]]+path:[[:space:]]*/, "", path)
      gsub(/"/, "", path)
      print id "\t" path
    }
  ' "$index_file"
}

extract_migration_records() {
  local index_file="$1"
  awk '
    /^[[:space:]]+- id:[[:space:]]*/ {
      id=$0
      sub(/^[[:space:]]+- id:[[:space:]]*/, "", id)
      gsub(/"/, "", id)
    }
    /^[[:space:]]+path:[[:space:]]*/ {
      path=$0
      sub(/^[[:space:]]+path:[[:space:]]*/, "", path)
      gsub(/"/, "", path)
    }
    /^[[:space:]]+adr:[[:space:]]*/ {
      adr=$0
      sub(/^[[:space:]]+adr:[[:space:]]*/, "", adr)
      gsub(/"/, "", adr)
    }
    /^[[:space:]]+evidence:[[:space:]]*/ {
      evidence=$0
      sub(/^[[:space:]]+evidence:[[:space:]]*/, "", evidence)
      gsub(/"/, "", evidence)
      print id "\t" path "\t" adr "\t" evidence
    }
  ' "$index_file"
}

extract_evidence_records() {
  local index_file="$1"
  awk '
    /^[[:space:]]+- id:[[:space:]]*/ {
      id=$0
      sub(/^[[:space:]]+- id:[[:space:]]*/, "", id)
      gsub(/"/, "", id)
    }
    /^[[:space:]]+kind:[[:space:]]*/ {
      kind=$0
      sub(/^[[:space:]]+kind:[[:space:]]*/, "", kind)
      gsub(/"/, "", kind)
    }
    /^[[:space:]]+path:[[:space:]]*/ {
      path=$0
      sub(/^[[:space:]]+path:[[:space:]]*/, "", path)
      gsub(/"/, "", path)
    }
    /^[[:space:]]+source_record:[[:space:]]*/ {
      source=$0
      sub(/^[[:space:]]+source_record:[[:space:]]*/, "", source)
      gsub(/"/, "", source)
      print id "\t" kind "\t" path "\t" source
    }
  ' "$index_file"
}

extract_digest_records() {
  local index_file="$1"
  awk '
    /^[[:space:]]+- id:[[:space:]]*/ {
      id=$0
      sub(/^[[:space:]]+- id:[[:space:]]*/, "", id)
      gsub(/"/, "", id)
    }
    /^[[:space:]]+path:[[:space:]]*/ {
      path=$0
      sub(/^[[:space:]]+path:[[:space:]]*/, "", path)
      gsub(/"/, "", path)
      if (records == 1) {
        print id "\t" path
      }
    }
    /^records:[[:space:]]*$/ {
      records=1
    }
  ' "$index_file"
}

extract_runtime_surface_records() {
  local projection_file="$1"
  awk '
    /^runtime_surfaces:[[:space:]]*$/ {
      in_surfaces=1
      next
    }
    in_surfaces == 1 && /^[[:space:]]+- id:[[:space:]]*/ {
      id=$0
      sub(/^[[:space:]]+- id:[[:space:]]*/, "", id)
      gsub(/"/, "", id)
      next
    }
    in_surfaces == 1 && /^[[:space:]]+index:[[:space:]]*/ {
      path=$0
      sub(/^[[:space:]]+index:[[:space:]]*/, "", path)
      gsub(/"/, "", path)
      print id "\t" path
      next
    }
    in_surfaces == 1 && /^[^[:space:]]/ {
      in_surfaces=0
    }
  ' "$projection_file"
}

extract_actions_from_ledger() {
  local ledger_file="$1"
  awk '
    /^[[:space:]]+- id:[[:space:]]*/ {
      id=$0
      sub(/^[[:space:]]+- id:[[:space:]]*/, "", id)
      gsub(/"/, "", id)
      next
    }
    /^[[:space:]]+source_digest:[[:space:]]*/ {
      source=$0
      sub(/^[[:space:]]+source_digest:[[:space:]]*/, "", source)
      gsub(/"/, "", source)
      next
    }
    /^[[:space:]]+owner:[[:space:]]*/ {
      owner=$0
      sub(/^[[:space:]]+owner:[[:space:]]*/, "", owner)
      gsub(/"/, "", owner)
      next
    }
    /^[[:space:]]+due_date:[[:space:]]*/ {
      due=$0
      sub(/^[[:space:]]+due_date:[[:space:]]*/, "", due)
      gsub(/"/, "", due)
      next
    }
    /^[[:space:]]+status:[[:space:]]*/ {
      status=$0
      sub(/^[[:space:]]+status:[[:space:]]*/, "", status)
      gsub(/"/, "", status)
      next
    }
    /^[[:space:]]+summary:[[:space:]]*/ {
      summary=$0
      sub(/^[[:space:]]+summary:[[:space:]]*/, "", summary)
      gsub(/"/, "", summary)
      next
    }
    /^[[:space:]]+evidence:[[:space:]]*/ {
      evidence=$0
      sub(/^[[:space:]]+evidence:[[:space:]]*/, "", evidence)
      gsub(/"/, "", evidence)
      print id "\t" source "\t" owner "\t" due "\t" status "\t" summary "\t" evidence
    }
  ' "$ledger_file"
}

extract_digest_actions() {
  local digest_file="$1"
  awk '
    function flush_action() {
      if (id == "") return
      # Use Unit Separator to preserve empty fields when read by bash.
      printf "%s\037%s\037%s\037%s\037%s\037%s\n", id, owner, due_date, status, summary, evidence
      id=""
      owner=""
      due_date=""
      status=""
      summary=""
      evidence=""
    }
    /^---[[:space:]]*$/ {
      delim++
      if (delim == 2) {
        flush_action()
        exit
      }
      next
    }
    delim == 1 {
      if ($0 ~ /^actions:[[:space:]]*$/) {
        in_actions=1
        next
      }
      if (in_actions != 1) {
        next
      }

      if ($0 ~ /^[[:space:]]*-[[:space:]]+id:[[:space:]]*/) {
        flush_action()
        line=$0
        sub(/^[[:space:]]*-[[:space:]]+id:[[:space:]]*/, "", line)
        gsub(/^"/, "", line)
        gsub(/"$/, "", line)
        id=line
        next
      }

      if ($0 ~ /^[[:space:]]+owner:[[:space:]]*/) {
        line=$0
        sub(/^[[:space:]]+owner:[[:space:]]*/, "", line)
        gsub(/^"/, "", line)
        gsub(/"$/, "", line)
        owner=line
        next
      }

      if ($0 ~ /^[[:space:]]+due_date:[[:space:]]*/) {
        line=$0
        sub(/^[[:space:]]+due_date:[[:space:]]*/, "", line)
        gsub(/^"/, "", line)
        gsub(/"$/, "", line)
        due_date=line
        next
      }

      if ($0 ~ /^[[:space:]]+status:[[:space:]]*/) {
        line=$0
        sub(/^[[:space:]]+status:[[:space:]]*/, "", line)
        gsub(/^"/, "", line)
        gsub(/"$/, "", line)
        status=line
        next
      }

      if ($0 ~ /^[[:space:]]+summary:[[:space:]]*/) {
        line=$0
        sub(/^[[:space:]]+summary:[[:space:]]*/, "", line)
        gsub(/^"/, "", line)
        gsub(/"$/, "", line)
        summary=line
        next
      }

      if ($0 ~ /^[[:space:]]+evidence:[[:space:]]*/) {
        line=$0
        sub(/^[[:space:]]+evidence:[[:space:]]*/, "", line)
        gsub(/^"/, "", line)
        gsub(/"$/, "", line)
        evidence=line
        next
      }

      if ($0 ~ /^[^[:space:]]/ && $0 !~ /^actions:[[:space:]]*$/) {
        in_actions=0
      }
    }
    END {
      flush_action()
    }
  ' "$digest_file"
}

generate_decisions_context() {
  local index_file
  local raw

  index_file="$DECISIONS_INDEX_PATH"
  raw="$(mktemp "$TMP_ROOT/decisions.XXXX")"

  {
    cat <<'HEADER'
---
title: Decisions
description: Generated ADR summary for cognition runtime decision discovery.
mutability: generated
generated_from:
  - /.octon/instance/cognition/decisions/index.yml
  - /.octon/instance/cognition/decisions/*.md
generated_at: "__GENERATED_AT__"
generator_version: "__GENERATOR_VERSION__"
---

# Decisions

This file is generated by `/.octon/framework/cognition/_ops/runtime/scripts/sync-runtime-artifacts.sh`.
Do not edit manually. Update ADR files and `/.octon/instance/cognition/decisions/index.yml` instead.

## ADR Catalog

| ADR | Status | Date | Title | Path |
|---|---|---|---|---|
HEADER

    while IFS=$'\t' read -r record_id record_path; do
      [[ -z "$record_id" || -z "$record_path" ]] && continue
      local adr_file
      local adr_number
      local title
      local status
      local date

      adr_file="$(dirname "$DECISIONS_INDEX_PATH")/$record_path"
      adr_number="${record_id%%-*}"

      if [[ -f "$adr_file" ]]; then
        title="$(extract_adr_title "$adr_file" || true)"
        status="$(extract_adr_status "$adr_file" || true)"
        date="$(extract_adr_date "$adr_file" || true)"
      else
        title="missing ADR file"
        status="unknown"
        date="unknown"
      fi

      [[ -z "$title" ]] && title="$record_id"
      [[ -z "$status" ]] && status="unknown"
      [[ -z "$date" ]] && date="unknown"

      title="$(markdown_escape "$title")"
      status="$(markdown_escape "$status")"
      date="$(markdown_escape "$date")"

      printf '| ADR-%s | %s | %s | %s | `/.octon/instance/cognition/decisions/%s` |\n' "$adr_number" "$status" "$date" "$title" "$record_path"
    done < <(extract_index_id_path "$index_file")

    cat <<'FOOTER'

## Update Procedure

1. Add or update ADR files in `/.octon/instance/cognition/decisions/`.
2. Update `/.octon/instance/cognition/decisions/index.yml`.
3. Run `bash .octon/framework/cognition/_ops/runtime/scripts/sync-runtime-artifacts.sh`.
FOOTER
  } > "$raw"

  perl -0pi -e 's#__GENERATOR_VERSION__#'"$GENERATOR_VERSION"'#g' "$raw"
  finalize_candidate "$DECISIONS_SUMMARY_PATH" "$raw" "generated_at" "timestamp"
}

generate_projection_materialized() {
  local target
  local raw

  target="$PROJECTION_MATERIALIZED_PATH"
  raw="$(mktemp "$TMP_ROOT/projection.XXXX")"

  {
    cat <<'HEADER'
projection_id: cognition-runtime-surface-map
schema_version: "1.0"
generated_at: "__GENERATED_AT__"
generator_version: "__GENERATOR_VERSION__"
generated_from:
  - ../definitions/cognition-runtime-surface-map.yml
  - __CONTEXT_INDEX__
  - __DECISIONS_INDEX__
  - __MIGRATIONS_INDEX__
  - __ANALYSES_INDEX__
  - __KNOWLEDGE_INDEX__
  - __EVIDENCE_INDEX__
  - __EVALUATIONS_INDEX__
  - __PROJECTIONS_INDEX__

runtime_surfaces:
HEADER

    cat <<'SURFACES'
  - id: context
    index: __CONTEXT_INDEX__
  - id: decisions
    index: __DECISIONS_INDEX__
  - id: migrations
    index: __MIGRATIONS_INDEX__
  - id: analyses
    index: __ANALYSES_INDEX__
  - id: knowledge
    index: __KNOWLEDGE_INDEX__
  - id: evidence
    index: __EVIDENCE_INDEX__
  - id: evaluations
    index: __EVALUATIONS_INDEX__
  - id: projections
    index: __PROJECTIONS_INDEX__
SURFACES
  } > "$raw"

  perl -0pi -e 's#__CONTEXT_INDEX__#'"$CONTEXT_INDEX_PATH"'#g; s#__DECISIONS_INDEX__#'"$DECISIONS_INDEX_PATH"'#g; s#__MIGRATIONS_INDEX__#'"$MIGRATIONS_INDEX_PATH"'#g; s#__ANALYSES_INDEX__#'"$ANALYSES_INDEX_PATH"'#g; s#__KNOWLEDGE_INDEX__#'"$KNOWLEDGE_INDEX_PATH"'#g; s#__EVIDENCE_INDEX__#'"$EVIDENCE_INDEX_PATH"'#g; s#__EVALUATIONS_INDEX__#'"$EVALUATIONS_INDEX_PATH"'#g; s#__PROJECTIONS_INDEX__#'"$PROJECTIONS_INDEX_PATH"'#g;' "$raw"

  perl -0pi -e 's#__GENERATOR_VERSION__#'"$GENERATOR_VERSION"'#g' "$raw"
  finalize_candidate "$target" "$raw" "generated_at" "timestamp"
}

generate_mission_autonomy_views() {
  local mission_id
  [[ -f "$MISSION_REGISTRY_PATH" ]] || return 0

  while IFS= read -r mission_id; do
    [[ -n "$mission_id" ]] || continue

    local mission_dir="$MISSION_AUTHORITY_ROOT/$mission_id"
    local control_dir="$MISSION_CONTROL_ROOT/$mission_id"
    local continuity_dir="$MISSION_CONTINUITY_ROOT/$mission_id"
    local scenario_route_file="$MISSION_EFFECTIVE_ROUTE_ROOT/$mission_id/scenario-resolution.yml"
    local mission_file="$mission_dir/mission.yml"
    local mode_state_file="$control_dir/mode-state.yml"
    local intent_register_file="$control_dir/intent-register.yml"
    local autonomy_budget_file="$control_dir/autonomy-budget.yml"
    local circuit_breakers_file="$control_dir/circuit-breakers.yml"
    local subscriptions_file="$control_dir/subscriptions.yml"
    local handoff_file="$continuity_dir/handoff.md"
    local next_actions_file="$continuity_dir/next-actions.yml"

    if [[ "$MODE" != "check" && -x "$MISSION_EFFECTIVE_ROUTE_PUBLISHER" ]]; then
      bash "$MISSION_EFFECTIVE_ROUTE_PUBLISHER" --mission-id "$mission_id" >/dev/null
    fi
    [[ -f "$scenario_route_file" ]] || {
      echo "missing mission scenario route: ${scenario_route_file#$ROOT_DIR/}" >&2
      return 1
    }

    local title status mission_class owner_ref oversight_mode execution_posture phase budget_state breaker_state safety_state
    local route_family route_boundary_class route_digest_route route_recovery_window route_generated_at route_fresh_until route_action_class
    local route_scenario_source route_boundary_source route_recovery_source
    local route_ref current_slice_ref next_slice_ref active_directives active_authorize_updates
    title="$(extract_yaml_scalar "$mission_file" "title")"
    status="$(extract_yaml_scalar "$mission_file" "status")"
    mission_class="$(extract_yaml_scalar "$mission_file" "mission_class")"
    owner_ref="$(extract_yaml_scalar "$mission_file" "owner_ref")"
    safety_state="$(extract_yaml_scalar "$mode_state_file" "safety_state")"
    oversight_mode="$(yq -r '.effective.oversight_mode // ""' "$scenario_route_file" 2>/dev/null || true)"
    execution_posture="$(yq -r '.effective.execution_posture // ""' "$scenario_route_file" 2>/dev/null || true)"
    phase="$(extract_yaml_scalar "$mode_state_file" "phase")"
    budget_state="$(extract_yaml_scalar "$autonomy_budget_file" "state")"
    breaker_state="$(extract_yaml_scalar "$circuit_breakers_file" "state")"
    route_family="$(yq -r '.effective.effective_scenario_family // .effective.scenario_family // ""' "$scenario_route_file" 2>/dev/null || true)"
    route_action_class="$(yq -r '.effective.effective_action_class // .effective.recovery_profile.action_class // ""' "$scenario_route_file" 2>/dev/null || true)"
    route_boundary_class="$(yq -r '.effective.safe_interrupt_boundary_class // ""' "$scenario_route_file" 2>/dev/null || true)"
    route_scenario_source="$(yq -r '.effective.scenario_family_source // ""' "$scenario_route_file" 2>/dev/null || true)"
    route_boundary_source="$(yq -r '.effective.boundary_source // ""' "$scenario_route_file" 2>/dev/null || true)"
    route_recovery_source="$(yq -r '.effective.recovery_source // ""' "$scenario_route_file" 2>/dev/null || true)"
    route_digest_route="$(yq -r '.effective.digest_route // ""' "$scenario_route_file" 2>/dev/null || true)"
    route_recovery_window="$(yq -r '.effective.recovery_profile.recovery_window // ""' "$scenario_route_file" 2>/dev/null || true)"
    route_generated_at="$(yq -r '.generated_at // ""' "$scenario_route_file" 2>/dev/null || true)"
    route_fresh_until="$(yq -r '.fresh_until // ""' "$scenario_route_file" 2>/dev/null || true)"
    route_ref="$(yq -r '.effective_scenario_resolution_ref // ""' "$mode_state_file" 2>/dev/null || true)"
    current_slice_ref="$(yq -r '.current_slice_ref.path // .current_slice_ref // ""' "$mode_state_file" 2>/dev/null || true)"
    next_slice_ref="$(yq -r '.entries[]? | select((.state // .status) == "active" or (.state // .status) == "queued" or (.state // .status) == "published") | .action_slice_ref // .slice_ref.path // .slice_ref.id // ""' "$intent_register_file" 2>/dev/null | awk 'NF {print; exit}')"
    if [[ -n "$next_slice_ref" && "$next_slice_ref" != .octon/* && "$next_slice_ref" != */*.yml ]]; then
      next_slice_ref="/.octon/state/control/execution/missions/${mission_id}/action-slices/${next_slice_ref}.yml"
    fi
    active_directives="$(yq -r '.directives[]? | select(((.state // .status) == "pending") or ((.state // .status) == "applied") or ((.state // .status) == "accepted")) | (.type // .kind // "")' "$control_dir/directives.yml" 2>/dev/null | paste -sd ',' -)"
    active_authorize_updates="$(yq -r '.authorize_updates[]? | select(((.state // .status) == "pending") or ((.state // .status) == "applied")) | .type' "$control_dir/authorize-updates.yml" 2>/dev/null | paste -sd ',' -)"

    [[ -z "$title" ]] && title="$mission_id"
    [[ -z "$status" ]] && status="unknown"
    [[ -z "$mission_class" ]] && mission_class="unknown"
    [[ -z "$owner_ref" ]] && owner_ref="unassigned"
    [[ -z "$oversight_mode" ]] && oversight_mode="unknown"
    [[ -z "$execution_posture" ]] && execution_posture="unknown"
    [[ -z "$phase" ]] && phase="unknown"
    [[ -z "$safety_state" ]] && safety_state="unknown"
    [[ -z "$budget_state" ]] && budget_state="unknown"
    [[ -z "$breaker_state" ]] && breaker_state="unknown"
    [[ -z "$route_ref" ]] && route_ref="/.octon/generated/effective/orchestration/missions/${mission_id}/scenario-resolution.yml"

    local run_ids_file run_contract_refs_file runtime_state_refs_file rollback_posture_refs_file
    local checkpoint_refs_file receipt_refs_file replay_pointer_refs_file retained_evidence_refs_file trace_pointer_refs_file
    local run_count active_run_ids first_receipt_ref first_replay_pointer_ref
    run_ids_file="$(mktemp "$TMP_ROOT/mission-run-ids.XXXX")"
    run_contract_refs_file="$(mktemp "$TMP_ROOT/mission-run-contracts.XXXX")"
    runtime_state_refs_file="$(mktemp "$TMP_ROOT/mission-runtime-states.XXXX")"
    rollback_posture_refs_file="$(mktemp "$TMP_ROOT/mission-rollback-postures.XXXX")"
    checkpoint_refs_file="$(mktemp "$TMP_ROOT/mission-checkpoints.XXXX")"
    receipt_refs_file="$(mktemp "$TMP_ROOT/mission-receipts.XXXX")"
    replay_pointer_refs_file="$(mktemp "$TMP_ROOT/mission-replay-pointers.XXXX")"
    retained_evidence_refs_file="$(mktemp "$TMP_ROOT/mission-retained-evidence.XXXX")"
    trace_pointer_refs_file="$(mktemp "$TMP_ROOT/mission-trace-pointers.XXXX")"
    : > "$run_ids_file"
    : > "$run_contract_refs_file"
    : > "$runtime_state_refs_file"
    : > "$rollback_posture_refs_file"
    : > "$checkpoint_refs_file"
    : > "$receipt_refs_file"
    : > "$replay_pointer_refs_file"
    : > "$retained_evidence_refs_file"
    : > "$trace_pointer_refs_file"

    while IFS= read -r run_id; do
      [[ -n "$run_id" ]] || continue
      printf '%s\n' "$run_id" >> "$run_ids_file"
      printf '/.octon/state/control/execution/runs/%s/run-contract.yml\n' "$run_id" >> "$run_contract_refs_file"
      printf '/.octon/state/control/execution/runs/%s/runtime-state.yml\n' "$run_id" >> "$runtime_state_refs_file"
      printf '/.octon/state/control/execution/runs/%s/rollback-posture.yml\n' "$run_id" >> "$rollback_posture_refs_file"
      printf '/.octon/state/control/execution/runs/%s/checkpoints/bound.yml\n' "$run_id" >> "$checkpoint_refs_file"
      printf '/.octon/state/evidence/runs/%s/replay-pointers.yml\n' "$run_id" >> "$replay_pointer_refs_file"
      printf '/.octon/state/evidence/runs/%s/retained-run-evidence.yml\n' "$run_id" >> "$retained_evidence_refs_file"
      printf '/.octon/state/evidence/runs/%s/trace-pointers.yml\n' "$run_id" >> "$trace_pointer_refs_file"
      if [[ -d "$RUN_EVIDENCE_ROOT/$run_id/receipts" ]]; then
        while IFS= read -r receipt_file; do
          printf '/.octon/state/evidence/runs/%s/receipts/%s\n' "$run_id" "$(basename "$receipt_file")" >> "$receipt_refs_file"
        done < <(find "$RUN_EVIDENCE_ROOT/$run_id/receipts" -maxdepth 1 -type f | sort)
      fi
    done < <(collect_mission_run_ids "$mission_id")

    run_count="$(awk 'NF {count++} END {print count+0}' "$run_ids_file")"
    active_run_ids="$(paste -sd ',' "$run_ids_file" 2>/dev/null || true)"
    first_receipt_ref="$(head -n1 "$receipt_refs_file" 2>/dev/null || true)"
    first_replay_pointer_ref="$(head -n1 "$replay_pointer_refs_file" 2>/dev/null || true)"

    local raw_now raw_next raw_recent raw_recover raw_projection raw_operator operator_id

    raw_now="$(mktemp "$TMP_ROOT/mission-now.XXXX")"
    cat > "$raw_now" <<EOF
---
title: Mission Now
description: Generated current-state mission summary.
mutability: generated
generated_from:
  - /.octon/instance/orchestration/missions/${mission_id}/mission.yml
  - /.octon/generated/effective/orchestration/missions/${mission_id}/scenario-resolution.yml
  - /.octon/state/control/execution/missions/${mission_id}/mode-state.yml
  - /.octon/state/control/execution/missions/${mission_id}/intent-register.yml
  - /.octon/state/control/execution/missions/${mission_id}/autonomy-budget.yml
  - /.octon/state/control/execution/missions/${mission_id}/circuit-breakers.yml
$(if [[ -n "$current_slice_ref" ]]; then printf '  - %s\n' "$current_slice_ref"; fi)
generated_at: "__GENERATED_AT__"
generator_version: "__GENERATOR_VERSION__"
---

# Mission Now

- mission_id: \`${mission_id}\`
- title: \`${title}\`
- status: \`${status}\`
- mission_class: \`${mission_class}\`
- effective_scenario_family: \`${route_family}\`
- effective_action_class: \`${route_action_class}\`
- owner_ref: \`${owner_ref}\`
- oversight_mode: \`${oversight_mode}\`
- execution_posture: \`${execution_posture}\`
- safety_state: \`${safety_state}\`
- safe_interrupt_boundary_class: \`${route_boundary_class}\`
- phase: \`${phase}\`
- autonomy_budget_state: \`${budget_state}\`
- breaker_state: \`${breaker_state}\`
- recovery_window: \`${route_recovery_window}\`
- scenario_route_generated_at: \`${route_generated_at}\`
- scenario_route_fresh_until: \`${route_fresh_until}\`
EOF
    perl -0pi -e 's#__GENERATOR_VERSION__#'"$GENERATOR_VERSION"'#g' "$raw_now"
    finalize_candidate "$MISSION_SUMMARIES_ROOT/$mission_id/now.md" "$raw_now" "generated_at" "timestamp"

    raw_next="$(mktemp "$TMP_ROOT/mission-next.XXXX")"
    cat > "$raw_next" <<EOF
---
title: Mission Next
description: Generated next-step mission summary.
mutability: generated
generated_from:
  - /.octon/generated/effective/orchestration/missions/${mission_id}/scenario-resolution.yml
  - /.octon/state/control/execution/missions/${mission_id}/intent-register.yml
  - /.octon/state/continuity/repo/missions/${mission_id}/next-actions.yml
$(if [[ -n "$next_slice_ref" ]]; then printf '  - %s\n' "$next_slice_ref"; fi)
generated_at: "__GENERATED_AT__"
generator_version: "__GENERATOR_VERSION__"
---

# Mission Next

- mission_id: \`${mission_id}\`
- digest_route: \`${route_digest_route}\`
- recovery_window: \`${route_recovery_window}\`
- current_slice_ref: \`${current_slice_ref}\`
- next_slice_ref: \`${next_slice_ref}\`
- intent_register: \`/.octon/state/control/execution/missions/${mission_id}/intent-register.yml\`
- next_actions: \`/.octon/state/continuity/repo/missions/${mission_id}/next-actions.yml\`
EOF
    perl -0pi -e 's#__GENERATOR_VERSION__#'"$GENERATOR_VERSION"'#g' "$raw_next"
    finalize_candidate "$MISSION_SUMMARIES_ROOT/$mission_id/next.md" "$raw_next" "generated_at" "timestamp"

    raw_recent="$(mktemp "$TMP_ROOT/mission-recent.XXXX")"
    cat > "$raw_recent" <<EOF
---
title: Mission Recent
description: Generated recent mission evidence summary.
mutability: generated
generated_from:
  - /.octon/generated/effective/orchestration/missions/${mission_id}/scenario-resolution.yml
  - /.octon/state/evidence/runs/**
  - /.octon/state/evidence/control/execution/**
  - /.octon/state/continuity/repo/missions/${mission_id}/handoff.md
  - /.octon/state/control/execution/missions/${mission_id}/directives.yml
  - /.octon/state/control/execution/missions/${mission_id}/authorize-updates.yml
generated_at: "__GENERATED_AT__"
generator_version: "__GENERATOR_VERSION__"
---

# Mission Recent

- mission_id: \`${mission_id}\`
- route_fresh_until: \`${route_fresh_until}\`
- retained_run_evidence_root: \`/.octon/state/evidence/runs/\`
- run_count: \`${run_count}\`
- active_run_ids: \`${active_run_ids}\`
- first_receipt_ref: \`${first_receipt_ref}\`
- retained_control_evidence_root: \`/.octon/state/evidence/control/execution/\`
- active_directives: \`${active_directives}\`
- active_authorize_updates: \`${active_authorize_updates}\`
- handoff: \`/.octon/state/continuity/repo/missions/${mission_id}/handoff.md\`
EOF
    perl -0pi -e 's#__GENERATOR_VERSION__#'"$GENERATOR_VERSION"'#g' "$raw_recent"
    finalize_candidate "$MISSION_SUMMARIES_ROOT/$mission_id/recent.md" "$raw_recent" "generated_at" "timestamp"

    raw_recover="$(mktemp "$TMP_ROOT/mission-recover.XXXX")"
    cat > "$raw_recover" <<EOF
---
title: Mission Recover
description: Generated mission recovery summary.
mutability: generated
generated_from:
  - /.octon/generated/effective/orchestration/missions/${mission_id}/scenario-resolution.yml
  - /.octon/state/evidence/runs/**
  - /.octon/state/evidence/control/execution/**
  - /.octon/state/control/execution/missions/${mission_id}/mode-state.yml
$(if [[ -n "$current_slice_ref" ]]; then printf '  - %s\n' "$current_slice_ref"; fi)
generated_at: "__GENERATED_AT__"
generator_version: "__GENERATOR_VERSION__"
---

# Mission Recover

- mission_id: \`${mission_id}\`
- recovery_window: \`${route_recovery_window}\`
- route_ref: \`${route_ref}\`
- recovery_source: \`/.octon/state/evidence/runs/\`
- replay_pointer_ref: \`${first_replay_pointer_ref}\`
- mode_state: \`/.octon/state/control/execution/missions/${mission_id}/mode-state.yml\`
EOF
    perl -0pi -e 's#__GENERATOR_VERSION__#'"$GENERATOR_VERSION"'#g' "$raw_recover"
    finalize_candidate "$MISSION_SUMMARIES_ROOT/$mission_id/recover.md" "$raw_recover" "generated_at" "timestamp"

    raw_projection="$(mktemp "$TMP_ROOT/mission-projection.XXXX")"
    cat > "$raw_projection" <<EOF
schema_version: "mission-view-v1"
mission_id: "$mission_id"
mission:
  title: $(yaml_quote "$title")
  status: $(yaml_quote "$status")
  mission_class: $(yaml_quote "$mission_class")
  owner_ref: $(yaml_quote "$owner_ref")
mode_state:
  oversight_mode: $(yaml_quote "$oversight_mode")
  execution_posture: $(yaml_quote "$execution_posture")
  safety_state: $(yaml_quote "$safety_state")
  phase: $(yaml_quote "$phase")
  route_ref: $(yaml_quote "$route_ref")
effective_route:
  mission_class: $(yaml_quote "$mission_class")
  effective_scenario_family: $(yaml_quote "$route_family")
  effective_action_class: $(yaml_quote "$route_action_class")
  safe_interrupt_boundary_class: $(yaml_quote "$route_boundary_class")
  scenario_family_source: $(yaml_quote "$route_scenario_source")
  boundary_source: $(yaml_quote "$route_boundary_source")
  recovery_source: $(yaml_quote "$route_recovery_source")
  digest_route: $(yaml_quote "$route_digest_route")
  route_generated_at: $(yaml_quote "$route_generated_at")
  route_fresh_until: $(yaml_quote "$route_fresh_until")
current_slice_ref: $( [[ -n "$current_slice_ref" ]] && yaml_quote "$current_slice_ref" || printf 'null' )
next_slice_ref: $( [[ -n "$next_slice_ref" ]] && yaml_quote "$next_slice_ref" || printf 'null' )
budget_breaker_summary:
  autonomy_budget_state: $(yaml_quote "$budget_state")
  breaker_state: $(yaml_quote "$breaker_state")
active_directives:
$(printf '%s\n' "$active_directives" | tr ',' '\n' | awk 'NF {count++; printf "  - \"%s\"\n", $0} END {if (count == 0) printf "  []\n"}')
active_authorize_updates:
$(printf '%s\n' "$active_authorize_updates" | tr ',' '\n' | awk 'NF {count++; printf "  - \"%s\"\n", $0} END {if (count == 0) printf "  []\n"}')
recovery_finalize_summary:
  recovery_window: $(yaml_quote "$route_recovery_window")
  block_finalize: $(yq -r '.effective.finalize_policy.block_finalize // false' "$scenario_route_file" 2>/dev/null || printf 'false')
  exception_active: $(yq -r '.effective.finalize_policy.exception_active // false' "$scenario_route_file" 2>/dev/null || printf 'false')
run_evidence_refs:
  active_run_ids:
$(awk 'NF {count++; printf "    - \"%s\"\n", $0} END {if (count == 0) printf "    []\n"}' "$run_ids_file")
  run_contracts:
$(awk 'NF {count++; printf "    - \"%s\"\n", $0} END {if (count == 0) printf "    []\n"}' "$run_contract_refs_file")
  runtime_states:
$(awk 'NF {count++; printf "    - \"%s\"\n", $0} END {if (count == 0) printf "    []\n"}' "$runtime_state_refs_file")
  rollback_postures:
$(awk 'NF {count++; printf "    - \"%s\"\n", $0} END {if (count == 0) printf "    []\n"}' "$rollback_posture_refs_file")
  checkpoints:
$(awk 'NF {count++; printf "    - \"%s\"\n", $0} END {if (count == 0) printf "    []\n"}' "$checkpoint_refs_file")
  receipts:
$(awk 'NF {count++; printf "    - \"%s\"\n", $0} END {if (count == 0) printf "    []\n"}' "$receipt_refs_file")
  replay_pointers:
$(awk 'NF {count++; printf "    - \"%s\"\n", $0} END {if (count == 0) printf "    []\n"}' "$replay_pointer_refs_file")
  retained_evidence:
$(awk 'NF {count++; printf "    - \"%s\"\n", $0} END {if (count == 0) printf "    []\n"}' "$retained_evidence_refs_file")
  trace_pointers:
$(awk 'NF {count++; printf "    - \"%s\"\n", $0} END {if (count == 0) printf "    []\n"}' "$trace_pointer_refs_file")
summary_refs:
  now: "/.octon/generated/cognition/summaries/missions/${mission_id}/now.md"
  next: "/.octon/generated/cognition/summaries/missions/${mission_id}/next.md"
  recent: "/.octon/generated/cognition/summaries/missions/${mission_id}/recent.md"
  recover: "/.octon/generated/cognition/summaries/missions/${mission_id}/recover.md"
continuity_refs:
  handoff: "/.octon/state/continuity/repo/missions/${mission_id}/handoff.md"
  next_actions: "/.octon/state/continuity/repo/missions/${mission_id}/next-actions.yml"
source_refs:
  mission: "/.octon/instance/orchestration/missions/${mission_id}/mission.yml"
  route: "/.octon/generated/effective/orchestration/missions/${mission_id}/scenario-resolution.yml"
  mode_state: "/.octon/state/control/execution/missions/${mission_id}/mode-state.yml"
  intent_register: "/.octon/state/control/execution/missions/${mission_id}/intent-register.yml"
  run_control_root: "/.octon/state/control/execution/runs/"
$(if [[ -n "$current_slice_ref" ]]; then printf '  current_action_slice: "%s"\n' "$current_slice_ref"; fi)
  continuity: "/.octon/state/continuity/repo/missions/${mission_id}/handoff.md"
  control_evidence_root: "/.octon/state/evidence/control/execution/"
  run_evidence_root: "/.octon/state/evidence/runs/"
last_refresh_at: "__LAST_REFRESH_AT__"
EOF
    finalize_candidate "$MISSION_PROJECTION_ROOT/$mission_id/mission-view.yml" "$raw_projection" "last_refresh_at" "timestamp"

    while IFS= read -r operator_ref; do
      [[ -n "$operator_ref" ]] || continue
      operator_id="$(operator_slug "$operator_ref")"
      raw_operator="$(mktemp "$TMP_ROOT/operator-digest.XXXX")"
      cat > "$raw_operator" <<EOF
---
title: Mission Operator Digest
description: Generated operator digest entry for mission routing.
mutability: generated
generated_from:
  - /.octon/instance/orchestration/missions/${mission_id}/mission.yml
  - /.octon/generated/effective/orchestration/missions/${mission_id}/scenario-resolution.yml
  - /.octon/state/control/execution/missions/${mission_id}/subscriptions.yml
  - /.octon/instance/governance/ownership/registry.yml
generated_at: "__GENERATED_AT__"
generator_version: "__GENERATOR_VERSION__"
---

# Operator Mission Digest

- operator_id: \`${operator_id}\`
- mission_id: \`${mission_id}\`
- title: \`${title}\`
- oversight_mode: \`${oversight_mode}\`
- digest_route: \`${route_digest_route}\`
- budget_state: \`${budget_state}\`
- breaker_state: \`${breaker_state}\`
- route_fresh_until: \`${route_fresh_until}\`
- attention_required: \`$( [[ "$breaker_state" != "clear" || "$active_authorize_updates" == *approve* ]] && printf 'yes' || printf 'no' )\`
EOF
      perl -0pi -e 's#__GENERATOR_VERSION__#'"$GENERATOR_VERSION"'#g' "$raw_operator"
      finalize_candidate "$OPERATOR_DIGESTS_ROOT/$operator_id/$mission_id.md" "$raw_operator" "generated_at" "timestamp"
    done < <(yq -r '.owners[]?, .watchers[]?, .digest_recipients[]?, .alert_recipients[]?' "$subscriptions_file" 2>/dev/null | awk 'NF' | sort -u)
  done < <(extract_active_mission_ids "$MISSION_REGISTRY_PATH")
}

generate_evidence_index() {
  local target
  local raw
  local migrations_index
  local audits_index
  local records

  target="$EVIDENCE_INDEX_PATH"
  raw="$(mktemp "$TMP_ROOT/evidence.XXXX")"
  records="$(mktemp "$TMP_ROOT/evidence-records.XXXX")"
  migrations_index="$(resolve_target_source "$MIGRATIONS_INDEX_PATH")"
  audits_index="$(resolve_target_source "$INSTANCE_COGNITION_SHARED_DIR/audits/index.yml")"

  : > "$records"

  while IFS=$'\t' read -r migration_id _plan_path _adr_path _evidence_path; do
    [[ -z "$migration_id" ]] && continue
    printf '%s\tmigration\t/.octon/state/evidence/migration/%s/evidence.md\t%s\n' "$migration_id" "$migration_id" "$MIGRATIONS_INDEX_PATH" >> "$records"
  done < <(extract_migration_records "$migrations_index")

  if [[ -f "$audits_index" ]]; then
    while IFS=$'\t' read -r audit_id _audit_path; do
      [[ -z "$audit_id" ]] && continue
      printf '%s\taudit\t/.octon/state/evidence/validation/audits/%s/evidence.md\t%s\n' "$audit_id" "$audit_id" "$INSTANCE_COGNITION_SHARED_DIR/audits/index.yml" >> "$records"
    done < <(extract_index_id_path "$audits_index")
  fi

  if [[ -d "$EVIDENCE_DIR/decisions/repo/reports" ]]; then
    while IFS= read -r bundle_dir; do
      [[ -z "$bundle_dir" ]] && continue
      local bundle_id
      bundle_id="$(basename "$bundle_dir")"
      if [[ -f "$bundle_dir/evidence.md" ]]; then
        printf '%s\tdecision\t/.octon/state/evidence/decisions/repo/reports/%s/evidence.md\t%s\n' "$bundle_id" "$bundle_id" "$DECISIONS_INDEX_PATH" >> "$records"
      fi
    done < <(find "$EVIDENCE_DIR/decisions/repo/reports" -mindepth 1 -maxdepth 1 -type d -name '[0-9][0-9][0-9]-*' | sort)
  fi

  {
    cat <<'HEADER'
# Runtime Evidence Index
# Canonical map from runtime records to output evidence bundles.

schema_version: "1.0"
files:
  - id: evidence-map-overview
    path: README.md
    summary: Runtime evidence map orientation and source boundaries.
    when: First entrypoint for cognition runtime evidence routing.

  - id: decision-evidence-contract
    path: /.octon/state/evidence/decisions/repo/reports/README.md
    summary: Decision evidence bundle contract and required files.
    when: Before creating or validating decision evidence bundles.

  - id: migration-evidence-contract
    path: /.octon/state/evidence/migration/README.md
    summary: Migration evidence bundle contract and required files.
    when: Before creating or validating migration evidence bundles.

  - id: audit-evidence-contract
    path: /.octon/state/evidence/validation/audits/README.md
    summary: Bounded audit evidence bundle contract and required files.
    when: Before creating or validating audit evidence bundles.

records:
HEADER

    if [[ -s "$records" ]]; then
      sort -t$'\t' -k1,1 "$records" | while IFS=$'\t' read -r id kind path source_record; do
        printf '  - id: %s\n' "$id"
        printf '    kind: %s\n' "$kind"
        printf '    path: %s\n' "$path"
        printf '    source_record: %s\n\n' "$source_record"
      done
    fi
  } > "$raw"

  finalize_candidate "$target" "$raw"
}

generate_evaluations_digests_index() {
  local target
  local raw
  local records
  local digests_dir

  target="$DIGESTS_INDEX_PATH"
  raw="$(mktemp "$TMP_ROOT/digest-index.XXXX")"
  records="$(mktemp "$TMP_ROOT/digest-records.XXXX")"
  digests_dir="$DIGESTS_DIR"

  : > "$records"

  while IFS= read -r digest_file; do
    [[ -z "$digest_file" ]] && continue
    local basename_no_ext
    local digest_id
    local week
    local digest_date
    local status

    basename_no_ext="$(basename "$digest_file")"
    basename_no_ext="${basename_no_ext%.md}"
    digest_id="$basename_no_ext"

    week="$(frontmatter_value "$digest_file" "week" || true)"
    digest_date="$(frontmatter_value "$digest_file" "digest_date" || true)"
    status="$(frontmatter_value "$digest_file" "status" || true)"

    [[ -z "$week" ]] && week="$digest_id"
    [[ -z "$digest_date" ]] && digest_date="unknown"
    [[ -z "$status" ]] && status="draft"

    printf '%s\t%s.md\t%s\t%s\t%s\n' "$digest_id" "$digest_id" "$week" "$digest_date" "$status" >> "$records"
  done < <(find "$digests_dir" -mindepth 1 -maxdepth 1 -type f -name '*.md' ! -name 'README.md' ! -name 'template-weekly-digest.md' | sort)

  {
    cat <<'HEADER'
# Runtime Evaluation Digests Index
# Machine-readable discovery index for weekly scorecard digests.

schema_version: "1.0"
files:
  - id: digests-overview
    path: README.md
    summary: Runtime digest surface orientation and naming conventions.
    when: First entrypoint for digest artifact discovery.

  - id: digest-template
    path: template-weekly-digest.md
    summary: Template for creating weekly scorecard digest artifacts.
    when: When drafting a new weekly digest.

records:
HEADER

    if [[ -s "$records" ]]; then
      sort -t$'\t' -k1,1 "$records" | while IFS=$'\t' read -r id path week digest_date status; do
        printf '  - id: %s\n' "$id"
        printf '    path: %s\n' "$path"
        printf '    week: %s\n' "$week"
        printf '    digest_date: %s\n' "$digest_date"
        printf '    status: %s\n\n' "$status"
      done
    fi
  } > "$raw"

  finalize_candidate "$target" "$raw"
}

generate_evaluations_open_actions() {
  local target
  local raw
  local records
  local digests_dir

  target="$OPEN_ACTIONS_PATH"
  raw="$(mktemp "$TMP_ROOT/open-actions.XXXX")"
  records="$(mktemp "$TMP_ROOT/action-records.XXXX")"
  digests_dir="$DIGESTS_DIR"

  : > "$records"

  while IFS= read -r digest_file; do
    [[ -z "$digest_file" ]] && continue
    local digest_id
    digest_id="$(basename "$digest_file")"
    digest_id="${digest_id%.md}"

    while IFS=$'\x1f' read -r action_id owner due_date status summary evidence; do
      [[ -z "$action_id" ]] && continue
      local status_lc
      status_lc="$(printf '%s' "$status" | tr '[:upper:]' '[:lower:]')"
      case "$status_lc" in
        closed|done|resolved|cancelled)
          continue
          ;;
      esac

      [[ -z "$owner" ]] && owner="unassigned"
      [[ -z "$due_date" ]] && due_date="tbd"
      [[ -z "$status" ]] && status="open"
      [[ -z "$summary" ]] && summary="unspecified"
      [[ -z "$evidence" ]] && evidence="n/a"

      printf '%s\t%s\t%s\t%s\t%s\t%s\t%s\n' "$action_id" "$digest_id" "$owner" "$due_date" "$status" "$summary" "$evidence" >> "$records"
    done < <(extract_digest_actions "$digest_file")
  done < <(find "$digests_dir" -mindepth 1 -maxdepth 1 -type f -name '*.md' ! -name 'README.md' ! -name 'template-weekly-digest.md' | sort)

  {
    cat <<'HEADER'
schema_version: "1.0"
updated: "__UPDATED__"

# Expected fields per action:
# - id
# - source_digest
# - owner
# - due_date
# - status
# - summary
# - evidence
HEADER

    if [[ -s "$records" ]]; then
      echo "actions:"
      sort -t$'\t' -k4,4 -k1,1 "$records" | while IFS=$'\t' read -r id source_digest owner due_date status summary evidence; do
        printf '  - id: "%s"\n' "$(yaml_escape "$id")"
        printf '    source_digest: "%s"\n' "$(yaml_escape "$source_digest")"
        printf '    owner: "%s"\n' "$(yaml_escape "$owner")"
        printf '    due_date: "%s"\n' "$(yaml_escape "$due_date")"
        printf '    status: "%s"\n' "$(yaml_escape "$status")"
        printf '    summary: "%s"\n' "$(yaml_escape "$summary")"
        printf '    evidence: "%s"\n' "$(yaml_escape "$evidence")"
      done
    else
      echo "actions: []"
    fi
  } > "$raw"

  finalize_candidate "$target" "$raw" "updated" "date"
}

generate_knowledge_nodes() {
  local target
  local raw
  local records
  local projection_file
  local decisions_index
  local migrations_index
  local audits_index
  local evidence_index
  local digests_index
  local actions_ledger

  target="$GRAPH_NODES_PATH"
  raw="$(mktemp "$TMP_ROOT/nodes.XXXX")"
  records="$(mktemp "$TMP_ROOT/node-records.XXXX")"

  projection_file="$(resolve_target_source "$PROJECTION_MATERIALIZED_PATH")"
  decisions_index="$(resolve_target_source "$DECISIONS_INDEX_PATH")"
  migrations_index="$(resolve_target_source "$MIGRATIONS_INDEX_PATH")"
  audits_index="$(resolve_target_source "$INSTANCE_COGNITION_SHARED_DIR/audits/index.yml")"
  evidence_index="$(resolve_target_source "$EVIDENCE_INDEX_PATH")"
  digests_index="$(resolve_target_source "$DIGESTS_INDEX_PATH")"
  actions_ledger="$(resolve_target_source "$OPEN_ACTIONS_PATH")"

  : > "$records"

  printf 'projection:cognition-runtime-surface-map\tprojection\tcognition-runtime-surface-map\t%s\n' "$PROJECTION_MATERIALIZED_PATH" >> "$records"

  while IFS=$'\t' read -r surface_id surface_index; do
    [[ -z "$surface_id" ]] && continue
    printf 'surface:%s\truntime-surface\t%s\t%s\n' "$surface_id" "$surface_id" "$surface_index" >> "$records"
  done < <(extract_runtime_surface_records "$projection_file")

  while IFS=$'\t' read -r decision_id decision_path; do
    [[ -z "$decision_id" ]] && continue
    printf 'adr:%s\tdecision-adr\t%s\t%s/%s\n' "$decision_id" "$decision_id" "$(dirname "$DECISIONS_INDEX_PATH")" "$decision_path" >> "$records"
  done < <(extract_index_id_path "$decisions_index")

  while IFS=$'\t' read -r migration_id migration_path _adr_path _evidence_path; do
    [[ -z "$migration_id" ]] && continue
    printf 'migration:%s\tmigration-record\t%s\t%s/%s\n' "$migration_id" "$migration_id" "$(dirname "$MIGRATIONS_INDEX_PATH")" "$migration_path" >> "$records"
  done < <(extract_migration_records "$migrations_index")

  if [[ -f "$audits_index" ]]; then
    while IFS=$'\t' read -r audit_id audit_path; do
      [[ -z "$audit_id" ]] && continue
      printf 'audit:%s\taudit-record\t%s\t%s/%s\n' "$audit_id" "$audit_id" "$(dirname "$audits_index")" "$audit_path" >> "$records"
    done < <(extract_index_id_path "$audits_index")
  fi

  while IFS=$'\t' read -r evidence_id evidence_kind evidence_path _source_record; do
    [[ -z "$evidence_id" ]] && continue
    printf 'evidence:%s\tevidence-%s\t%s\t%s\n' "$evidence_id" "$evidence_kind" "$evidence_id" "$evidence_path" >> "$records"
  done < <(extract_evidence_records "$evidence_index")

  while IFS=$'\t' read -r digest_id digest_path; do
    [[ -z "$digest_id" || -z "$digest_path" ]] && continue
    printf 'digest:%s\tevaluation-digest\t%s\t%s/%s\n' "$digest_id" "$digest_id" "$(dirname "$DIGESTS_INDEX_PATH")" "$digest_path" >> "$records"
  done < <(extract_digest_records "$digests_index")

  while IFS=$'\t' read -r action_id _source_digest _owner _due _status _summary _evidence; do
    [[ -z "$action_id" ]] && continue
    printf 'action:%s\tevaluation-action\t%s\t%s\n' "$action_id" "$action_id" "$OPEN_ACTIONS_PATH" >> "$records"
  done < <(extract_actions_from_ledger "$actions_ledger")

  {
    cat <<'HEADER'
schema_version: "1.0"
generated_at: "__GENERATED_AT__"
generator_version: "__GENERATOR_VERSION__"

# Node records are materialized from canonical runtime surfaces.
nodes:
HEADER

    if [[ -s "$records" ]]; then
      sort -t$'\t' -k1,1 -u "$records" | while IFS=$'\t' read -r id type label path; do
        printf '  - id: "%s"\n' "$(yaml_escape "$id")"
        printf '    type: "%s"\n' "$(yaml_escape "$type")"
        printf '    label: "%s"\n' "$(yaml_escape "$label")"
        printf '    path: "%s"\n' "$(yaml_escape "$path")"
      done
    else
      echo "  []"
    fi
  } > "$raw"

  perl -0pi -e 's#__GENERATOR_VERSION__#'"$GENERATOR_VERSION"'#g' "$raw"
  finalize_candidate "$target" "$raw" "generated_at" "timestamp"
}

generate_knowledge_edges() {
  local target
  local raw
  local records
  local projection_file
  local migrations_index
  local audits_index
  local evidence_index
  local actions_ledger

  target="$GRAPH_EDGES_PATH"
  raw="$(mktemp "$TMP_ROOT/edges.XXXX")"
  records="$(mktemp "$TMP_ROOT/edge-records.XXXX")"

  projection_file="$(resolve_target_source "$PROJECTION_MATERIALIZED_PATH")"
  migrations_index="$(resolve_target_source "$MIGRATIONS_INDEX_PATH")"
  audits_index="$(resolve_target_source "$INSTANCE_COGNITION_SHARED_DIR/audits/index.yml")"
  evidence_index="$(resolve_target_source "$EVIDENCE_INDEX_PATH")"
  actions_ledger="$(resolve_target_source "$OPEN_ACTIONS_PATH")"

  : > "$records"

  while IFS=$'\t' read -r surface_id _surface_index; do
    [[ -z "$surface_id" ]] && continue
    printf 'projection:cognition-runtime-surface-map->surface:%s\tprojects-surface\tprojection:cognition-runtime-surface-map\tsurface:%s\t%s\n' "$surface_id" "$surface_id" "$PROJECTION_MATERIALIZED_PATH" >> "$records"
  done < <(extract_runtime_surface_records "$projection_file")

  while IFS=$'\t' read -r migration_id migration_path adr_path evidence_path; do
    [[ -z "$migration_id" ]] && continue
    local adr_id
    adr_id="$(basename "$adr_path")"
    adr_id="${adr_id%.md}"

    printf 'migration:%s->adr:%s\treferences-adr\tmigration:%s\tadr:%s\t%s/%s\n' "$migration_id" "$adr_id" "$migration_id" "$adr_id" "$(dirname "$MIGRATIONS_INDEX_PATH")" "$migration_path" >> "$records"
    printf 'migration:%s->evidence:%s\thas-evidence\tmigration:%s\tevidence:%s\t%s\n' "$migration_id" "$migration_id" "$migration_id" "$migration_id" "$evidence_path" >> "$records"
  done < <(extract_migration_records "$migrations_index")

  if [[ -f "$audits_index" ]]; then
    while IFS=$'\t' read -r audit_id audit_path; do
      [[ -z "$audit_id" ]] && continue
      printf 'audit:%s->evidence:%s\thas-evidence\taudit:%s\tevidence:%s\t%s/%s\n' "$audit_id" "$audit_id" "$audit_id" "$audit_id" "$(dirname "$audits_index")" "$audit_path" >> "$records"
    done < <(extract_index_id_path "$audits_index")
  fi

  while IFS=$'\t' read -r evidence_id evidence_kind evidence_path _source; do
    [[ -z "$evidence_id" ]] && continue
    if [[ "$evidence_kind" == "decision" ]]; then
      printf 'adr:%s->evidence:%s\thas-evidence\tadr:%s\tevidence:%s\t%s\n' "$evidence_id" "$evidence_id" "$evidence_id" "$evidence_id" "$evidence_path" >> "$records"
    fi
  done < <(extract_evidence_records "$evidence_index")

  while IFS=$'\t' read -r action_id source_digest _owner _due _status _summary _evidence; do
    [[ -z "$action_id" || -z "$source_digest" ]] && continue
    printf 'action:%s->digest:%s\toriginates-from-digest\taction:%s\tdigest:%s\t%s\n' "$action_id" "$source_digest" "$action_id" "$source_digest" "$OPEN_ACTIONS_PATH" >> "$records"
  done < <(extract_actions_from_ledger "$actions_ledger")

  {
    cat <<'HEADER'
schema_version: "1.0"
generated_at: "__GENERATED_AT__"
generator_version: "__GENERATOR_VERSION__"

# Edge records are materialized from canonical contracts.
# Expected fields per entry: id, type, from, to, evidence.
edges:
HEADER

    if [[ -s "$records" ]]; then
      sort -t$'\t' -k1,1 -u "$records" | while IFS=$'\t' read -r id type from to evidence; do
        printf '  - id: "%s"\n' "$(yaml_escape "$id")"
        printf '    type: "%s"\n' "$(yaml_escape "$type")"
        printf '    from: "%s"\n' "$(yaml_escape "$from")"
        printf '    to: "%s"\n' "$(yaml_escape "$to")"
        printf '    evidence: "%s"\n' "$(yaml_escape "$evidence")"
      done
    else
      echo "  []"
    fi
  } > "$raw"

  perl -0pi -e 's#__GENERATOR_VERSION__#'"$GENERATOR_VERSION"'#g' "$raw"
  finalize_candidate "$target" "$raw" "generated_at" "timestamp"
}

generate_knowledge_receipts() {
  local target
  local raw

  target="$INGESTION_RECEIPTS_PATH"
  raw="$(mktemp "$TMP_ROOT/receipts.XXXX")"

  {
    cat <<'HEADER'
schema_version: "1.0"
updated: "__UPDATED__"

# Expected fields per receipt:
# - id
# - source
# - source_type
# - artifact
# - ingested_at
# - status
receipts:
  - id: "decisions-summary-materialization"
    source: "__DECISIONS_INDEX__"
    source_type: "internal-generator"
    artifact: "__DECISIONS_SUMMARY__"
    ingested_at: "__UPDATED__"
    status: "success"

  - id: "projection-materialization"
    source: "__PROJECTION_DEFINITION__"
    source_type: "internal-generator"
    artifact: "__PROJECTION_MATERIALIZED__"
    ingested_at: "__UPDATED__"
    status: "success"

  - id: "evidence-map-materialization"
    source: "__MIGRATIONS_INDEX__,__AUDITS_INDEX__"
    source_type: "internal-generator"
    artifact: "__EVIDENCE_INDEX__"
    ingested_at: "__UPDATED__"
    status: "success"

  - id: "evaluations-materialization"
    source: "__DIGESTS_DIR__/*.md"
    source_type: "internal-generator"
    artifact: "__OPEN_ACTIONS__"
    ingested_at: "__UPDATED__"
    status: "success"

  - id: "knowledge-graph-materialization"
    source: "__PROJECTION_MATERIALIZED__"
    source_type: "internal-generator"
    artifact: "__GRAPH_NODES__"
    ingested_at: "__UPDATED__"
    status: "success"

  - id: "knowledge-graph-edge-materialization"
    source: "__PROJECTION_MATERIALIZED__"
    source_type: "internal-generator"
    artifact: "__GRAPH_EDGES__"
    ingested_at: "__UPDATED__"
    status: "success"
HEADER
  } > "$raw"

  perl -0pi -e '
    s#__DECISIONS_INDEX__#$ENV{DECISIONS_INDEX_PATH}#g;
    s#__DECISIONS_SUMMARY__#$ENV{DECISIONS_SUMMARY_PATH}#g;
    s#__PROJECTION_DEFINITION__#$ENV{PROJECTION_DEFINITION_PATH}#g;
    s#__PROJECTION_MATERIALIZED__#$ENV{PROJECTION_MATERIALIZED_PATH}#g;
    s#__MIGRATIONS_INDEX__#$ENV{MIGRATIONS_INDEX_PATH}#g;
    s#__AUDITS_INDEX__#$ENV{INSTANCE_COGNITION_SHARED_DIR}/audits/index.yml#g;
    s#__EVIDENCE_INDEX__#$ENV{EVIDENCE_INDEX_PATH}#g;
    s#__DIGESTS_DIR__#$ENV{DIGESTS_DIR}#g;
    s#__OPEN_ACTIONS__#$ENV{OPEN_ACTIONS_PATH}#g;
    s#__GRAPH_NODES__#$ENV{GRAPH_NODES_PATH}#g;
    s#__GRAPH_EDGES__#$ENV{GRAPH_EDGES_PATH}#g;
  ' "$raw"

  finalize_candidate "$target" "$raw" "updated" "date"
}

reconcile_outputs() {
  local drift=0
  local target
  for target in "${GENERATED_TARGETS[@]}"; do
    local stage_file
    local rel
    stage_file="$(stage_path_for_target "$target")"
    if [[ "$target" == "$ROOT_DIR/"* ]]; then
      rel="${target#$ROOT_DIR/}"
    else
      rel="${target#$COGNITION_DIR/}"
    fi

    if [[ ! -f "$target" ]] || ! cmp -s "$stage_file" "$target"; then
      if [[ "$MODE" == "apply" ]]; then
        mkdir -p "$(dirname -- "$target")"
        cp "$stage_file" "$target"
        echo "[UPDATED] $rel"
      else
        echo "[DRIFT] $rel"
        drift=$((drift + 1))
      fi
    fi
  done

  if [[ "$MODE" == "check" && $drift -gt 0 ]]; then
    echo
    echo "Generated cognition runtime artifacts are out of date." >&2
    echo "Run: bash .octon/framework/cognition/_ops/runtime/scripts/sync-runtime-artifacts.sh" >&2
    exit 1
  fi

  if [[ "$MODE" == "check" ]]; then
    echo "Generated cognition runtime artifacts are up to date."
  fi
}

main() {
  local -a default_generators=(
    "generate_decisions_context"
    "generate_mission_autonomy_views"
    "generate_projection_materialized"
    "generate_evidence_index"
    "generate_evaluations_digests_index"
    "generate_evaluations_open_actions"
    "generate_knowledge_nodes"
    "generate_knowledge_edges"
    "generate_knowledge_receipts"
  )
  local -a generators=()
  local target
  local generator
  local existing

  if [[ ${#REQUESTED_TARGETS[@]} -eq 0 ]]; then
    generators=("${default_generators[@]}")
  else
    for target in "${REQUESTED_TARGETS[@]}"; do
      case "$target" in
        decisions)
          generators+=("generate_decisions_context")
          ;;
        missions)
          generators+=("generate_mission_autonomy_views")
          ;;
        projections)
          generators+=("generate_projection_materialized")
          ;;
        evidence)
          generators+=("generate_evidence_index")
          ;;
        evaluations-digests)
          generators+=("generate_evaluations_digests_index")
          ;;
        evaluations-actions)
          generators+=("generate_evaluations_open_actions")
          ;;
        evaluations)
          generators+=("generate_evaluations_digests_index" "generate_evaluations_open_actions")
          ;;
        knowledge-nodes)
          generators+=("generate_knowledge_nodes")
          ;;
        knowledge-edges)
          generators+=("generate_knowledge_edges")
          ;;
        knowledge-receipts)
          generators+=("generate_knowledge_receipts")
          ;;
        knowledge)
          generators+=("generate_knowledge_nodes" "generate_knowledge_edges" "generate_knowledge_receipts")
          ;;
        *)
          echo "Unknown target selector: $target" >&2
          usage >&2
          exit 2
          ;;
      esac
    done
  fi

  local -a deduped_generators=()
  local seen
  for generator in "${generators[@]}"; do
    seen=0
    for existing in "${deduped_generators[@]}"; do
      if [[ "$existing" == "$generator" ]]; then
        seen=1
        break
      fi
    done
    if [[ $seen -eq 0 ]]; then
      deduped_generators+=("$generator")
    fi
  done

  for generator in "${deduped_generators[@]}"; do
    "$generator"
  done
  reconcile_outputs
}

main "$@"
