# Skills System Post-Remediation: 4-Tier Completion Plan

## Context

The skills system audit (2026-02-10) identified critical issues that were remediated across 7 phases. The remediation summary reports EXIT 6 with 6 errors and 67 warnings. However, deep code analysis reveals:

1. **The validator itself has bugs** producing false positives — the `REPO_ROOT` path calculation is wrong (off by one `dirname` level), causing `SKILLS_REGISTRY` to resolve to a doubled `.harmony/.harmony/...` path. This breaks 11+ validation checks and generates cascading warnings.
2. **Orphaned directory detection** flags valid group directories (`foundations/`, `platforms/`, etc.) as orphaned because it only checks top-level dirs against manifest `id:` fields.
3. **The allowed-tools mapping is actually correct** — `split_allowed_tools()` (line 386) properly handles parenthesized tokens with spaces, and all token types have case branches. The 6 errors reported in the remediation summary likely stem from the REPO_ROOT cascade, not from allowed-tools mapping.

Fixing the validator first is critical because it's the feedback loop for all subsequent work.

---

## Tier 1: Fix the Validator (unblocks everything)

### 1A. Fix `REPO_ROOT` path calculation

**File:** `.harmony/capabilities/skills/scripts/validate-skills.sh`
**Lines:** 67-73

**Current (broken):**
```bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILLS_DIR="$(dirname "$SCRIPT_DIR")"
HARMONY_DIR="$(dirname "$SKILLS_DIR")"        # ← .harmony/capabilities (mislabeled)
REPO_ROOT="$(dirname "$HARMONY_DIR")"          # ← .harmony (wrong, should be project root)
```

**Fix:** Add proper intermediate variables matching the actual directory hierarchy:
```
{repo_root}/.harmony/capabilities/skills/scripts/  ← SCRIPT_DIR
{repo_root}/.harmony/capabilities/skills/           ← SKILLS_DIR
{repo_root}/.harmony/capabilities/                  ← (intermediate)
{repo_root}/.harmony/                               ← HARMONY_DIR (actual .harmony dir)
{repo_root}/                                        ← REPO_ROOT
```

**Change to:**
```bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILLS_DIR="$(dirname "$SCRIPT_DIR")"
HARMONY_DIR="$(dirname "$(dirname "$SKILLS_DIR")")"   # .harmony/
REPO_ROOT="$(dirname "$HARMONY_DIR")"                  # project root
```

This automatically fixes `SKILLS_REGISTRY` on line 73 since it derives from `REPO_ROOT`.

**Impact:** Fixes 11+ downstream checks that depend on SKILLS_REGISTRY (I/O mapping validation, path scope validation, placeholder format checks, etc.).

### 1B. Fix orphaned directory detection

**File:** `.harmony/capabilities/skills/scripts/validate-skills.sh`
**Lines:** 2218-2231

**Current:** Iterates top-level `$SKILLS_DIR/*/` directories, skips only `_template` and `scripts`, flags everything else not matching a manifest `id:`.

**Problem:** Group directories (`foundations/`, `platforms/`, `quality-gate/`, `synthesis/`, `meta/`) and infrastructure directories (`archive/`, `configs/`, `logs/`, `resources/`, `runs/`) are falsely flagged.

**Fix:** Build a skip list from known infrastructure dirs + group names extracted from the manifest:

```bash
# Known infrastructure directories
local infra_dirs="_template scripts archive configs logs resources runs"

# Extract unique group names from manifest
local group_dirs
group_dirs=$(awk '/group:/{gsub(/.*group: */, ""); gsub(/[[:space:]]*$/, ""); print}' "$MANIFEST" | sort -u)

for dir in "$SKILLS_DIR"/*/; do
    dir_name=$(basename "$dir")
    if echo "$infra_dirs" | grep -qw "$dir_name"; then continue; fi
    if echo "$group_dirs" | grep -qw "$dir_name"; then continue; fi
    if ! grep -q "id: $dir_name" "$MANIFEST"; then
        log_warning "Directory '$dir_name' exists but not listed in manifest"
    fi
done
```

### 1C. Run validator and establish clean baseline

After fixes, run the validator and record the new error/warning counts. The expected outcome:
- REPO_ROOT-related warnings eliminated (~21 "Skills registry not found" warnings gone)
- Orphaned directory false positives eliminated (~5-10 warnings gone)
- Remaining issues are genuine and actionable

**Verification:** `bash .harmony/capabilities/skills/scripts/validate-skills.sh 2>&1 | tail -10`

---

## Tier 2: Address Legitimate Warnings

*Execute after Tier 1 establishes a clean baseline.*

### 2A. Triage remaining warnings by category

Run validator, categorize output into:
- Token budget warnings (manifest entries, reference files, aggregate complexity)
- Description/summary alignment warnings
- Duplicate trigger warnings (if any remain)
- Table drift warnings (duplicated parameter/tool tables in SKILL.md)
- Version staleness warnings
- Any genuine allowed-tools errors

