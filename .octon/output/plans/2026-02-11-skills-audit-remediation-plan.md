# Skills Exhaustive Audit Remediation Plan

Date: 2026-02-11
Source: `.octon/output/reports/analysis/2026-02-10-skills-exhaustive-audit.md`

## Context

The exhaustive audit produced 14 findings: 3 critical, 8 important, 2 minor, 1 informational. This plan addresses all findings in dependency order across 7 phases. Each phase produces a verifiable checkpoint before the next begins.

## Guiding Principles

- **Validator first:** Fix the validator before fixing data, so data fixes can be validated mechanically.
- **Scripts before content:** Fix infrastructure scripts before regenerating content they produce.
- **Critical before important:** All critical findings resolved before addressing important ones.
- **Single-commit phases:** Each phase is a single atomic commit for clean revertability.

---

## Phase 1: Validator — add unscoped `Write` enforcement

**Findings addressed:** [C]-D5-001 (partial), [I]-D3-001 (partial)

**Why first:** The validator currently fails unscoped `Bash` (line 2428) but silently passes unscoped `Write`. Fixing the validator first ensures Phase 2's `Write` scoping changes can be validated mechanically.

**File:** `.octon/capabilities/skills/_ops/scripts/validate-skills.sh`

**Changes:**

1. After the unscoped `Bash` check (line 2428-2429), add a parallel check for unscoped `Write`:

   ```bash
   if [[ "$manifest_status" == "active" ]] && get_skill_allowed_tools "$skill_dir" | grep -qx "Write"; then
       log_error "Unscoped Write permission found in active skill. Use Write(<path>/*) scopes."
   fi
   ```

   The `grep -qx "Write"` pattern matches only the bare token `Write` (exact line match), not `Write(_ops/state/logs/*)` or other scoped variants, because `get_skill_allowed_tools` emits one token per line.

2. Add missing contract checks gated behind `--strict` mode (addresses D3-001 coverage gaps). These are additive checks that don't affect normal mode:

   a. **Status value validation** — after manifest presence check: verify `status` is one of `active|deprecated|experimental|draft`.

   b. **Parameter type validation** — during registry parsing: verify each `parameter.type` is one of `text|boolean|file|folder`.

   c. **Output determinism validation** — during I/O parsing: verify each `io.outputs[].determinism` is one of `stable|variable|unique`.

**Verification:**

```bash
# Should report errors for 13 skills with bare Write
.octon/capabilities/skills/_ops/scripts/validate-skills.sh 2>&1 | grep -c "Unscoped Write"
# Expected: 13
```

**Commit message:** `fix(skills): add unscoped Write enforcement and strict-mode contract checks to validator`

---

## Phase 2: Scope bare `Write` permissions in foundation and meta skills

**Findings addressed:** [C]-D5-001

**Why now:** Validator can now catch bare `Write`. This phase eliminates all 13 instances.

**Files (13 SKILL.md files):**

### Foundation child skills with scaffolding Write

These skills intentionally write to user project directories. The appropriate scope is `Write(<project-root>/**)` — but since skills execute within a harness context, the correct pattern is to scope writes to the harness root using `Write(../../../**)` (3 levels up from `_ops/scripts/` to repo root) or use the semantic equivalent per the existing convention.

However, examining the existing comment in these files ("Write is intentionally unscoped: scaffolds into user project directories"), the correct remediation is to use a broad but explicit scope that covers the harness root. The pattern used by `create-skill` is instructive: `Write(.octon/capabilities/skills/*)`. For scaffolding skills that write into the user's project tree, scope to the harness root:

**Python API family (6 files):**

| File | Current `allowed-tools` | New `allowed-tools` |
|------|------------------------|---------------------|
| `foundations/python-api/scaffold-package/SKILL.md:10` | `Read Grep Glob Edit Write Bash(mkdir) Bash(uv)` | `Read Grep Glob Edit Write(<project>/**) Write(_ops/state/logs/*) Bash(mkdir) Bash(uv)` |
| `foundations/python-api/contract-first-api/SKILL.md:10` | same pattern | same fix pattern |
| `foundations/python-api/test-harness/SKILL.md:10` | same pattern | same fix pattern |
| `foundations/python-api/dev-toolchain/SKILL.md:10` | same pattern | same fix pattern |
| `foundations/python-api/infra-manifest/SKILL.md:10` | same pattern | same fix pattern |
| `foundations/python-api/contributor-guide/SKILL.md:10` | same pattern | same fix pattern |

