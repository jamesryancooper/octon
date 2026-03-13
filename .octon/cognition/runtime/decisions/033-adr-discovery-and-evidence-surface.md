# ADR 033: ADR Discovery and Evidence Surface

- Date: 2026-02-21
- Status: Accepted
- Deciders: Octon maintainers
- Supersedes: Ad-hoc ADR discovery without a canonical runtime index

## Context

ADR records under `cognition/runtime/decisions/` are canonical, but discovery
was file-list based and lacked a machine-readable index similar to migrations.

Decision-specific evidence also had no dedicated optional surface, leading to
ad-hoc placement when deeper receipts were needed.

## Decision

Adopt a canonical ADR discovery and optional evidence surface model:

- Keep ADR files as the canonical decision SSOT:
  - `/.octon/cognition/runtime/decisions/<NNN>-<slug>.md`
- Add a canonical ADR discovery index:
  - `/.octon/cognition/runtime/decisions/index.yml`
- Keep decision summaries in:
  - `/.octon/cognition/runtime/context/decisions.md`
- Add optional decision evidence bundles:
  - `/.octon/output/reports/decisions/<NNN>-<slug>/`
  - required files (when a bundle exists):
    - `bundle.yml`
    - `evidence.md`
    - `commands.md`
    - `validation.md`
    - `inventory.md`

This decision does not convert ADRs to per-decision directories.

## Consequences

### Benefits

- ADR discovery becomes deterministic for agents and tooling.
- Decision evidence gains a dedicated, discoverable optional surface.
- Canonical ADR file simplicity is preserved.

### Risks

- New contract surfaces can drift without guardrails.
- Tooling may still rely on ad-hoc file listing.

### Mitigations

- Add harness guardrails requiring `decisions/index.yml` and the
  decision-evidence bundle contract when bundles are present.
- Update runtime/output READMEs to document canonical placement.
