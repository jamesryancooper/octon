# Generate Verification Prompt

Build a verification prompt that checks implementation against manifests,
acceptance criteria, implementation plan, validation plan, promotion targets,
evidence expectations, and residual risks. Require findings to use stable ids,
severity, affected paths, evidence, expected behavior, correction scope, and
acceptance criteria.

The verification prompt must re-ground against the current repository state and
separate implemented durable outputs from proposal-local claims. It must check
that required generated/runtime surfaces and retained evidence exist when the
packet depends on them, durable targets no longer depend on active proposal
paths, and no prompt, generated projection, GitHub surface, external tool, or
chat context is treated as authority.

If the packet or source material requires closure certification, include the
required validator pass count, no-new-finding rule, and two-consecutive-clean
pass requirement. The prompt must return `clean`, `corrections-needed`,
`needs-packet-revision`, `blocked`, `superseded`, or `explicitly-deferred`
instead of using ambiguous success language.