**Swift macOS family (6 files):**

| File | Current `allowed-tools` | New `allowed-tools` |
|------|------------------------|---------------------|
| `foundations/swift-macos-app/scaffold-package/SKILL.md:10` | `Read Grep Glob Edit Write Bash(mkdir) Bash(swift)` | `Read Grep Glob Edit Write(<project>/**) Write(_ops/state/logs/*) Bash(mkdir) Bash(swift)` |
| `foundations/swift-macos-app/data-layer/SKILL.md:10` | same pattern | same fix pattern |
| `foundations/swift-macos-app/cli-interface/SKILL.md:10` | same pattern | same fix pattern |
| `foundations/swift-macos-app/daemon-service/SKILL.md:10` | same pattern | same fix pattern |
| `foundations/swift-macos-app/test-harness/SKILL.md:10` | same pattern | same fix pattern |
| `foundations/swift-macos-app/contributor-guide/SKILL.md:10` | same pattern | same fix pattern |

**Meta skill (1 file):**

| File | Current `allowed-tools` | New `allowed-tools` |
|------|------------------------|---------------------|
| `meta/build-mcp-server/SKILL.md:18` | `Read Glob Grep Edit Write Bash(npm) Bash(npx) Bash(mkdir) Bash(cp) Bash(node) Write(_ops/state/logs/*)` | `Read Glob Grep Edit Write(<project>/**) Bash(npm) Bash(npx) Bash(mkdir) Bash(cp) Bash(node) Write(_ops/state/logs/*)` |

> **Decision needed:** The `<project>` token is a placeholder for "the project root relative to the skill directory." The exact glob depends on how the harness resolves write scopes at execution time. If the validator's `Write(*)` case (line 488) already maps to `filesystem.write.scoped`, then `Write(**/*)` may suffice. Review the path-scope validator to confirm. If the existing scope mechanism cannot express "user's project root," introduce a `Write(<harness-root>/**)` convention and document it in `specification.md`.

**Verification:**

```bash
# Should report 0 unscoped Write errors
.octon/capabilities/skills/_ops/scripts/validate-skills.sh 2>&1 | grep -c "Unscoped Write"
# Expected: 0
```

**Commit message:** `fix(skills): scope bare Write permissions in 13 active SKILL.md files`

---

## Phase 3: Fix `setup-harness-links.sh` and regenerate symlinks

**Findings addressed:** [C]-D7-001, [C]-D8-001

**Why now:** Critical infrastructure — broken symlinks affect all host adapters.

**File:** `.octon/capabilities/skills/_ops/scripts/setup-harness-links.sh`

**Root cause analysis:**

1. **Line 13:** `PROJECT_ROOT` is computed as 3 levels up from `_ops/scripts/` (`../../..`), but `_ops/scripts/` is at `.octon/capabilities/skills/_ops/scripts/`, so 3 levels up gives `.octon/` — not the repo root. The correct depth is **4 levels up** (or better: derive from manifest location).
2. **Lines 97-113:** `discover_skills()` iterates only top-level directories under `SKILLS_DIR`, which finds group directories (`foundations/`, `meta/`, etc.) but not the actual skills nested inside them.
3. **Lines 36-44:** `find_skill_location()` checks `$SKILLS_DIR/$skill_id` — flat path only.
4. **Line 58:** Symlink target is `../../.octon/capabilities/skills/$skill_id` — flat path, doesn't work for grouped skills.

**Changes:**

1. **Fix `PROJECT_ROOT` resolution (line 13):**

   Replace the level-counting approach with manifest-based discovery:

   ```bash
   SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
   SKILLS_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
   MANIFEST="$SKILLS_DIR/manifest.yml"
   # Repo root is 3 levels above skills dir: .octon/capabilities/skills/ → repo
   PROJECT_ROOT="$(cd "$SKILLS_DIR/../../.." && pwd)"
   ```

2. **Replace `discover_skills()` with manifest-driven discovery (lines 89-114):**

   ```bash
   discover_skills() {
       # Extract id and path pairs from manifest
       awk '/^  - id:/{id=$NF} /^    path:/{gsub(/["'\'']/, "", $NF); print id, $NF}' "$MANIFEST"
   }
   ```

   This emits `skill-id path/to/skill` pairs, handling grouped paths natively.

3. **Replace `find_skill_location()` with path-based lookup (lines 36-44):**

   ```bash
   find_skill_location() {
       local skill_id="$1"
       # Look up path from manifest
       awk -v id="$skill_id" '
           /^  - id:/ && $NF == id {found=1}
           found && /^    path:/ {gsub(/["'\'']/, "", $NF); print $NF; exit}
       ' "$MANIFEST"
   }
   ```

