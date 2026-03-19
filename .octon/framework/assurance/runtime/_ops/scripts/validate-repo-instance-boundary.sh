#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
DEFAULT_OCTON_DIR="$(cd -- "$SCRIPT_DIR/../../../../../" && pwd)"
OCTON_DIR="${OCTON_DIR_OVERRIDE:-$DEFAULT_OCTON_DIR}"
ROOT_DIR="${OCTON_ROOT_DIR:-$(cd -- "$OCTON_DIR/.." && pwd)}"

INSTANCE_DIR="$OCTON_DIR/instance"
INSTANCE_MANIFEST="$INSTANCE_DIR/manifest.yml"
OVERLAY_REGISTRY="$OCTON_DIR/framework/overlay-points/registry.yml"
EXTENSIONS_MANIFEST="$INSTANCE_DIR/extensions.yml"

errors=0

fail() {
  echo "[ERROR] $1"
  errors=$((errors + 1))
}

pass() {
  echo "[OK] $1"
}

require_file() {
  local path="$1"
  if [[ -f "$path" ]]; then
    pass "found file: ${path#$ROOT_DIR/}"
  else
    fail "missing file: ${path#$ROOT_DIR/}"
  fi
}

require_dir() {
  local path="$1"
  if [[ -d "$path" ]]; then
    pass "found directory: ${path#$ROOT_DIR/}"
  else
    fail "missing directory: ${path#$ROOT_DIR/}"
  fi
}

check_required_structure() {
  require_file "$INSTANCE_DIR/locality/README.md"
  require_file "$INSTANCE_DIR/locality/manifest.yml"
  require_file "$INSTANCE_DIR/locality/registry.yml"
  require_dir "$INSTANCE_DIR/locality/scopes"
  require_dir "$INSTANCE_DIR/cognition/context/scopes"
  require_file "$INSTANCE_DIR/cognition/context/scopes/README.md"
  require_dir "$INSTANCE_DIR/orchestration/missions"
  require_file "$INSTANCE_DIR/orchestration/missions/README.md"
  require_file "$INSTANCE_DIR/orchestration/missions/registry.yml"
  require_dir "$INSTANCE_DIR/orchestration/missions/.archive"
  require_dir "$INSTANCE_DIR/orchestration/missions/_scaffold/template"
  require_file "$INSTANCE_DIR/orchestration/missions/_scaffold/template/mission.yml"
  require_file "$INSTANCE_DIR/orchestration/missions/_scaffold/template/mission.md"
  require_file "$INSTANCE_DIR/orchestration/missions/_scaffold/template/tasks.json"
  require_file "$INSTANCE_DIR/orchestration/missions/_scaffold/template/log.md"
  require_dir "$INSTANCE_DIR/capabilities/runtime/commands"
  require_file "$INSTANCE_DIR/capabilities/runtime/commands/README.md"
}

check_enabled_overlay_roots() {
  local overlay_id instance_glob root_path

  while IFS= read -r overlay_id; do
    [[ -n "$overlay_id" ]] || continue
    instance_glob="$(yq -r ".overlay_points[]? | select(.overlay_point_id == \"$overlay_id\") | .instance_glob // \"\"" "$OVERLAY_REGISTRY" 2>/dev/null || true)"
    if [[ -z "$instance_glob" ]]; then
      fail "enabled overlay point '$overlay_id' is not declared in framework registry"
      continue
    fi
    root_path="${instance_glob%/**}"
    if [[ -d "$ROOT_DIR/$root_path" ]]; then
      pass "enabled overlay root exists: $root_path"
    else
      fail "enabled overlay root missing: $root_path"
    fi
  done < <(yq -r '.enabled_overlay_points[]? // ""' "$INSTANCE_MANIFEST" 2>/dev/null || true)
}

