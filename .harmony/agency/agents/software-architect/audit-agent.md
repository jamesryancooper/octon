# Audit Agent

Review ONLY [agent.md](./agent.md)

Goal: find all remaining MATERIAL issues that reduce flexibility/adaptability or create directive tension.

Exclude minor wording/calibration issues.

Method (mandatory):

1) Run a full pass across these lenses:

- precedence/conflict
- ambiguity/interpretability
- stack-agnostic flexibility
- archetype parity
- automation/autonomy compatibility
- risk/mode/output consistency
- operational practicality
- safety/compliance interaction
- polyglot/systems-runtime risks
- internal redundancy/contradiction

2) For each lens, explicitly output either:

- “No material issue”, or
- findings with line refs.

3) Then run a second adversarial pass to find what pass #1 missed.
4) Then run a rebuttal pass to try to disprove each finding.
5) Return only findings that survive rebuttal with confidence >= 0.8.

Output format:

- Findings first, ordered by severity (P1/P2 only), with:
  - title
  - file + line
  - why it materially impacts flexibility/adaptability
  - minimal fix
- Coverage matrix: each lens -> covered / no issue / issue found.
- Rejected candidates: potential issues dropped and why.
- Final status: NO_NEW_FINDINGS only if all lenses covered and no surviving P1/P2 issues.
