# Validation Plan

## 1. Proposal structural validation

Run:

- `validate-proposal-standard.sh --package <path>`
- `validate-architecture-proposal.sh --package <path>`
- `generate-proposal-registry.sh --write`

Validate that:

- manifests parse
- required files exist
- proposal registry accepts the new active packet

## 2. Ingress and documentation coherence validation

Validate that:

- ingress manifest and ingress `AGENTS.md` agree on the contextual gate
- no authoritative workflow doc still says to ask the same closeout question
  after every file-changing turn
- no authoritative workflow doc still treats Codex App as the default or only
  supported worktree environment

Suggested sweeps:

- `rg "Are you ready to closeout this branch\\?" .octon/instance .octon/framework/agency`
- `rg "Codex App Worktree Operating Model|do not resolve other people's comments|All review conversations resolved" .octon .github`

## 3. Script and helper validation

Validate that:

- `git-pr-open.sh` still refuses `main`
- `git-pr-ship.sh --help` and success messaging describe request or helper
  semantics rather than readiness proof
- cleanup behavior clearly covers both ref convergence and worktree-directory
  handling, whether automated or documented

Use dry-run or help-mode checks where possible.

## 4. Review remediation validation

Validate that:

- `pull-request-standards.md`
- the remediation skill
- the companion PR template

all agree on the same author-side behavior:

1. fix
2. commit
3. push
4. reply
5. wait for reviewer or maintainer confirmation on reviewer-owned threads

## 5. Scenario-matrix validation

Exercise these cases against the final docs and scripts:

1. `main` worktree, no PR
   - result: branch/worktree prompt, not PR-open attempt
2. branch worktree, no PR
   - result: draft-PR closeout prompt
3. branch worktree, draft PR, autonomous lane ready
   - result: ready plus squash auto-merge prompt
4. branch worktree, draft PR, manual lane ready
   - result: ready for human review with auto-merge off
5. branch worktree, red required checks
   - result: blocker report, no closeout prompt
6. branch worktree, outstanding author action items
   - result: blocker report, no closeout prompt
7. branch worktree, ready PR waiting on reviewer-owned thread resolution
   - result: status report, no misleading closeout prompt

## 6. Implementation closeout gate

The packet is closeout-ready only when:

- the scenario matrix passes
- ingress and practice docs agree
- companion PR-template wording is aligned
- there are no stale fixed-prompt instructions left in durable workflow docs
- the proposal registry rebuild succeeds
