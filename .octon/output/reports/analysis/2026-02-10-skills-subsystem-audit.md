# Skills Subsystem Audit Report

Date: 2026-02-10  
Selected Context: archetype=library/SDK/tooling (primary), platform/infra (secondary); testing=§8.3; operations=§9.2; risk_tier=B; mode=full-documentation.

## Scope and Method

Audited all files under `.octon/capabilities/skills/` across 14 dimensions from the audit plan.

Execution highlights:

- Ran baseline validator: `bash .octon/capabilities/skills/scripts/validate-skills.sh` (exit `0`, "All checks passed")
- Parsed `manifest.yml`, `registry.yml`, `capabilities.yml`, all non-infra `SKILL.md` files, all `references/*.md`, logs, runs/configs/resources, and `_template/`
- Built structural/schema/dependency/security/token checks with scripted set comparisons
- Ran isolated validator mutation checks in `/tmp` to confirm selected checks are live
- Ran isolated `--fix` in `/tmp` and compared trees (`diff -qr` showed no changes)

## Executive Summary

- Total findings: 11
- `critical`: 1
- `important`: 5
- `minor`: 3
- `informational`: 2

Top risks:

1. Unscoped tool permissions in an active meta skill (`build-mcp-server`) violate deny-by-default.
2. Foundation child skill catalog is structurally incomplete: 12 child `SKILL.md` directories are not represented in manifest/registry but are advertised as invocable commands by parent foundations.
3. Registry output schema is inconsistent for directory outputs in `create-skill` and `build-mcp-server`.

---

## Dimension 1: Structural Integrity

### Finding D1-1

- Severity: `important`
- Issue: 12 directories containing `SKILL.md` exist but are absent from `manifest.yml` (and therefore routing/registry).
- Affected files:
  - `.octon/capabilities/skills/foundations/python-api/contract-first-api/SKILL.md`
  - `.octon/capabilities/skills/foundations/python-api/contributor-guide/SKILL.md`
  - `.octon/capabilities/skills/foundations/python-api/dev-toolchain/SKILL.md`
  - `.octon/capabilities/skills/foundations/python-api/infra-manifest/SKILL.md`
  - `.octon/capabilities/skills/foundations/python-api/scaffold-package/SKILL.md`
  - `.octon/capabilities/skills/foundations/python-api/test-harness/SKILL.md`
  - `.octon/capabilities/skills/foundations/swift-macos-app/cli-interface/SKILL.md`
  - `.octon/capabilities/skills/foundations/swift-macos-app/contributor-guide/SKILL.md`
  - `.octon/capabilities/skills/foundations/swift-macos-app/daemon-service/SKILL.md`
  - `.octon/capabilities/skills/foundations/swift-macos-app/data-layer/SKILL.md`
  - `.octon/capabilities/skills/foundations/swift-macos-app/scaffold-package/SKILL.md`
  - `.octon/capabilities/skills/foundations/swift-macos-app/test-harness/SKILL.md`
- Notes: `manifest.yml` and `registry.yml` are otherwise in sync (`22` IDs each), and all manifest paths resolve to real directories with `SKILL.md`.
- Remediation:
  - Either register these as first-class child skills (manifest + registry + commands) or convert/archive them as non-routable docs.

## Dimension 2: Schema Conformance

### Finding D2-1

- Severity: `important`
- Issue: `registry.yml` outputs for two skills omit required `format` and `determinism` fields on directory outputs.
- Affected files:
  - `.octon/capabilities/skills/registry.yml:654`
  - `.octon/capabilities/skills/registry.yml:655`
  - `.octon/capabilities/skills/registry.yml:656`
  - `.octon/capabilities/skills/registry.yml:657`
  - `.octon/capabilities/skills/registry.yml:908`
  - `.octon/capabilities/skills/registry.yml:909`
  - `.octon/capabilities/skills/registry.yml:910`
  - `.octon/capabilities/skills/registry.yml:911`
- Remediation:
  - Add `format` and `determinism` to those outputs or explicitly relax the schema and validator to allow directory outputs without those fields.

### Finding D2-2

- Severity: `important`
- Issue: 12 unregistered child `SKILL.md` files miss required frontmatter field `skill_sets`.
- Affected files: same 12 files listed in D1-1.
- Remediation:
  - If kept as skills, normalize frontmatter to current schema.
  - If not intended as skills, move out of skill discovery surface.

## Dimension 3: Single Source of Truth Enforcement

Result: no material violations.

