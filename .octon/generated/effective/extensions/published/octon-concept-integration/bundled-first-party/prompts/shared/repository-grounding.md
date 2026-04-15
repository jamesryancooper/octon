# Repository Grounding Contract

This file is the single source of truth for shared repository-grounding rules
across the `octon-concept-integration` prompt-bundle family.

## Base Anchor Contract

Each bundle manifest under `prompts/<bundle>/manifest.yml` is the source of
truth for that bundle's base repo anchor list under `required_repo_anchors`.

Every stage and companion prompt must:

- inspect those base anchors before making current-state claims,
- treat them as the default starting point unless the user explicitly narrows
  the starting point,
- and add only stage-specific extra inspections rather than redefining the
  base list inline.

## Precedence And Drift

- The live checked-out repository outranks stale prompt text, prior runs,
  earlier packets, generated views, and thread-local summaries.
- Octon's canonical authority, control, evidence, and governance surfaces take
  precedence over external sources and over prompt-set assumptions whenever
  they conflict.
- Treat Octon as non-steady-state: assume related concepts, gaps, or packet
  assumptions may have changed since any earlier extraction, verification,
  packetization, or implementation run.
- If live repo inspection materially changes an earlier assumption, record the
  stage-appropriate drift note and proceed from observed repo state.

## Shared Repository Assumptions To Verify

Assume the following are binding unless live repo inspection proves
divergence:

- Octon uses one `/.octon/` super-root with canonical class roots:
  `framework/`, `instance/`, `inputs/`, `state/`, and `generated/`.
- Only `framework/**` and `instance/**` are authored authority.
- `state/**` is authoritative only as mutable operational truth and retained
  evidence.
- `generated/**` is derived-only and never source of truth.
- Raw `inputs/**` must never become a direct runtime or policy dependency.
- Proposal packets are exploratory lineage under
  `/.octon/inputs/exploratory/proposals/**` and must not be treated as durable
  authority.
- Host and model adapters may shape execution but never mint authority.

## Shared Anti-Patterns

Reject or correct any instruction path that would:

- create a second authoritative control plane,
- make chat, session, or app memory canonical,
- turn raw `inputs/**` into runtime or policy truth,
- make generated views authoritative,
- let host or model adapters mint authority,
- widen support claims without explicit governance, evidence, and disclosure
  treatment,
- or treat proposal packets, exploratory notes, or generated summaries as if
  they were already implemented capability.
