# Proposal Packet Terminal Closeout Evaluator

This evaluator is an evidence-only review surface for terminal closeout. It can
summarize whether the retained terminal closeout evidence appears coherent, but
it cannot authorize archive relocation, proposal status mutation, Git/GitHub
mutation, residue deletion, generated publication, or scope expansion.

## Inputs

- Proposal packet path.
- Terminal closeout profile, when supplied.
- Terminal closeout receipt.
- Implementation conformance and post-implementation drift/churn receipts.
- Publication freshness, run-health, capability-publication, extension-
  publication, repo-hygiene, worktree-hygiene, Git/GitHub route, and
  architecture review evidence referenced by the terminal receipt.

## Output

Use `.octon/framework/assurance/evaluators/templates/proposal-packet-terminal-closeout-template.md`.

The evaluator verdict must be one of:

- `evidence-coherent`
- `evidence-incomplete`
- `contradictory-evidence`

Only the terminal closeout workflow receipt may claim `archive-ready` or
`blocked`. If the evaluator finds missing, stale, or contradictory evidence, it
must report the finding as evidence-only and point back to
`proposal-packet-terminal-closeout`.

## Boundaries

- Do not move packets to `.archive`.
- Do not mutate `proposal.yml`.
- Do not stage, commit, push, create PRs, land branches, or clean branches.
- Do not delete residue.
- Do not edit generated/effective outputs.
- Do not treat generated outputs, host projections, proposal-local support
  files, tool state, chat state, or model memory as authority.
