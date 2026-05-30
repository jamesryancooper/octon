# Target Architecture

_Status: Accepted child target architecture_

## Target State

1. Private raw execution logs, raw cleanup authorization details, machine paths, local transcripts, and external payload scratch material live under `.octon/state/evidence/local/**`.
2. The ignore rule is implemented as `.octon/state/evidence/.gitignore` so the child remains `octon-internal` and avoids repo-root target-family mixing.
3. Local evidence may support debugging and redaction but cannot satisfy hosted/shared closeout by itself.
4. Repo-hygiene policy classifies the local root as local-only retained debugging material unless a child-owned receipt promotes a publishable summary.

## Authority Boundary

This child may propose durable changes only under its promotion targets. It
must preserve the parent program's rule that local raw evidence, generated read
models, raw inputs, and proposal-local files do not satisfy evidence or closeout
gates.

## Non-Target State

The child does not target a clean-sheet evidence-store redesign, raw transcript
publication, generated-output authority, or parent-owned child receipt truth.
