# Pull Requests — Convention and Quality Standards

> A PR is a proposal to change the codebase. It should make the reviewer's job easy: clear intent, minimal scope, obvious correctness, and enough context to evaluate tradeoffs without a meeting.

---

## Quick Path

Use this progressive path to get only the depth you need:

1. **Fast reminder:** use `.github/PULL_REQUEST_TEMPLATE.md`
2. **Human policy details:** this file (`pull-request-standards.md`)
3. **Machine-enforced headings/checklist:** `.github/workflows/pr-quality.yml`
4. **Related commit/branch contract:** `commits.md` and
   `standards/commit-pr-standards.json`
5. **GitHub autonomy credential/runbook:** `github-autonomy-runbook.md`

---

## Principles

1. **One concern per PR.** A PR does one thing well. Feature + refactor + config change = three PRs. If the description needs multiple paragraphs covering unrelated topics, split it.
2. **Small over large.** Aim for <400 lines of meaningful diff. Large PRs get rubber-stamped, not reviewed. If a feature is too big for one PR, decompose it into a stack of reviewable increments - each one shippable or safely behind a flag.
3. **Self-review before requesting review.** Read your own diff as if you've never seen the code. Catch formatting drift, accidental inclusions, missing tests, TODO comments, and debug logging before anyone else has to.
4. **The PR must pass CI.** Never request review or merge on a red build. This includes lint, type checks, tests, and any other quality gates.

---

## Autonomy-First Flow

Default PR execution in Octon is draft-first and autonomy-first:

1. Open early as draft from a branch worktree.
2. Keep one task or PR per branch worktree and iterate on the same branch and
   same PR.
3. Let triage apply `type:*`, `area:*`, and `risk:*`.
4. Address review with `fix + commit + push + reply`.
5. Move to ready only when the work is complete, no unresolved author action
   items remain, and the lane is appropriate.
6. Use autonomous squash merge only for eligible PRs.

Ready-for-review is a state criterion, not a helper-script side effect or a
synonym for "probably done." Helper scripts may request ready or auto-merge
transitions, but canonical mergeability still comes from required checks,
policy, and reviewer or maintainer confirmation, including the documented
solo-maintainer exception when its evidence requirements are met.
Ordinary review remediation remains `fix + commit + push + reply`; history
rewrite is not the default review path.

Human check-ins are exception-based and intentionally narrow:

- PRs from `exp/*` branches stay in the manual lane.
- High-impact path changes are triaged out of the autonomous merge lane and
  require ordinary human review and merge.
- Dependabot major or unknown version jumps are triaged out of the autonomous
  merge lane and require ordinary human review and merge.
- No label, comment, or check may act as repo-local approval authority.
- AI-gate waivers are not supported in the autonomy lane; blocking findings
  must be fixed or handled outside the lane.
- Merge eligibility is determined from canonical authority artifacts and
  required checks, not autonomy lane labels.

---

## Enforcement

This practice is platform-agnostic. Repositories can enforce it with any source
control provider and CI system.

- Use PR templates (or equivalent automation) to prompt required structure.
- Validate required PR sections and checklist items on every PR update.
- Enforce branch naming and commit-message conventions with automated checks.
- Protect trunk so required PR quality and commit/branch checks must pass
  before merge.
- Unresolved review conversations block merge.
- Authors address reviewer-owned threads by pushing fixes and replying; the
  reviewer or a maintainer confirms and resolves those threads.
- In solo-maintainer repositories, an author who is also repository owner or
  maintainer may resolve reviewer-owned threads programmatically only after
  fix, commit, push, reply, green required checks, and explicit maintainer
  override evidence. This is conversation cleanup only and never substitutes
  for required review approval, required checks, rulesets, or GitHub
  mergeability.
- AI review gate (provider-agnostic required control):
  `.github/workflows/ai-review-gate.yml` (required status check:
  `AI Review Gate / decision`; shadow mode with `AI_GATE_ENFORCE=false`,
  strict mode with `AI_GATE_ENFORCE=true`).
- Codex provider review remains advisory:
  `.github/workflows/codex-pr-review.yml`.
- Autonomy lane credential and permissions guidance:
  `github-autonomy-runbook.md` (`AUTONOMY_PAT`, fine-grained PAT minimum scope,
  and Checks API limitation notes).

---

## PR Description Template

Use `.github/PULL_REQUEST_TEMPLATE.md` as the canonical PR template for all
non-trivial PRs. For trivial changes (typo fixes, single-line config), a
one-line summary is acceptable.

- This standards document defines policy and review expectations.
- The template defines the PR body structure and prompts.
- Scoped templates under `.github/PULL_REQUEST_TEMPLATE/` may add context
  sections, but must preserve all canonical headings and checklist items
  through `## Checklist`.
- CI validation in `.github/workflows/pr-quality.yml` enforces canonical
  template structure against PR bodies.
