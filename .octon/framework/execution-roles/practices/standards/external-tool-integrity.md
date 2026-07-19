# External Tool Integrity

## Authority Posture

This standard projects constitutional rule `NK-016` and fail-closed rule
`FCR-039`. Detailed machine policy lives at
`.octon/instance/governance/policies/external-tool-integrity.yml`.

## Rule

Treat every external tool as an immutable dependency.

Never recommend, propose, require, or implement an Octon solution that depends
on forking, patching, modifying, reengineering, or maintaining a private
derivative of an external tool. This includes tools such as Codex, provider
clients, host CLIs, runtimes, services, and upstream repositories.

Every required behavior must be implemented inside Octon's own architecture
and codebase.

## Allowed Integration

Octon may:

- use external documentation or source as design evidence;
- invoke documented APIs, CLIs, protocols, configuration, extension points,
  and operating-system interfaces;
- pin or select an unmodified supported version;
- wrap, mediate, sandbox, constrain, or observe the external tool from
  Octon-owned code;
- replace one unmodified tool with another when existing Octon contracts allow
  the substitution; and
- record an upstream feature request as optional, nonblocking context.

External evidence may inform Octon but cannot become Octon authority.

## Prohibited Strategies

- an Octon-maintained external-tool fork;
- source patches, binary patches, monkey patches, or private derivatives;
- reengineering an external tool to add an Octon-specific control surface;
- depending on undocumented private internals as the integration contract;
- making an upstream maintainer change a prerequisite for Octon acceptance,
  readiness, implementation, or support; and
- describing external modification as the practical fallback when an Octon
  design is difficult.

## Required Recommendation Behavior

When an external limitation is encountered:

1. Treat the limitation as a fixed design constraint.
2. Search for an Octon-owned wrapper, adapter, broker, sandbox, policy,
   configuration, validation, or workflow solution using supported interfaces.
3. If no sound Octon-owned solution exists, reduce scope or record a blocker.
4. Do not transfer the implementation obligation to the external tool or its
   maintainers.

## Review And Evidence

Recommendations, proposals, and reviews involving external tools must state:

- the external tool and supported interface;
- the Octon-owned enforcement or adaptation surface;
- the proof that the tool remains unmodified;
- the proof that no upstream change is an acceptance dependency; and
- the fail-closed outcome when the supported interface is insufficient.

Architecture-review receipts emitted after the policy effective time must
record `mode_specific_coverage.external_tool_integrity`.
