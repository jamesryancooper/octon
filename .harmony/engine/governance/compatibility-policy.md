# Compatibility Policy

## Clean-Break Default

Engine migrations are clean-break by default: no compatibility shims, no dual-mode execution, and no transitional flags.

## Constraints

- Legacy runtime paths and contracts are removed in the same change set.
- If behavior continuity is needed, it is reimplemented in the new authority path.
- Exceptions require explicit approval under repository migration exception policy.
