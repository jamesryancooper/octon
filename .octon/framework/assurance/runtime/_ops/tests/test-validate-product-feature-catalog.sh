#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd -- "$SCRIPT_DIR/../../../../../.." && pwd)"
VALIDATOR="$REPO_ROOT/.octon/framework/assurance/runtime/_ops/scripts/validate-product-feature-catalog.sh"

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
  root="$(mktemp -d "${TMPDIR:-/tmp}/product-feature-catalog.XXXXXX")"
  CLEANUP_DIRS+=("$root")
  mkdir -p "$root/.octon/framework/product/features"
  mkdir -p "$root/.octon/framework/product/contracts"
  mkdir -p "$root/.octon/framework/constitution/obligations"
  mkdir -p "$root/.octon/framework/assurance/runtime/_ops/tests"
  mkdir -p "$root/.octon/framework/assurance/runtime/_ops/scripts"
  mkdir -p "$root/.octon/framework/engine/runtime/crates/kernel/src"
  mkdir -p "$root/.octon/framework/engine/runtime/crates/lifecycle_executor"
  mkdir -p "$root/.octon/framework/engine/runtime/spec"
  mkdir -p "$root/.octon/inputs/additive/extensions/example/context"
  mkdir -p "$root/.octon/generated/effective/extensions"

  touch "$root/.octon/framework/constitution/CHARTER.md"
  touch "$root/.octon/framework/constitution/obligations/fail-closed.yml"
  touch "$root/.octon/framework/product/contracts/product-feature-catalog-v1.schema.json"
  touch "$root/.octon/framework/engine/runtime/crates/kernel/src/lifecycle.rs"
  touch "$root/.octon/framework/engine/runtime/crates/lifecycle_executor/Cargo.toml"
  touch "$root/.octon/framework/engine/runtime/spec/example.schema.json"
  touch "$root/.octon/framework/assurance/runtime/_ops/scripts/example-validator.sh"
  touch "$root/.octon/framework/assurance/runtime/_ops/tests/example-test.sh"
  touch "$root/.octon/inputs/additive/extensions/example/context/lifecycle.contract.yml"
  touch "$root/.octon/generated/effective/extensions/catalog.effective.yml"
  touch "$root/.octon/framework/product/features/example-feature.md"

  printf '%s\n' "$root"
}

write_valid_catalog() {
  local root="$1"
  cat >"$root/.octon/framework/product/features/catalog.yml" <<'YAML'
schema_version: "octon-product-feature-catalog-v1"
catalog_role: "navigation-only"
authority_note: "Navigation only; no authority is minted here."
features:
  - feature_id: "example-feature"
    name: "Example Feature"
    implementation_status: "implemented"
    summary: "Fixture feature."
    primary_audiences: ["agents"]
    owner_subsystems: ["engine/runtime"]
    entrypoints:
      - kind: "cli"
        value: "octon example"
    authoritative_refs:
      - path: ".octon/framework/constitution/CHARTER.md"
        role: "constitutional root"
        authority_class: "authored-authority"
      - path: ".octon/framework/product/contracts/product-feature-catalog-v1.schema.json"
        role: "catalog schema"
        authority_class: "product-contract"
    runtime_surfaces:
      - path: ".octon/framework/engine/runtime/crates/kernel/src/lifecycle.rs"
        role: "runtime implementation"
        authority_class: "runtime-implementation"
      - path: ".octon/framework/engine/runtime/spec/example.schema.json"
        role: "runtime schema"
        authority_class: "runtime-spec"
    extension_surfaces:
      - path: ".octon/inputs/additive/extensions/example/context/lifecycle.contract.yml"
        role: "extension authoring input"
        authority_class: "publication-input-only"
    generated_effective_surfaces:
      - path: ".octon/generated/effective/extensions/catalog.effective.yml"
        role: "generated effective projection"
        authority_class: "generated-effective-non-authority"
    evidence_surfaces:
      - path_pattern: ".octon/state/evidence/runs/workflows/<run-id>/"
        role: "run evidence pattern"
        authority_class: "retained-evidence-pattern"
    validation_refs:
      - path: ".octon/framework/assurance/runtime/_ops/tests/example-test.sh"
        role: "fixture test"
        authority_class: "validation"
    related_docs:
      - path: ".octon/framework/product/features/example-feature.md"
        role: "feature note"
        authority_class: "navigation-only"
    authority_notes:
      - "Fixture catalog entry is navigation-only."
YAML
}

