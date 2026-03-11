#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
ASSURANCE_DIR="$(cd -- "$SCRIPT_DIR/../../.." && pwd)"
HARMONY_DIR="$(cd -- "$ASSURANCE_DIR/.." && pwd)"
ROOT_DIR="$(cd -- "$HARMONY_DIR/.." && pwd)"

TASKS_FILE="$HARMONY_DIR/continuity/tasks.json"
ENTITIES_FILE="$HARMONY_DIR/continuity/entities.json"
NEXT_FILE="$HARMONY_DIR/continuity/next.md"
DECISIONS_DIR="$HARMONY_DIR/continuity/decisions"
DECISIONS_POLICY_FILE="$DECISIONS_DIR/retention.json"
DECISION_SCHEMA_FILE="$HARMONY_DIR/continuity/_meta/architecture/schemas/decision-record.schema.json"
RUNS_DIR="$HARMONY_DIR/continuity/runs"
RUNS_POLICY_FILE="$RUNS_DIR/retention.json"

errors=0
warnings=0

fail() {
  echo "[ERROR] $1"
  errors=$((errors + 1))
}

warn() {
  echo "[WARN] $1"
  warnings=$((warnings + 1))
}

pass() {
  echo "[OK] $1"
}

require_file() {
  local file="$1"
  if [[ ! -f "$file" ]]; then
    fail "missing file: ${file#$ROOT_DIR/}"
    return 1
  fi
  pass "found file: ${file#$ROOT_DIR/}"
}

require_dir() {
  local dir="$1"
  if [[ ! -d "$dir" ]]; then
    fail "missing directory: ${dir#$ROOT_DIR/}"
    return 1
  fi
  pass "found directory: ${dir#$ROOT_DIR/}"
}

check_jq_available() {
  if command -v jq >/dev/null 2>&1; then
    pass "jq is available"
  else
    fail "jq is required for continuity validation"
  fi
}

validate_json_file() {
  local file="$1"
  if jq empty "$file" >/dev/null 2>&1; then
    pass "valid JSON: ${file#$ROOT_DIR/}"
  else
    fail "invalid JSON: ${file#$ROOT_DIR/}"
  fi
}

