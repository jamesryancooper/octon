# Authority, Effect, and Credential Map

## Current map

| Surface | Can decide or assert authority | Can launch or mutate | Credential or privileged context | Current boundary | Target disposition |
|---|---|---|---|---|---|
| authority_engine | Yes, canonical authorize_execution and typed issuance | Selected runtime effects | No provider credential required by core | Strong validation, file-backed consumption | Preserve semantics; move operation/token state into SQLite transaction |
| lifecycle authorizer | Yes, request-local admission and DelegationProof | Gates Codex, Claude, workflow dispatch | Inherits caller context indirectly | Competing descriptive authority | Demote to validation only; require canonical launch guard |
| lifecycle adapter | No independent policy, but owns dispatch | Spawns child processes | Inherited HOME, env, Git context, network posture | No structural typed guard | Replace raw spawn with isolated guard-consuming launcher |
| Codex child | Model-driven | Workspace writes and tools | Writable Codex home; deployment network enabled | Canonical checkout, no credential scrub | Disposable credentialless sandbox and isolated Git |
| Claude child | Model-driven | Repository edits and shell according to host config | Inherited environment and user state | No explicit launcher sandbox flag | Same credentialless isolation contract |
| policy-grant-broker.sh | Emits/serves policy grant artifacts | File state only | No durable-effect custody role found | Name suggests broader broker than implementation | Rename/merge as policy helper; do not create second broker |
| hosted no-PR authorizer | Yes, self-emits approved JSON | Prepares landing authorization | Ambient shell context | Self-attested, repository-mutable | Replace with canonical broker reservation |
| hosted no-PR landing script | Validates receipt fields | Direct git push to main | Git credential helper/transport context | Unsanitized direct effect | Move into broker Git adapter |
| GitHub Actions required checks | Reports check results | Gates default-branch update | GITHUB_TOKEN read context | Candidate-controlled workflow/scripts | Base-owned or separately pinned verifier |
| pr-auto-merge workflow | Evaluates and auto-merges | Contents and pull-request writes | AUTONOMY_PAT or GITHUB_TOKEN | Candidate code executes after checkout | Disable/repair before privileged automation |
| runtime_bus | Validates transitions and appends journal | Writes evidence/manifests | Local filesystem | Hash chain, no transaction/fsync | SQLite event/outbox transaction and signed checkpoints |
| evolution promotion | Evaluates declared blockers | Does not itself activate | No activation credential identified | Governance scaffolding | Exact-version inert landing plus guarded activator |

## Canonical target chain

1. The kernel forms an operation request from canonical inputs.
2. authority_engine returns a decision and mints a scoped operation/launch
   reservation inside the single SQLite/WAL transaction.
3. A launcher consumes the one-shot guard in the same transaction that records
   dispatch intent and evidence capacity.
4. The candidate runs credentialless in isolated HOME, filesystem, process,
   network, and Git state.
5. Durable effects are submitted as exact, bounded requests to the local
   broker; the candidate cannot access broker credentials.
6. The broker validates canonical authorization, source/target bindings,
   expiry/revocation, idempotency key, and adapter policy.
7. The broker performs a sanitized Git/provider effect and records a signed
   result or unknown outcome transactionally.
8. An independent exact-SHA verifier observes provider state and signs only
   what it verified.
9. Reconciliation reaches a terminal state before retry or support claims.

## Credential inventory and custody implications

Provider metadata exposed secret names, never values: OPENAI_API_KEY,
ANTHROPIC_API_KEY, and AUTONOMY_PAT. GitHub CLI authentication used a keyring;
Git used osxkeychain configuration; an SSH agent socket existed but held no
identities during inspection. Codex and Claude also depend on local user
configuration.

The target must separate:

- model-provider access needed by the outer trusted launcher;
- GitHub/Git publication credentials owned only by the broker or protected
  remote worker;
- signing keys owned by broker/verifier processes;
- candidate environment, which receives none of those credentials.

Secret names and metadata are CONFIGURATION_DERIVED or PROVIDER_OBSERVED.
Credential use or exfiltration was not tested and remains UNVERIFIED.

