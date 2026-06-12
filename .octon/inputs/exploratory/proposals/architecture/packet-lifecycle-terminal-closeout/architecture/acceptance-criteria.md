# Acceptance Criteria

## Proposal Acceptance

- The packet defines a canonical packet terminal closeout workflow modeled on
  proposal program aggregate receipts.
- The packet explains why terminalization belongs in packet lifecycle rather
  than closeout-worktree, closeout-change, archive-proposal, or
  lifecycle-postmortem.
- The packet preserves proposal inputs as non-authority and generated outputs
  as derived-only.
- The packet defines postmortem and architecture review outputs as
  evidence-only.
- The packet states that archive-proposal remains the archive relocation owner.
- The packet includes implementation phases, validation plan, risks, and
  non-goals.
- Proposal standard, architecture proposal, and proposal review gate validators
  pass for the packet or report only blockers outside this packet.

## Future Implementation Acceptance

- A workflow named `proposal-packet-terminal-closeout` exists and is registered.
- A profile schema validates terminal closeout inputs and expected retained
  evidence.
- A receipt schema validates packet-local aggregate terminal receipts.
- The workflow verifies durable implementation state before terminal claims.
- The workflow requires current implementation conformance and
  post-implementation drift/churn receipts.
- Publication freshness failures are repaired only through canonical
  publishers, followed by rerunning the failed and adjacent validators.
- Generated/input non-authority, run-health, capability publication, and
  extension publication validators are part of the terminal gate.
- Repo-hygiene cleanup happens only through authorized cleanup routes.
- Worktree hygiene blocks archive-ready when foreign or ambiguous residue
  remains.
- Post-integration architecture review runs after conformance and drift pass and
  remains evidence-only.
- Packet terminal evaluator or lifecycle-postmortem runs on blocked,
  nonterminal, cancelled, rollback, or repeated-retry terminal runs and remains
  evidence-only.
- Git/GitHub exact-SHA hosted checks are triggered or validated through the
  canonical closeout route when policy allows.
- Failed hosted checks report exact check, SHA, workflow, and next route.
- The terminal receipt records `archive-ready` only when all gates pass.
- The terminal receipt records `blocked` with exact blocker and next canonical
  route when any gate fails.
- The terminal receipt does not move the packet into `.archive`.

## Negative Controls

- A terminal receipt without implementation conformance fails validation.
- A terminal receipt without post-implementation drift/churn evidence fails
  validation.
- Directly edited generated output freshness repair fails validation.
- Lifecycle-postmortem output used as closeout authority fails validation.
- Post-integration architecture review output used as archive authority fails
  validation.
- Branch-no-pr hosted landing without exact-SHA checks fails validation.
- Branch cleanup without governed authorization fails validation.
- Archive-ready verdict with dirty worktree or foreign residue fails
  validation.
- Archive-ready verdict that performs archive relocation fails validation.
