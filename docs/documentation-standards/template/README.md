# Harmony Documentation Stubs

For full guidance on how these stubs fit together and how to use them, see the Documentation Standards guide: [docs/documentation-standards/README.md](/.harmony/scaffolding/templates/documentation-standards.md).

This bundle contains **ready-to-rename** stubs for the Harmony workflow:

- `Spec One-Pager` + lightweight `ADR`
- `Feature Story` (execution plan) + **Contracts** (OpenAPI + JSON Schema)
- `Component/Developer Guide`
- `Operations Runbook`

> Rename `{{feature-name}}` and `{{component-name}}` to your real names. Then do a global find/replace inside files.

## Suggested next steps

1. Rename folders and file placeholders.
2. Edit `packages/contracts/openapi.yaml` and `schemas/feature-name.schema.json` to match your API/events.
3. Enable CI checks (oasdiff, schema validation, contract tests) as described in `packages/contracts/README.md`.
4. Keep features **behind a feature flag** until rollout.

### Notes

- The `Component/Developer Guide` includes sections such as Quick Snapshot, I/O & Contracts, Artifacts & Layout, Publishing/Serving, Validation & Health, Harmony Alignment, and FAQs. Fill only what applies to your kit to keep docs lean.
- For methodology alignment, see `.harmony/cognition/methodology/README.md`.
- For multi-mode components, replicate the per-mode sub-structure in the guide: “What it does” / “I/O” / “Wins” / “Opinionated choices” for each mode you support.
 - Opinionated tech choices (frameworks, libraries, backends, models) belong in the guide’s “Opinionated Implementation Choices” section; if the choice is org‑wide or high‑impact, capture it in an ADR and link from the guide.