validate_tasks_contract() {
  echo "== Validate continuity/tasks.json =="
  require_file "$TASKS_FILE" || return
  validate_json_file "$TASKS_FILE"

  if ! jq -e '
    type == "object"
    and .schema_version == "1.2"
    and (.goal | type == "string" and length > 0)
    and (.tasks | type == "array")
  ' "$TASKS_FILE" >/dev/null; then
    fail "tasks.json root contract mismatch (expected schema_version 1.2, non-empty goal, tasks array)"
  else
    pass "tasks.json root contract is valid"
  fi

  local dup_ids
  dup_ids="$(
    jq -r '[.tasks[].id] | group_by(.)[] | select(length > 1) | .[0]' "$TASKS_FILE" 2>/dev/null || true
  )"
  if [[ -n "$dup_ids" ]]; then
    fail "duplicate task ids: $(echo "$dup_ids" | paste -sd ', ' -)"
  else
    pass "task ids are unique"
  fi

  local missing_core
  missing_core="$(
    jq -r '
      .tasks[]
      | select(
          (.id | type) != "string" or (.id | length) == 0
          or (.description | type) != "string" or (.description | length) == 0
          or (.status | type) != "string"
        )
      | (.id // "<missing-id>")
    ' "$TASKS_FILE" 2>/dev/null || true
  )"
  if [[ -n "$missing_core" ]]; then
    fail "tasks missing required id/description/status fields: $(echo "$missing_core" | paste -sd ', ' -)"
  else
    pass "all tasks have required id/description/status fields"
  fi

  local invalid_status
  invalid_status="$(
    jq -r '
      .tasks[]
      | select((.status as $s | ["pending","in_progress","blocked","completed","cancelled"] | index($s)) == null)
      | .id
    ' "$TASKS_FILE" 2>/dev/null || true
  )"
  if [[ -n "$invalid_status" ]]; then
    fail "tasks with invalid status values: $(echo "$invalid_status" | paste -sd ', ' -)"
  else
    pass "task status values are valid"
  fi

  local legacy_blocked_by
  legacy_blocked_by="$(
    jq -r '.tasks[] | select(has("blocked_by")) | .id' "$TASKS_FILE" 2>/dev/null || true
  )"
  if [[ -n "$legacy_blocked_by" ]]; then
    fail "legacy blocked_by field detected (use blockers array): $(echo "$legacy_blocked_by" | paste -sd ', ' -)"
  else
    pass "no legacy blocked_by fields found"
  fi

  local unknown_fields
  unknown_fields="$(
    jq -r \
      --argjson allowed '["id","description","status","priority","owner","blockers","acceptance_criteria","knowledge_links","risk_tier","required_approvals","goal_contribution","completed_at","note"]' '
      .tasks[]
      | (.id // "<missing-id>") as $id
      | ((keys_unsorted - $allowed) // []) as $extra
      | select(($extra | length) > 0)
      | "\($id)\t\($extra | join(","))"
    ' "$TASKS_FILE" 2>/dev/null || true
  )"
  if [[ -n "$unknown_fields" ]]; then
    while IFS=$'\t' read -r task_id extras; do
      fail "task ${task_id} contains unsupported fields: ${extras}"
    done <<< "$unknown_fields"
  else
    pass "task fields conform to canonical schema"
  fi

  local active_missing
  active_missing="$(
    jq -r '
      def active_status: . == "pending" or . == "in_progress" or . == "blocked";
      def nonempty_str: type == "string" and length > 0;
      def nonempty_str_array: type == "array" and length > 0 and all(.[]; type == "string" and length > 0);
      def valid_links:
        type == "object"
        and (.specs | type == "array")
        and (.contracts | type == "array")
        and (.decisions | type == "array")
        and (.evidence | type == "array")
        and ((.specs | length) + (.contracts | length) + (.decisions | length) + (.evidence | length) > 0);
      .tasks[]
      | select(.status | active_status)
      | select(
          ((.owner | nonempty_str) | not)
          or ((.blockers | type == "array") | not)
          or ((.acceptance_criteria | nonempty_str_array) | not)
          or ((.knowledge_links | valid_links) | not)
        )
      | .id
    ' "$TASKS_FILE" 2>/dev/null || true
  )"
  if [[ -n "$active_missing" ]]; then
    fail "active tasks missing required owner/blockers/acceptance_criteria/knowledge_links fields: $(echo "$active_missing" | paste -sd ', ' -)"
  else
    pass "active tasks include ownership, blockers, acceptance criteria, and knowledge links"
  fi

  local blocked_invalid
  blocked_invalid="$(
    jq -r '
      .tasks[]
      | select(.status == "blocked" and ((.blockers | type != "array") or (.blockers | length == 0)))
      | .id
    ' "$TASKS_FILE" 2>/dev/null || true
  )"
  if [[ -n "$blocked_invalid" ]]; then
    fail "blocked tasks must include at least one blocker: $(echo "$blocked_invalid" | paste -sd ', ' -)"
  else
    pass "blocked tasks have blocker references"
  fi

  local completed_invalid
  completed_invalid="$(
    jq -r '
      .tasks[]
      | select(.status == "completed" and (((.completed_at // "") | test("^[0-9]{4}-[0-9]{2}-[0-9]{2}$")) | not))
      | .id
    ' "$TASKS_FILE" 2>/dev/null || true
  )"
  if [[ -n "$completed_invalid" ]]; then
    fail "completed tasks must include completed_at (YYYY-MM-DD): $(echo "$completed_invalid" | paste -sd ', ' -)"
  else
    pass "completed tasks include completed_at values"
  fi

  local invalid_risk_tier
  invalid_risk_tier="$(
    jq -r '
      .tasks[]
      | select(has("risk_tier") and ((.risk_tier as $r | ["T1","T2","T3"] | index($r)) == null))
      | .id
    ' "$TASKS_FILE" 2>/dev/null || true
  )"
  if [[ -n "$invalid_risk_tier" ]]; then
    fail "invalid risk_tier values found: $(echo "$invalid_risk_tier" | paste -sd ', ' -)"
  else
    pass "risk_tier values are valid where present"
  fi

  local invalid_approvals
  invalid_approvals="$(
    jq -r '
      .tasks[]
      | select(
          has("required_approvals")
          and (
            (.required_approvals | type != "array")
            or ([.required_approvals[]? | select((type != "string") or (length == 0))] | length > 0)
          )
        )
      | .id
    ' "$TASKS_FILE" 2>/dev/null || true
  )"
  if [[ -n "$invalid_approvals" ]]; then
    fail "required_approvals must be a non-empty-string array: $(echo "$invalid_approvals" | paste -sd ', ' -)"
  else
    pass "required_approvals values are valid where present"
  fi

  local in_progress_count
  in_progress_count="$(jq '[.tasks[] | select(.status == "in_progress")] | length' "$TASKS_FILE" 2>/dev/null || echo "0")"
  if [[ "$in_progress_count" -gt 1 ]]; then
    fail "multiple tasks marked in_progress (${in_progress_count})"
  else
    pass "single in_progress invariant holds"
  fi

  declare -A task_id_set=()
  while IFS= read -r task_id; do
    [[ -z "$task_id" ]] && continue
    task_id_set["$task_id"]=1
  done < <(jq -r '.tasks[] | .id // empty' "$TASKS_FILE" 2>/dev/null || true)

  while IFS=$'\t' read -r task_id blocker; do
    [[ -z "$task_id" || -z "$blocker" ]] && continue
    if [[ "$task_id" == "$blocker" ]]; then
      fail "task ${task_id} cannot block itself"
      continue
    fi
    if [[ "$blocker" == external:* ]]; then
      continue
    fi
    if [[ -z "${task_id_set[$blocker]+x}" ]]; then
      fail "task ${task_id} references unknown blocker: ${blocker}"
    fi
  done < <(
    jq -r '
      .tasks[]
      | .id as $id
      | (.blockers // [])[]?
      | [$id, .]
      | @tsv
    ' "$TASKS_FILE" 2>/dev/null || true
  )
  pass "task blocker references are valid"
}

validate_entities_contract() {
  echo "== Validate continuity/entities.json =="
  require_file "$ENTITIES_FILE" || return
  validate_json_file "$ENTITIES_FILE"

  if ! jq -e '
    type == "object"
    and .schema_version == "1.1"
    and (.description | type == "string" and length > 0)
    and (.entities | type == "object")
  ' "$ENTITIES_FILE" >/dev/null; then
    fail "entities.json root contract mismatch (expected schema_version 1.1, non-empty description, entities object)"
  else
    pass "entities.json root contract is valid"
  fi

  local invalid_entities
  invalid_entities="$(
    jq -r '
      .entities
      | to_entries[]
      | select((.value | type) != "object")
      | .key
    ' "$ENTITIES_FILE" 2>/dev/null || true
  )"
  if [[ -n "$invalid_entities" ]]; then
    fail "entity records must be objects: $(echo "$invalid_entities" | paste -sd ', ' -)"
  else
    pass "entity records are object-shaped"
  fi

  local unknown_fields
  unknown_fields="$(
    jq -r \
      --argjson allowed '["type","status","last_modified","owner","notes","related_tasks","knowledge_links"]' '
      .entities
      | to_entries[]
      | .key as $name
      | .value as $entity
      | (($entity | keys_unsorted) - $allowed) as $extra
      | select(($extra | length) > 0)
      | "\($name)\t\($extra | join(","))"
    ' "$ENTITIES_FILE" 2>/dev/null || true
  )"
  if [[ -n "$unknown_fields" ]]; then
    while IFS=$'\t' read -r entity extras; do
      fail "entity ${entity} contains unsupported fields: ${extras}"
    done <<< "$unknown_fields"
  else
    pass "entity fields conform to canonical schema"
  fi

  local invalid_core
  invalid_core="$(
    jq -r '
      def valid_type:
        . == "file"
        or . == "directory"
        or . == "mission"
        or . == "workflow"
        or . == "domain"
        or . == "service"
        or . == "artifact"
        or . == "other";
      def valid_status:
        . == "stable"
        or . == "in_progress"
        or . == "blocked"
        or . == "needs_review"
        or . == "archived";
      def nonempty_str: type == "string" and length > 0;
      .entities
      | to_entries[]
      | .key as $name
      | .value as $entity
      | select(
          (($entity.type | type) != "string")
          or (($entity.type | valid_type) | not)
          or (($entity.status | type) != "string")
          or (($entity.status | valid_status) | not)
          or (((($entity.last_modified // "") | test("^[0-9]{4}-[0-9]{2}-[0-9]{2}$")) | not))
          or (($entity.owner | nonempty_str) | not)
        )
      | $name
    ' "$ENTITIES_FILE" 2>/dev/null || true
  )"
  if [[ -n "$invalid_core" ]]; then
    fail "entity records missing valid core fields (type/status/last_modified/owner): $(echo "$invalid_core" | paste -sd ', ' -)"
  else
    pass "entity core fields are valid"
  fi

  local context_missing
  context_missing="$(
    jq -r '
      def needs_context: . == "in_progress" or . == "blocked" or . == "needs_review";
      def valid_links:
        type == "object"
        and (.specs | type == "array")
        and (.contracts | type == "array")
        and (.decisions | type == "array")
        and (.evidence | type == "array")
        and ((.specs | length) + (.contracts | length) + (.decisions | length) + (.evidence | length) > 0);
      .entities
      | to_entries[]
      | .key as $name
      | .value as $entity
      | select(
          ($entity.status | needs_context)
          and (
            (($entity.related_tasks | type != "array") or ($entity.related_tasks | length == 0))
            or (($entity.knowledge_links | valid_links) | not)
          )
        )
      | $name
    ' "$ENTITIES_FILE" 2>/dev/null || true
  )"
  if [[ -n "$context_missing" ]]; then
    fail "non-stable entities must include related_tasks and knowledge_links: $(echo "$context_missing" | paste -sd ', ' -)"
  else
    pass "non-stable entities include task and knowledge linkage"
  fi

  declare -A task_id_set=()
  while IFS= read -r task_id; do
    [[ -z "$task_id" ]] && continue
    task_id_set["$task_id"]=1
  done < <(jq -r '.tasks[] | .id // empty' "$TASKS_FILE" 2>/dev/null || true)

  while IFS=$'\t' read -r entity_name task_ref; do
    [[ -z "$entity_name" || -z "$task_ref" ]] && continue
    if [[ "$task_ref" == external:* ]]; then
      continue
    fi
    if [[ -z "${task_id_set[$task_ref]+x}" ]]; then
      fail "entity ${entity_name} references unknown related task: ${task_ref}"
    fi
  done < <(
    jq -r '
      .entities
      | to_entries[]
      | .key as $name
      | (.value.related_tasks // [])[]?
      | [$name, .]
      | @tsv
    ' "$ENTITIES_FILE" 2>/dev/null || true
  )
  pass "entity related task references are valid"
}

validate_next_contract() {
  echo "== Validate continuity/next.md coherence =="
  require_file "$NEXT_FILE" || return

  local current_section
  current_section="$(
    awk '
      /^##[[:space:]]+Current[[:space:]]*$/ { in_current=1; next }
      /^##[[:space:]]+/ { if (in_current) exit }
      { if (in_current) print }
    ' "$NEXT_FILE"
  )"

  local active_unblocked_ids=()
  while IFS= read -r task_id; do
    [[ -z "$task_id" ]] && continue
    active_unblocked_ids+=("$task_id")
  done < <(
    jq -r '
      .tasks[]
      | select((.status == "pending" or .status == "in_progress") and ((.blockers // []) | length == 0))
      | .id
    ' "$TASKS_FILE" 2>/dev/null || true
  )

  local active_count="${#active_unblocked_ids[@]}"
  local current_items
  current_items="$(printf '%s\n' "$current_section" | grep -E '^[[:space:]]*-[[:space:]]+' || true)"

  if [[ "$active_count" -gt 0 && -z "$current_items" ]]; then
    fail "next.md must contain Current list items for active unblocked tasks"
  else
    pass "next.md Current section includes actionable list items"
  fi

  if [[ "$active_count" -gt 0 ]] && grep -Fq "<!-- Add immediate next actions here -->" <<< "$current_section"; then
    fail "next.md Current section still contains placeholder content"
  else
    pass "next.md Current section placeholder removed"
  fi

  if [[ "$active_count" -eq 0 ]]; then
    warn "no active unblocked tasks found; Current section may intentionally be empty"
  fi

  local active_id
  for active_id in "${active_unblocked_ids[@]}"; do
    if ! grep -Fq "$active_id" <<< "$current_section"; then
      fail "active unblocked task not referenced in next.md Current section: $active_id"
    fi
  done
  pass "next.md Current section references active unblocked tasks"
}

validate_decisions_retention_contract() {
  echo "== Validate continuity/decisions retention and records =="
  require_dir "$DECISIONS_DIR" || return
  require_file "$DECISIONS_POLICY_FILE" || return
  require_file "$DECISIONS_DIR/README.md" || return
  require_file "$DECISION_SCHEMA_FILE" || return
  validate_json_file "$DECISIONS_POLICY_FILE"
  validate_json_file "$DECISION_SCHEMA_FILE"

  if ! jq -e '
    type == "object"
    and .schema_version == "1.0"
    and (.default_action | type == "string" and length > 0)
    and (.classes | type == "array" and length > 0)
    and (.always_keep_files | type == "array")
  ' "$DECISIONS_POLICY_FILE" >/dev/null; then
    fail "decisions retention policy root contract mismatch"
  else
    pass "decisions retention policy root contract is valid"
  fi

  local dup_class_ids
  dup_class_ids="$(
    jq -r '.classes | map(.id) | group_by(.)[] | select(length > 1) | .[0]' "$DECISIONS_POLICY_FILE" 2>/dev/null || true
  )"
  if [[ -n "$dup_class_ids" ]]; then
    fail "duplicate decision retention class ids: $(echo "$dup_class_ids" | paste -sd ', ' -)"
  else
    pass "decision retention class ids are unique"
  fi

  local bad_classes
  bad_classes="$(
    jq -r '
      .classes[]
      | select(
          (.id | type != "string" or length == 0)
          or (.description | type != "string" or length == 0)
          or (.match_prefixes | type != "array" or length == 0)
          or ([.match_prefixes[]? | select((type != "string") or (length == 0))] | length > 0)
          or (.retention_days | type != "number" or . <= 0)
          or ((.action_after_retention as $a | ["archive","prune","retain"] | index($a)) == null)
        )
      | .id
    ' "$DECISIONS_POLICY_FILE" 2>/dev/null || true
  )"
  if [[ -n "$bad_classes" ]]; then
    fail "decision retention classes missing required fields: $(echo "$bad_classes" | paste -sd ', ' -)"
  else
    pass "decision retention classes are well formed"
  fi

  declare -A allowed_files=()
  while IFS= read -r filename; do
    [[ -z "$filename" ]] && continue
    allowed_files["$filename"]=1
  done < <(jq -r '.always_keep_files[]?' "$DECISIONS_POLICY_FILE" 2>/dev/null || true)

  while IFS= read -r top_file; do
    [[ -z "$top_file" ]] && continue
    local file_name
    file_name="$(basename "$top_file")"
    if [[ -z "${allowed_files[$file_name]+x}" ]]; then
      fail "decisions/ contains top-level file not listed in always_keep_files: ${file_name}"
    fi
  done < <(find "$DECISIONS_DIR" -mindepth 1 -maxdepth 1 -type f | sort)
  pass "decisions top-level files match retention policy allowlist"

  local class_prefixes
  class_prefixes="$(
    jq -r '.classes[] | .id as $id | .match_prefixes[] | [$id, .] | @tsv' "$DECISIONS_POLICY_FILE" 2>/dev/null || true
  )"

  local decision_path decision_name matched class_id prefix
  while IFS= read -r decision_path; do
    [[ -z "$decision_path" ]] && continue
    decision_name="$(basename "$decision_path")"

    if [[ "$decision_name" == "approvals" ]]; then
      local approval_extra approval_json
      approval_extra="$(
        find "$decision_path" -mindepth 1 -maxdepth 1 -type f \
          ! -name 'README.md' ! -name '*.json' -print
      )"
      if [[ -n "$approval_extra" ]]; then
        fail "approval container contains unsupported files: $(echo "$approval_extra" | sed "s#${ROOT_DIR}/##g" | paste -sd ', ' -)"
      else
        pass "approval container contains only README.md and approval JSON artifacts: ${decision_path#$ROOT_DIR/}"
      fi

      while IFS= read -r approval_json; do
        [[ -z "$approval_json" ]] && continue
        validate_json_file "$approval_json"
      done < <(find "$decision_path" -mindepth 1 -maxdepth 1 -type f -name '*.json' | sort)

      continue
    fi

    matched=0

    while IFS=$'\t' read -r class_id prefix; do
      [[ -z "$class_id" || -z "$prefix" ]] && continue
      if [[ "$decision_name" == "$prefix"* ]]; then
        matched=1
        break
      fi
    done <<< "$class_prefixes"

    if [[ "$matched" -eq 0 ]]; then
      fail "decision directory does not match any retention class prefix: $decision_name"
    fi

    local decision_json digest_md extra_files
    decision_json="$decision_path/decision.json"
    digest_md="$decision_path/digest.md"
    if [[ ! -f "$decision_json" ]]; then
      fail "decision directory missing decision.json: ${decision_path#$ROOT_DIR/}"
      continue
    fi

    validate_json_file "$decision_json"

    extra_files="$(
      find "$decision_path" -mindepth 1 -maxdepth 1 -type f \
        ! -name 'decision.json' ! -name 'digest.md' -print
    )"
    if [[ -n "$extra_files" ]]; then
      fail "decision directory contains unsupported files: $(echo "$extra_files" | sed "s#${ROOT_DIR}/##g" | paste -sd ', ' -)"
    else
      pass "decision directory contains only allowed files: ${decision_path#$ROOT_DIR/}"
    fi

    local invalid_root
    invalid_root="$(
      jq -r '
        def nonempty_string: type == "string" and length > 0;
        select(
          (type != "object")
          or ((.decision_id | nonempty_string) | not)
          or ((.outcome as $o | ["allow","block","escalate"] | index($o)) == null)
          or ((.surface | nonempty_string) | not)
          or ((.action | nonempty_string) | not)
          or ((.actor | nonempty_string) | not)
          or (((.decided_at // "") | test("^[0-9]{4}-[0-9]{2}-[0-9]{2}T.+$")) | not)
          or ((.summary | nonempty_string) | not)
          or (.reason_codes | type != "array" or length == 0 or ([.reason_codes[]? | select((type != "string") or (length == 0))] | length > 0))
        )
        | .decision_id // "<missing-decision-id>"
      ' "$decision_json" 2>/dev/null || true
    )"
    if [[ -n "$invalid_root" ]]; then
      fail "decision record missing required root fields: ${decision_json#$ROOT_DIR/}"
      continue
    else
      pass "decision record root fields are valid: ${decision_json#$ROOT_DIR/}"
    fi

    local unknown_fields
    unknown_fields="$(
      jq -r \
        --argjson allowed '["decision_id","outcome","surface","action","actor","decided_at","reason_codes","summary","workflow_ref","mission_id","automation_id","incident_id","event_id","queue_item_id","run_id","approval_refs"]' '
        ((keys_unsorted - $allowed) // []) | join(",")
      ' "$decision_json" 2>/dev/null || true
    )"
    if [[ -n "$unknown_fields" ]]; then
      fail "decision record contains unsupported fields (${unknown_fields}): ${decision_json#$ROOT_DIR/}"
    else
      pass "decision record fields conform to canonical schema: ${decision_json#$ROOT_DIR/}"
    fi

    local bad_workflow_ref
    bad_workflow_ref="$(
      jq -r '
        select(has("workflow_ref"))
        | select(
            (.workflow_ref | type != "object")
            or ((.workflow_ref.workflow_group | type) != "string")
            or ((.workflow_ref.workflow_group | length) == 0)
            or ((.workflow_ref.workflow_id | type) != "string")
            or ((.workflow_ref.workflow_id | length) == 0)
            or (((.workflow_ref | keys_unsorted) - ["workflow_group","workflow_id"]) | length > 0)
          )
        | .decision_id
      ' "$decision_json" 2>/dev/null || true
    )"
    if [[ -n "$bad_workflow_ref" ]]; then
      fail "decision record workflow_ref is invalid: ${decision_json#$ROOT_DIR/}"
    else
      pass "decision record workflow_ref is valid when present: ${decision_json#$ROOT_DIR/}"
    fi

    local bad_approval_refs
    bad_approval_refs="$(
      jq -r '
        select(
          has("approval_refs")
          and (
            (.approval_refs | type != "array")
            or ([.approval_refs[]? | select((type != "string") or (length == 0))] | length > 0)
          )
        )
        | .decision_id
      ' "$decision_json" 2>/dev/null || true
    )"
    if [[ -n "$bad_approval_refs" ]]; then
      fail "decision record approval_refs must be a non-empty-string array: ${decision_json#$ROOT_DIR/}"
    else
      pass "decision record approval_refs are valid when present: ${decision_json#$ROOT_DIR/}"
    fi

    local basename_mismatch
    basename_mismatch="$(
      jq -r '.decision_id' "$decision_json" 2>/dev/null || true
    )"
    if [[ -n "$basename_mismatch" && "$basename_mismatch" != "$decision_name" ]]; then
      fail "decision directory name does not match decision_id: ${decision_path#$ROOT_DIR/}"
    else
      pass "decision directory name matches decision_id: ${decision_path#$ROOT_DIR/}"
    fi

    local bad_run_outcome
    bad_run_outcome="$(
      jq -r '
        select(has("run_id") and .outcome != "allow")
        | .decision_id
      ' "$decision_json" 2>/dev/null || true
    )"
    if [[ -n "$bad_run_outcome" ]]; then
      fail "decision record run_id is only allowed when outcome=allow: ${decision_json#$ROOT_DIR/}"
    else
      pass "decision record run_id/outcome invariant holds: ${decision_json#$ROOT_DIR/}"
    fi
  done < <(find "$DECISIONS_DIR" -mindepth 1 -maxdepth 1 -type d | sort)

  pass "decision directories map to retention classes"
}

