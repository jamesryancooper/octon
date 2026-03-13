# Subsystem Override Policy

## Purpose

Ensure repo-level overrides that alter subsystem-provided assurance policy weights are explicit, reviewable, and auditable, while preserving the resolver precedence contract:

`global -> run-mode -> subsystem -> maturity -> repo` (later wins).

Canonical precedence contract:
`/Users/jamesryancooper/Projects/octon/.octon/assurance/governance/precedence.md`

The policy introduces governance around repo overrides; it does not alter how effective weights are computed.

This policy is enforced by the Assurance Engine, which is the
authoritative local engine for assurance governance in Octon.

## Non-goals

- Do not change precedence order or merge algorithm.
- Do not forbid all repo overrides.
- Do not require subsystem forks or profile proliferation.

## Definitions

- **Override**: A value set at `weights.profiles.<profile>.weights.repo.<repo_id>.<attribute>`.
- **Deviation**: A repo override that changes a subsystem-provided weight for a specific context (profile/run-mode/maturity/repo/subsystem).
- **Control-plane subsystem**: High-governance surfaces (`runtime`, `assurance`, `continuity`, `agency`) where override drift can compromise trust/safety.
- **Productivity subsystem**: Lower-blast-radius surfaces focused on ergonomics and throughput (`scaffolding`, `output`, `ideation`, `capabilities`, `orchestration`, `cognition`).
- **Permitted reasons**: `regulated`, `incident-response`, `experimental`, `performance`, `security`, `reliability`, `portability`, `developer-experience`, `compatibility`, `governance`.

## Required Artifacts For A Deviation

A declared deviation record in `/Users/jamesryancooper/Projects/octon/.octon/assurance/governance/overrides.yml` with:

- target: `repo`, `profile` (optional), `subsystem`, `attribute`
- value delta: `old_value`, `new_value`
- rationale: `reason_category`, `reason`
- governance links: `adr`, `changelog_version`
- charter alignment: explicit acknowledgement when lowering top-priority Charter outcomes (Assurance-first guardrail)
- ownership and accountability: `owner`, `approved_by`, `created_at`
- lifecycle: `temporary`, `expires_at` (or `permanent_justification`)
- supporting evidence pointers

## Review Rules

### Control-plane deviations

Minimum requirements:

- explicit deviation declaration
- valid ADR link
- changelog reference matching `weights.yml` versioned changelog
- minimum 2 reviewers (`approved_by`)
- permitted reason category
- owner assigned

### Productivity deviations

Minimum requirements:

- declaration strongly recommended
- large change (`abs(new-old) >= 2`) requires ADR
- single reviewer minimum

## Expiration And Deprecation

- Temporary deviations must include `expires_at`.
- Missing expiry without `permanent_justification` is warned.
- Expired deviations are policy violations.
- Permanent deviations require explicit `permanent_justification`.

## Exception Process (Break-glass)

Allowed only for incident containment or legal/regulatory response.

Required:

- `reason_category=incident-response` or `regulated`
- owner + two reviewers
- ADR (can be rapid ADR)
- temporary flag with near-term expiry
- evidence/log link to incident artifact

## No Silent Nudges Rationale

Without explicit deviation records, repo-level weight nudges can silently neutralize subsystem intent, especially in control-plane surfaces. This policy makes every deviation attributable and reviewable.

## Enforcement Summary

- Control-plane override without declaration/ADR/changelog: hard fail (active in Phase 2).
- Productivity override without declaration: warn.
- Productivity large-change missing ADR: hard fail (active in Phase 2).
- Weights policy changes must include version bump, changelog entry, and deviation capture for changed repo overrides.
- Charter or charter-intent policy changes must include a versioned changelog entry with ADR and `charter_ref`.
