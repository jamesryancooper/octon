# Target Architecture

_Status: Accepted child target architecture_

## Target State

1. Publishable receipts use `schema_version: publishable-evidence-receipt-v1` and `disclosure_tier: repo-publishable`.
2. Receipts include claim scope, source summary, validation summary, redactions, limitations, local evidence references, outcome, rollback or discard posture, and timestamp.
3. Local evidence references use both a relative local evidence path or logical id and a digest when raw evidence is cited but not published.
4. Publishable receipts are required for hosted/shared closeout and any claim intended to leave the local machine; purely local debugging runs may retain local-only evidence without a publishable claim.
5. Default concision policy warns above 64 KiB and fails above 256 KiB for a single publishable receipt unless an explicit schema field authorizes a larger claim bundle.

## Authority Boundary

This child may propose durable changes only under its promotion targets. It
must preserve the parent program's rule that local raw evidence, generated read
models, raw inputs, and proposal-local files do not satisfy evidence or closeout
gates.

## Non-Target State

The child does not target a clean-sheet evidence-store redesign, raw transcript
publication, generated-output authority, or parent-owned child receipt truth.
