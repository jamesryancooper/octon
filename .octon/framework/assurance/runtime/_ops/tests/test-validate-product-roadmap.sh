#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd -- "$SCRIPT_DIR/../../../../../.." && pwd)"
VALIDATOR="$REPO_ROOT/.octon/framework/assurance/runtime/_ops/scripts/validate-product-roadmap.sh"

pass_count=0
fail_count=0
declare -a CLEANUP_DIRS=()

cleanup() {
  local dir
  for dir in "${CLEANUP_DIRS[@]}"; do
    [[ -n "$dir" ]] && rm -r "$dir"
  done
}
trap cleanup EXIT

pass() { printf 'PASS: %s\n' "$1"; pass_count=$((pass_count + 1)); }
fail() { printf 'FAIL: %s\n' "$1" >&2; fail_count=$((fail_count + 1)); }

new_fixture_repo() {
  local root
  root="$(mktemp -d "${TMPDIR:-/tmp}/product-roadmap.XXXXXX")"
  CLEANUP_DIRS+=("$root")
  mkdir -p "$root/.octon/framework/product/roadmap"
  mkdir -p "$root/.octon/framework/product/features"
  mkdir -p "$root/.octon/framework/product/contracts"
  mkdir -p "$root/.octon/framework/engine/runtime/crates/kernel/src"
  mkdir -p "$root/.octon/framework/assurance/runtime/_ops/tests"
  mkdir -p "$root/.octon/framework/assurance/runtime/_ops/scripts"
  mkdir -p "$root/.octon/inputs/additive/extensions/example"
  mkdir -p "$root/.octon/generated/effective/example"

  touch "$root/.octon/framework/product/contracts/product-roadmap-v1.schema.json"
  touch "$root/.octon/framework/product/roadmap/example-feature.md"
  touch "$root/.octon/framework/product/features/example-feature.md"
  touch "$root/.octon/framework/engine/runtime/crates/kernel/src/lifecycle.rs"
  touch "$root/.octon/framework/assurance/runtime/_ops/tests/example-test.sh"
  touch "$root/.octon/framework/assurance/runtime/_ops/scripts/example-validator.sh"
  touch "$root/.octon/inputs/additive/extensions/example/source.md"
  touch "$root/.octon/generated/effective/example/output.yml"

  cat >"$root/.octon/framework/product/features/catalog.yml" <<'YAML'
schema_version: "octon-product-feature-catalog-v1"
catalog_role: "navigation-only"
authority_note: "Navigation only."
features:
  - feature_id: "example-feature"
    name: "Example Feature"
    implementation_status: "implemented"
    summary: "Fixture feature."
    primary_audiences: ["agents"]
    owner_subsystems: ["product"]
    entrypoints:
      - kind: "path"
        value: ".octon/framework/product/features/example-feature.md"
    authoritative_refs:
      - path: ".octon/framework/product/contracts/product-roadmap-v1.schema.json"
        role: "fixture contract"
        authority_class: "product-contract"
    runtime_surfaces:
      - path: ".octon/framework/engine/runtime/crates/kernel/src/lifecycle.rs"
        role: "fixture runtime"
        authority_class: "runtime-implementation"
    extension_surfaces:
      - path: ".octon/inputs/additive/extensions/example/source.md"
        role: "fixture input"
        authority_class: "publication-input-only"
    generated_effective_surfaces:
      - path: ".octon/generated/effective/example/output.yml"
        role: "fixture generated output"
        authority_class: "generated-effective-non-authority"
    evidence_surfaces:
      - path_pattern: ".octon/state/evidence/runs/<run-id>/"
        role: "fixture evidence"
        authority_class: "retained-evidence-pattern"
    validation_refs:
      - path: ".octon/framework/assurance/runtime/_ops/tests/example-test.sh"
        role: "fixture test"
        authority_class: "validation"
    related_docs:
      - path: ".octon/framework/product/features/example-feature.md"
        role: "fixture note"
        authority_class: "navigation-only"
    authority_notes:
      - "Fixture feature entry."
YAML

  printf '%s\n' "$root"
}

write_valid_roadmap() {
  local root="$1"
  cat >"$root/.octon/framework/product/roadmap/catalog.yml" <<'YAML'
schema_version: "octon-product-roadmap-v1"
roadmap_role: "planning-only"
authority_note: "Planning only; no authority is minted here."
items:
  - roadmap_item_id: "example-feature-follow-up"
    title: "Example Feature Follow-Up"
    status: "suggested"
    feature_id: "example-feature"
    summary: "Fixture roadmap item."
    why_deferred: "Fixture work is deferred."
    owner_subsystems: ["product"]
    source_refs:
      - path: ".octon/framework/product/features/example-feature.md"
        role: "feature note"
        authority_class: "navigation-only"
    acceptance_criteria:
      - "Fixture acceptance criterion exists."
    validation_refs:
      - path: ".octon/framework/assurance/runtime/_ops/tests/example-test.sh"
        role: "fixture test"
        authority_class: "validation"
    completion_refs: []
    authority_notes:
      - "Fixture roadmap item is planning-only."
YAML
}

