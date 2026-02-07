# Skills Audit with Diminishing Returns Exclusion

Analyze the architecture and content of @.harmony/skills and @.workspace/skills to ensure alignment with Harmony's pillars, principles, and production readiness, as well as alignment with Agent Skills spec (<https://agentskills.io/specification>).

## Evaluation Framework

### 1. Pillar Alignment

- Direction: Are skill purposes validated and well-scoped?
- Focus: Does the architecture absorb complexity effectively? Is cognitive load minimized?
- Velocity: Does the structure enable fast skill discovery, execution, and creation?
- Trust: Are tool permissions bounded? Is behavior deterministic and predictable?
- Continuity: Is knowledge captured in appropriate locations?
- Insight: Does logging enable learning from skill executions?

### 2. Principle Compliance

| Principle | Evaluation Questions |
|-----------|---------------------|
| **Progressive Disclosure** | Is the four-tier model (manifest → registry → SKILL.md → references) implemented correctly? Are token budgets respected (~50 tokens/manifest entry, <5000 tokens/SKILL.md)? |
| **Single Source of Truth** | Is each piece of metadata defined in exactly one location? Are there any duplicate definitions that could drift? Is `allowed-tools` in SKILL.md the sole source for tool permissions? |
| **Locality** | Does context live close to where it's needed? Is the two-tier architecture (shared `.harmony/` vs local `.workspace/`) correctly separating concerns? |
| **Simplicity Over Complexity** | Are there unnecessary abstractions, configuration options, or indirection? Could anything be simpler without losing functionality? |
| **Deny by Default** | Are tool permissions explicit allowlists? Are output paths constrained to designated directories? |
| **Determinism** | Will the same inputs produce the same routing decisions? Are there any sources of non-determinism in discovery or execution? |

### 3. Specification Compliance

Verify alignment with <https://agentskills.io/specification>:

- Required frontmatter (`name`, `description`) present in all SKILL.md files
- Optional fields (`license`, `compatibility`, `metadata`, `allowed-tools`) used correctly
- Directory structure follows spec (`references/`, `scripts/`, `assets/`)
- SKILL.md files under 500 lines (details in `references/`)
- Name matches directory name
- Extensions documented and justified

### 4. Quality Attributes

| Attribute | Evaluation Criteria |
|-----------|---------------------|
| **Clarity** | Is purpose obvious from file names, structure, and content? |
| **Understandability** | Can a new developer understand the system from START.md and manifest? |
| **Maintainability** | Are files organized for easy updates? Is there clear ownership? |
| **Robustness** | Does validation catch invalid configurations? Are error cases handled? |
| **Efficiency** | Is discovery fast? Are token budgets respected? |
| **Scalability** | Will the architecture handle 10+ skills without degradation? |
| **Usability** | Is skill invocation intuitive (triggers, commands, explicit calls)? |

### 5. Risk Assessment

**Drift Risk:**

- Identify any data that exists in multiple locations
- Check for derived data that could become stale
- Verify mapping functions are comprehensive

**Cognitive Complexity:**

- Count configuration files required to understand a skill's behavior
- Identify any unnecessary indirection
- Flag files whose purpose is unclear

**Ambiguity:**

- Identify conflicting or unclear guidance
- Check for overlapping trigger patterns
- Verify commands are unique across skills

## Notes

The complexities introduced by the Two Registries design, Reference File Tier System, and Host Adapter Symlinks are acceptable to us because the number of skills will grow significantly once the skills system has been finalized, and the system will be well positioned to handle this.

## Output Format

Provide analysis in these sections:

1. **Alignment Summary**: Overall assessment against pillars and principles (pass/partial/fail per item)

2. **Conformance Issues**: Specific violations of spec, principles, or best practices

3. **Drift Risks**: Locations where data could become inconsistent

4. **Complexity Concerns**: Areas where simplification would improve maintainability

5. **Recommendations**: Prioritized list of improvements that are:
   - Pragmatic (actionable with clear benefit)
   - Highly beneficial (significant impact on quality attributes)
   - Necessary (address actual risks, not theoretical concerns)
   - Aligned with Agent Skills spec and Harmony principles
   - Minimal (do not introduce new cognitive complexity or drift risk)

   **Omit recommendations that offer diminishing returns:**
   - Skip suggestions where implementation effort significantly outweighs the benefit
   - Do not recommend changes that optimize for unlikely edge cases
   - Avoid perfectionist improvements when current state is "good enough" for practical use
   - Do not suggest additional validation, tooling, or process when manual review suffices at current scale
   - Prefer "accept current state" over low-ROI refactoring

## Additional Context

Reference documentation:

- @docs/architecture/workspaces/skills (implementation details)
- @.harmony/skills
- @.workspace/skills
- @docs/principles (principle definitions)
- @docs/pillars (pillar definitions)
- <https://agentskills.io/specification>