- `allowed-tools` is not duplicated in `manifest.yml`/`registry.yml` (only mentioned in comments).
- No `version:` found in `SKILL.md` frontmatter.
- Manifest summary alignment is broadly acceptable (semantic overlaps vary but no hard contradiction found).

## Dimension 4: Capability-Reference Coherence

### Finding D4-1

- Severity: `informational`
- Issue: No missing required reference files, but many skills include non-required references under current `capability_refs` mapping (e.g., `io-contract.md`, `safety.md`, `validation.md`, `rules.md`).
- Affected files: multiple skills (16 entries flagged).
- Interpretation: this likely reflects a "minimum required" mapping model rather than true drift, but the policy should be explicit.
- Remediation:
  - Document optional-reference policy or expand `capability_refs` semantics.

## Dimension 5: Token Budgets

Result: no findings.

- All `SKILL.md` files are below `5000` tokens and `500` lines.
- All manifest entries remain below `150`-token budget.
- Reference-specific budgets (io-contract, safety, examples, phases, validation) are within thresholds.
- Aggregate activation budgets are below the configured guideline.

## Dimension 6: Trigger Quality

### Finding D6-1

- Severity: `informational`
- Issue: No exact duplicate triggers, but 3 high-similarity trigger pairs increase potential routing ambiguity.
- Examples:
  - `react` vs `react-native`: "react workflow guidance" vs "react native workflow guidance"
  - `react-best-practices` vs `react-native-best-practices` (2 similar phrases)
- Remediation:
  - Add more discriminative trigger phrases for closely related sibling skills.

## Dimension 7: Security and Safety

### Finding D7-1

- Severity: `critical`
- Issue: Active skill `build-mcp-server` declares unscoped `Write` and unscoped `Bash`.
- Affected files:
  - `.octon/capabilities/skills/meta/build-mcp-server/SKILL.md:18`
- Why critical: violates deny-by-default and allows unrestricted filesystem/shell behavior from an invocable skill.
- Remediation:
  - Replace with scoped permissions, e.g. scoped write paths and command-scoped shell actions.
  - Add validator rule: fail on unscoped `Write`/`Bash` in active skills.

### Finding D7-2

- Severity: `important`
- Issue: 12 unregistered foundation child skill files also use unscoped `Bash` and unscoped `Write` (`Read Grep Glob Bash Write Edit`).
- Affected files:
  - `.octon/capabilities/skills/foundations/python-api/scaffold-package/SKILL.md:7`
  - `.octon/capabilities/skills/foundations/swift-macos-app/scaffold-package/SKILL.md:7`
  - Plus 10 sibling child files under `python-api/*` and `swift-macos-app/*`
- Remediation:
  - Same as D1-1 decision: register+harden, or archive/remove from active skill tree.

## Dimension 8: Cross-Skill Dependencies

Result: no findings.

- All `depends_on` targets resolve to existing active manifest IDs.
- No dependency cycles detected.

## Dimension 9: Lifecycle and Versioning

### Finding D9-1

- Severity: `minor`
- Issue: 14 skills appear stale by metadata date (`metadata.updated` older than last git commit date).
- Affected files: multiple active skills (including `synthesize-research`, `refine-prompt`, `refactor`, `audit-*`, best-practices skills, `spec-to-implementation`, `build-mcp-server`).
- Remediation:
  - Update `metadata.updated` automatically in skill-edit workflows.

### Finding D9-2

- Severity: `minor`
- Issue: runtime/config naming drift for legacy `research-synthesizer` remains.
- Affected paths:
  - `.octon/capabilities/skills/runs/research-synthesizer/`
  - `.octon/capabilities/skills/configs/research-synthesizer/`
- Remediation:
  - Rename to `synthesize-research` or document as intentional compatibility alias.

## Dimension 10: Logging and Runtime Artifacts

### Finding D10-1

- Severity: `important`
- Issue: `audit-migration` logs do not follow required YAML-frontmatter run log format.
- Affected files:
  - `.octon/capabilities/skills/logs/FORMAT.md:33`
  - `.octon/capabilities/skills/logs/audit-migration/2026-02-08-workspace-to-harness.md:1`
  - `.octon/capabilities/skills/logs/audit-migration/2026-02-08-workspace-to-harness-rerun.md:1`
- Remediation:
  - Backfill required frontmatter and enforce format at write time.

### Clean checks

- `logs/index.yml` and per-skill indexes do not reference missing files.
- No orphaned directories in `resources/`.

## Dimension 11: Documentation Completeness

### Finding D11-1