assert_success() {
  local label="$1" root="$2"
  if OCTON_ROOT_DIR="$root" bash "$VALIDATOR" >/tmp/product-feature-catalog.out 2>&1; then
    pass "$label"
  else
    cat /tmp/product-feature-catalog.out >&2
    fail "$label"
  fi
}

assert_failure() {
  local label="$1" root="$2"
  if OCTON_ROOT_DIR="$root" bash "$VALIDATOR" >/tmp/product-feature-catalog.out 2>&1; then
    cat /tmp/product-feature-catalog.out >&2
    fail "$label"
  else
    pass "$label"
  fi
}

main() {
  local root

  root="$(new_fixture_repo valid)"
  write_valid_catalog "$root"
  assert_success "valid catalog passes" "$root"

  root="$(new_fixture_repo duplicate-id)"
  write_valid_catalog "$root"
  yq -i '.features += [.features[0]]' "$root/.octon/framework/product/features/catalog.yml"
  assert_failure "duplicate feature id fails" "$root"

  root="$(new_fixture_repo missing-required)"
  write_valid_catalog "$root"
  yq -i 'del(.features[0].summary)' "$root/.octon/framework/product/features/catalog.yml"
  assert_failure "missing required feature field fails" "$root"

  root="$(new_fixture_repo empty-array-item)"
  write_valid_catalog "$root"
  yq -i '.features[0].primary_audiences = [""]' "$root/.octon/framework/product/features/catalog.yml"
  assert_failure "empty required array item fails" "$root"

  root="$(new_fixture_repo missing-path)"
  write_valid_catalog "$root"
  yq -i '.features[0].runtime_surfaces[0].path = ".octon/framework/missing.rs"' "$root/.octon/framework/product/features/catalog.yml"
  assert_failure "missing referenced path fails" "$root"

  root="$(new_fixture_repo generated-authority)"
  write_valid_catalog "$root"
  yq -i '.features[0].generated_effective_surfaces[0].authority_class = "authored-authority"' "$root/.octon/framework/product/features/catalog.yml"
  assert_failure "generated path marked as authority fails" "$root"

  root="$(new_fixture_repo input-authority)"
  write_valid_catalog "$root"
  yq -i '.features[0].extension_surfaces[0].authority_class = "authored-authority"' "$root/.octon/framework/product/features/catalog.yml"
  assert_failure "input path marked as authority fails" "$root"

  root="$(new_fixture_repo missing-validation)"
  write_valid_catalog "$root"
  yq -i '.features[0].validation_refs = []' "$root/.octon/framework/product/features/catalog.yml"
  assert_failure "missing validation refs fails" "$root"

  root="$(new_fixture_repo support-authority)"
  write_valid_catalog "$root"
  mkdir -p "$root/proposals/example/support"
  touch "$root/proposals/example/support/proposal-review.md"
  yq -i '.features[0].related_docs += [{"path": "proposals/example/support/proposal-review.md", "role": "proposal-local receipt", "authority_class": "authored-authority"}]' "$root/.octon/framework/product/features/catalog.yml"
  assert_failure "proposal-local support receipt marked as authority fails" "$root"

  if OCTON_ROOT_DIR="$REPO_ROOT" bash "$VALIDATOR" >/tmp/product-feature-catalog-real.out 2>&1; then
    pass "real product feature catalog passes"
  else
    cat /tmp/product-feature-catalog-real.out >&2
    fail "real product feature catalog passes"
  fi

  echo "Test summary: passes=$pass_count failures=$fail_count"
  if [[ "$fail_count" -gt 0 ]]; then
    exit 1
  fi
}

main "$@"