assert_success() {
  local label="$1" root="$2"
  if OCTON_ROOT_DIR="$root" bash "$VALIDATOR" >/tmp/product-roadmap.out 2>&1; then
    pass "$label"
  else
    cat /tmp/product-roadmap.out >&2
    fail "$label"
  fi
}

assert_failure() {
  local label="$1" root="$2"
  if OCTON_ROOT_DIR="$root" bash "$VALIDATOR" >/tmp/product-roadmap.out 2>&1; then
    cat /tmp/product-roadmap.out >&2
    fail "$label"
  else
    pass "$label"
  fi
}

main() {
  local root

  root="$(new_fixture_repo valid)"
  write_valid_roadmap "$root"
  assert_success "valid roadmap passes" "$root"

  root="$(new_fixture_repo duplicate-id)"
  write_valid_roadmap "$root"
  yq -i '.items += [.items[0]]' "$root/.octon/framework/product/roadmap/catalog.yml"
  assert_failure "duplicate roadmap item id fails" "$root"

  root="$(new_fixture_repo missing-required)"
  write_valid_roadmap "$root"
  yq -i 'del(.items[0].summary)' "$root/.octon/framework/product/roadmap/catalog.yml"
  assert_failure "missing required field fails" "$root"

  root="$(new_fixture_repo invalid-status)"
  write_valid_roadmap "$root"
  yq -i '.items[0].status = "maybe"' "$root/.octon/framework/product/roadmap/catalog.yml"
  assert_failure "invalid status fails" "$root"

  root="$(new_fixture_repo unknown-feature)"
  write_valid_roadmap "$root"
  yq -i '.items[0].feature_id = "missing-feature"' "$root/.octon/framework/product/roadmap/catalog.yml"
  assert_failure "unknown feature id fails" "$root"

  root="$(new_fixture_repo missing-path)"
  write_valid_roadmap "$root"
  yq -i '.items[0].source_refs[0].path = ".octon/framework/product/missing.md"' "$root/.octon/framework/product/roadmap/catalog.yml"
  assert_failure "missing referenced path fails" "$root"

  root="$(new_fixture_repo generated-authority)"
  write_valid_roadmap "$root"
  yq -i '.items[0].source_refs[0].path = ".octon/generated/effective/example/output.yml" | .items[0].source_refs[0].authority_class = "authored-authority"' "$root/.octon/framework/product/roadmap/catalog.yml"
  assert_failure "generated path marked as authority fails" "$root"

  root="$(new_fixture_repo input-authority)"
  write_valid_roadmap "$root"
  yq -i '.items[0].source_refs[0].path = ".octon/inputs/additive/extensions/example/source.md" | .items[0].source_refs[0].authority_class = "authored-authority"' "$root/.octon/framework/product/roadmap/catalog.yml"
  assert_failure "input path marked as authority fails" "$root"

  root="$(new_fixture_repo completed-no-completion)"
  write_valid_roadmap "$root"
  yq -i '.items[0].status = "completed"' "$root/.octon/framework/product/roadmap/catalog.yml"
  assert_failure "completed item without completion ref fails" "$root"

    root="$(new_fixture_repo completed-with-completion)"
    write_valid_roadmap "$root"
    yq -i '.items[0].status = "completed" | .items[0].completion_refs = [{"path": ".octon/framework/product/roadmap/example-feature.md", "role": "completion note", "authority_class": "planning-only"}]' "$root/.octon/framework/product/roadmap/catalog.yml"
    assert_success "completed item with completion ref passes" "$root"

    root="$(new_fixture_repo lifecycle-roadmap-overclaim)"
    write_valid_roadmap "$root"
    cat >"$root/.octon/framework/product/roadmap/lifecycle-autopilot.md" <<'MD'
# Lifecycle Autopilot Roadmap

The roadmap adds external workflow engines and Durable Objects support.
MD
    assert_failure "lifecycle-autopilot roadmap overstated support claim fails" "$root"

    root="$(new_fixture_repo lifecycle-roadmap-remain-overclaim)"
    write_valid_roadmap "$root"
    cat >"$root/.octon/framework/product/roadmap/lifecycle-autopilot.md" <<'MD'
# Lifecycle Autopilot Roadmap

Lifecycle Autopilot remains fully transactional across all program operations.
MD
    assert_failure "lifecycle-autopilot roadmap remain overclaim fails" "$root"

    if OCTON_ROOT_DIR="$REPO_ROOT" bash "$VALIDATOR" >/tmp/product-roadmap-real.out 2>&1; then
      pass "real product roadmap passes"
    else
    cat /tmp/product-roadmap-real.out >&2
    fail "real product roadmap passes"
  fi

  echo "Test summary: passes=$pass_count failures=$fail_count"
  if [[ "$fail_count" -gt 0 ]]; then
    exit 1
  fi
}

main "$@"