### 2B. Fix description/summary alignment

**Priority: react-best-practices rule count discrepancy.**

The manifest says "57 React/Next.js performance rules" but the SKILL.md description says "40+ rules." Verify the actual count by reading the skill content, then align both to the correct number.

Other skills with minor wording drift (audit-migration, spec-to-implementation, build-mcp-server) — update manifest summaries to better reflect SKILL.md descriptions where the description is more precise.

### 2C. Optimize manifest token budgets

The validator's `MANIFEST_ENTRY_TOKEN_BUDGET` is 100 tokens (line 81). The manifest header comments aspire to ~50 tokens/entry. Three skills significantly exceed 100 tokens:
- `triage-ci-failure` (~70+ tokens, 6 triggers)
- `audit-migration` (~68 tokens, 5 triggers)
- `audit-ui` (~64 tokens, 6 triggers)

**Fix:** Trim triggers for these skills to 3-4 per skill, removing semantic duplicates:
- `triage-ci-failure`: Keep "triage CI failure", "fix CI", "debug build failure" — drop "CI is failing", "fix the build", "tests are failing in CI"
- `audit-ui`: Keep "audit the UI", "check UI guidelines", "review accessibility" — drop "review interface design", "web design audit", "check design compliance"

### 2D. Address duplicate triggers (if any remain)

The current manifest appears to have no exact duplicate triggers between vercel and vercel-deploy (remediation resolved this). Validate by running the trigger overlap check and confirming zero duplicates.

### 2E. Review build-mcp-server broad permissions

`build-mcp-server` uses unscoped `Write` and `Bash` in allowed-tools. If this is intentional (it scaffolds files across the project), add a comment. If not, scope to specific paths.

---

## Tier 3: End-to-End Stretch Skill Validation

*Execute after Tier 2 resolves all warnings/errors.*

### 3A. Create a new skill that exercises new capabilities

Use `/create-skill` to scaffold a skill that declares `external-output` or `long-running` capability (the newly added capabilities from Phase 6 of the remediation).

**Suggested skill:** A simple `deploy-status` skill that checks deployment status (exercises `external-output` + `external-dependent`).

### 3B. Validate the full pipeline

1. Scaffold creates correct directory structure with grouped path
2. Manifest entry is added with correct group/path
3. Registry entry is added
4. Capability resolution produces correct reference files (including new `external-outputs.md`)
5. Validator passes with EXIT 0 for this skill
6. Reference files contain meaningful, customized content (not just template placeholders)

### 3C. Remove or mark as draft after validation

If the stretch skill isn't needed long-term, either delete it or set `status: draft` to keep it as a reference implementation without routing to it.

---

## Tier 4: Track Deferred Items

*No implementation — documentation only.*

### 4A. Create a deferred-items tracking file

Create `.harmony/output/reports/2026-02-10-deferred-items.md` listing:

1. **Parameter types**: `number`, `enum`, `list`, `object`, `secret` — add when a skill needs non-text input
2. **I/O kinds**: `api`, `database`, `stream` — add when a skill produces non-file outputs beyond URLs
3. **Trigger patterns**: regex/intent matching — add when catalog exceeds ~50 skills and NL triggers lose precision
4. **Dependency model**: optional deps, version constraints, cycle detection — add when cross-skill dependencies become common
5. **New skill sets**: `observer`, `notifier`, `generator` — add when concrete skills need patterns not covered by existing 7 sets
6. **New capabilities**: `adaptive`, `feedback-aware`, `multimodal-input`, `multimodal-output`, `streaming-output`, `secret-handling`, `security-scanning` — add when concrete skills need them

Each item should include:
- What it is
- Why it was deferred (no concrete skill needs it yet)
- What would trigger its addition (a specific skill requirement)

---

## Files Modified

| Tier | File | Change |
|------|------|--------|
| 1A | `validate-skills.sh:67-73` | Fix REPO_ROOT/HARMONY_DIR path calculation |
| 1B | `validate-skills.sh:2218-2231` | Skip group + infra dirs in orphan check |
| 2B | Multiple SKILL.md + manifest.yml | Align descriptions/summaries |
| 2C | `manifest.yml` | Trim triggers for 3 high-token skills |
| 3A | New skill directory + manifest + registry | Stretch skill scaffold |
| 4A | `.harmony/output/reports/` | New deferred-items tracking file |

## Verification

After each tier:
- **Tier 1:** Run `validate-skills.sh` — expect significant error/warning reduction. Target: 0 errors from validator bugs.
- **Tier 2:** Run `validate-skills.sh` — target: 0 errors, minimal warnings (only informational).
- **Tier 3:** Run `validate-skills.sh <new-skill-id>` — target: EXIT 0 for the new skill.
- **Tier 4:** No validation needed — documentation only.

Final target: `validate-skills.sh` exits 0 with zero errors and only intentional informational warnings.