4. **Fix `create_skill_link()` to use grouped path for symlink target (lines 48-86):**

   ```bash
   create_skill_link() {
       local skill_id="$1"
       local skill_path
       skill_path=$(find_skill_location "$skill_id")

       if [[ -z "$skill_path" ]]; then
           echo "Error: Skill '$skill_id' not found in manifest" >&2
           return 1
       fi

       # Verify SKILL.md exists at the resolved path
       if [[ ! -f "$SKILLS_DIR/$skill_path/SKILL.md" ]]; then
           echo "Error: SKILL.md not found at $SKILLS_DIR/$skill_path" >&2
           return 1
       fi

       local target="../../.octon/capabilities/skills/$skill_path"

       for harness in "${HARNESSES[@]}"; do
           harness_dir="$PROJECT_ROOT/$harness"
           link_path="$harness_dir/$skill_id"
           # ... rest of symlink logic unchanged, using $target
       done
   }
   ```

5. **Update main loop (lines 126-136):**

   ```bash
   # All skills mode
   discover_skills | while read -r skill_id skill_path; do
       echo "Skill: $skill_id ($skill_path)"
       create_skill_link "$skill_id" || true
       echo ""
   done
   ```

6. **Add stale link cleanup:** After creating new links, scan each harness directory for symlinks that point to non-existent targets and remove them:

   ```bash
   # Clean stale links
   for harness in "${HARNESSES[@]}"; do
       harness_dir="$PROJECT_ROOT/$harness"
       [[ -d "$harness_dir" ]] || continue
       for link in "$harness_dir"/*; do
           [[ -L "$link" ]] || continue
           if [[ ! -e "$link" ]]; then
               echo "  [prune] $(basename "$link") (broken link)"
               rm "$link"
           fi
       done
   done
   ```

**Verification:**

```bash
# Run script
bash .octon/capabilities/skills/_ops/scripts/setup-harness-links.sh

# Verify no broken symlinks
find .claude/skills .cursor/skills .codex/skills -type l ! -exec test -e {} \; -print
# Expected: empty output (no broken links)

# Verify a grouped skill resolves
ls -la .claude/skills/create-skill
# Expected: -> ../../.octon/capabilities/skills/meta/create-skill
```

**Commit message:** `fix(skills): rewrite setup-harness-links.sh for grouped paths and manifest-driven discovery`

---

## Phase 4: Fix `generate-reference-headers.sh` for grouped paths

**Findings addressed:** [I]-D7-002

**File:** `.octon/capabilities/skills/_ops/scripts/generate-reference-headers.sh`

**Root cause:** Line 191 constructs `skill_dir="$SKILLS_DIR/$skill_id"` — a flat path that doesn't account for grouped directory structure. The `get_manifest_skills()` function (line 236) extracts skill IDs, but the `process_skill()` function needs the manifest `path` instead.

**Changes:**

1. **Replace `get_manifest_skills()` (line 235-237) with path-aware extraction:**

   ```bash
   get_manifest_skill_paths() {
       awk '/^  - id:/{id=$NF} /^    path:/{gsub(/["'"'"']/, "", $NF); print id, $NF}' "$SKILLS_DIR/manifest.yml"
   }
   ```

2. **Update `process_skill()` (line 189-191) to accept a path argument:**

   ```bash
   process_skill() {
       local skill_id="$1"
       local skill_path="$2"
       local skill_dir="$SKILLS_DIR/$skill_path"
   ```

3. **Update main loop (lines 249-252) to pass both id and path:**

   ```bash
   get_manifest_skill_paths | while read -r skill_id skill_path; do
       process_skill "$skill_id" "$skill_path"
   done
   ```

4. **Update single-skill mode (lines 245-247) to look up path from manifest:**

   ```bash
   if [[ -n "$1" ]]; then
       skill_path=$(awk -v id="$1" '/^  - id:/ && $NF == id {found=1} found && /^    path:/ {gsub(/["'"'"']/, "", $NF); print $NF; exit}' "$SKILLS_DIR/manifest.yml")
       if [[ -z "$skill_path" ]]; then
           log_error "Skill '$1' not found in manifest"
           exit 1
       fi
       process_skill "$1" "$skill_path"
   ```

**Verification:**

