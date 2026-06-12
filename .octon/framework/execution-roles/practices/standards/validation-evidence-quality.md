# Validation Evidence Quality

## Purpose

Make validation evidence prove behavior, boundaries, or support claims rather
than merely mirroring implementation details.

## Valid Evidence Classes

Validation evidence should identify which class it proves:

- behavior proof;
- boundary proof;
- architecture or placement proof;
- runtime authorization proof;
- dependency proof;
- deletion or ablation proof;
- generated-output freshness proof;
- compact validator-log proof;
- support-target or disclosure proof.

## Weak Evidence Patterns

Evidence is weak or insufficient when it:

- only asserts implementation text without exercising behavior;
- snapshots generated text without canonical source references;
- relies on proposal paths as policy or runtime authority;
- relies only on transport artifacts without retained evidence when retained
  evidence is required;
- claims behavior without lab, replay, scenario, shadow-run, or equivalent
  proof when the change class requires it;
- omits negative controls for support or boundary claims.

Compact validator-log proof is valid only when it records command, cwd,
canonical runtime, start time, end time, exit code, retained full-log digest
when available, bounded excerpts, and evidence ref. Compact logs are validation
evidence only; they do not replace schemas, receipts, canonical state, or
validator pass/fail results.

## Receipt

Record:

- claim being proven;
- validator, test, replay, scenario, or review evidence used;
- retained evidence location or reason retained evidence is not required;
- known gaps or `none`.
