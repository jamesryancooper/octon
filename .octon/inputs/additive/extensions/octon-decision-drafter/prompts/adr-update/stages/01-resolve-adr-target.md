# Resolve ADR Target

Resolve the ADR target and normalize the drafting inputs.

## Do

1. Confirm that exactly one diff source is present.
2. Normalize `changed_paths`, deriving them from the diff when needed.
3. Resolve the ADR target from `adr_ref` when present.
4. When `adr_ref` is absent, infer at most one candidate ADR from the changed
   paths and cited decision context. If the candidate set is ambiguous, stop.
5. Normalize retained evidence refs and record any missing grounding.

## Stop When

- no ADR target can be resolved confidently
- the diff source is missing or ambiguous
- the request would require automatic edits to ADR discovery indexes or
  evidence bundles
