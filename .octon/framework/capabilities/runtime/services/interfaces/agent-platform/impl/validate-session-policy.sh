#!/usr/bin/env bash
# validate-session-policy.sh - Validate canonical session policy semantics.

set -euo pipefail

input_file=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --file)
      input_file="${2:-}"
      shift 2
      ;;
    *)
      echo "Unknown argument: $1" >&2
      exit 2
      ;;
  esac
done

if [[ -z "$input_file" ]]; then
  echo "Usage: $0 --file <session-policy.json>" >&2
  exit 2
fi

if [[ ! -f "$input_file" ]]; then
  echo "Input file not found: $input_file" >&2
  exit 2
fi

node - "$input_file" <<'NODE'
const fs = require('fs');

const file = process.argv[2];
const raw = fs.readFileSync(file, 'utf8');
let data;

try {
  data = JSON.parse(raw);
} catch (err) {
  console.error(JSON.stringify({ ok: false, errors: ['invalid-json'] }, null, 2));
  process.exit(1);
}

const errors = [];
const required = [
  'interop_contract_version',
  'policy_id',
  'scope_class',
  'reset_class',
  'send_class',
  'context_budget',
  'pruning_class',
  'memory',
  'routing',
  'presence'
];

for (const key of required) {
  if (!(key in data)) {
    errors.push(`missing:${key}`);
  }
}

if (data.interop_contract_version !== '1.0.0') {
  errors.push('interop_contract_version-must-be-1.0.0');
}

if (!['session', 'run', 'task'].includes(data.scope_class)) {
  errors.push('scope_class-invalid');
}

if (!['none', 'soft', 'hard'].includes(data.reset_class)) {
  errors.push('reset_class-invalid');
}

if (!['append', 'replace', 'branch'].includes(data.send_class)) {
  errors.push('send_class-invalid');
}

const budget = data.context_budget || {};
if (!Number.isInteger(budget.max_units) || budget.max_units <= 0) {
  errors.push('context_budget.max_units-invalid');
}
if (!Number.isInteger(budget.used_units) || budget.used_units < 0) {
  errors.push('context_budget.used_units-invalid');
}
if (Number.isInteger(budget.max_units) && Number.isInteger(budget.used_units) && budget.used_units > budget.max_units) {
  errors.push('context_budget.used_units-exceeds-max_units');
}
if (budget.warning_threshold_percent !== 80) {
  errors.push('context_budget.warning_threshold_percent-must-be-80');
}
if (budget.flush_threshold_percent !== 90) {
  errors.push('context_budget.flush_threshold_percent-must-be-90');
}

if (!['none', 'conservative', 'aggressive'].includes(data.pruning_class)) {
  errors.push('pruning_class-invalid');
}

const memory = data.memory || {};
if (memory.flush_before_compaction !== true) {
  errors.push('memory.flush_before_compaction-must-be-true');
}
if (memory.fail_closed_on_flush_failure !== true) {
  errors.push('memory.fail_closed_on_flush_failure-must-be-true');
}

const precedence = (((data.routing || {}).precedence) || []);
const expectedPrecedence = [
  'human-safety',
  'governance-policy',
  'agent-policy',
  'adapter-execution'
];

if (
  !Array.isArray(precedence) ||
  precedence.length !== expectedPrecedence.length ||
  precedence.some((item, idx) => item !== expectedPrecedence[idx])
) {
  errors.push('routing.precedence-invalid');
}

const presence = data.presence || {};
if (!Number.isInteger(presence.heartbeat_seconds) || presence.heartbeat_seconds < 5 || presence.heartbeat_seconds > 300) {
  errors.push('presence.heartbeat_seconds-invalid');
}

const requiredPresenceFields = [
  'run_id',
  'session_id',
  'heartbeat_at',
  'mode',
  'active_capabilities',
  'degraded_capabilities'
];

const evidenceFields = Array.isArray(presence.evidence_fields) ? presence.evidence_fields : [];
for (const field of requiredPresenceFields) {
  if (!evidenceFields.includes(field)) {
    errors.push(`presence.evidence_fields-missing:${field}`);
  }
}

if (errors.length > 0) {
  console.error(JSON.stringify({ ok: false, interop_contract_version: '1.0.0', errors }, null, 2));
  process.exit(1);
}

console.log(JSON.stringify({ ok: true, interop_contract_version: '1.0.0', policy_id: data.policy_id }, null, 2));
NODE
