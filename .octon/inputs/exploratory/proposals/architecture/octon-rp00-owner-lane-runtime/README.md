# RP-00 Owner-Lane Runtime Boundary

This packet implements the trusted executor required by the accepted RP-00
containment protocol. The corrected runtime is a staged authority consumer: it
seals pre-issuance intent, captures one fine-grained PAT through an inherited
descriptor, writes token-specific lifecycle evidence before authenticated use,
performs admission-only reads, seals the admitted manifest and attestation,
executes the provider prefix, derives the provider-assigned PR binding, then
constructs and executes the typed suffix.

The packet extends the existing authority engine and GitHub control-plane
contract. It does not create a connector, daemon, credential broker, parallel
control plane, general GitHub client, recurring automation surface, or ambient
credential fallback.

Every provider request is journaled before send. Unknown outcomes permanently
deny resend. Token bytes remain outside chat, argv, environment, URLs, durable
files, logs, evidence, `gh`, SSH, and credential helpers. Terminalization uses
the same token, requires provider `401`, local destruction, an empty secret
census, and a retirement receipt.

Start with `navigation/source-of-truth-map.md`, then review the architecture,
validation, risk, and acceptance artifacts. Proposal artifacts are planning
inputs only and authorize no live provider action.