- For governance, migration, or refactor changes, PR bodies must include the
  execution-profile governance receipt contract:
  - `## Profile Selection Receipt`
  - `## Implementation Plan`
  - `## Impact Map (code, tests, docs, contracts)`
  - `## Compliance Receipt`
  - `## Exceptions/Escalations`
- Governance receipts must declare machine keys when applicable:
  - `change_profile`
  - `release_state`
  - `transitional_exception_note` (required for `pre-1.0` + `transitional`)

---

## Rules

### Scope and Focus

- Never mix refactoring with behavior changes. Refactor first in a separate
  PR, then build the feature on the clean foundation. Reviewers can't verify
  "no behavior change" and "correct new behavior" in the same diff.
- Never mix dependency updates with code changes. Dependency bumps are their
  own PR.
- Never mix formatting or whitespace changes with logic changes.
- If a PR touches more than 3 modules, question whether it should be split.

### Commit Hygiene

- Clean up commit history before review. Squash WIP commits, fixups, and false
  starts. The commit log should read as a clean narrative (see `commits.md`).
- Each commit in the PR should pass CI independently.
- Commit messages should make sense when read in sequence. A reviewer should
  be able to understand the PR by reading the commit log alone.

### Context for Reviewers

- Link the ticket or issue. Don't make the reviewer search for context.
- Every PR description must include either:
  - `Closes/Fixes/Resolves #<issue>` or
  - `No-Issue: <reason>`
- If the PR introduces a pattern the team hasn't used before, call it out
  explicitly and explain the reasoning.
- If there's a visual change, include a screenshot or recording.
- If there's a performance impact, include before and after measurements.
- If there's a migration, describe the rollback procedure.

### Review Responsiveness

- Respond to all review comments, even if the response is "done" or
  "acknowledged."
- When code or documentation changes are required, the default author sequence
  is: fix, commit, push, reply.
- Do not amend, rebase, or force-push during ordinary review remediation.
- When you disagree with feedback, explain your reasoning. Don't just
  re-request review without addressing the comment.
- Review work is complete only when no unresolved author action items remain.
- Do not resolve other people's comments unless acting under the documented
  solo-maintainer exception. By default, let the reviewer or a maintainer
  confirm and resolve reviewer-owned threads when they are satisfied.
- Re-request review once author-side action items are closed and another pass
  is needed.
- Do not merge `main` into the branch as a remediation shortcut.

### What Disqualifies a PR

These should be caught in self-review and never reach a reviewer:

- failing CI
- committed secrets, credentials, or `.env` files
- `console.log` or `print` debugging statements left in
- commented-out code without an explanation and a ticket to remove it
- TODO, FIXME, or HACK comments without a linked ticket
- unrelated changes mixed in

---

## PR Size Guidelines

| Size | Lines Changed | Expectation |
|------|--------------|-------------|
| **XS** | <50 | Typos, config, single-line fixes. One-line description is fine. |
| **S** | 50-200 | Focused change. Standard template. Quick review. |
| **M** | 200-400 | Full template required. Should still be one concern. |
| **L** | 400-800 | Needs justification for why it can't be split. Full template required. |
| **XL** | 800+ | Almost always should be split. Acceptable only for generated code, migrations, or initial scaffolding. Requires explicit reviewer agreement before submitting. |

---

## Stacked PRs (for large features)

When a feature is too large for a single reviewable PR:

1. **Plan the stack.** Break the feature into increments where each PR is independently shippable or safely inert (behind a flag).
2. **Number them.** Title format: `feat(payments): add invoice model [1/3]`. Reference the overall ticket and link to the next PR in the stack.
3. **Each PR stands alone.** Every PR in the stack must pass CI, have its own tests, and be mergeable independently. Never create a PR that "will work once the next one lands."
4. **Review in order.** Each PR should be reviewable without needing to read the later ones. The reviewer should understand the value of the current PR on its own.

---

## Examples

**Good PR title:**

```text
feat(auth): add email verification on signup [AUTH-42]
```

**Good PR description (abbreviated):**

```markdown
## What
Adds email verification as a required step after signup. Unverified
users can log in but are redirected to a verification prompt.

## Why
Reduces fake/throwaway account creation (currently ~18% of signups).
Refs: AUTH-42

## How
Token-based verification via SendGrid. Tokens expire after 24h.
Considered magic links but rejected - adds URL-signing complexity
we don't need yet (YAGNI). Can revisit if we add passwordless login.

## Tradeoffs
- Adds signup friction (mitigated: verification email sends within <2s)
- SendGrid dependency (acceptable: already used for transactional email)
- No SMS fallback yet (tracked: AUTH-58)

## Testing
- Unit tests for token generation, expiry, and validation
- Integration test for full signup->verify->access flow
- Manual test: expired token, already-verified re-click, invalid token

## Rollout
Behind `email_verification_enabled` feature flag. Default off.
Will enable for 10% of new signups, monitor verification completion
rate and support tickets for 48h, then ramp to 100%.
```

**Bad PR title:**

```text
updates
```

**Bad PR description:**

```text
Fixed some stuff. Please review.
```
