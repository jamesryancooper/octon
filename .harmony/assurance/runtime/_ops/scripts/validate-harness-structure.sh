#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
ASSURANCE_DIR="$(cd -- "$SCRIPT_DIR/../../.." && pwd)"
HARMONY_DIR="$(cd -- "$ASSURANCE_DIR/.." && pwd)"
ROOT_DIR="$(cd -- "$HARMONY_DIR/.." && pwd)"
DOMAIN_PROFILES_FILE="$HARMONY_DIR/cognition/governance/domain-profiles.yml"

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
  else
    pass "found file: ${file#$ROOT_DIR/}"
  fi
}

require_dir() {
  local dir="$1"
  if [[ ! -d "$dir" ]]; then
    fail "missing directory: ${dir#$ROOT_DIR/}"
  else
    pass "found directory: ${dir#$ROOT_DIR/}"
  fi
}

extract_index_paths() {
  local index_file="$1"
  awk '
    /^[[:space:]]+path:[[:space:]]*/ {
      line=$0
      sub(/^[[:space:]]+path:[[:space:]]*/, "", line)
      sub(/[[:space:]]+#.*/, "", line)
      gsub(/^"/, "", line)
      gsub(/"$/, "", line)
      if (length(line) > 0) print line
    }
  ' "$index_file"
}

check_index_path_contract() {
  local index_file="$1"
  local base_dir="$2"
  local label="$3"
  local allow_empty="${4:-false}"
  local path
  local found=0

  require_file "$index_file"
  if [[ ! -f "$index_file" ]]; then
    return
  fi

  while IFS= read -r path; do
    [[ -z "$path" ]] && continue
    found=1
    if [[ "$path" == /* ]]; then
      fail "$label index path must be relative (not absolute): ${index_file#$ROOT_DIR/} -> $path"
      continue
    fi
    if [[ -e "$base_dir/$path" ]]; then
      pass "$label index path resolves: ${index_file#$ROOT_DIR/} -> $path"
    else
      fail "$label index path missing target: ${index_file#$ROOT_DIR/} -> $path"
    fi
  done < <(extract_index_paths "$index_file")

  if [[ $found -eq 0 ]]; then
    if [[ "$allow_empty" == "true" ]]; then
      pass "$label index has no path entries (allowed): ${index_file#$ROOT_DIR/}"
    else
      warn "$label index has no path entries: ${index_file#$ROOT_DIR/}"
    fi
  fi
}

extract_sidecar_scalar() {
  local index_file="$1"
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
  ' "$index_file"
}

extract_sidecar_headings() {
  local index_file="$1"
  awk '
    /^[[:space:]]+heading:[[:space:]]*/ {
      line=$0
      sub(/^[[:space:]]+heading:[[:space:]]*/, "", line)
      sub(/[[:space:]]+#.*/, "", line)
      gsub(/^"/, "", line)
      gsub(/"$/, "", line)
      if (length(line) > 0) print line
    }
  ' "$index_file"
}

markdown_has_heading() {
  local markdown_file="$1"
  local heading="$2"
  awk -v heading="$heading" '
    /^#+[[:space:]]+/ {
      line=$0
      sub(/^#+[[:space:]]+/, "", line)
      if (line == heading) {
        found=1
        exit
      }
    }
    END { exit(found ? 0 : 1) }
  ' "$markdown_file"
}

check_section_sidecar_contract() {
  local index_file="$1"
  local base_dir="$2"
  local label="$3"
  local source_rel source_file heading_count heading

  require_file "$index_file"
  if [[ ! -f "$index_file" ]]; then
    return
  fi

  source_rel="$(extract_sidecar_scalar "$index_file" "source")"
  if [[ -z "$source_rel" ]]; then
    fail "$label sidecar index missing source field: ${index_file#$ROOT_DIR/}"
    return
  fi

  if [[ "$source_rel" == /* ]]; then
    fail "$label sidecar source must be relative: ${index_file#$ROOT_DIR/} -> $source_rel"
    return
  fi

  source_file="$base_dir/$source_rel"
  if [[ ! -f "$source_file" ]]; then
    fail "$label sidecar source file missing: ${index_file#$ROOT_DIR/} -> $source_rel"
    return
  fi
  pass "$label sidecar source exists: ${index_file#$ROOT_DIR/} -> $source_rel"

  heading_count=0
  while IFS= read -r heading; do
    [[ -z "$heading" ]] && continue
    heading_count=$((heading_count + 1))
    if markdown_has_heading "$source_file" "$heading"; then
      pass "$label sidecar heading resolved: ${index_file#$ROOT_DIR/} -> $heading"
    else
      fail "$label sidecar heading missing in source: ${index_file#$ROOT_DIR/} -> $heading"
    fi
  done < <(extract_sidecar_headings "$index_file")

  if [[ $heading_count -eq 0 ]]; then
    warn "$label sidecar index has no heading entries: ${index_file#$ROOT_DIR/}"
  fi
}

extract_domain_profile() {
  local domain="$1"
  awk -v domain="$domain" '
    /^domains:[[:space:]]*$/ { in_domains=1; next }
    in_domains == 1 {
      if ($0 ~ /^[^[:space:]]/) {
        in_domains=0
      }
      if ($0 ~ "^[[:space:]]+" domain ":[[:space:]]*[a-z0-9-]+[[:space:]]*$") {
        line=$0
        sub("^[[:space:]]+" domain ":[[:space:]]*", "", line)
        gsub(/[[:space:]]+$/, "", line)
        print line
        found=1
        exit
      }
    }
    END {
      if (!found) exit 1
    }
  ' "$DOMAIN_PROFILES_FILE"
}

expected_domain_profile() {
  local domain="$1"
  case "$domain" in
    agency|capabilities|cognition|orchestration|scaffolding|assurance|engine)
      echo "bounded-surfaces"
      ;;
    continuity)
      echo "state-tracking"
      ;;
    ideation)
      echo "human-led"
      ;;
    output)
      echo "artifact-sink"
      ;;
    *)
      return 1
      ;;
  esac
}

check_readme_orientation() {
  local readme="$1"
  local rel="${readme#$ROOT_DIR/}"

  if ! grep -qE '^# ' "$readme"; then
    fail "README missing title heading: $rel"
    return
  fi

  if ! grep -qE '^## ' "$readme"; then
    fail "README missing orientation sections: $rel"
    return
  fi

  pass "README orientation present: $rel"
}

extract_structure_tree_entries() {
  local doc="$1"
  awk '
    BEGIN {
      in_structure = 0
      in_code = 0
      found_structure = 0
      found_code = 0
    }

    /^##[[:space:]]+Structure[[:space:]]*$/ {
      in_structure = 1
      found_structure = 1
      next
    }

    in_structure == 1 && in_code == 0 && /^```/ {
      in_code = 1
      found_code = 1
      next
    }

    in_code == 1 && /^```/ {
      exit
    }

    in_code == 0 {
      next
    }

    {
      line = $0
      sub(/[[:space:]]*(<-|←).*/, "", line)
      sub(/[[:space:]]+$/, "", line)
      if (line ~ /^[[:space:]]*$/) {
        next
      }

      if (line ~ /^\.harmony\/?$/) {
        stack[0] = ".harmony"
        print "dir\t.harmony\t" NR
        next
      }

      if (line ~ /(├──|└──)/) {
        split(line, parts, /├──|└──/)
        prefix = parts[1]
        node = parts[2]
        gsub(/^[[:space:]]+|[[:space:]]+$/, "", node)
        if (node == "") {
          print "error\tempty-node\t" NR
          next
        }

        tmp = prefix
        gsub(/│/, " ", tmp)
        depth = int(length(tmp) / 4)
        parent = stack[depth]
        if (parent == "") {
          print "error\tmissing-parent\t" NR
          next
        }

        is_dir = (node ~ /\/$/)
        clean = node
        sub(/\/$/, "", clean)
        full = parent "/" clean
        if (is_dir) {
          stack[depth + 1] = full
          print "dir\t" full "\t" NR
        } else {
          print "file\t" full "\t" NR
        }
      }
    }

    END {
      if (found_structure == 0) {
        print "error\tmissing-structure-section\t0"
      } else if (found_code == 0) {
        print "error\tmissing-structure-codeblock\t0"
      }
    }
  ' "$doc"
}

check_structure_tree_contract() {
  local doc="$1"
  local rel="${doc#$ROOT_DIR/}"
  local kind path lineno
  local entries=0

  require_file "$doc"
  if [[ ! -f "$doc" ]]; then
    return
  fi

  while IFS=$'\t' read -r kind path lineno; do
    [[ -z "$kind" ]] && continue
    entries=$((entries + 1))

    if [[ "$kind" == "error" ]]; then
      fail "structure tree parse error in ${rel} (line ${lineno}): ${path}"
      continue
    fi

    if [[ "$path" != .harmony* ]]; then
      fail "structure tree path must stay inside .harmony in ${rel} (line ${lineno}): ${path}"
      continue
    fi

    if [[ "$kind" == "dir" ]]; then
      if [[ -d "$ROOT_DIR/$path" ]]; then
        pass "structure tree directory exists (${rel}:${lineno}): ${path}/"
      else
        fail "structure tree directory missing (${rel}:${lineno}): ${path}/"
      fi
      continue
    fi

    if [[ "$kind" == "file" ]]; then
      if [[ -f "$ROOT_DIR/$path" ]]; then
        pass "structure tree file exists (${rel}:${lineno}): ${path}"
      else
        fail "structure tree file missing (${rel}:${lineno}): ${path}"
      fi
      continue
    fi

    fail "structure tree produced unknown entry kind in ${rel} (line ${lineno}): ${kind}"
  done < <(extract_structure_tree_entries "$doc")

  if [[ $entries -eq 0 ]]; then
    fail "structure tree has no entries: ${rel}"
  else
    pass "structure tree parsed (${entries} entries): ${rel}"
  fi
}

check_structure_docs_contract() {
  check_structure_tree_contract "$HARMONY_DIR/README.md"
  check_structure_tree_contract "$HARMONY_DIR/START.md"
}

check_subsystem_baseline() {
  local subsystem="$1"
  local root="$HARMONY_DIR/$subsystem"

  require_dir "$root"
  require_file "$root/README.md"
  check_readme_orientation "$root/README.md"
  require_file "$root/_meta/architecture/README.md"
}

check_engine_baseline() {
  local root="$HARMONY_DIR/engine"

  require_dir "$root"
  require_file "$root/README.md"
  check_readme_orientation "$root/README.md"

  require_dir "$root/runtime"
  require_file "$root/runtime/README.md"
  check_readme_orientation "$root/runtime/README.md"
  require_file "$root/runtime/run"
  require_file "$root/runtime/run.cmd"
  require_dir "$root/runtime/config"
  require_dir "$root/runtime/crates"
  require_dir "$root/runtime/spec"
  require_dir "$root/runtime/wit"

  require_dir "$root/_meta"
  require_file "$root/_meta/architecture/README.md"
  require_file "$root/_meta/evidence/README.md"
  require_dir "$root/_ops"
  require_dir "$root/_ops/bin"
  require_dir "$root/_ops/state"

  require_dir "$root/governance"
  require_file "$root/governance/README.md"
  check_readme_orientation "$root/governance/README.md"
  require_file "$root/governance/protocol-versioning.md"
  require_file "$root/governance/compatibility-policy.md"
  require_file "$root/governance/release-gates.md"

  require_dir "$root/practices"
  require_file "$root/practices/README.md"
  check_readme_orientation "$root/practices/README.md"
  require_file "$root/practices/release-runbook.md"
  require_file "$root/practices/incident-operations.md"
  require_file "$root/practices/local-dev-validation.md"
}

check_meta_namespace_layout() {
  local meta_dir rel child name top_files child_count

  while IFS= read -r meta_dir; do
    rel="${meta_dir#$ROOT_DIR/}"
    top_files="$(find "$meta_dir" -mindepth 1 -maxdepth 1 -type f)"
    if [[ -n "$top_files" ]]; then
      fail "_meta directory contains loose files (must use namespaced subdirs): $rel"
    else
      pass "_meta directory has no loose files: $rel"
    fi

    child_count=0
    while IFS= read -r child; do
      [[ -z "$child" ]] && continue
      child_count=$((child_count + 1))
      name="$(basename "$child")"
      case "$name" in
        architecture|docs|evidence)
          pass "_meta namespace allowed: ${child#$ROOT_DIR/}"
          ;;
        principles)
          if [[ "$rel" == ".harmony/cognition/_meta" ]]; then
            pass "_meta namespace allowed: ${child#$ROOT_DIR/}"
          else
            fail "_meta namespace not allowed (${name}); expected one of architecture|docs|evidence: ${child#$ROOT_DIR/}"
          fi
          ;;
        *)
          fail "_meta namespace not allowed (${name}); expected one of architecture|docs|evidence: ${child#$ROOT_DIR/}"
          ;;
      esac

      if [[ ! -f "$child/README.md" ]]; then
        fail "missing namespace index: ${child#$ROOT_DIR/}/README.md"
      else
        pass "namespace index present: ${child#$ROOT_DIR/}/README.md"
      fi
    done < <(find "$meta_dir" -mindepth 1 -maxdepth 1 -type d | sort)

    if [[ $child_count -eq 0 ]]; then
      warn "_meta directory has no namespaced subdirectories: $rel"
    fi
  done < <(find "$HARMONY_DIR" -type d -name "_meta" | sort)
}

check_domain_profile_registry() {
  require_file "$DOMAIN_PROFILES_FILE"

  local domains
  domains=(agency capabilities cognition orchestration scaffolding assurance engine continuity ideation output)

  local domain expected actual
  for domain in "${domains[@]}"; do
    expected="$(expected_domain_profile "$domain")"
    actual="$(extract_domain_profile "$domain" || true)"

    if [[ -z "$actual" ]]; then
      fail "domain profile missing for '$domain' in ${DOMAIN_PROFILES_FILE#$ROOT_DIR/}"
      continue
    fi

    if [[ "$actual" != "$expected" ]]; then
      fail "domain profile mismatch for '$domain': expected '$expected', found '$actual'"
      continue
    fi

    pass "domain profile mapping validated: $domain -> $actual"
  done
}

check_discovery_contracts() {
  require_file "$HARMONY_DIR/agency/manifest.yml"
  require_file "$HARMONY_DIR/agency/runtime/agents/registry.yml"
  require_file "$HARMONY_DIR/agency/runtime/assistants/registry.yml"
  require_file "$HARMONY_DIR/agency/runtime/teams/registry.yml"
  require_file "$HARMONY_DIR/agency/governance/CONSTITUTION.md"
  require_file "$HARMONY_DIR/agency/governance/DELEGATION.md"
  require_file "$HARMONY_DIR/agency/governance/MEMORY.md"

  require_file "$HARMONY_DIR/capabilities/runtime/commands/manifest.yml"
  require_file "$HARMONY_DIR/capabilities/runtime/skills/manifest.yml"
  require_file "$HARMONY_DIR/capabilities/runtime/services/manifest.yml"
  require_file "$HARMONY_DIR/capabilities/runtime/services/manifest.runtime.yml"
  require_file "$HARMONY_DIR/capabilities/runtime/services/registry.runtime.yml"
  require_file "$HARMONY_DIR/capabilities/runtime/tools/manifest.yml"
  require_file "$HARMONY_DIR/capabilities/governance/policy/deny-by-default.v2.yml"
  require_file "$HARMONY_DIR/capabilities/practices/README.md"

  require_file "$HARMONY_DIR/cognition/index.yml"
  require_file "$HARMONY_DIR/cognition/runtime/index.yml"
  require_file "$HARMONY_DIR/cognition/runtime/context/index.yml"
  require_file "$HARMONY_DIR/cognition/runtime/decisions/index.yml"
  require_file "$HARMONY_DIR/cognition/runtime/migrations/index.yml"
  require_file "$HARMONY_DIR/cognition/runtime/audits/index.yml"
  require_file "$HARMONY_DIR/cognition/runtime/analyses/index.yml"
  require_file "$HARMONY_DIR/cognition/runtime/knowledge/index.yml"
  require_file "$HARMONY_DIR/cognition/runtime/knowledge/graph/index.yml"
  require_file "$HARMONY_DIR/cognition/runtime/knowledge/sources/index.yml"
  require_file "$HARMONY_DIR/cognition/runtime/knowledge/queries/index.yml"
  require_file "$HARMONY_DIR/cognition/runtime/evidence/index.yml"
  require_file "$HARMONY_DIR/cognition/runtime/evaluations/index.yml"
  require_file "$HARMONY_DIR/cognition/runtime/evaluations/digests/index.yml"
  require_file "$HARMONY_DIR/cognition/runtime/evaluations/actions/index.yml"
  require_file "$HARMONY_DIR/cognition/runtime/projections/index.yml"
  require_file "$HARMONY_DIR/cognition/runtime/projections/definitions/index.yml"
  require_file "$HARMONY_DIR/cognition/runtime/projections/materialized/index.yml"
  require_file "$HARMONY_DIR/cognition/governance/index.yml"
  require_file "$HARMONY_DIR/cognition/governance/principles/index.yml"
  require_file "$HARMONY_DIR/cognition/governance/pillars/index.yml"
  require_file "$HARMONY_DIR/cognition/governance/purpose/index.yml"
  require_file "$HARMONY_DIR/cognition/governance/controls/README.md"
  require_file "$HARMONY_DIR/cognition/governance/controls/index.yml"
  require_file "$HARMONY_DIR/cognition/governance/controls/ra-acp-glossary.md"
  require_file "$HARMONY_DIR/cognition/governance/controls/ra-acp-promotion-inputs-matrix.md"
  require_file "$HARMONY_DIR/cognition/governance/controls/flag-metadata-contract.md"
  require_file "$HARMONY_DIR/cognition/governance/controls/promotable-slice-decomposition.md"
  require_file "$HARMONY_DIR/cognition/governance/exceptions/README.md"
  require_file "$HARMONY_DIR/cognition/governance/exceptions/index.yml"
  require_file "$HARMONY_DIR/cognition/governance/exceptions/waivers-and-exceptions.md"
  require_file "$HARMONY_DIR/cognition/practices/index.yml"
  require_file "$HARMONY_DIR/cognition/practices/operations/README.md"
  require_file "$HARMONY_DIR/cognition/practices/operations/index.yml"
  require_file "$HARMONY_DIR/cognition/practices/methodology/index.yml"
  require_file "$HARMONY_DIR/cognition/practices/methodology/migrations/index.yml"
  require_file "$HARMONY_DIR/cognition/practices/methodology/audits/index.yml"
  require_file "$HARMONY_DIR/cognition/practices/methodology/templates/index.yml"
  require_file "$HARMONY_DIR/cognition/practices/methodology/README.index.yml"
  require_file "$HARMONY_DIR/cognition/practices/methodology/implementation-guide.index.yml"
  require_file "$HARMONY_DIR/cognition/_meta/architecture/index.yml"
  require_file "$HARMONY_DIR/cognition/_meta/architecture/artifact-surface/index.yml"
  require_file "$HARMONY_DIR/cognition/_meta/architecture/README.index.yml"
  require_file "$HARMONY_DIR/cognition/_meta/architecture/resources.index.yml"
  require_file "$HARMONY_DIR/cognition/_meta/docs/index.yml"
  require_file "$HARMONY_DIR/cognition/_meta/principles/index.yml"
  require_file "$HARMONY_DIR/cognition/_meta/docs/intent-surface-atlas.md"
  require_file "$HARMONY_DIR/cognition/governance/principles/principles.md"
  require_file "$HARMONY_DIR/cognition/practices/methodology/README.md"
  require_file "$HARMONY_DIR/cognition/_ops/principles/scripts/lint-principles-governance.sh"
  require_file "$HARMONY_DIR/cognition/_ops/knowledge/scripts/validate-knowledge-runtime.sh"
  require_file "$HARMONY_DIR/cognition/_ops/evaluations/scripts/validate-evaluations-runtime.sh"
  require_file "$HARMONY_DIR/cognition/_ops/projections/scripts/validate-projections-runtime.sh"
  require_file "$HARMONY_DIR/cognition/_ops/runtime/scripts/sync-runtime-artifacts.sh"
  require_file "$HARMONY_DIR/cognition/_ops/runtime/scripts/validate-generated-runtime-artifacts.sh"

  require_file "$HARMONY_DIR/orchestration/runtime/workflows/manifest.yml"
  require_file "$HARMONY_DIR/orchestration/runtime/workflows/registry.yml"
  require_file "$HARMONY_DIR/orchestration/runtime/missions/registry.yml"
  require_file "$HARMONY_DIR/orchestration/runtime/automations/manifest.yml"
  require_file "$HARMONY_DIR/orchestration/runtime/automations/registry.yml"
  require_file "$HARMONY_DIR/orchestration/runtime/watchers/manifest.yml"
  require_file "$HARMONY_DIR/orchestration/runtime/watchers/registry.yml"
  require_file "$HARMONY_DIR/orchestration/runtime/queue/registry.yml"
  require_file "$HARMONY_DIR/orchestration/runtime/queue/schema.yml"
  require_file "$HARMONY_DIR/orchestration/runtime/runs/index.yml"
  require_file "$HARMONY_DIR/orchestration/runtime/incidents/index.yml"
  require_file "$HARMONY_DIR/orchestration/governance/incidents.md"
  require_file "$HARMONY_DIR/orchestration/governance/production-incident-runbook.md"
  require_file "$HARMONY_DIR/orchestration/governance/approver-authority-registry.json"
  require_file "$HARMONY_DIR/orchestration/governance/automation-policy.md"
  require_file "$HARMONY_DIR/orchestration/governance/queue-safety-policy.md"
  require_file "$HARMONY_DIR/orchestration/governance/watcher-signal-policy.md"
  require_file "$HARMONY_DIR/orchestration/practices/automation-authoring-standards.md"
  require_file "$HARMONY_DIR/orchestration/practices/automation-operations.md"
  require_file "$HARMONY_DIR/orchestration/practices/watcher-authoring-standards.md"
  require_file "$HARMONY_DIR/orchestration/practices/watcher-operations.md"
  require_file "$HARMONY_DIR/orchestration/practices/queue-operations-standards.md"
  require_file "$HARMONY_DIR/orchestration/practices/run-linkage-standards.md"
  require_file "$HARMONY_DIR/orchestration/practices/incident-lifecycle-standards.md"

  require_file "$HARMONY_DIR/continuity/decisions/README.md"
  require_file "$HARMONY_DIR/continuity/decisions/retention.json"
  require_file "$HARMONY_DIR/continuity/decisions/approvals/README.md"

  require_file "$HARMONY_DIR/assurance/governance/CHARTER.md"
  require_file "$HARMONY_DIR/assurance/governance/weights/weights.yml"
  require_file "$HARMONY_DIR/assurance/governance/scores/scores.yml"
  require_file "$HARMONY_DIR/assurance/runtime/_ops/scripts/compute-assurance-score.sh"
  require_file "$HARMONY_DIR/assurance/runtime/_ops/scripts/assurance-gate.sh"
  require_file "$HARMONY_DIR/assurance/runtime/_ops/scripts/validate-audit-convergence-contract.sh"
  require_file "$HARMONY_DIR/assurance/runtime/_ops/scripts/validate-contract-governance.sh"
  require_file "$HARMONY_DIR/assurance/runtime/_ops/scripts/validate-design-package-standard.sh"
  require_file "$HARMONY_DIR/assurance/runtime/_ops/scripts/validate-orchestration-design-package.sh"
  require_file "$HARMONY_DIR/assurance/runtime/_ops/scripts/validate-tier-downgrade-policy.sh"
  require_file "$HARMONY_DIR/assurance/practices/complete.md"
  require_file "$HARMONY_DIR/assurance/practices/session-exit.md"
  require_file "$HARMONY_DIR/output/reports/audits/README.md"

  require_file "$HARMONY_DIR/AGENTS.md"
  require_file "$HARMONY_DIR/OBJECTIVE.md"
  require_file "$HARMONY_DIR/cognition/runtime/context/intent.contract.yml"
  require_file "$HARMONY_DIR/engine/runtime/spec/objective-brief-v1.schema.json"
  require_file "$HARMONY_DIR/scaffolding/runtime/bootstrap/README.md"
  require_file "$HARMONY_DIR/scaffolding/runtime/bootstrap/manifest.yml"
  require_file "$HARMONY_DIR/scaffolding/runtime/bootstrap/AGENTS.md"
  require_file "$HARMONY_DIR/scaffolding/runtime/bootstrap/init-project.sh"
  require_file "$HARMONY_DIR/scaffolding/runtime/bootstrap/objectives/registry.txt"
  require_file "$HARMONY_DIR/scaffolding/runtime/templates/manifest.schema.json"
  require_file "$HARMONY_DIR/scaffolding/runtime/templates/design-package.schema.json"
  require_file "$HARMONY_DIR/scaffolding/runtime/templates/README.md"
  require_file "$HARMONY_DIR/scaffolding/runtime/_ops/scripts/sync-bootstrap-projection.sh"
  require_file "$HARMONY_DIR/scaffolding/runtime/templates/audits/template.bounded-audit.md"
  require_file "$HARMONY_DIR/scaffolding/runtime/_ops/scripts/init-project.sh"
  require_file "$HARMONY_DIR/assurance/runtime/_ops/scripts/validate-bootstrap-ingress.sh"
  require_file "$HARMONY_DIR/assurance/runtime/_ops/scripts/validate-bootstrap-projections.sh"
  require_file "$HARMONY_DIR/scaffolding/governance/patterns/README.md"
  require_file "$HARMONY_DIR/scaffolding/governance/patterns/design-package-standard.md"
  require_file "$HARMONY_DIR/scaffolding/practices/README.md"
}

check_expected_internals() {
  require_dir "$HARMONY_DIR/agency/runtime/agents"
  require_dir "$HARMONY_DIR/agency/runtime/assistants"
  require_dir "$HARMONY_DIR/agency/runtime/teams"
  require_dir "$HARMONY_DIR/agency/governance"

  require_dir "$HARMONY_DIR/capabilities/runtime"
  require_dir "$HARMONY_DIR/capabilities/runtime/skills"
  require_dir "$HARMONY_DIR/capabilities/runtime/commands"
  require_dir "$HARMONY_DIR/capabilities/runtime/tools"
  require_dir "$HARMONY_DIR/capabilities/runtime/services"
  require_dir "$HARMONY_DIR/capabilities/governance"
  require_dir "$HARMONY_DIR/capabilities/practices"

  require_dir "$HARMONY_DIR/cognition/runtime"
  require_dir "$HARMONY_DIR/cognition/runtime/context"
  require_dir "$HARMONY_DIR/cognition/runtime/migrations"
  require_dir "$HARMONY_DIR/cognition/runtime/audits"
  require_dir "$HARMONY_DIR/cognition/runtime/decisions"
  require_dir "$HARMONY_DIR/cognition/runtime/analyses"
  require_dir "$HARMONY_DIR/cognition/runtime/knowledge"
  require_dir "$HARMONY_DIR/cognition/runtime/knowledge/graph"
  require_dir "$HARMONY_DIR/cognition/runtime/knowledge/sources"
  require_dir "$HARMONY_DIR/cognition/runtime/knowledge/queries"
  require_dir "$HARMONY_DIR/cognition/runtime/evidence"
  require_dir "$HARMONY_DIR/cognition/runtime/evaluations"
  require_dir "$HARMONY_DIR/cognition/runtime/evaluations/digests"
  require_dir "$HARMONY_DIR/cognition/runtime/evaluations/actions"
  require_dir "$HARMONY_DIR/cognition/runtime/projections"
  require_dir "$HARMONY_DIR/cognition/runtime/projections/definitions"
  require_dir "$HARMONY_DIR/cognition/runtime/projections/materialized"
  require_dir "$HARMONY_DIR/cognition/governance"
  require_dir "$HARMONY_DIR/cognition/governance/controls"
  require_dir "$HARMONY_DIR/cognition/governance/exceptions"
  require_dir "$HARMONY_DIR/cognition/governance/principles"
  require_dir "$HARMONY_DIR/cognition/governance/pillars"
  require_dir "$HARMONY_DIR/cognition/governance/purpose"
  require_dir "$HARMONY_DIR/cognition/practices"
  require_dir "$HARMONY_DIR/cognition/practices/operations"
  require_dir "$HARMONY_DIR/cognition/practices/methodology"
  require_dir "$HARMONY_DIR/cognition/practices/methodology/migrations"
  require_dir "$HARMONY_DIR/cognition/practices/methodology/audits"
  require_dir "$HARMONY_DIR/cognition/practices/methodology/templates"
  require_dir "$HARMONY_DIR/cognition/_meta/architecture"
  require_dir "$HARMONY_DIR/cognition/_meta/architecture/artifact-surface"
  require_dir "$HARMONY_DIR/cognition/_meta/docs"
  require_dir "$HARMONY_DIR/cognition/_meta/principles"
  require_dir "$HARMONY_DIR/cognition/_ops"
  require_dir "$HARMONY_DIR/cognition/_ops/principles"
  require_dir "$HARMONY_DIR/cognition/_ops/principles/scripts"
  require_dir "$HARMONY_DIR/cognition/_ops/knowledge"
  require_dir "$HARMONY_DIR/cognition/_ops/knowledge/scripts"
  require_dir "$HARMONY_DIR/cognition/_ops/evaluations"
  require_dir "$HARMONY_DIR/cognition/_ops/evaluations/scripts"
  require_dir "$HARMONY_DIR/cognition/_ops/projections"
  require_dir "$HARMONY_DIR/cognition/_ops/projections/scripts"
  require_dir "$HARMONY_DIR/cognition/_ops/runtime"
  require_dir "$HARMONY_DIR/cognition/_ops/runtime/scripts"

  require_dir "$HARMONY_DIR/orchestration/runtime/workflows"
  require_dir "$HARMONY_DIR/orchestration/runtime/missions"
  require_dir "$HARMONY_DIR/orchestration/runtime/automations"
  require_dir "$HARMONY_DIR/orchestration/runtime/watchers"
  require_dir "$HARMONY_DIR/orchestration/runtime/queue"
  require_dir "$HARMONY_DIR/orchestration/runtime/runs"
  require_dir "$HARMONY_DIR/orchestration/runtime/incidents"
  require_dir "$HARMONY_DIR/orchestration/runtime/_coordination"
  require_dir "$HARMONY_DIR/orchestration/runtime"
  require_dir "$HARMONY_DIR/orchestration/governance"
  require_dir "$HARMONY_DIR/orchestration/practices"

  require_dir "$HARMONY_DIR/assurance/runtime"
  require_dir "$HARMONY_DIR/assurance/runtime/_ops"
  require_dir "$HARMONY_DIR/assurance/runtime/trust"
  require_dir "$HARMONY_DIR/assurance/governance"
  require_dir "$HARMONY_DIR/assurance/practices"
  require_dir "$HARMONY_DIR/assurance/practices/standards"

  require_dir "$HARMONY_DIR/scaffolding/runtime"
  require_dir "$HARMONY_DIR/scaffolding/runtime/_ops"
  require_dir "$HARMONY_DIR/scaffolding/runtime/_ops/scripts"
  require_dir "$HARMONY_DIR/scaffolding/runtime/bootstrap"
  require_dir "$HARMONY_DIR/scaffolding/runtime/templates"
  require_dir "$HARMONY_DIR/scaffolding/runtime/templates/audits"
  require_dir "$HARMONY_DIR/scaffolding/runtime/templates/harmony/scaffolding/runtime/bootstrap"
  require_dir "$HARMONY_DIR/scaffolding/governance"
  require_dir "$HARMONY_DIR/scaffolding/governance/patterns"
  require_dir "$HARMONY_DIR/scaffolding/practices"
  require_dir "$HARMONY_DIR/scaffolding/practices/prompts"
  require_dir "$HARMONY_DIR/scaffolding/practices/examples"

  require_file "$HARMONY_DIR/assurance/practices/complete.md"
  require_file "$HARMONY_DIR/assurance/practices/session-exit.md"

  require_file "$HARMONY_DIR/continuity/log.md"
  require_file "$HARMONY_DIR/continuity/tasks.json"
  require_file "$HARMONY_DIR/continuity/entities.json"
  require_file "$HARMONY_DIR/continuity/next.md"
  require_dir "$HARMONY_DIR/continuity/runs"
  require_file "$HARMONY_DIR/continuity/runs/README.md"
  require_file "$HARMONY_DIR/continuity/runs/retention.json"

  require_dir "$HARMONY_DIR/ideation/scratchpad"
  require_dir "$HARMONY_DIR/ideation/projects"

  require_dir "$HARMONY_DIR/output/reports"
  require_dir "$HARMONY_DIR/output/reports/decisions"
  require_dir "$HARMONY_DIR/output/reports/migrations"
  require_dir "$HARMONY_DIR/output/reports/audits"
  require_dir "$HARMONY_DIR/output/drafts"
  require_dir "$HARMONY_DIR/output/artifacts"
}

check_cognition_decision_record_surface() {
  local runtime_dir="$HARMONY_DIR/cognition/runtime/decisions"
  local index_file="$runtime_dir/index.yml"
  local adr_count
  local index_entry_count
  local duplicate_filename_numbers
  local duplicate_index_ids
  local duplicate_index_numbers
  local file
  local id path id_num path_num path_base
  local matched=0

  require_dir "$runtime_dir"
  require_file "$runtime_dir/README.md"
  require_file "$index_file"

  adr_count="$(find "$runtime_dir" -mindepth 1 -maxdepth 1 -type f -name '[0-9][0-9][0-9]-*.md' | wc -l | tr -d ' ')"
  if [[ "$adr_count" == "0" ]]; then
    warn "no ADR files found under cognition/runtime/decisions/"
    return
  else
    pass "found ${adr_count} ADR files under cognition/runtime/decisions/"
  fi

  duplicate_filename_numbers="$(
    find "$runtime_dir" -mindepth 1 -maxdepth 1 -type f -name '[0-9][0-9][0-9]-*.md' \
      -exec basename {} \; |
      sed -E 's/^([0-9]{3})-.*/\1/' |
      sort | uniq -d || true
  )"
  if [[ -n "$duplicate_filename_numbers" ]]; then
    fail "duplicate ADR numeric prefixes on disk: $(echo "$duplicate_filename_numbers" | paste -sd ', ' -)"
  else
    pass "ADR numeric prefixes are unique on disk"
  fi

  duplicate_index_ids="$(
    awk '
      /^[[:space:]]+- id:[[:space:]]*/ {
        line=$0
        sub(/^[[:space:]]+- id:[[:space:]]*/, "", line)
        gsub(/"/, "", line)
        print line
      }
    ' "$index_file" | sort | uniq -d || true
  )"
  if [[ -n "$duplicate_index_ids" ]]; then
    fail "duplicate decision ids in decisions index: $(echo "$duplicate_index_ids" | paste -sd ', ' -)"
  else
    pass "decision ids are unique in decisions index"
  fi

  duplicate_index_numbers="$(
    awk '
      /^[[:space:]]+- id:[[:space:]]*/ {
        line=$0
        sub(/^[[:space:]]+- id:[[:space:]]*/, "", line)
        gsub(/"/, "", line)
        sub(/-.*/, "", line)
        print line
      }
    ' "$index_file" | sort | uniq -d || true
  )"
  if [[ -n "$duplicate_index_numbers" ]]; then
    fail "duplicate decision numeric prefixes in decisions index: $(echo "$duplicate_index_numbers" | paste -sd ', ' -)"
  else
    pass "decision numeric prefixes are unique in decisions index"
  fi

  while IFS=$'\t' read -r id path; do
    [[ -z "$id" || -z "$path" ]] && continue
    matched=1
    id_num="${id%%-*}"
    path_base="$(basename "$path")"
    path_num="${path_base%%-*}"

    if [[ ! -f "$runtime_dir/$path" ]]; then
      fail "decisions index path missing on disk: ${index_file#$ROOT_DIR/} -> $path"
      continue
    fi
    pass "decisions index path exists: ${index_file#$ROOT_DIR/} -> $path"

    if [[ "$id_num" != "$path_num" ]]; then
      fail "decisions index id/path numeric mismatch: id=$id path=$path"
    else
      pass "decisions index id/path numeric prefix aligned: $id"
    fi
  done < <(
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
  )

  if [[ $matched -eq 0 ]]; then
    fail "decisions index has no id/path records: ${index_file#$ROOT_DIR/}"
  fi

  for file in "$runtime_dir"/[0-9][0-9][0-9]-*.md; do
    [[ -e "$file" ]] || continue
    if grep -qE "^[[:space:]]+path:[[:space:]]*\"?$(basename "$file")\"?$" "$index_file"; then
      pass "ADR file covered by decisions index: ${file#$ROOT_DIR/}"
    else
      fail "ADR file missing from decisions index: ${file#$ROOT_DIR/}"
    fi
  done

  index_entry_count="$(
    awk '/^[[:space:]]+- id:[[:space:]]*/ {count++} END {print count+0}' "$index_file"
  )"
  if [[ "$index_entry_count" != "$adr_count" ]]; then
    fail "decisions index/file count mismatch: index=${index_entry_count} files=${adr_count}"
  else
    pass "decisions index/file count aligned (${adr_count})"
  fi
}

check_cognition_migration_record_surface() {
  local policy_dir="$HARMONY_DIR/cognition/practices/methodology/migrations"
  local runtime_dir="$HARMONY_DIR/cognition/runtime/migrations"

  require_dir "$runtime_dir"
  require_file "$runtime_dir/README.md"
  require_file "$runtime_dir/index.yml"

  local legacy_records
  legacy_records="$(find "$policy_dir" -mindepth 1 -maxdepth 1 -type d -name '20*-*' | sort || true)"
  if [[ -n "$legacy_records" ]]; then
    fail "dated migration records must not exist under practices surface: ${policy_dir#$ROOT_DIR/}"
  else
    pass "dated migration records isolated to runtime surface"
  fi
}

check_cognition_audit_record_surface() {
  local policy_dir="$HARMONY_DIR/cognition/practices/methodology/audits"
  local runtime_dir="$HARMONY_DIR/cognition/runtime/audits"

  require_dir "$policy_dir"
  require_file "$policy_dir/README.md"
  require_file "$policy_dir/index.yml"
  require_file "$policy_dir/doctrine.md"
  require_file "$policy_dir/invariants.md"
  require_file "$policy_dir/exceptions.md"
  require_file "$policy_dir/ci-gates.md"
  require_file "$policy_dir/findings-contract.md"

  require_dir "$runtime_dir"
  require_file "$runtime_dir/README.md"
  require_file "$runtime_dir/index.yml"

  local legacy_records
  legacy_records="$(find "$policy_dir" -mindepth 1 -maxdepth 1 -type d -name '20*-*' | sort || true)"
  if [[ -n "$legacy_records" ]]; then
    fail "dated audit records must not exist under practices surface: ${policy_dir#$ROOT_DIR/}"
  else
    pass "dated audit records isolated to runtime surface"
  fi
}

check_output_migration_evidence_surface() {
  local reports_root="$HARMONY_DIR/output/reports"
  local migration_reports_dir="$reports_root/migrations"
  local legacy_migration_evidence
  local flat_migration_evidence
  local bundle_dirs
  local required_files
  local bundle required rel bundle_name

  required_files=(bundle.yml evidence.md commands.md validation.md inventory.md)

  require_dir "$migration_reports_dir"
  require_file "$migration_reports_dir/README.md"

  mapfile -t legacy_migration_evidence < <(
    find "$reports_root" -mindepth 1 -maxdepth 1 -type f | sort |
      grep -E '/[0-9]{4}-[0-9]{2}-[0-9]{2}-.*(migration|clean-break).*evidence\.md$' || true
  )

  if [[ ${#legacy_migration_evidence[@]} -gt 0 ]]; then
    fail "migration evidence reports must live under output/reports/migrations/"
  else
    pass "migration evidence reports isolated to output/reports/migrations/"
  fi

  mapfile -t flat_migration_evidence < <(
    find "$migration_reports_dir" -mindepth 1 -maxdepth 1 -type f | sort |
      grep -E '/[0-9]{4}-[0-9]{2}-[0-9]{2}-.*evidence\.md$' || true
  )
  if [[ ${#flat_migration_evidence[@]} -gt 0 ]]; then
    fail "flat migration evidence files are forbidden; use bundle directories under output/reports/migrations/"
  else
    pass "no flat migration evidence files under output/reports/migrations/"
  fi

  mapfile -t bundle_dirs < <(
    find "$migration_reports_dir" -mindepth 1 -maxdepth 1 -type d -name '20*-*' | sort
  )
  if [[ ${#bundle_dirs[@]} -eq 0 ]]; then
    warn "no migration evidence bundle directories found under output/reports/migrations/"
    return
  fi
  pass "found ${#bundle_dirs[@]} migration evidence bundle directories"

  for bundle in "${bundle_dirs[@]}"; do
    rel="${bundle#$ROOT_DIR/}"
    bundle_name="$(basename "$bundle")"

    for required in "${required_files[@]}"; do
      if [[ ! -f "$bundle/$required" ]]; then
        fail "migration evidence bundle missing required file (${required}): $rel"
      else
        pass "migration evidence bundle file present (${required}): $rel"
      fi
    done

    if [[ -f "$bundle/bundle.yml" ]]; then
      if grep -Eq '^kind:[[:space:]]*"?migration-evidence-bundle"?$' "$bundle/bundle.yml"; then
        pass "bundle metadata kind valid: $rel/bundle.yml"
      else
        fail "bundle metadata missing/invalid kind (migration-evidence-bundle): $rel/bundle.yml"
      fi

      if grep -Eq "^id:[[:space:]]*\"?${bundle_name}\"?$" "$bundle/bundle.yml"; then
        pass "bundle metadata id matches directory: $rel/bundle.yml"
      else
        fail "bundle metadata id must match directory name (${bundle_name}): $rel/bundle.yml"
      fi

      if grep -Eq '^evidence:[[:space:]]*"?evidence\.md"?$' "$bundle/bundle.yml"; then
        pass "bundle metadata evidence pointer valid: $rel/bundle.yml"
      else
        fail "bundle metadata evidence pointer must be evidence.md: $rel/bundle.yml"
      fi

      if grep -Eq '^commands:[[:space:]]*"?commands\.md"?$' "$bundle/bundle.yml"; then
        pass "bundle metadata commands pointer valid: $rel/bundle.yml"
      else
        fail "bundle metadata commands pointer must be commands.md: $rel/bundle.yml"
      fi

      if grep -Eq '^validation:[[:space:]]*"?validation\.md"?$' "$bundle/bundle.yml"; then
        pass "bundle metadata validation pointer valid: $rel/bundle.yml"
      else
        fail "bundle metadata validation pointer must be validation.md: $rel/bundle.yml"
      fi

      if grep -Eq '^inventory:[[:space:]]*"?inventory\.md"?$' "$bundle/bundle.yml"; then
        pass "bundle metadata inventory pointer valid: $rel/bundle.yml"
      else
        fail "bundle metadata inventory pointer must be inventory.md: $rel/bundle.yml"
      fi
    fi
  done
}

check_output_audit_evidence_surface() {
  local audits_reports_dir="$HARMONY_DIR/output/reports/audits"
  local flat_audit_evidence
  local bundle_dirs
  local required_files
  local bundle required rel bundle_name

  required_files=(bundle.yml findings.yml coverage.yml convergence.yml evidence.md commands.md validation.md inventory.md)

  require_dir "$audits_reports_dir"
  require_file "$audits_reports_dir/README.md"

  mapfile -t flat_audit_evidence < <(
    find "$audits_reports_dir" -mindepth 1 -maxdepth 1 -type f | sort |
      grep -E '/[0-9]{4}-[0-9]{2}-[0-9]{2}-.*\.md$' || true
  )
  if [[ ${#flat_audit_evidence[@]} -gt 0 ]]; then
    fail "flat bounded-audit evidence files are forbidden; use bundle directories under output/reports/audits/"
  else
    pass "no flat bounded-audit evidence files under output/reports/audits/"
  fi

  mapfile -t bundle_dirs < <(
    find "$audits_reports_dir" -mindepth 1 -maxdepth 1 -type d -name '20*-*' | sort
  )
  if [[ ${#bundle_dirs[@]} -eq 0 ]]; then
    pass "no bounded-audit evidence bundles present (optional surface)"
    return
  fi
  pass "found ${#bundle_dirs[@]} bounded-audit evidence bundle directories"

  for bundle in "${bundle_dirs[@]}"; do
    rel="${bundle#$ROOT_DIR/}"
    bundle_name="$(basename "$bundle")"

    for required in "${required_files[@]}"; do
      if [[ ! -f "$bundle/$required" ]]; then
        fail "bounded-audit evidence bundle missing required file (${required}): $rel"
      else
        pass "bounded-audit evidence bundle file present (${required}): $rel"
      fi
    done

    if [[ -f "$bundle/bundle.yml" ]]; then
      if grep -Eq '^kind:[[:space:]]*"?audit-evidence-bundle"?$' "$bundle/bundle.yml"; then
        pass "bounded-audit bundle metadata kind valid: $rel/bundle.yml"
      else
        fail "bounded-audit bundle metadata missing/invalid kind (audit-evidence-bundle): $rel/bundle.yml"
      fi

      if grep -Eq "^id:[[:space:]]*\"?${bundle_name}\"?$" "$bundle/bundle.yml"; then
        pass "bounded-audit bundle metadata id matches directory: $rel/bundle.yml"
      else
        fail "bounded-audit bundle metadata id must match directory name (${bundle_name}): $rel/bundle.yml"
      fi

      if grep -Eq '^findings:[[:space:]]*"?findings\.yml"?$' "$bundle/bundle.yml"; then
        pass "bounded-audit bundle metadata findings pointer valid: $rel/bundle.yml"
      else
        fail "bounded-audit bundle metadata findings pointer must be findings.yml: $rel/bundle.yml"
      fi

      if grep -Eq '^coverage:[[:space:]]*"?coverage\.yml"?$' "$bundle/bundle.yml"; then
        pass "bounded-audit bundle metadata coverage pointer valid: $rel/bundle.yml"
      else
        fail "bounded-audit bundle metadata coverage pointer must be coverage.yml: $rel/bundle.yml"
      fi

      if grep -Eq '^convergence:[[:space:]]*"?convergence\.yml"?$' "$bundle/bundle.yml"; then
        pass "bounded-audit bundle metadata convergence pointer valid: $rel/bundle.yml"
      else
        fail "bounded-audit bundle metadata convergence pointer must be convergence.yml: $rel/bundle.yml"
      fi

      if grep -Eq '^evidence:[[:space:]]*"?evidence\.md"?$' "$bundle/bundle.yml"; then
        pass "bounded-audit bundle metadata evidence pointer valid: $rel/bundle.yml"
      else
        fail "bounded-audit bundle metadata evidence pointer must be evidence.md: $rel/bundle.yml"
      fi

      if grep -Eq '^commands:[[:space:]]*"?commands\.md"?$' "$bundle/bundle.yml"; then
        pass "bounded-audit bundle metadata commands pointer valid: $rel/bundle.yml"
      else
        fail "bounded-audit bundle metadata commands pointer must be commands.md: $rel/bundle.yml"
      fi

      if grep -Eq '^validation:[[:space:]]*"?validation\.md"?$' "$bundle/bundle.yml"; then
        pass "bounded-audit bundle metadata validation pointer valid: $rel/bundle.yml"
      else
        fail "bounded-audit bundle metadata validation pointer must be validation.md: $rel/bundle.yml"
      fi

      if grep -Eq '^inventory:[[:space:]]*"?inventory\.md"?$' "$bundle/bundle.yml"; then
        pass "bounded-audit bundle metadata inventory pointer valid: $rel/bundle.yml"
      else
        fail "bounded-audit bundle metadata inventory pointer must be inventory.md: $rel/bundle.yml"
      fi
    fi
  done
}

check_output_decision_evidence_surface() {
  local decisions_reports_dir="$HARMONY_DIR/output/reports/decisions"
  local flat_decision_evidence
  local bundle_dirs
  local required_files
  local bundle required rel bundle_name

  required_files=(bundle.yml evidence.md commands.md validation.md inventory.md)

  require_dir "$decisions_reports_dir"
  require_file "$decisions_reports_dir/README.md"

  mapfile -t flat_decision_evidence < <(
    find "$decisions_reports_dir" -mindepth 1 -maxdepth 1 -type f | sort |
      grep -E '/[0-9]{3}-.*\.md$' || true
  )
  if [[ ${#flat_decision_evidence[@]} -gt 0 ]]; then
    fail "flat decision evidence files are forbidden; use bundle directories under output/reports/decisions/"
  else
    pass "no flat decision evidence files under output/reports/decisions/"
  fi

  mapfile -t bundle_dirs < <(
    find "$decisions_reports_dir" -mindepth 1 -maxdepth 1 -type d -name '[0-9][0-9][0-9]-*' | sort
  )
  if [[ ${#bundle_dirs[@]} -eq 0 ]]; then
    pass "no decision evidence bundles present (optional surface)"
    return
  fi
  pass "found ${#bundle_dirs[@]} decision evidence bundle directories"

  for bundle in "${bundle_dirs[@]}"; do
    rel="${bundle#$ROOT_DIR/}"
    bundle_name="$(basename "$bundle")"

    for required in "${required_files[@]}"; do
      if [[ ! -f "$bundle/$required" ]]; then
        fail "decision evidence bundle missing required file (${required}): $rel"
      else
        pass "decision evidence bundle file present (${required}): $rel"
      fi
    done

    if [[ -f "$bundle/bundle.yml" ]]; then
      if grep -Eq '^kind:[[:space:]]*"?decision-evidence-bundle"?$' "$bundle/bundle.yml"; then
        pass "decision bundle metadata kind valid: $rel/bundle.yml"
      else
        fail "decision bundle metadata missing/invalid kind (decision-evidence-bundle): $rel/bundle.yml"
      fi

      if grep -Eq "^id:[[:space:]]*\"?${bundle_name}\"?$" "$bundle/bundle.yml"; then
        pass "decision bundle metadata id matches directory: $rel/bundle.yml"
      else
        fail "decision bundle metadata id must match directory name (${bundle_name}): $rel/bundle.yml"
      fi

      if grep -Eq '^evidence:[[:space:]]*"?evidence\.md"?$' "$bundle/bundle.yml"; then
        pass "decision bundle metadata evidence pointer valid: $rel/bundle.yml"
      else
        fail "decision bundle metadata evidence pointer must be evidence.md: $rel/bundle.yml"
      fi

      if grep -Eq '^commands:[[:space:]]*"?commands\.md"?$' "$bundle/bundle.yml"; then
        pass "decision bundle metadata commands pointer valid: $rel/bundle.yml"
      else
        fail "decision bundle metadata commands pointer must be commands.md: $rel/bundle.yml"
      fi

      if grep -Eq '^validation:[[:space:]]*"?validation\.md"?$' "$bundle/bundle.yml"; then
        pass "decision bundle metadata validation pointer valid: $rel/bundle.yml"
      else
        fail "decision bundle metadata validation pointer must be validation.md: $rel/bundle.yml"
      fi

      if grep -Eq '^inventory:[[:space:]]*"?inventory\.md"?$' "$bundle/bundle.yml"; then
        pass "decision bundle metadata inventory pointer valid: $rel/bundle.yml"
      else
        fail "decision bundle metadata inventory pointer must be inventory.md: $rel/bundle.yml"
      fi
    fi
  done
}

check_cognition_discovery_indexes() {
  check_index_path_contract \
    "$HARMONY_DIR/cognition/index.yml" \
    "$HARMONY_DIR/cognition" \
    "cognition domain"

  check_index_path_contract \
    "$HARMONY_DIR/cognition/runtime/index.yml" \
    "$HARMONY_DIR/cognition/runtime" \
    "cognition runtime"

  check_index_path_contract \
    "$HARMONY_DIR/cognition/runtime/context/index.yml" \
    "$HARMONY_DIR/cognition/runtime/context" \
    "cognition runtime context"

  check_index_path_contract \
    "$HARMONY_DIR/cognition/runtime/audits/index.yml" \
    "$HARMONY_DIR/cognition/runtime/audits" \
    "cognition runtime audits" \
    true

  check_index_path_contract \
    "$HARMONY_DIR/cognition/runtime/analyses/index.yml" \
    "$HARMONY_DIR/cognition/runtime/analyses" \
    "cognition runtime analyses"

  check_index_path_contract \
    "$HARMONY_DIR/cognition/runtime/knowledge/index.yml" \
    "$HARMONY_DIR/cognition/runtime/knowledge" \
    "cognition runtime knowledge"

  check_index_path_contract \
    "$HARMONY_DIR/cognition/runtime/knowledge/graph/index.yml" \
    "$HARMONY_DIR/cognition/runtime/knowledge/graph" \
    "cognition runtime knowledge graph"

  check_index_path_contract \
    "$HARMONY_DIR/cognition/runtime/knowledge/sources/index.yml" \
    "$HARMONY_DIR/cognition/runtime/knowledge/sources" \
    "cognition runtime knowledge sources"

  check_index_path_contract \
    "$HARMONY_DIR/cognition/runtime/knowledge/queries/index.yml" \
    "$HARMONY_DIR/cognition/runtime/knowledge/queries" \
    "cognition runtime knowledge queries"

  check_index_path_contract \
    "$HARMONY_DIR/cognition/runtime/evidence/index.yml" \
    "$HARMONY_DIR/cognition/runtime/evidence" \
    "cognition runtime evidence"

  check_index_path_contract \
    "$HARMONY_DIR/cognition/runtime/evaluations/index.yml" \
    "$HARMONY_DIR/cognition/runtime/evaluations" \
    "cognition runtime evaluations"

  check_index_path_contract \
    "$HARMONY_DIR/cognition/runtime/evaluations/digests/index.yml" \
    "$HARMONY_DIR/cognition/runtime/evaluations/digests" \
    "cognition runtime evaluation digests"

  check_index_path_contract \
    "$HARMONY_DIR/cognition/runtime/evaluations/actions/index.yml" \
    "$HARMONY_DIR/cognition/runtime/evaluations/actions" \
    "cognition runtime evaluation actions"

  check_index_path_contract \
    "$HARMONY_DIR/cognition/runtime/projections/index.yml" \
    "$HARMONY_DIR/cognition/runtime/projections" \
    "cognition runtime projections"

  check_index_path_contract \
    "$HARMONY_DIR/cognition/runtime/projections/definitions/index.yml" \
    "$HARMONY_DIR/cognition/runtime/projections/definitions" \
    "cognition runtime projection definitions"

  check_index_path_contract \
    "$HARMONY_DIR/cognition/runtime/projections/materialized/index.yml" \
    "$HARMONY_DIR/cognition/runtime/projections/materialized" \
    "cognition runtime projection materialized"

  check_index_path_contract \
    "$HARMONY_DIR/cognition/governance/index.yml" \
    "$HARMONY_DIR/cognition/governance" \
    "cognition governance"

  check_index_path_contract \
    "$HARMONY_DIR/cognition/governance/principles/index.yml" \
    "$HARMONY_DIR/cognition/governance/principles" \
    "cognition governance principles"

  check_index_path_contract \
    "$HARMONY_DIR/cognition/governance/pillars/index.yml" \
    "$HARMONY_DIR/cognition/governance/pillars" \
    "cognition governance pillars"

  check_index_path_contract \
    "$HARMONY_DIR/cognition/governance/purpose/index.yml" \
    "$HARMONY_DIR/cognition/governance/purpose" \
    "cognition governance purpose"

  check_index_path_contract \
    "$HARMONY_DIR/cognition/governance/controls/index.yml" \
    "$HARMONY_DIR/cognition/governance/controls" \
    "cognition governance controls"

  check_index_path_contract \
    "$HARMONY_DIR/cognition/governance/exceptions/index.yml" \
    "$HARMONY_DIR/cognition/governance/exceptions" \
    "cognition governance exceptions"

  check_index_path_contract \
    "$HARMONY_DIR/cognition/practices/index.yml" \
    "$HARMONY_DIR/cognition/practices" \
    "cognition practices"

  check_index_path_contract \
    "$HARMONY_DIR/cognition/practices/operations/index.yml" \
    "$HARMONY_DIR/cognition/practices/operations" \
    "cognition practices operations"

  check_index_path_contract \
    "$HARMONY_DIR/cognition/practices/methodology/index.yml" \
    "$HARMONY_DIR/cognition/practices/methodology" \
    "cognition methodology"

  check_index_path_contract \
    "$HARMONY_DIR/cognition/practices/methodology/migrations/index.yml" \
    "$HARMONY_DIR/cognition/practices/methodology/migrations" \
    "cognition methodology migrations"

  check_index_path_contract \
    "$HARMONY_DIR/cognition/practices/methodology/audits/index.yml" \
    "$HARMONY_DIR/cognition/practices/methodology/audits" \
    "cognition methodology audits"

  check_index_path_contract \
    "$HARMONY_DIR/cognition/practices/methodology/templates/index.yml" \
    "$HARMONY_DIR/cognition/practices/methodology/templates" \
    "cognition methodology templates"

  check_section_sidecar_contract \
    "$HARMONY_DIR/cognition/practices/methodology/README.index.yml" \
    "$HARMONY_DIR/cognition/practices/methodology" \
    "cognition methodology readme"

  check_section_sidecar_contract \
    "$HARMONY_DIR/cognition/practices/methodology/implementation-guide.index.yml" \
    "$HARMONY_DIR/cognition/practices/methodology" \
    "cognition methodology implementation guide"

  check_index_path_contract \
    "$HARMONY_DIR/cognition/_meta/architecture/index.yml" \
    "$HARMONY_DIR/cognition/_meta/architecture" \
    "cognition architecture"

  check_index_path_contract \
    "$HARMONY_DIR/cognition/_meta/architecture/artifact-surface/index.yml" \
    "$HARMONY_DIR/cognition/_meta/architecture/artifact-surface" \
    "cognition artifact-surface architecture"

  check_index_path_contract \
    "$HARMONY_DIR/cognition/_meta/docs/index.yml" \
    "$HARMONY_DIR/cognition/_meta/docs" \
    "cognition discovery docs"

  check_index_path_contract \
    "$HARMONY_DIR/cognition/_meta/principles/index.yml" \
    "$HARMONY_DIR/cognition/_meta/principles" \
    "cognition principles support docs"

  check_section_sidecar_contract \
    "$HARMONY_DIR/cognition/_meta/architecture/README.index.yml" \
    "$HARMONY_DIR/cognition/_meta/architecture" \
    "cognition architecture readme"

  check_section_sidecar_contract \
    "$HARMONY_DIR/cognition/_meta/architecture/resources.index.yml" \
    "$HARMONY_DIR/cognition/_meta/architecture" \
    "cognition architecture resources"
}

check_cognition_migration_index_cross_references() {
  local index_file="$HARMONY_DIR/cognition/runtime/migrations/index.yml"
  local index_dir="$HARMONY_DIR/cognition/runtime/migrations"
  local id path adr evidence
  local seen=0

  require_file "$index_file"
  if [[ ! -f "$index_file" ]]; then
    return
  fi

  while IFS=$'\t' read -r id path adr evidence; do
    [[ -z "$id" ]] && continue
    seen=1

    if [[ -z "$path" || -z "$adr" || -z "$evidence" ]]; then
      fail "migration index record missing required fields (path/adr/evidence): $id"
      continue
    fi

    if [[ ! -f "$index_dir/$path" ]]; then
      fail "migration index path missing on disk: ${index_file#$ROOT_DIR/} -> $path"
    else
      pass "migration index path exists: ${index_file#$ROOT_DIR/} -> $path"
    fi

    if [[ "$path" =~ /plan\.md$ ]]; then
      pass "migration index path uses plan.md contract: $id"
    else
      fail "migration index path must point to plan.md: $id -> $path"
    fi

    if [[ ! -f "$index_dir/$adr" ]]; then
      fail "migration index adr reference missing on disk: ${index_file#$ROOT_DIR/} -> $adr"
    else
      pass "migration index adr reference exists: ${index_file#$ROOT_DIR/} -> $adr"
    fi

    if [[ ! -f "$index_dir/$evidence" ]]; then
      fail "migration index evidence reference missing on disk: ${index_file#$ROOT_DIR/} -> $evidence"
    else
      pass "migration index evidence reference exists: ${index_file#$ROOT_DIR/} -> $evidence"
    fi
  done < <(
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
  )

  if [[ $seen -eq 0 ]]; then
    warn "no records found in migration index: ${index_file#$ROOT_DIR/}"
  fi
}

check_cognition_audit_index_cross_references() {
  local index_file="$HARMONY_DIR/cognition/runtime/audits/index.yml"
  local index_dir="$HARMONY_DIR/cognition/runtime/audits"
  local id path evidence
  local seen=0

  require_file "$index_file"
  if [[ ! -f "$index_file" ]]; then
    return
  fi

  while IFS=$'\t' read -r id path evidence; do
    [[ -z "$id" ]] && continue
    seen=1

    if [[ -z "$path" || -z "$evidence" ]]; then
      fail "audit index record missing required fields (path/evidence): $id"
      continue
    fi

    if [[ ! -f "$index_dir/$path" ]]; then
      fail "audit index path missing on disk: ${index_file#$ROOT_DIR/} -> $path"
    else
      pass "audit index path exists: ${index_file#$ROOT_DIR/} -> $path"
    fi

    if [[ "$path" =~ /plan\.md$ ]]; then
      pass "audit index path uses plan.md contract: $id"
    else
      fail "audit index path must point to plan.md: $id -> $path"
    fi

    if [[ ! -f "$index_dir/$evidence" ]]; then
      fail "audit index evidence reference missing on disk: ${index_file#$ROOT_DIR/} -> $evidence"
    else
      pass "audit index evidence reference exists: ${index_file#$ROOT_DIR/} -> $evidence"
    fi
  done < <(
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
      /^[[:space:]]+evidence:[[:space:]]*/ {
        evidence=$0
        sub(/^[[:space:]]+evidence:[[:space:]]*/, "", evidence)
        gsub(/"/, "", evidence)
        print id "\t" path "\t" evidence
      }
    ' "$index_file"
  )

  if [[ $seen -eq 0 ]]; then
    pass "no records found in audit index: ${index_file#$ROOT_DIR/} (allowed)"
  fi
}

check_profile_shape_bounded_surfaces() {
  local domain="$1"
  local root="$HARMONY_DIR/$domain"

  require_dir "$root/runtime"
  require_dir "$root/governance"
  require_dir "$root/practices"
  require_file "$root/runtime/README.md"
  require_file "$root/governance/README.md"
  require_file "$root/practices/README.md"
}

check_profile_shape_state_tracking() {
  local domain="$1"
  local root="$HARMONY_DIR/$domain"

  require_file "$root/log.md"
  require_file "$root/tasks.json"
  require_file "$root/entities.json"
  require_file "$root/next.md"

  local forbidden
  forbidden=(runtime governance practices)
  local dir
  for dir in "${forbidden[@]}"; do
    if [[ -e "$root/$dir" ]]; then
      fail "state-tracking domain '$domain' must not define '$dir/' surface"
    else
      pass "state-tracking domain '$domain' does not define '$dir/' surface"
    fi
  done
}

check_profile_shape_human_led() {
  local domain="$1"
  local root="$HARMONY_DIR/$domain"

  require_dir "$root/scratchpad"
  require_dir "$root/projects"

  local forbidden
  forbidden=(runtime governance practices)
  local dir
  for dir in "${forbidden[@]}"; do
    if [[ -e "$root/$dir" ]]; then
      fail "human-led domain '$domain' must not define '$dir/' surface"
    else
      pass "human-led domain '$domain' does not define '$dir/' surface"
    fi
  done
}

check_profile_shape_artifact_sink() {
  local domain="$1"
  local root="$HARMONY_DIR/$domain"

  require_dir "$root/reports"
  require_dir "$root/drafts"
  require_dir "$root/artifacts"

  local forbidden
  forbidden=(runtime governance practices)
  local dir
  for dir in "${forbidden[@]}"; do
    if [[ -e "$root/$dir" ]]; then
      fail "artifact-sink domain '$domain' must not define '$dir/' surface"
    else
      pass "artifact-sink domain '$domain' does not define '$dir/' surface"
    fi
  done
}

check_domain_profile_shapes() {
  local domains
  domains=(agency capabilities cognition orchestration scaffolding assurance engine continuity ideation output)

  local domain profile
  for domain in "${domains[@]}"; do
    profile="$(extract_domain_profile "$domain" || true)"
    if [[ -z "$profile" ]]; then
      fail "cannot validate profile shape for '$domain': missing profile mapping"
      continue
    fi

    case "$profile" in
      bounded-surfaces)
        check_profile_shape_bounded_surfaces "$domain"
        ;;
      state-tracking)
        check_profile_shape_state_tracking "$domain"
        ;;
      human-led)
        check_profile_shape_human_led "$domain"
        ;;
      artifact-sink)
        check_profile_shape_artifact_sink "$domain"
        ;;
      *)
        fail "unsupported domain profile '$profile' for '$domain'"
        ;;
    esac
  done
}

check_deprecated_agency_paths() {
  local deprecated
  deprecated=(
    "$HARMONY_DIR/agency/actors"
    "$HARMONY_DIR/agency/agents"
    "$HARMONY_DIR/agency/assistants"
    "$HARMONY_DIR/agency/teams"
    "$HARMONY_DIR/agency/subagents"
    "$HARMONY_DIR/agency/CONSTITUTION.md"
    "$HARMONY_DIR/agency/DELEGATION.md"
    "$HARMONY_DIR/agency/MEMORY.md"
  )

  local path rel
  for path in "${deprecated[@]}"; do
    rel="${path#$ROOT_DIR/}"
    if [[ -e "$path" ]]; then
      fail "deprecated agency path exists: $rel"
    else
      pass "deprecated agency path removed: $rel"
    fi
  done
}

check_deprecated_capabilities_paths() {
  local deprecated
  deprecated=(
    "$HARMONY_DIR/capabilities/commands"
    "$HARMONY_DIR/capabilities/skills"
    "$HARMONY_DIR/capabilities/tools"
    "$HARMONY_DIR/capabilities/services"
    "$HARMONY_DIR/capabilities/_ops/policy"
  )

  local path rel
  for path in "${deprecated[@]}"; do
    rel="${path#$ROOT_DIR/}"
    if [[ -e "$path" ]]; then
      fail "deprecated capabilities path exists: $rel"
    else
      pass "deprecated capabilities path removed: $rel"
    fi
  done
}

check_deprecated_orchestration_paths() {
  local deprecated
  deprecated=(
    "$HARMONY_DIR/orchestration/workflows"
    "$HARMONY_DIR/orchestration/missions"
    "$HARMONY_DIR/orchestration/incidents.md"
    "$HARMONY_DIR/orchestration/incident-response.md"
  )

  local path rel
  for path in "${deprecated[@]}"; do
    rel="${path#$ROOT_DIR/}"
    if [[ -e "$path" ]]; then
      fail "deprecated orchestration path exists: $rel"
    else
      pass "deprecated orchestration path removed: $rel"
    fi
  done
}

check_deprecated_assurance_paths() {
  local deprecated
  deprecated=(
    "$HARMONY_DIR/assurance/CHARTER.md"
    "$HARMONY_DIR/assurance/DOCTRINE.md"
    "$HARMONY_DIR/assurance/CHANGELOG.md"
    "$HARMONY_DIR/assurance/complete.md"
    "$HARMONY_DIR/assurance/session-exit.md"
    "$HARMONY_DIR/assurance/standards"
    "$HARMONY_DIR/assurance/trust"
    "$HARMONY_DIR/assurance/_ops/scripts"
    "$HARMONY_DIR/assurance/_ops/state"
  )

  local path rel
  for path in "${deprecated[@]}"; do
    rel="${path#$ROOT_DIR/}"
    if [[ -e "$path" ]]; then
      fail "deprecated assurance path exists: $rel"
    else
      pass "deprecated assurance path removed: $rel"
    fi
  done
}

check_deprecated_scaffolding_paths() {
  local deprecated
  deprecated=(
    "$HARMONY_DIR/scaffolding/patterns"
    "$HARMONY_DIR/scaffolding/templates"
    "$HARMONY_DIR/scaffolding/prompts"
    "$HARMONY_DIR/scaffolding/examples"
    "$HARMONY_DIR/scaffolding/_ops/scripts"
  )

  local path rel
  for path in "${deprecated[@]}"; do
    rel="${path#$ROOT_DIR/}"
    if [[ -e "$path" ]]; then
      fail "deprecated scaffolding path exists: $rel"
    else
      pass "deprecated scaffolding path removed: $rel"
    fi
  done
}

check_deprecated_engine_paths() {
  local deprecated
  deprecated=(
    "$HARMONY_DIR/runtime"
  )

  local path rel
  for path in "${deprecated[@]}"; do
    rel="${path#$ROOT_DIR/}"
    if [[ -e "$path" ]]; then
      fail "deprecated engine path exists: $rel"
    else
      pass "deprecated engine path removed: $rel"
    fi
  done
}

check_deprecated_cognition_paths() {
  local deprecated
  deprecated=(
    "$HARMONY_DIR/cognition/principles"
    "$HARMONY_DIR/cognition/pillars"
    "$HARMONY_DIR/cognition/purpose"
    "$HARMONY_DIR/cognition/methodology"
    "$HARMONY_DIR/cognition/context"
    "$HARMONY_DIR/cognition/decisions"
    "$HARMONY_DIR/cognition/analyses"
    "$HARMONY_DIR/cognition/knowledge-plane"
    "$HARMONY_DIR/cognition/principles/_ops"
    "$HARMONY_DIR/cognition/principles/_meta"
    "$HARMONY_DIR/cognition/governance/principles/_meta/docs"
    "$HARMONY_DIR/cognition/_meta/principles/ra-acp-glossary.md"
    "$HARMONY_DIR/cognition/_meta/principles/ra-acp-promotion-inputs-matrix.md"
    "$HARMONY_DIR/cognition/_meta/principles/flag-metadata-contract.md"
    "$HARMONY_DIR/cognition/_meta/principles/promotable-slice-decomposition.md"
  )

  local path rel
  for path in "${deprecated[@]}"; do
    rel="${path#$ROOT_DIR/}"
    if [[ -e "$path" ]]; then
      fail "deprecated cognition path exists: $rel"
    else
      pass "deprecated cognition path removed: $rel"
    fi
  done
}

check_deprecated_cognition_discovery_section_paths() {
  local deprecated
  deprecated=(
    "$HARMONY_DIR/cognition/practices/methodology/sections"
    "$HARMONY_DIR/cognition/_meta/architecture/sections"
  )

  local path rel
  for path in "${deprecated[@]}"; do
    rel="${path#$ROOT_DIR/}"
    if [[ -e "$path" ]]; then
      fail "deprecated cognition section-discovery path exists: $rel"
    else
      pass "deprecated cognition section-discovery path removed: $rel"
    fi
  done
}

check_cognition_generated_runtime_artifacts() {
  local script="$HARMONY_DIR/cognition/_ops/runtime/scripts/validate-generated-runtime-artifacts.sh"
  if [[ ! -f "$script" ]]; then
    fail "missing generated runtime artifact validator: ${script#$ROOT_DIR/}"
    return
  fi

  if bash "$script"; then
    pass "generated cognition runtime artifact validator passed"
  else
    fail "generated cognition runtime artifact validator failed"
  fi
}

check_alignment_guardrail() {
  local script="$SCRIPT_DIR/validate-audit-subsystem-health-alignment.sh"
  if [[ ! -f "$script" ]]; then
    fail "missing alignment validator script: ${script#$ROOT_DIR/}"
    return
  fi
  if bash "$script" --static-only; then
    pass "audit-subsystem-health alignment guardrail (static) passed"
  else
    fail "audit-subsystem-health alignment guardrail (static) failed"
  fi
}

check_audit_convergence_guardrail() {
  local script="$SCRIPT_DIR/validate-audit-convergence-contract.sh"
  if [[ ! -f "$script" ]]; then
    fail "missing bounded-audit convergence validator script: ${script#$ROOT_DIR/}"
    return
  fi
  if bash "$script"; then
    pass "bounded-audit convergence contract guardrail passed"
  else
    fail "bounded-audit convergence contract guardrail failed"
  fi
}

check_execution_profile_governance_surfaces() {
  local root_agents="$ROOT_DIR/AGENTS.md"
  local migrations_readme="$HARMONY_DIR/cognition/practices/methodology/migrations/README.md"
  local migrations_doctrine="$HARMONY_DIR/cognition/practices/methodology/migrations/doctrine.md"
  local migrations_invariants="$HARMONY_DIR/cognition/practices/methodology/migrations/invariants.md"
  local migrations_exceptions="$HARMONY_DIR/cognition/practices/methodology/migrations/exceptions.md"
  local migrations_ci_gates="$HARMONY_DIR/cognition/practices/methodology/migrations/ci-gates.md"
  local migration_template="$HARMONY_DIR/scaffolding/runtime/templates/migrations/template.clean-break-migration.md"
  local migration_instructions="$HARMONY_DIR/agency/practices/clean-break-migration.instructions.md"
  local migration_prompt="$HARMONY_DIR/scaffolding/practices/prompts/clean-break-migration.prompt.md"
  local workflows_readme="$HARMONY_DIR/orchestration/runtime/workflows/README.md"
  local pr_template="$ROOT_DIR/.github/PULL_REQUEST_TEMPLATE.md"
  local pr_template_kaizen="$ROOT_DIR/.github/PULL_REQUEST_TEMPLATE/kaizen.md"
  local pr_standards="$HARMONY_DIR/agency/practices/pull-request-standards.md"
  local compatibility_policy="$HARMONY_DIR/engine/governance/compatibility-policy.md"
  local protocol_versioning="$HARMONY_DIR/engine/governance/protocol-versioning.md"
  local release_gates="$HARMONY_DIR/engine/governance/release-gates.md"
  local release_runbook="$HARMONY_DIR/engine/practices/release-runbook.md"
  local local_dev_validation="$HARMONY_DIR/engine/practices/local-dev-validation.md"

  require_file "$root_agents"
  require_file "$migrations_readme"
  require_file "$migrations_doctrine"
  require_file "$migrations_invariants"
  require_file "$migrations_exceptions"
  require_file "$migrations_ci_gates"
  require_file "$migration_template"
  require_file "$migration_instructions"
  require_file "$migration_prompt"
  require_file "$workflows_readme"
  require_file "$pr_template"
  require_file "$pr_template_kaizen"
  require_file "$pr_standards"
  require_file "$compatibility_policy"
  require_file "$protocol_versioning"
  require_file "$release_gates"
  require_file "$release_runbook"
  require_file "$local_dev_validation"

  if ! grep -Fq 'change_profile' "$migrations_doctrine"; then
    fail "migration doctrine missing change_profile governance key"
  fi
  if ! grep -Fq 'release_state' "$migrations_doctrine"; then
    fail "migration doctrine missing release_state governance key"
  fi
  if ! grep -Fq 'transitional_exception_note' "$migrations_doctrine"; then
    fail "migration doctrine missing transitional_exception_note governance key"
  fi

  if ! grep -Fq 'Profile Selection Receipt' "$migrations_readme"; then
    fail "migration README missing required section: Profile Selection Receipt"
  fi
  if ! grep -Fq 'Implementation Plan' "$migrations_readme"; then
    fail "migration README missing required section: Implementation Plan"
  fi
  if ! grep -Fq 'Impact Map (code, tests, docs, contracts)' "$migrations_readme"; then
    fail "migration README missing required section: Impact Map (code, tests, docs, contracts)"
  fi
  if ! grep -Fq 'Compliance Receipt' "$migrations_readme"; then
    fail "migration README missing required section: Compliance Receipt"
  fi
  if ! grep -Fq 'Exceptions/Escalations' "$migrations_readme"; then
    fail "migration README missing required section: Exceptions/Escalations"
  fi

  if ! grep -Fq 'Profile Selection Receipt' "$migration_template"; then
    fail "migration template missing section: Profile Selection Receipt"
  fi
  if ! grep -Fq 'Implementation Plan' "$migration_template"; then
    fail "migration template missing section: Implementation Plan"
  fi
  if ! grep -Fq 'Impact Map (code, tests, docs, contracts)' "$migration_template"; then
    fail "migration template missing section: Impact Map (code, tests, docs, contracts)"
  fi
  if ! grep -Fq 'Compliance Receipt' "$migration_template"; then
    fail "migration template missing section: Compliance Receipt"
  fi
  if ! grep -Fq 'Exceptions/Escalations' "$migration_template"; then
    fail "migration template missing section: Exceptions/Escalations"
  fi
  if ! grep -Fq 'change_profile' "$migration_template"; then
    fail "migration template missing change_profile key"
  fi
  if ! grep -Fq 'release_state' "$migration_template"; then
    fail "migration template missing release_state key"
  fi
  if ! grep -Fq 'transitional_exception_note' "$migration_template"; then
    fail "migration template missing transitional_exception_note key"
  fi

  if ! grep -Fq 'change_profile' "$migration_instructions"; then
    fail "agency migration instructions missing change_profile key"
  fi
  if ! grep -Fq 'transitional_exception_note' "$migration_instructions"; then
    fail "agency migration instructions missing transitional_exception_note key"
  fi

  if ! grep -Fq 'change_profile' "$migration_prompt"; then
    fail "migration prompt missing change_profile key"
  fi
  if ! grep -Fq 'transitional_exception_note' "$migration_prompt"; then
    fail "migration prompt missing transitional_exception_note key"
  fi

  if ! grep -Fq '`execution_profile`' "$workflows_readme"; then
    fail "workflows README missing execution_profile disambiguation"
  fi
  if ! grep -Fq '`core`' "$workflows_readme" || ! grep -Fq '`external-dependent`' "$workflows_readme"; then
    fail "workflows README missing execution_profile allowed values (`core`, `external-dependent`)"
  fi
  if ! grep -Fq 'change_profile' "$workflows_readme"; then
    fail "workflows README missing governance change_profile disambiguation"
  fi

  if ! grep -Fq 'Profile Selection Receipt' "$pr_template"; then
    fail "PR template missing section: Profile Selection Receipt"
  fi
  if ! grep -Fq 'Implementation Plan' "$pr_template"; then
    fail "PR template missing section: Implementation Plan"
  fi
  if ! grep -Fq 'Impact Map (code, tests, docs, contracts)' "$pr_template"; then
    fail "PR template missing section: Impact Map (code, tests, docs, contracts)"
  fi
  if ! grep -Fq 'Compliance Receipt' "$pr_template"; then
    fail "PR template missing section: Compliance Receipt"
  fi
  if ! grep -Fq 'Exceptions/Escalations' "$pr_template"; then
    fail "PR template missing section: Exceptions/Escalations"
  fi

  if ! grep -Fq 'Profile Selection Receipt' "$pr_template_kaizen"; then
    fail "Kaizen PR template missing section: Profile Selection Receipt"
  fi
  if ! grep -Fq 'Implementation Plan' "$pr_template_kaizen"; then
    fail "Kaizen PR template missing section: Implementation Plan"
  fi
  if ! grep -Fq 'Impact Map (code, tests, docs, contracts)' "$pr_template_kaizen"; then
    fail "Kaizen PR template missing section: Impact Map (code, tests, docs, contracts)"
  fi
  if ! grep -Fq 'Compliance Receipt' "$pr_template_kaizen"; then
    fail "Kaizen PR template missing section: Compliance Receipt"
  fi
  if ! grep -Fq 'Exceptions/Escalations' "$pr_template_kaizen"; then
    fail "Kaizen PR template missing section: Exceptions/Escalations"
  fi

  if ! grep -Fq 'Profile Selection Receipt' "$pr_standards"; then
    fail "pull-request-standards missing profile receipt requirement"
  fi
  if ! grep -Fq 'change_profile' "$pr_standards"; then
    fail "pull-request-standards missing change_profile requirement"
  fi

  if ! grep -Fq 'change_profile' "$compatibility_policy"; then
    fail "engine compatibility policy missing change_profile governance linkage"
  fi
  if ! grep -Fq 'release_state' "$protocol_versioning"; then
    fail "engine protocol versioning missing release_state governance linkage"
  fi
  if ! grep -Fq 'Profile Selection Receipt' "$release_gates"; then
    fail "engine release gates missing profile receipt gate"
  fi
  if ! grep -Fq 'change_profile' "$release_runbook"; then
    fail "engine release runbook missing change_profile release checklist requirement"
  fi
  if ! grep -Fq 'change_profile' "$local_dev_validation"; then
    fail "engine local-dev validation missing change_profile checks"
  fi

  pass "execution-profile governance surfaces validated"
}

main() {
  echo "== Harness Structure Validation =="

  local subsystems
  subsystems=(agency capabilities cognition orchestration scaffolding assurance continuity ideation output)
  local subsystem
  for subsystem in "${subsystems[@]}"; do
    check_subsystem_baseline "$subsystem"
  done

  check_engine_baseline
  check_meta_namespace_layout
  check_domain_profile_registry
  check_discovery_contracts
  check_expected_internals
  check_structure_docs_contract
  check_cognition_decision_record_surface
  check_cognition_migration_record_surface
  check_cognition_audit_record_surface
  check_cognition_discovery_indexes
  check_cognition_generated_runtime_artifacts
  check_cognition_migration_index_cross_references
  check_cognition_audit_index_cross_references
  check_output_decision_evidence_surface
  check_output_migration_evidence_surface
  check_output_audit_evidence_surface
  check_domain_profile_shapes
  check_deprecated_agency_paths
  check_deprecated_engine_paths
  check_deprecated_cognition_paths
  check_deprecated_cognition_discovery_section_paths
  check_deprecated_orchestration_paths
  check_deprecated_capabilities_paths
  check_deprecated_assurance_paths
  check_deprecated_scaffolding_paths
  check_alignment_guardrail
  check_audit_convergence_guardrail
  check_execution_profile_governance_surfaces

  echo
  echo "Validation summary: errors=$errors warnings=$warnings"
  if [[ $errors -gt 0 ]]; then
    exit 1
  fi
}

main "$@"
