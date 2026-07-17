# Current-State Gap Map

| Current state | Gap | Required change |
|---|---|---|
| Preauthorization binds manifest digest | Manifest is post-admission evidence, creating an impossible temporal dependency | Bind an independent operation-plan digest before issuance; generate manifest after admission |
| Admission receipt is a required input | Receipt asserts `200`, admitted, pagination, and prior authenticated success before the credential is read | Generate it from journaled live probes inside the executor |
| Credential tuple has four fields | Resource owner, selected repository, permissions, issuance provenance, expiry, deadline, and recovery locks are not representable | Add complete intended tuple and strict capture metadata |
| Manifest contains fixed resolved URLs/bodies | Provider assigns the PR number only after PR creation | Commit typed templates, reconcile PR identity, and resolve suffix from completed-prefix evidence |
| Completed-prefix receipt is output-only telemetry | It cannot supply authority-bound values to later requests | Make it the sole provider-assigned binding source for suffix construction |
| Existing secret transport and no-resend journal pass hermetic tests | Replacing them would add risk without solving the ordering defect | Preserve and reuse them unchanged where possible |
| Live support claim names the old monolithic protocol proof | Corrected staging changes the proven operation semantics | Refresh the same exact-operation proof only after staged hermetic validation |