```bash
# Should process all manifest skills without "Skill directory not found" errors
bash .octon/capabilities/skills/_ops/scripts/generate-reference-headers.sh 2>&1 | grep -c "ERROR"
# Expected: 0

# Single-skill mode should work for a grouped skill
bash .octon/capabilities/skills/_ops/scripts/generate-reference-headers.sh create-skill
# Expected: "Processing: create-skill" with no errors
```

**Commit message:** `fix(skills): update generate-reference-headers.sh to resolve grouped skill paths from manifest`

---

## Phase 5: Fix log infrastructure and stale metadata

**Findings addressed:** [I]-D7-003, [I]-D1-002

### 5a: Update `FORMAT.md` paths

**File:** `.octon/capabilities/skills/_ops/state/logs/FORMAT.md`

**Changes:**

1. **Line 20:** Change `skills/logs/runs/{{timestamp}}-{{skill_id}}.md` → `skills/_ops/state/logs/{{skill_id}}/{{timestamp}}-{{skill_id}}.md`

2. **Line 25:** Change `runs/20250116-143052-refine-prompt.md` → `refine-prompt/20250116-143052-refine-prompt.md`

3. **Lines 183-191:** Update `find` command examples from `skills/logs/runs` → `skills/_ops/state/logs`

4. **Lines 335-337 (See Also):** Update links from `workspaces/skills/` → `harness/skills/`

### 5b: Rebuild top-level log index

**File:** `.octon/capabilities/skills/_ops/state/logs/index.yml`

**Changes:**

Populate with actual log data:

```yaml
updated: "2026-02-08T00:00:00Z"

recent_runs:
  - run_id: "2026-02-08-workspace-to-harness-rerun"
    skill_id: "audit-migration"
    path: "audit-migration/2026-02-08-workspace-to-harness-rerun.md"
    status: "success"
  - run_id: "2026-02-08-workspace-to-harness"
    skill_id: "audit-migration"
    path: "audit-migration/2026-02-08-workspace-to-harness.md"
    status: "success"

summary:
  total_runs: 2
  by_skill:
    audit-migration: 2
```

### 5c: Add missing per-skill log indexes

**Files to create** (matching the existing `audit-migration/index.yml` pattern):

- `.octon/capabilities/skills/_ops/state/logs/refactor/index.yml`
- `.octon/capabilities/skills/_ops/state/logs/refine-prompt/index.yml`
- `.octon/capabilities/skills/_ops/state/logs/synthesize-research/index.yml`

Each with:

```yaml
skill_id: "<skill-id>"
updated: null
runs: []
```

### 5d: Standardize `create-skill` placeholder style

**Findings addressed:** [I]-D1-002

**Files:**

- `.octon/capabilities/skills/meta/create-skill/SKILL.md` (lines 73-74)
- `.octon/capabilities/skills/meta/create-skill/references/io-contract.md` (lines 32, 52, 78)

**Changes:**

Replace hyphen-style placeholders with snake_case to match registry convention:

| Current | Replacement |
|---------|-------------|
| `{{skill-name}}` | `{{skill_name}}` |
| `{{run-id}}` | `{{run_id}}` |

This aligns user-facing prose with the registry.yml path definitions (line 1083) which already use `{{skill_name}}`.

**Verification:**

```bash
# No hyphen-style placeholders in create-skill
grep -r '{{skill-name}}\|{{run-id}}' .octon/capabilities/skills/meta/create-skill/
# Expected: 0 matches
```

**Commit message:** `fix(skills): update log infrastructure paths/indexes and standardize create-skill placeholders`

---

## Phase 6: Resolve stale references in deprecated workflow and cognition artifacts

**Findings addressed:** [I]-D8-002, [I]-D8-003, [I]-D1-001 (partial), [I]-D5-002

This phase addresses two categories: deprecated workflow files and cognition artifacts with stale vocabulary.

### 6a: Deprecate or update `create-skill(x)` workflow

**Decision:** The `create-skill(x)` workflow is superseded by the `create-skill` skill itself. The cleanest approach is to mark it deprecated and add a redirect notice, rather than maintaining two parallel creation paths.

**Files:**

- `.octon/orchestration/workflows/meta/create-skill(x)/00-overview.md`
- `.octon/orchestration/workflows/meta/create-skill(x)/02-copy-template.md`
- `.octon/orchestration/workflows/meta/create-skill(x)/03-initialize-skill.md`
- `.octon/orchestration/workflows/meta/create-skill(x)/06-report-success.md`

**Changes:**

Add a deprecation notice at the top of `00-overview.md`:

