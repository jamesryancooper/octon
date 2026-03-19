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
  DECISIONS_SUMMARY_PATH="$COGNITION_DIR/runtime/context/decisions.md"
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
  DECISIONS_SUMMARY_PATH="$INSTANCE_COGNITION_SHARED_DIR/decisions.md"
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
fi
RUNTIME_DIR="$COGNITION_DIR/runtime"
if [[ -n "${OUTPUT_DIR_OVERRIDE:-}" ]]; then
  EVIDENCE_DIR="$(cd -- "$OUTPUT_DIR_OVERRIDE/state/evidence" && pwd)"
else
  EVIDENCE_DIR="$(cd -- "$COGNITION_DIR/../../state/evidence" && pwd)"
fi

MODE="apply"
declare -a REQUESTED_TARGETS=()

usage() {
  cat <<'USAGE'
Usage: sync-runtime-artifacts.sh [--check] [--target <name> ...]

Generates deterministic cognition runtime derived artifacts:
- instance/cognition/context/shared/decisions.md
- generated/cognition/projections/materialized/cognition-runtime-surface-map.latest.yml
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
  local target
  local raw

  index_file="$DECISIONS_INDEX_PATH"
  target="$DECISIONS_SUMMARY_PATH"
  raw="$(mktemp "$TMP_ROOT/decisions.XXXX")"

  {
    cat <<'HEADER'
---
title: Decisions
description: Generated ADR summary for cognition runtime decision discovery.
mutability: generated
generated_from:
  - ../decisions/index.yml
  - ../decisions/*.md
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

      printf '| ADR-%s | %s | %s | %s | `../decisions/%s` |\n' "$adr_number" "$status" "$date" "$title" "$record_path"
    done < <(extract_index_id_path "$index_file")

    cat <<'FOOTER'

## Update Procedure

1. Add or update ADR files in `/.octon/instance/cognition/decisions/`.
2. Update `/.octon/instance/cognition/decisions/index.yml`.
3. Run `bash .octon/framework/cognition/_ops/runtime/scripts/sync-runtime-artifacts.sh`.
FOOTER
  } > "$raw"

  finalize_candidate "$target" "$raw"
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

  perl -0pi -e '
    s#__CONTEXT_INDEX__#$ENV{CONTEXT_INDEX_PATH}#g;
    s#__DECISIONS_INDEX__#$ENV{DECISIONS_INDEX_PATH}#g;
    s#__MIGRATIONS_INDEX__#$ENV{MIGRATIONS_INDEX_PATH}#g;
    s#__ANALYSES_INDEX__#$ENV{ANALYSES_INDEX_PATH}#g;
    s#__KNOWLEDGE_INDEX__#$ENV{KNOWLEDGE_INDEX_PATH}#g;
    s#__EVIDENCE_INDEX__#$ENV{EVIDENCE_INDEX_PATH}#g;
    s#__EVALUATIONS_INDEX__#$ENV{EVALUATIONS_INDEX_PATH}#g;
    s#__PROJECTIONS_INDEX__#$ENV{PROJECTIONS_INDEX_PATH}#g;
  ' "$raw"

  finalize_candidate "$target" "$raw" "generated_at" "timestamp"
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
updated: "__UPDATED__"

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

  finalize_candidate "$target" "$raw" "updated" "date"
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
updated: "__UPDATED__"

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

  finalize_candidate "$target" "$raw" "updated" "date"
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
