#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
OCTON_DIR="$(cd -- "$SCRIPT_DIR/../../../../../" && pwd)"

TMP_FILE="$(mktemp "${TMPDIR:-/tmp}/octon-state-surface-alignment.XXXXXX")"
trap 'rm -f -- "$TMP_FILE"' EXIT

LEGACY_OCTON_CONTINUITY_PATTERN='\.octon/'"continuity"
LEGACY_CONTINUITY_META_PATTERN='continuity/'"_meta/architecture"
LEGACY_RUNS_PATTERN='\.octon/'"continuity/runs/"
LEGACY_DECISIONS_PATTERN='\.octon/'"continuity/decisions/"
LEGACY_SCOPE_GATE_PATTERN='scope continuity remains gated off|scope continuity is not legal '"before Packet "'7'
LEGACY_PACKET7_UNTIL_PATTERN='until Packet '"7"
LEGACY_PACKET7_BEFORE_PATTERN='before Packet '"7"
STATE_SURFACE_PATTERN="(${LEGACY_OCTON_CONTINUITY_PATTERN}|${LEGACY_CONTINUITY_META_PATTERN}|${LEGACY_RUNS_PATTERN}|${LEGACY_DECISIONS_PATTERN}|${LEGACY_SCOPE_GATE_PATTERN}|${LEGACY_PACKET7_UNTIL_PATTERN}|${LEGACY_PACKET7_BEFORE_PATTERN})"

if rg -n \
  --glob '!*.png' \
  --glob '!*.jpg' \
  --glob '!*.jpeg' \
  "$STATE_SURFACE_PATTERN" \
  "$OCTON_DIR/README.md" \
  "$OCTON_DIR/instance/bootstrap/START.md" \
  "$OCTON_DIR/instance/bootstrap/catalog.md" \
  "$OCTON_DIR/instance/ingress/AGENTS.md" \
  "$OCTON_DIR/instance/cognition/context/shared/memory-map.md" \
  "$OCTON_DIR/instance/cognition/context/shared/continuity.md" \
  "$OCTON_DIR/instance/cognition/context/scopes/README.md" \
  "$OCTON_DIR/framework/cognition/_meta/architecture/specification.md" \
  "$OCTON_DIR/framework/cognition/_meta/architecture/shared-foundation.md" \
  "$OCTON_DIR/framework/cognition/governance/principles/locality.md" \
  "$OCTON_DIR/framework/cognition/_meta/architecture/state" \
  "$OCTON_DIR/framework/cognition/_meta/architecture/artifact-surface/README.md" \
  "$OCTON_DIR/framework/cognition/_meta/architecture/artifact-surface/overview.md" \
  "$OCTON_DIR/framework/cognition/_meta/architecture/artifact-surface/architecture-overview.md" \
  "$OCTON_DIR/framework/cognition/_meta/architecture/artifact-surface/architecture-diagram.md" \
  "$OCTON_DIR/framework/cognition/_meta/architecture/artifact-surface/technical-specification.md" \
  "$OCTON_DIR/framework/cognition/_meta/architecture/artifact-surface/implementation-roadmap.md" \
  "$OCTON_DIR/framework/cognition/_meta/architecture/artifact-surface/pillar-convivial-alignment.md" \
  "$OCTON_DIR/framework/cognition/_meta/architecture/artifact-surface/runtime-artifact-layer.md" \
  "$OCTON_DIR/framework/engine/runtime/spec/policy-interface-v1.md" \
  "$OCTON_DIR/framework/orchestration/practices/run-linkage-standards.md" \
  "$OCTON_DIR/framework/orchestration/practices/automation-operations.md" \
  "$OCTON_DIR/framework/orchestration/_meta/architecture/missions.md" \
  "$OCTON_DIR/framework/orchestration/runtime/runs/README.md" \
  "$OCTON_DIR/framework/orchestration/runtime/workflows/tasks/agent-led-happy-path/stages/01-inline.md" \
  "$OCTON_DIR/framework/assurance/practices/session-exit.md" \
  "$OCTON_DIR/framework/assurance/practices/complete.md" \
  "$OCTON_DIR/state/evidence/decisions/repo/README.md" \
  "$OCTON_DIR/framework/capabilities/runtime/skills/audit/audit-data-governance/references/io-contract.md" \
  "$OCTON_DIR/framework/scaffolding/runtime/templates/octon/START.md" \
  "$OCTON_DIR/framework/scaffolding/runtime/templates/octon/manifest.json" \
  "$OCTON_DIR/framework/scaffolding/runtime/templates/octon/assurance/practices/session-exit.md" \
  "$OCTON_DIR/framework/scaffolding/runtime/templates/octon/assurance/practices/complete.md" \
  >"$TMP_FILE"; then
  echo "[ERROR] stale Packet 7 state-surface wording detected"
  cat "$TMP_FILE"
  exit 1
fi

echo "[OK] Packet 7 state-surface wording is aligned"
