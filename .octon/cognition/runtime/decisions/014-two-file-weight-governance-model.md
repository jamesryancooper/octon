# ADR 014: Two-File Assurance Weight Governance Model

- Date: 2026-02-18
- Status: accepted

## Context

Assurance policy weights changed infrequently, while measured subsystem scores change often. Storing both in one mutable structure creates noisy governance churn and weakens traceability for policy intent.

## Decision

Adopt a split model:

- Policy weights in `/Users/jamesryancooper/Projects/octon/.octon/assurance/standards/weights/weights.yml`
- Measurement scores in `/Users/jamesryancooper/Projects/octon/.octon/assurance/standards/scores/scores.yml`
- One deterministic resolver computes effective weights and weighted results using precedence:
  `global -> run-mode -> subsystem -> maturity -> repo`
- Name this capability the **Assurance Engine**.
- Treat the Assurance Engine as an **authoritative local engine**: repo-local policy/scores are canonical; local/CI execution is the enforcement authority.

## Consequences

- Policy changes are change-controlled with version bump + changelog rationale + ADR reference.
- Score updates remain lightweight but must include evidence for low scores and high-weight regressions.
- Existing scorecard outputs are retained for backward compatibility while adding effective/results markdown outputs.
- External services can aggregate/report across repos, but must not replace local deterministic resolution and gate enforcement.
