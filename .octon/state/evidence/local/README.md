# Local Evidence

This root is for local-private raw evidence that may help an operator debug,
redact, or reconstruct a repo-local run without publishing machine-local
details.

Allowed contents include raw execution logs, raw cleanup authorization details,
terminal transcripts, local file paths, temporary external payload captures, and
scratch material used to produce a publishable summary. Raw local evidence must
not be committed or used as a hosted/shared closeout artifact.

Forbidden consumers:

- runtime, policy, support, authority, closeout, archive, and generated-output
  gates
- generated read models and published registry projections
- hosted CI, release disclosure, or external support claims
- proposal packets, source inputs, host UI state, chat history, or model memory

Promotion route:

1. Summarize or redact the local material into a concise receipt outside this
   root.
2. Place the publishable receipt under the appropriate retained evidence root,
   such as `.octon/state/evidence/runs/**`,
   `.octon/state/evidence/control/execution/**`, or
   `.octon/state/evidence/validation/**`.
3. Cite the local material only by a relative local evidence path or logical id
   plus digest when the raw source must remain private.

Retention rule: keep local raw archives only while they are useful for local
debugging, redaction, or operator audit. Discard them only by explicit operator
cleanup decision or a policy-backed cleanup route that keeps local-private
evidence excluded from generic cleanup candidates and publishable closeout
claims.

This tracked README is the convention marker for the ignored local store. Raw
files under `.octon/state/evidence/local/**` are ignored by default.