```markdown
> **DEPRECATED:** This workflow is superseded by the `create-skill` skill.
> Use `use skill: create-skill` or `/create-skill` instead.
> This workflow is retained as a historical reference only.
> Active paths, reference file names, and directory structures described
> below may no longer be accurate.
```

Update the workflow manifest entry (if present) to set `status: deprecated`.

### 6b: Update cognition artifacts

**Files:**

| File | Line(s) | Change |
|------|---------|--------|
| `.octon/cognition/analyses/workflows-vs-skills-analysis.md:190` | `skill_mappings:` → `skills:` in YAML example | Replace with current registry schema (`skills.<id>.io`) |
| `.octon/cognition/analyses/workflows-vs-skills-analysis.md:558` | `references/behaviors.md` → `references/phases.md` | Update reference filename |
| `.octon/cognition/analyses/workflows-vs-skills-analysis.md:559` | `skills/refine-prompt/` → `skills/synthesis/refine-prompt/` | Update to grouped path |
| `.octon/cognition/context/decisions.md:53` (D029) | `behaviors.md` → `phases.md` | Update canonical reference file name |
| `.octon/cognition/decisions/001-octon-shared-foundation.md:59` | `skills/logs/` → `skills/_ops/state/logs/` | Update path convention |

### 6c: Update creation/design docs archetype language

**Findings addressed:** [M]-D4-001

**Files:**

| File | Line(s) | Change |
|------|---------|--------|
| `docs/architecture/harness/skills/creation.md:172` | "chosen archetype" | → "declared skill_sets and capabilities" |
| `docs/architecture/harness/skills/creation.md:198` | "Atomic archetype:" / "Complex archetype:" sections | → "Minimal skills (no phased execution):" / "Phased skills (executor skill_set):" |
| `docs/architecture/harness/skills/creation.md:208` | "Complex archetype" table header | → "Phased skill" table header |
| `docs/architecture/harness/skills/design-conventions.md:8` | "complex archetype skills" | → "phased executor skills" |
| `docs/architecture/harness/skills/design-conventions.md:182` | "Recommended for complex archetypes" | → "Recommended for phased executor skills" |

### 6d: Resolve foundation executor reference model

**Findings addressed:** [I]-D1-001

**Decision:** The 12 foundation child skills (6 python, 6 swift) declare `skill_sets: [executor]` but lack `phases.md`, `decisions.md`, and `checkpoints.md`. These skills are scaffolding tools that follow a fixed sequence — they don't truly branch or checkpoint. The correct fix is to reclassify them:

