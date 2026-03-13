# AE Spec Patch: Umbrella Chain Contract

## Patch Intent

Update the Assurance Engine specification so the only active priority chain is:

`Assurance > Productivity > Integration`

This patch is normative for:

- `.octon/assurance/CHARTER.md`
- `.octon/assurance/DOCTRINE.md`
- `.octon/assurance/standards/weights/weights.yml` (`charter` section)

## Normative Definitions

### 1) Priority Chain (Authoritative)

1. Assurance
2. Productivity
3. Integration

This order is the deterministic tie-break order when weighted attribute priority is equal.

### 2) Umbrella Definitions

Assurance:
Attributes that produce confidence, safety, correctness, and explainability of outcomes.

Productivity:
Attributes that maximize delivery throughput, low friction, and leverage, including bounded autonomy.

Integration:
Attributes that enable Octon to work across repos, environments, and tools.

### 3) Authoritative Primary Membership

Assurance:
`dependability`, `security`, `safety`, `reliability`, `availability`, `robustness`, `recoverability`, `auditability`, `observability`, `functional_suitability`

Productivity:
`autonomy`, `performance`, `scalability`, `simplicity`, `evolvability`, `maintainability`, `completeness`, `operability`, `testability`, `deployability`, `usability`, `accessibility`, `configurability`, `sustainability`

Integration:
`portability`, `interoperability`, `compatibility`

### 4) Design Constraints

- Attribute-level records remain the source of truth for scoring and gate evaluation.
- Umbrellas are derived rollups for ordering, reporting, and governance abstraction.
- Every attribute has exactly one primary umbrella.
- Secondary tags are optional metadata and never alter precedence unless explicitly configured.
- No compatibility support for old priority IDs or old-chain semantics.

## Autonomy Constraint (Productivity Attribute)

`autonomy` remains an attribute (not an umbrella).

Autonomy level guidance for scoring (deterministic):

| Level | Meaning | `autonomy` score cap without explicit evidence |
|---|---|---:|
| A0 | Assistive only | 1 |
| A1 | Drafting only | 2 |
| A2 | Reversible execution | 3 |
| A3 | Bounded side effects | 4 |
| A4/A5 | Chained or near-autonomous execution | 5 (only with policy + audit evidence) |

Rule:
Autonomy must never override Assurance guardrails (`security`, `safety`, `auditability`, `recoverability`).

## Spec Patch Snippet (Illustrative)

```yaml
# .octon/assurance/standards/weights/weights.yml
charter:
  version: "2.0.0"
  priority_chain:
    - id: assurance
      name: Assurance
    - id: productivity
      name: Productivity
    - id: integration
      name: Integration
  tie_break_rule: "When weighted priority ties, prefer higher umbrella rank: Assurance, then Productivity, then Integration."
  attribute_umbrella_map:
    security: assurance
    safety: assurance
    autonomy: productivity
    portability: integration
    interoperability: integration
    compatibility: integration
```

## Before/After Priority Output Example

Before:

```text
Priority chain: Trust > Speed of development > Ease of use > Portability > Interoperability
```

After:

```text
Priority chain: Assurance > Productivity > Integration
```
