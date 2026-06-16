# Acceptance Criteria

1. The product feature catalog either includes an
   `architectural-review-mechanism` entry or the durable docs explain why the
   mechanism is intentionally excluded from product features.
2. The governed mechanism index and mechanism detail page cover all six review
   modes or explicitly classify omitted modes as outside the native mechanism.
3. `architecture-readiness-audit` remains canonical everywhere live runtime,
   skill, command, workflow, and generated projection surfaces reference the
   readiness mode.
4. `domain-architecture-audit` and `surface-architecture-audit` have either
   matching canonical invocation surfaces or explicit alias mappings to
   `audit-domain-architecture` and `audit-surface-architecture`.
5. Validators fail closed on undeclared mode aliases, missing mode coverage,
   stale readiness naming, missing product feature rationale, and command
   facade ambiguity.
6. Pre-integration architecture review remains the only architectural-review
   lifecycle gate for architecture proposal acceptance and implementation
   authorization.
7. Post-integration and current-state mechanism architecture reviews remain
   evidence-only unless a separate explicit lifecycle policy changes them.
8. Implementation conformance and post-implementation drift/churn remain
   separate hard closeout gates.
9. Generated capability projections and host projections are regenerated
   through canonical publication scripts.
10. Generated proposal registry and artifacts are regenerated through the
    canonical proposal registry script.
11. No generated, raw input, proposal-local, extension packetization, host,
    dashboard, chat, or model-memory surface is treated as authority.
12. Proposal standard, architecture proposal, implementation readiness,
    architectural review, governed mechanism, product feature, capability
    publication, generated artifact handle, proposal registry, conformance, and
    drift/churn validations pass before implemented closeout.
