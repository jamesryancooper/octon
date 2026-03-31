# Documentation and Claim Alignment

## Problem class

Several `.octon/**` documents still frame Octon as portable or self-contained across repositories and agent environments in language that is broader than the currently retained proof-backed live envelope.

Separately, the binding subordinate principles surface still uses placeholder ownership identifiers such as `@you`.

These are different issues, but they share the same design failure: the document speaks more broadly or less durably than the repo currently proves.

## Target rule

1. Architectural **intent** may remain broad.
2. Live **support claims** must remain evidence-bounded.
3. Binding governance identifiers must resolve through durable ownership surfaces, not placeholders.

## Required claim-language correction

The following files should be rewritten so they distinguish clearly between:

- **portable authored core / profile-driven export intent**
- **current proof-backed live consequential support envelope**

Affected files:

- `/.octon/framework/constitution/CHARTER.md`
- `/.octon/instance/charter/workspace.md`
- `/.octon/instance/bootstrap/START.md`
- `/.octon/framework/cognition/governance/principles/principles.md`
- `/.octon/README.md`

### Replacement pattern

Replace broad language of the form:

- portable across repositories and agent environments
- self-contained across repositories and agent environments
- supported broadly across adapters/locales/environments

with evidence-bounded language of the form:

- the authored Octon core is designed to be portable through profile-driven export and replacement-safe adapters
- the currently proved live consequential envelope is the retained repo-local governed envelope named by the release HarnessCard
- broader portability or adapter coverage requires explicit support-target declaration plus retained disclosure proof before it may be claimed as live support

## Required owner-identifier correction

The following files must stop using placeholder owner identifiers:

- `/.octon/framework/cognition/governance/principles/principles.md`
- `/.octon/framework/cognition/governance/exceptions/principles-charter-overrides.md`

### Preferred replacement

Use the ownership-registry-backed operator identifier:

- `octon-maintainers`

because it already exists in:

- `/.octon/instance/governance/ownership/registry.yml`

Avoid inventing new identifiers when an existing durable one already exists.

## What this packet intentionally leaves out of promotion targets

This is an `octon-internal` active proposal. Under the proposal standard, it must not mix `/.octon/**` promotion targets with repo-local non-`/.octon/**` promotion targets.

That means the following still deserve remediation, but are tracked as **repo-local follow-on items** rather than direct promotion targets here:

- `/README.md` absolute local filesystem links
- `/CODEOWNERS` placeholder usernames

See `resources/repo-local-follow-on-items.md`.

## Validator contract

Add a lightweight textual validator or review gate that fails when:

- `.octon/**` live claim docs contain broad support wording without a nearby support-target/disclosure qualifier
- `.octon/framework/cognition/governance/**` still contains placeholder owner identifiers such as `@you` or `@teammate`

## Expected end state

After promotion:

- `.octon/**` docs still express architectural ambition, but live support language is proof-bounded
- the subordinate principles surface uses durable ownership identifiers
- repo-local non-`.octon/**` cleanup remains visible as explicit follow-on work rather than silently forgotten
