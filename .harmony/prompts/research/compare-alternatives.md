---
title: Compare Alternatives
description: Evaluate multiple options against defined criteria for decision-making.
access: human
---

# Compare Alternatives

## Context

Use this prompt when research has identified multiple alternatives (tools, approaches, architectures, etc.) that need systematic comparison. Helps structure evaluation and surface trade-offs.

## Inputs

- **Alternatives:** List of options to compare (2-5 recommended)
- **Criteria:** Evaluation dimensions (or ask to derive from research context)
- **Weights:** (Optional) Relative importance of each criterion
- **Context:** Research project path or decision context

## Instructions

1. **Define alternatives clearly**
   - List each alternative with a brief description
   - Ensure alternatives are comparable (same category)
   - Note any that should be excluded and why

2. **Establish criteria**
   - If not provided, derive from research goals and constraints
   - Ensure criteria are measurable or assessable
   - Assign weights if some criteria matter more

3. **Gather evidence**
   - For each alternative, collect data on each criterion
   - Note source of information (research notes, documentation, testing)
   - Flag where evidence is weak or missing

4. **Score and analyze**
   - Rate each alternative on each criterion
   - Calculate weighted scores if applicable
   - Identify clear winners and close calls

5. **Surface trade-offs**
   - What do you give up with each choice?
   - Are there deal-breakers for any option?
   - What assumptions affect the comparison?

6. **Recommend**
   - Provide a recommendation with rationale
   - Note conditions that might change the recommendation
   - Suggest validation steps if uncertainty is high

## Output

```markdown
## Comparison: [Decision topic]

### Alternatives

| Alternative | Description |
|-------------|-------------|
| [Option A] | [Brief description] |
| [Option B] | [Brief description] |
| [Option C] | [Brief description] |

### Evaluation Criteria

| Criterion | Weight | Description |
|-----------|--------|-------------|
| [Criterion 1] | [1-5] | [What we're measuring] |
| [Criterion 2] | [1-5] | [What we're measuring] |

### Comparison Matrix

| Criterion | [Option A] | [Option B] | [Option C] |
|-----------|------------|------------|------------|
| [Criterion 1] | [Score + notes] | [Score + notes] | [Score + notes] |
| [Criterion 2] | [Score + notes] | [Score + notes] | [Score + notes] |
| **Weighted Total** | [X] | [Y] | [Z] |

### Trade-off Analysis

#### [Option A]
- **Strengths:** [What you gain]
- **Weaknesses:** [What you give up]
- **Best when:** [Conditions favoring this option]

#### [Option B]
...

### Recommendation

**Recommended:** [Option X]

**Rationale:** [Why this option wins given the criteria and context]

**Caveats:**
- [Condition that might change this]
- [Assumption to validate]

**Next steps to validate:**
1. [Validation action]
2. [Validation action]
```
