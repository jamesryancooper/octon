# RP-00 Owner-Lane Runtime Boundary

This packet implements the missing trusted executor required by the accepted
RP-00 containment protocol. It extends the existing authority engine and GitHub
control-plane contract; it does not create a connector, daemon, credential
broker, parallel control plane, or broad GitHub automation surface.

Because the current live GitHub tuple is explicitly proven only for protected-
CI merge, this packet also performs one bounded evidence-backed expansion of
that same tuple. The expansion names only the exact owner-lane operation and is
invalid unless a retained full runtime run against a hermetic GitHub fixture,
all denial cases, and support validators pass. It does not admit a general API
client.

The runtime accepts only a strict, review-bound manifest and an exact
fine-grained PAT supplied through an inherited file descriptor. It removes
ambient GitHub credentials, `gh`, SSH, token arguments, token environment
variables, and persistent secret storage from the eligible path. Every
provider mutation consumes `AuthorizedEffect<ProviderRepositoryMutation>` and
is journaled before send. An unknown outcome blocks resend and enters
reconciliation. Terminalization uses GitHub's unauthenticated exposed-
credential revocation endpoint, then requires a genuine same-token `401`, local
destruction, and a retirement receipt.

Start with `navigation/source-of-truth-map.md`, then review the architecture,
validation, risk, and acceptance artifacts. Proposal artifacts are planning
inputs only.