check_overlay_domain_shape() {
  local stray_paths=""

  if [[ -d "$INSTANCE_DIR/governance" ]]; then
    stray_paths="$(find "$INSTANCE_DIR/governance" -mindepth 1 \
      ! -path "$INSTANCE_DIR/governance/policies" \
      ! -path "$INSTANCE_DIR/governance/policies/*" \
      ! -path "$INSTANCE_DIR/governance/contracts" \
      ! -path "$INSTANCE_DIR/governance/contracts/*" \
      -print | sort || true)"
    if [[ -n "$stray_paths" ]]; then
      fail "ad hoc governance overlay content exists outside ratified roots"
      printf '%s\n' "$stray_paths" | sed "s|$ROOT_DIR/||"
    else
      pass "governance overlay content stays inside ratified roots"
    fi
  fi

  if [[ -d "$INSTANCE_DIR/agency" ]]; then
    stray_paths="$(find "$INSTANCE_DIR/agency" -mindepth 1 \
      ! -path "$INSTANCE_DIR/agency/runtime" \
      ! -path "$INSTANCE_DIR/agency/runtime/*" \
      -print | sort || true)"
    if [[ -n "$stray_paths" ]]; then
      fail "ad hoc agency overlay content exists outside ratified roots"
      printf '%s\n' "$stray_paths" | sed "s|$ROOT_DIR/||"
    else
      pass "agency overlay content stays inside ratified roots"
    fi
  fi

  if [[ -d "$INSTANCE_DIR/assurance" ]]; then
    stray_paths="$(find "$INSTANCE_DIR/assurance" -mindepth 1 \
      ! -path "$INSTANCE_DIR/assurance/runtime" \
      ! -path "$INSTANCE_DIR/assurance/runtime/*" \
      -print | sort || true)"
    if [[ -n "$stray_paths" ]]; then
      fail "ad hoc assurance overlay content exists outside ratified roots"
      printf '%s\n' "$stray_paths" | sed "s|$ROOT_DIR/||"
    else
      pass "assurance overlay content stays inside ratified roots"
    fi
  fi
}

check_wrong_class_placements() {
  local wrong_dirs
  wrong_dirs="$(find "$INSTANCE_DIR" -type d \( -name state -o -name control -o -name generated -o -name inputs \) -print | sort || true)"
  if [[ -n "$wrong_dirs" ]]; then
    fail "wrong-class state/control/generated/inputs directories found under instance/**"
    printf '%s\n' "$wrong_dirs" | sed "s|$ROOT_DIR/||"
  else
    pass "no obvious wrong-class state/control/generated/inputs directories exist under instance/**"
  fi

  local forbidden_payloads
  forbidden_payloads="$(find "$INSTANCE_DIR" \( -name 'pack.yml' -o -name 'proposal.yml' -o -name 'design-proposal.yml' -o -name 'migration-proposal.yml' -o -name 'policy-proposal.yml' -o -name 'architecture-proposal.yml' -o -name 'artifact-map.yml' -o -name 'generation.lock.yml' -o -name 'catalog.effective.yml' -o -name 'active.yml' -o -name 'quarantine.yml' \) -print | sort || true)"
  if [[ -n "$forbidden_payloads" ]]; then
    fail "wrong-class raw input or generated/control payloads found under instance/**"
    printf '%s\n' "$forbidden_payloads" | sed "s|$ROOT_DIR/||"
  else
    pass "no wrong-class raw input or generated/control payloads exist under instance/**"
  fi
}

check_locality_scope_contract() {
  local scope_manifest_count
  scope_manifest_count="$(find "$INSTANCE_DIR/locality/scopes" -type f -name 'scope.yml' ! -path '*/_scaffold/*' | wc -l | tr -d ' ')"
  if [[ "$scope_manifest_count" -gt 0 ]]; then
    pass "locality scope manifests present under instance/locality/scopes/**"
  else
    fail "missing locality scope manifests under instance/locality/scopes/**"
  fi
}

check_active_reference_drift() {
  local -a targets=(
    "$OCTON_DIR/README.md"
    "$INSTANCE_DIR/ingress/AGENTS.md"
    "$INSTANCE_DIR/bootstrap"
    "$INSTANCE_DIR/cognition/context/shared"
    "$OCTON_DIR/framework/agency/practices"
    "$OCTON_DIR/framework/assurance/practices"
    "$OCTON_DIR/framework/capabilities/practices"
    "$OCTON_DIR/framework/capabilities/runtime/commands"
    "$OCTON_DIR/framework/cognition/governance/principles"
    "$OCTON_DIR/framework/cognition/_meta/architecture/README.md"
    "$OCTON_DIR/framework/cognition/_meta/architecture/context.md"
    "$OCTON_DIR/framework/cognition/_meta/architecture/dot-files.md"
    "$OCTON_DIR/framework/cognition/_meta/architecture/taxonomy.md"
    "$OCTON_DIR/framework/orchestration/runtime/workflows/meta/migrate-harness"
    "$OCTON_DIR/framework/orchestration/runtime/workflows/meta/update-harness"
    "$OCTON_DIR/framework/orchestration/practices"
    "$OCTON_DIR/framework/scaffolding/runtime/templates/octon"
    "$ROOT_DIR/.github/workflows/harness-self-containment.yml"
    "$ROOT_DIR/.github/workflows/main-push-safety.yml"
    "$ROOT_DIR/.github/workflows/smoke.yml"
  )

  local -a existing=()
  local target drift
  for target in "${targets[@]}"; do
    [[ -e "$target" ]] && existing+=("$target")
  done

  if [[ "${#existing[@]}" -eq 0 ]]; then
    pass "no active packet-4 drift targets found to scan"
    return
  fi

  drift="$(
    rg -n -P --no-heading \
      --glob '!**/migrations/**' \
      '(?<!framework/)(?<!instance/)cognition/runtime/context/|(?<!framework/)(?<!instance/)cognition/runtime/decisions/|(?<!state/)continuity/(log\.md|tasks\.json|entities\.json|next\.md)|(?<!framework/)(?<!instance/)orchestration/runtime/missions/' \
      "${existing[@]}" 2>/dev/null || true
  )"

  if [[ -n "$drift" ]]; then
    fail "active control-plane surfaces still reference retired mixed repo-instance paths"
    printf '%s\n' "$drift"
  else
    pass "active control-plane surfaces no longer reference retired mixed repo-instance paths"
  fi
}

check_native_collision_risk() {
  local -a enabled_packs=()
  local -a command_ids=()
  local pack_id command_path command_id

  while IFS= read -r pack_id; do
    [[ -n "$pack_id" ]] && enabled_packs+=("$pack_id")
  done < <(yq -r '.selection.enabled[]? // ""' "$EXTENSIONS_MANIFEST" 2>/dev/null || true)

  while IFS= read -r command_path; do
    command_id="$(basename "${command_path%.md}")"
    [[ -n "$command_id" ]] && command_ids+=("$command_id")
  done < <(find "$INSTANCE_DIR/capabilities/runtime/commands" -mindepth 1 -maxdepth 1 -type f -name '*.md' -print | sort || true)

  if [[ "${#enabled_packs[@]}" -eq 0 || "${#command_ids[@]}" -eq 0 ]]; then
    pass "no static repo-native command versus enabled-pack collisions detected"
    return
  fi

  local collisions=()
  for pack_id in "${enabled_packs[@]}"; do
    for command_id in "${command_ids[@]}"; do
      if [[ "$pack_id" == "$command_id" ]]; then
        collisions+=("$pack_id")
      fi
    done
  done

  if [[ "${#collisions[@]}" -gt 0 ]]; then
    fail "enabled pack ids collide with repo-native command ids: ${collisions[*]}"
  else
    pass "no static repo-native command versus enabled-pack collisions detected"
  fi
}

main() {
  echo "== Repo-Instance Boundary Validation =="

  require_file "$INSTANCE_MANIFEST"
  require_file "$OVERLAY_REGISTRY"
  require_file "$EXTENSIONS_MANIFEST"

  check_required_structure
  check_enabled_overlay_roots
  check_overlay_domain_shape
  check_wrong_class_placements
  check_locality_scope_contract
  check_active_reference_drift
  check_native_collision_risk

  echo "Validation summary: errors=$errors"
  if [[ $errors -gt 0 ]]; then
    exit 1
  fi
}

main "$@"