**Option A (recommended):** Change their `skill_sets` from `[executor]` to `[specialist]` and add `capabilities: [phased]` only (they do have phases but don't branch or checkpoint). This requires:

- Updating 12 SKILL.md frontmatter files
- Updating 12 manifest.yml entries
- Adding `phases.md` to each (since `phased` capability requires it)

**Option B:** Keep `[executor]` and add the missing `decisions.md` and `checkpoints.md` as minimal stubs. This inflates the reference count without adding value.

Recommendation: **Option A** — reclassify to match actual behavior.

**Files (12 SKILL.md + manifest.yml):**

```
foundations/python-api/scaffold-package/SKILL.md
foundations/python-api/contract-first-api/SKILL.md
foundations/python-api/test-harness/SKILL.md
foundations/python-api/dev-toolchain/SKILL.md
foundations/python-api/infra-manifest/SKILL.md
foundations/python-api/contributor-guide/SKILL.md
foundations/swift-macos-app/scaffold-package/SKILL.md
foundations/swift-macos-app/data-layer/SKILL.md
foundations/swift-macos-app/cli-interface/SKILL.md
foundations/swift-macos-app/daemon-service/SKILL.md
foundations/swift-macos-app/test-harness/SKILL.md
foundations/swift-macos-app/contributor-guide/SKILL.md
```

For each:

1. Change `skill_sets: [executor]` → `skill_sets: [specialist]`
2. Add `capabilities: [phased]`
3. Add a minimal `references/phases.md` describing the scaffolding phases
4. Update corresponding manifest.yml entries

### 6e: Add boundary sections to foundation child skills

**Findings addressed:** [I]-D5-002

For each of the 12 foundation child skills, add standard sections:

```markdown
## When to Use

- Starting a new <domain> project component
- Need <specific scaffolding> following Octon conventions

## Boundaries

- Does not modify existing source files
- Does not install dependencies (use the appropriate toolchain after scaffolding)

## When to Escalate

- Project requires non-standard directory structure
- Existing project needs migration rather than fresh scaffolding
```

Tailor the specific content to each skill's domain (python packaging, swift data layer, etc.).

**Verification:**

```bash
# Run validator — should pass with 0 errors
bash .octon/capabilities/skills/_ops/scripts/validate-skills.sh

# Verify no stale behaviors.md references in active docs
grep -rn 'behaviors\.md' docs/architecture/harness/skills/ .octon/cognition/ .octon/orchestration/
# Expected: only in deprecated workflow files (which now have deprecation notice)
```

**Commit message:** `fix(skills): deprecate create-skill(x) workflow, reclassify foundation skills, update stale references`

---

## Phase 7: Address minor and informational findings

**Findings addressed:** [M]-D5-003, [F]-D6-001

### 7a: Split oversized `rules.md` files

**Findings addressed:** [M]-D5-003

Four `rules.md` files exceed the 2,000 token reference budget:

| File | Est. Tokens | Budget | Action |
|------|------------|--------|--------|
| `react/composition-patterns/references/rules.md` | ~3,700 | 2,000 | Split into `rules.md` (summary matrix) + `rules-detail.md` (full examples) |
| `react/best-practices/references/rules.md` | ~22,400 | 2,000 | Split into 8 category files: `rules-waterfalls.md`, `rules-bundle.md`, `rules-rendering.md`, `rules-server.md`, `rules-async.md`, `rules-react19.md`, `rules-testing.md`, `rules-monitoring.md`. Keep `rules.md` as an index with a summary table |
| `react-native/best-practices/references/rules.md` | ~20,000 | 2,000 | Split by impact tier: `rules-critical.md`, `rules-high.md`, `rules-medium.md`, `rules-low.md`. Keep `rules.md` as index |
| `postgres/best-practices/references/rules.md` | ~2,700 | 2,000 | Compress: remove redundant examples, use tighter formatting. Target: <2,000 tokens |

The `rules.md` file for each skill remains the entry point (loaded at activation) but contains only a summary table. Detail files are loaded on-demand, matching the progressive disclosure model.

### 7b: Narrow high-overlap triggers (optional)

**Findings addressed:** [F]-D6-001

This is informational — the existing `ambiguity_resolution: "ask"` mode handles overlaps correctly. However, if desired:

1. Add domain qualifiers to foundation family triggers (e.g., "scaffold python package" not just "scaffold package")
2. Remove generic triggers like "setup swift" that could match any swift-related skill
3. Deduplicate triggers that appear in both parent and child foundation skills

**File:** `.octon/capabilities/skills/manifest.yml`

**Priority:** Low. Only address if trigger collisions cause actual user confusion.

**Verification:**

```bash
# Validate all skills pass with --strict (includes trigger overlap checks)
bash .octon/capabilities/skills/_ops/scripts/validate-skills.sh --strict

# Verify rules.md files are within budget
for f in $(find .octon/capabilities/skills/foundations -name "rules.md"); do
    words=$(wc -w < "$f")
    tokens=$((words * 13 / 10))
    echo "$f: ~$tokens tokens"
done
```

**Commit message:** `chore(skills): split oversized rules.md files and narrow trigger overlaps`

---

## Summary

| Phase | Priority | Findings Addressed | Files Modified | Depends On |
|-------|----------|-------------------|----------------|------------|
| 1 | Critical | D5-001 (partial), D3-001 (partial) | 1 | — |
| 2 | Critical | D5-001 | 13 | Phase 1 |
| 3 | Critical | D7-001, D8-001 | 1 + symlink regeneration | — |
| 4 | Important | D7-002 | 1 | — |
| 5 | Important | D7-003, D1-002 | 6 | — |
| 6 | Important | D8-002, D8-003, D4-001, D1-001, D5-002 | ~30 | Phase 1 |
| 7 | Minor | D5-003, D6-001 | ~10 | — |

**Independent phases:** Phases 1-2 (validator + Write scoping) are a sequential chain. Phases 3, 4, and 5 are independent of each other and can run in parallel. Phase 6 depends on Phase 1 (validator must catch reclassified skills). Phase 7 is independent.

**Optimal execution order with parallelism:**

```
Phase 1 ──→ Phase 2 ──→ Phase 6
Phase 3 ──────────────────────────→ (parallel)
Phase 4 ──────────────────────────→ (parallel)
Phase 5 ──────────────────────────→ (parallel)
                                     Phase 7
```

**Total files modified:** ~60
**Total commits:** 7
