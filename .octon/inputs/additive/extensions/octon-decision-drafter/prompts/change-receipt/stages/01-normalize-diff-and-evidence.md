# Normalize Diff And Evidence

Normalize the diff source and retained evidence set.

## Do

1. Confirm that exactly one diff source is present.
2. Normalize `changed_paths`, deriving them from the diff when needed.
3. Normalize retained evidence refs and contextual refs.
4. Confirm the selected output mode and any explicit patch target.
5. Record any grounding gap before drafting starts.

## Stop When

- the diff source is missing or ambiguous
- no retained grounding can be established
- the requested patch target points at a blocked surface
