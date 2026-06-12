# Validator Runtime Resolution

## Purpose

Validator/runtime resolution is validation hygiene. It helps operators find the
canonical repo-local validator and compatible runtime before deciding that a
gate is blocked. It never weakens the gate and never authorizes mutation,
closeout, archive, publication, or support widening.

## Rules

1. Prefer repo-local validators under
   `.octon/framework/assurance/runtime/_ops/scripts/`.
2. Use the shell or runtime expected by the validator contract. Shell
   validators should be invoked through `bash` unless their contract says
   otherwise.
3. If an initial command fails because the path, shell, or runtime was wrong,
   record the failed invocation and the corrected canonical invocation in the
   retained validation evidence.
4. Do not replace a missing validator with chat, host state, generated output,
   dashboard state, model memory, or proposal-local analysis.
5. Do not waive a lifecycle gate because the validator was hard to locate.
   Escalate only when the canonical validator is missing, malformed, or outside
   the current authorized scope.

## Compact Log Evidence

Long validator logs may be represented by a compact log artifact when the
artifact records command, cwd, canonical runtime path, start time, end time,
exit code, full-log digest when retained, bounded excerpts, and evidence ref.
Compact logs are validation evidence only. They do not replace schemas,
receipts, canonical state, or validator pass/fail results.
