# Target Architecture

_Status: Accepted child target architecture_

## Target State

1. A normative tier contract names exactly four tiers: private raw evidence, repo-publishable claim evidence, operator/release disclosure, and generated read models.
2. The contract preserves `.octon/state/evidence/runs/**` as canonical retained run evidence while narrowing its publishable role to concise claim evidence.
3. The contract defines `.octon/state/evidence/local/**` as private raw evidence that is local-only and ignored by default.
4. The contract keeps `.octon/state/evidence/disclosure/**` subordinate to evidence and `.octon/generated/**` derived-only.
5. Promotion from local raw evidence to publishable evidence requires transformation: summarization, redaction, limitations, validation summary, and receipt metadata.

## Authority Boundary

This child may propose durable changes only under its promotion targets. It
must preserve the parent program's rule that local raw evidence, generated read
models, raw inputs, and proposal-local files do not satisfy evidence or closeout
gates.

## Non-Target State

The child does not target a clean-sheet evidence-store redesign, raw transcript
publication, generated-output authority, or parent-owned child receipt truth.
