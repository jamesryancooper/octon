# ADR 016: Assurance Charter Integration in Assurance Engine

## Status
Accepted

## Context
The Assurance Engine already governed weights, scores, overrides, and gating, but the Assurance Charter was not yet enforced as a first-class machine-validated contract.

## Decision
Make `/Users/jamesryancooper/Projects/octon/.octon/assurance/CHARTER.md` canonical and enforceable by:

- adding an explicit `charter` contract block in `/Users/jamesryancooper/Projects/octon/.octon/assurance/standards/weights/weights.yml`,
- validating charter/weights alignment in resolver and gate paths,
- embedding charter priority chain and trade-off rules into generated assurance outputs,
- requiring governed changelog + ADR + charter reference for charter/policy intent changes.

## Consequences
- Charter drift becomes detectable and reviewable in CI/local gates.
- Top-driver prioritization is deterministic with charter tie-break behavior.
- Policy changes that alter charter intent cannot be silently introduced.
