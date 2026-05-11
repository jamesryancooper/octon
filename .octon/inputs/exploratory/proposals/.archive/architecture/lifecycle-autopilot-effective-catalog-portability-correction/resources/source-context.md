# Source Context

_Status: Proposal-local source context_

This packet was created after review of the Governed Workflow Runtime transition
program found that the proposal artifacts were structurally valid but the
Lifecycle Autopilot route did not execute end-to-end.

## Observed Failure

Current lifecycle planning for the parent program fails with:

```text
Error: effective extension catalog pack octon-concept-integration declares lifecycle contracts without lifecycle-contract capability profile
```

The effective extension catalog entry for `octon-concept-integration` has an
empty `lifecycle_contracts: []` list and does not declare the
`lifecycle-contract` capability profile. Runtime lifecycle discovery currently
treats the existence of the lifecycle contract field as enough to require the
capability profile, rather than distinguishing an empty list from a non-empty
contract declaration.

## Observed Fallback

The Governed Workflow Runtime transition child packets include proposal-local
creation receipts stating that Lifecycle Autopilot CLI planning was attempted
but blocked by effective extension catalog validation, then packet creation
proceeded from canonical templates and lifecycle skill conventions.

## Observed Validator Portability Gap

The proposal registry generator uses Bash associative arrays. The proposal
standard validator invokes `bash` for registry checks. On systems where that
resolves to macOS Bash 3.2, registry checks can fail even when the packet and
registry are otherwise structurally valid. Under Bash 5, the same registry check
passes.

## Source Lineage Classification

This context is proposal-local evidence. It is not runtime authority, policy
authority, generated authority, or promotion evidence.
