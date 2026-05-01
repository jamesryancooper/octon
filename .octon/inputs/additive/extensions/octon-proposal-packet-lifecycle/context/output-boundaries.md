# Output Boundaries

## Packet Support Artifacts

Generated packet-specific operational artifacts belong under the packet being
operated on:

```text
resources/
  source-context.md
  source-evaluation.md
  source-audit.md

support/
  proposal-packet-creation-prompt.md
  executable-implementation-prompt.md
  follow-up-verification-prompt.md
  custom-closeout-prompt.md
  correction-prompts/
  executable-program-implementation-prompt.md
  follow-up-program-verification-prompt.md
  program-correction-prompts/
  custom-program-closeout-prompt.md
  child-closeout-prompts/
```

`resources/**` preserves source lineage. `support/**` preserves operational
aids. Neither location becomes authority.

Packet directories should be directly usable as structured Markdown proposal
packages. Do not create zip files, downloadable build products, or other
incidental output artifacts unless the operator explicitly asks for an export
format and the artifact is excluded from authority claims.

## Durable Outputs

Durable behavior lands only in extension source, selected extension state,
generated effective extension and capability outputs, host projections,
validators, and retained evidence. Proposal packet paths are temporary inputs
or historical provenance only.