validate_runs_retention_contract() {
  echo "== Validate continuity/runs retention contract =="
  require_dir "$RUNS_DIR" || return
  require_file "$RUNS_POLICY_FILE" || return
  require_file "$RUNS_DIR/README.md" || return
  validate_json_file "$RUNS_POLICY_FILE"

  if ! jq -e '
    type == "object"
    and .schema_version == "1.0"
    and (.default_action | type == "string" and length > 0)
    and (.classes | type == "array" and length > 0)
    and (.always_keep_files | type == "array")
  ' "$RUNS_POLICY_FILE" >/dev/null; then
    fail "runs retention policy root contract mismatch"
  else
    pass "runs retention policy root contract is valid"
  fi

  local dup_class_ids
  dup_class_ids="$(
    jq -r '.classes | map(.id) | group_by(.)[] | select(length > 1) | .[0]' "$RUNS_POLICY_FILE" 2>/dev/null || true
  )"
  if [[ -n "$dup_class_ids" ]]; then
    fail "duplicate retention class ids: $(echo "$dup_class_ids" | paste -sd ', ' -)"
  else
    pass "retention class ids are unique"
  fi

  local bad_classes
  bad_classes="$(
    jq -r '
      .classes[]
      | select(
          (.id | type != "string" or length == 0)
          or (.description | type != "string" or length == 0)
          or (.match_prefixes | type != "array" or length == 0)
          or ([.match_prefixes[]? | select((type != "string") or (length == 0))] | length > 0)
          or (.retention_days | type != "number" or . <= 0)
          or ((.action_after_retention as $a | ["archive","prune","retain"] | index($a)) == null)
        )
      | .id
    ' "$RUNS_POLICY_FILE" 2>/dev/null || true
  )"
  if [[ -n "$bad_classes" ]]; then
    fail "retention classes missing required fields: $(echo "$bad_classes" | paste -sd ', ' -)"
  else
    pass "retention classes are well formed"
  fi

  declare -A allowed_files=()
  while IFS= read -r filename; do
    [[ -z "$filename" ]] && continue
    allowed_files["$filename"]=1
  done < <(jq -r '.always_keep_files[]?' "$RUNS_POLICY_FILE" 2>/dev/null || true)

  while IFS= read -r top_file; do
    [[ -z "$top_file" ]] && continue
    local file_name
    file_name="$(basename "$top_file")"
    if [[ -z "${allowed_files[$file_name]+x}" ]]; then
      fail "runs/ contains top-level file not listed in always_keep_files: ${file_name}"
    fi
  done < <(find "$RUNS_DIR" -mindepth 1 -maxdepth 1 -type f | sort)
  pass "runs top-level files match retention policy allowlist"

  local class_prefixes
  class_prefixes="$(
    jq -r '.classes[] | .id as $id | .match_prefixes[] | [$id, .] | @tsv' "$RUNS_POLICY_FILE" 2>/dev/null || true
  )"

  local run_path run_name matched line class_id prefix
  while IFS= read -r run_path; do
    [[ -z "$run_path" ]] && continue
    run_name="$(basename "$run_path")"
    matched=0

    while IFS=$'\t' read -r class_id prefix; do
      [[ -z "$class_id" || -z "$prefix" ]] && continue
      if [[ "$run_name" == "$prefix"* ]]; then
        matched=1
        break
      fi
    done <<< "$class_prefixes"

    if [[ "$matched" -eq 0 ]]; then
      fail "run directory does not match any retention class prefix: $run_name"
    fi

    if ! find "$run_path" -mindepth 1 -maxdepth 1 | grep -q .; then
      warn "run directory is empty: $run_name"
    fi
  done < <(find "$RUNS_DIR" -mindepth 1 -maxdepth 1 -type d | sort)
  pass "run directories map to retention classes"
}

main() {
  echo "== Validate Continuity Memory =="

  check_jq_available
  validate_tasks_contract
  validate_entities_contract
  validate_next_contract
  validate_decisions_retention_contract
  validate_runs_retention_contract

  echo
  echo "Continuity memory validation summary: errors=$errors warnings=$warnings"
  if [[ "$errors" -gt 0 ]]; then
    exit 1
  fi
}

main "$@"