- Severity: `important`
- Issue: README has architecture/procedure drift (references deprecated `skill_mappings`, duplicates shared vs harness registry path as the same file, and outdated creation flow text).
- Affected files:
  - `.octon/capabilities/skills/README.md:47`
  - `.octon/capabilities/skills/README.md:48`
  - `.octon/capabilities/skills/README.md:150`
  - `.octon/capabilities/skills/README.md:151`
  - `.octon/capabilities/skills/README.md:152`
- Remediation:
  - Rewrite quick-create and architecture sections to match current single-registry schema and grouped-path model.

### Finding D11-2

- Severity: `minor`
- Issue: 10 active skills do not include the full required section set from this audit policy (especially foundation/context skills and best-practices variants missing `Core Workflow`, and some missing multiple canonical sections).
- Affected skills:
  - `python-api`, `swift-macos-app`, `react`, `react-native`, `postgres`, `vercel`, `react-composition-patterns`, `react-best-practices`, `react-native-best-practices`, `postgres-best-practices`
- Remediation:
  - Either enforce section contract for all active skills or split policy: invocable vs non-invocable/foundation skills.

## Dimension 12: Validator Alignment

### Coverage mapping (27 checks)

- Covered strongly:
  - D1 (`1,2,3,4,5, manifest↔registry sync`)
  - D3 (`6,7,8,9,10,11,12,14c,17,18`)
  - D5 (`16,21,22,23`)
  - D6 (`trigger overlap`)
- Covered partially:
  - D2 (`5b,14,14b`; does not enforce all output subfields)
  - D4 (`24,25`; does not distinguish optional superfluous refs policy)
  - D7 (`14` syntax + path-scope check; does not enforce scoped Bash/Write minimality)
  - D9 (`20` only)
- Not covered materially:
  - D8 cycle/inactive-dependency rigor beyond existence checks
  - D10 log/index/runs/configs/resources hygiene
  - D11 README/body-section quality
  - D13 foundation-child invocability/registration coherence
  - D14 template coverage/drift beyond placeholder checks

### Correctness spot checks

- Baseline run: all checks passed on current tree.
- Mutation test 1 (added `requires.tools` in an io-contract) produced expected warning.
- Mutation test 2 (invalid placeholder `{{runId}}`) produced expected warning.
- `--fix` in isolated `/tmp` copy completed with no unintended tree changes (`diff -qr` clean).

## Dimension 13: Foundation Hierarchy

### Finding D13-1

- Severity: `important`
- Issue: Foundation parents advertise Python/Swift child commands as invocable (`/scaffold-package`, `/contract-first-api`, etc.), but those child skills are not registered in manifest/registry.
- Affected files:
  - `.octon/capabilities/skills/foundations/python-api/SKILL.md:43`
  - `.octon/capabilities/skills/foundations/swift-macos-app/SKILL.md:46`
- Notes:
  - Parent invocability is correctly non-invocable (empty `commands` in registry for foundation parents).
  - React/React Native/Postgres child relationships are represented in manifest/registry; Python/Swift are not.
- Remediation:
  - Register these child skills with nested paths and explicit commands, or remove command-style child declarations from parent docs.

## Dimension 14: Template Completeness

Result: no material findings.

- `_template/references/` covers all capability-mapped reference file types.
- `_template/SKILL.md` contains required frontmatter and required body sections.
- Placeholder formatting is consistent with `{{snake_case}}`.
- `_template/scripts/` and `_template/assets/` both exist.

Minor drift note:

- Most recently updated active skill (`create-skill`) includes additional sections not present in template (`Alignment-First Rule`, `Naming Convention`, `Verification Gate`).
- Consider whether these should be standardized into template or remain skill-specific.

---

## Recommended Remediation Batches

### Batch A (Immediate, security/integrity)

1. Scope `build-mcp-server` tool permissions (`Write`, `Bash`) and add validator hard-fail for unscoped forms.
2. Decide disposition of 12 unregistered Python/Swift child skill directories (register+harden vs archive/remove).
3. Add missing output schema fields (`format`, `determinism`) for `create-skill` and `build-mcp-server` directory outputs.

### Batch B (Operational hygiene)

1. Normalize `audit-migration` logs to `logs/FORMAT.md` frontmatter contract.
2. Clean or alias stale `research-synthesizer` directories in `runs/` and `configs/`.
3. Refresh stale `metadata.updated` values.

### Batch C (documentation/policy clarity)

1. Update `.octon/capabilities/skills/README.md` to current architecture and schema terms.
2. Clarify section requirements by skill class (invocable vs foundation context skills).
3. Document optional-reference policy for capability coherence checks.
