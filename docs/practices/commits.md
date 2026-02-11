# Commits - Convention and Discipline

> Commits are the permanent record of how a codebase evolved. Every commit
> should be atomic, intentional, and meaningful to a future engineer reading
> `git log` six months from now.

---

## Enforcement

- Local: `.husky/commit-msg` runs commitlint on every commit message.
- Run `pnpm install` after pulling changes so Husky installs local hooks.
- CI: `.github/workflows/commit-and-branch-standards.yml` validates commit
  messages for all commits in a pull request and checks branch naming.
- Branch protection: require the `Commit and Branch Standards` check before
  merge.

---

## Format: Conventional Commits

```text
<type>(<scope>): <short summary>

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
Verify before committing: lint passes, types check, tests pass.

### 3. Commit the Intent, Not the Journey

Squash false starts, debugging artifacts, and WIP checkpoints before merging.
Final history should read as a clean narrative of deliberate changes.

### 4. Never Commit

- Secrets, credentials, API keys, `.env` files
- Generated files (`node_modules`, `dist`, build artifacts, lockfile changes
  you did not intend)
- IDE/editor configuration (`.idea`, `.vscode`, unless project-shared)
- OS files (`.DS_Store`, `Thumbs.db`)
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
chore(deps): bump express from 4.18.2 to 4.21.0

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

- Lowercase, hyphen-separated
- Ticket ID when one exists
- Short but descriptive enough to identify without opening the ticket

Examples:

```text
feat/AUTH-42-email-verification
fix/API-108-rate-limit-bypass
refactor/CORE-15-extract-payment-module
chore/CI-7-parallel-test-runners
docs/README-onboarding-update
```
