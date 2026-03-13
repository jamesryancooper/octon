# Commits - Convention and Discipline

> Commits are the permanent record of how a codebase evolved. Every commit
> should be atomic, intentional, and meaningful to a future engineer reading
> `git log` six months from now.

---

## Quick Path

Use this progressive path to get only the depth you need:

1. **Fast reminder:** `<type>(<scope>): <summary>` and
   `<type>/<ticket-id>-<short-description>`
2. **Human policy details:** this file (`commits.md`)
3. **Machine-enforced values:** `standards/commit-pr-standards.json`
4. **Runtime enforcement:** `.github/workflows/commit-and-branch-standards.yml`

---

## Enforcement

This practice is tool-agnostic. Repositories can enforce it using any local
and CI mechanism (native Git hooks, hook frameworks, custom scripts, or
pipeline checks).

Canonical enforcement in this repository:

- PR-time branch and commit checks:
  `.github/workflows/commit-and-branch-standards.yml`
- Main-branch safety checks:
  `.github/workflows/main-push-safety.yml`
- Machine-readable enforcement contract:
  `.octon/agency/practices/standards/commit-pr-standards.json`

If you want local pre-commit enforcement, mirror the same contract in your
editor or local Git hooks.

For a message to pass enforcement, it must satisfy this contract
(values are sourced from `commit-pr-standards.json`):

- Header format: `<type>(<scope>): <summary>`
- Allowed types: `feat`, `fix`, `refactor`, `perf`, `test`, `docs`, `chore`,
  `ci`, `revert`
- `type` must be lowercase
- `scope` is required and must be lowercase
- `summary` is required, lowercase, and must not end with `.`
- Header max length: 72 characters
- Body line max length: 72 characters
- Footer line max length: 72 characters

Implementation detail: if a repository includes auto-normalization before
linting, review the final message text before confirming the commit.

---

## Format: Conventional Commits

```text
<type>(<scope>): <summary>

<optional body - why, not what>

<optional footer - breaking changes, ticket refs>
```

### Types

- `feat` - new functionality visible to users
- `fix` - bug fix
- `refactor` - restructuring without behavior change
- `perf` - performance improvement
- `test` - adding or fixing tests
- `docs` - documentation only
- `chore` - build, deps, config, tooling
- `ci` - CI/CD pipeline changes
- `revert` - reverting a previous commit

### Scope

Scope maps to module or domain boundaries. Use consistent, lowercase scope
names across the project (for example: `auth`, `payments`, `api`, `ui`, `db`).
If a change truly spans multiple scopes, it is usually multiple commits.

### Subject Line

- Imperative mood: "add validation", not "added validation" or "adds
  validation"
- Lowercase, no period at the end
- Non-empty
- Max 72 characters
- Describes the outcome, not the activity
- If you need "and" in the subject, split into multiple commits

### Body

- Separated from subject by a blank line
- Explains why the change was made; the diff already shows what
- Include rationale, alternatives considered, and tradeoffs accepted
- Wrap at 72 characters

### Footer

- `BREAKING CHANGE: <description>` for any breaking change
- Ticket references: `Refs: AUTH-42` or `Closes: API-108`
- Co-author attribution when applicable

---

## Rules

### 1. One Logical Change Per Commit

A commit does one thing. Ask: "Can I describe this commit without using
'and'?" If not, split it.

### 2. Every Commit Passes CI

Never commit code that breaks the build, even if the next commit fixes it.
Verify before committing: required quality checks for your stack pass
(lint/static analysis/tests/build validation).

### 3. Commit the Intent, Not the Journey

Squash false starts, debugging artifacts, and WIP checkpoints before merging.
Final history should read as a clean narrative of deliberate changes.

### 3.1 Autonomy Mode

In autonomy-first flow, iterative branch-local commits are allowed while an
agent is actively refining a solution. The durable trunk artifact is still the
squash commit on `main`, and it must satisfy the canonical Conventional Commit
contract (`<type>(<scope>): <summary>`).

Treat branch commits as working narration and trunk commits as permanent
history.

### 4. Never Commit

- Secrets, credentials, API keys, `.env` files
- Generated/vendor artifacts unless intentionally versioned for the project
- Local IDE/editor settings unless explicitly shared by team convention
- Local operating-system metadata files
- Large binaries or media without explicit need

Enforce with `.gitignore` and review staged files before every commit.

### 5. Make Diffs Reviewable

- Separate formatting/whitespace changes from behavioral changes
- Separate dependency updates from code changes
- Separate refactors from feature additions
- When possible, separate pure renames from content edits

### 6. Write for Future Readers

The primary audience for a commit message is an engineer running `git blame`
months later. Give them the intent, constraints, and enough context to
understand why the code looks the way it does.

---

## Examples

Good:

```text
feat(auth): add email verification on signup

New users must verify their email before accessing the dashboard.
Chose token-based verification over magic links for simplicity.
Magic links add short-lived URL-signing complexity we do not need yet.

Closes: AUTH-42
```

```text
fix(api): prevent rate limit bypass via header spoofing

X-Forwarded-For was trusted without validation, allowing clients
to rotate IPs by injecting headers. Now validate against a trusted
proxy allowlist before extracting client IP.

Refs: SEC-17
```

```text
refactor(payments): extract billing calculation into domain service

Billing logic was duplicated across three API handlers with slight
variations. Unified into PaymentCalculator with explicit rounding
rules. No behavior change, verified by existing test suite.
```

```text
chore(deps): bump gateway framework from 4.18.2 to 4.21.0

Security patch for CVE-2024-XXXX (request smuggling via malformed
Transfer-Encoding headers). No breaking changes per changelog.
```

Bad:

```text
update code
```

```text
fix stuff
```

```text
feat(auth): add email verification and fix password reset and update user model and refactor middleware
```

```text
WIP - will fix later
```

---

## Branch Naming

```text
<type>/<ticket-id>-<short-description>
```

- Keep `type` and short description lowercase and hyphen-separated
- Preserve ticket casing only when your tracker requires it
- Ticket ID when one exists
- Short but descriptive enough to identify without opening the ticket

Examples:

```text
feat/AUTH-42-email-verification
fix/API-108-rate-limit-bypass
refactor/CORE-15-extract-payment-module
chore/CI-7-parallel-test-runners
docs/readme-onboarding-update
```
