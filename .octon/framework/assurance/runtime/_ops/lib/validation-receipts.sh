#!/usr/bin/env bash

validation_receipt_field_equals() {
  local file="$1" field="$2" expected="$3"
  [[ -f "$file" ]] && grep -Eq "^${field}:[[:space:]]*\"?${expected}\"?[[:space:]]*$" "$file"
}

validation_receipt_records_pass() {
  local file="$1" table_rows
  [[ -f "$file" ]] || return 1
  if validation_receipt_field_equals "$file" verdict pass; then
    return 0
  fi
  if grep -Eiq 'All listed commands exited successfully\.?' "$file"; then
    return 0
  fi
  table_rows="$(grep -E '^\|[[:space:]]*`[^`]+`[[:space:]]*\|[[:space:]]*[^|]+[[:space:]]*\|' "$file" || true)"
  if [[ -z "$table_rows" ]]; then
    return 1
  fi
  if grep -Eiq '\|[[:space:]]*(fail|failed|error|blocked)[[:space:]]*\|' <<<"$table_rows"; then
    return 1
  fi
  grep -Eiq '\|[[:space:]]*pass[[:space:]]*\|' <<<"$table_rows"
}
