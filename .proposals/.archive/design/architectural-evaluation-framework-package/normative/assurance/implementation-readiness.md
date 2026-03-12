# Implementation Readiness

## Status

- current status: `draft`

## Package Readiness Definition

This package becomes implementation-ready only when engineers can derive, from
the package alone, the required target classification rules, runtime surfaces,
output contract, failure-mode model, and first implementation slice without
inventing architecture.

## Future Live Framework Readiness

The live framework is ready when:

1. supported and unsupported target classes are enforced deterministically
2. whole-harness and bounded-domain modes both work
3. outputs include score summary, hard-gate failures, failure-mode assessment,
   and exact remediation artifacts
4. live methodology and ADR pattern stand on their own without references back
   to this package

## Remaining Work

- materialize methodology docs in `/.harmony/cognition/practices/`
- implement the primary audit skill
- implement the orchestration workflow
- promote the ADR matrix into scaffolding governance patterns
