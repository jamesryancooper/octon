# Target Architecture

_Status: Accepted child target architecture_

## Target State

1. Validators fail tracked files under `.octon/state/evidence/local/**` except explicitly allowed marker files if any are defined.
2. Validators fail publishable evidence missing `disclosure_tier` or required publishable receipt fields.
3. Validators warn above 64 KiB and fail above 256 KiB for a single publishable receipt unless an explicit exception field is present.
4. Validators fail hosted/shared closeout when the claim requires local-only evidence to be present.
5. Negative controls prove generated read models and local raw evidence do not satisfy evidence gates.

## Authority Boundary

This child may propose durable changes only under its promotion targets. It
must preserve the parent program's rule that local raw evidence, generated read
models, raw inputs, and proposal-local files do not satisfy evidence or closeout
gates.

## Non-Target State

The child does not target a clean-sheet evidence-store redesign, raw transcript
publication, generated-output authority, or parent-owned child receipt truth.
