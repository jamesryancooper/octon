# Source Context

_Status: Proposal-local source summary_

The operator supplied a design recommending a balanced evidence disclosure
tier architecture:

- Keep `.octon/state/evidence/runs/**` as canonical retained run evidence, but
  treat it as publishable claim evidence rather than a raw-log dumping ground.
- Add `.octon/state/evidence/local/**` as ignored local-only raw evidence for
  logs, cleanup receipts, machine paths, and transcripts.
- Keep `.octon/state/evidence/disclosure/**` for operator and release
  disclosure.
- Keep `.octon/generated/**` derived-only and never authoritative.
- Require promotion from local raw evidence to publishable evidence through
  summarization, redaction, and explicit receipts.
- Add validators for local-only tracking prevention, disclosure tier metadata,
  publishable receipt concision, generated read-model non-authority, and hosted
  closeout independence from local-only evidence.

The proposed durable surfaces include:

- retention contracts under `.octon/framework/constitution/contracts/retention/`;
- runtime prose specs under `.octon/framework/engine/runtime/spec/`;
- evidence obligations under `.octon/framework/constitution/obligations/evidence.yml`;
- assurance validators under `.octon/framework/assurance/runtime/_ops/scripts/`;
- repo-hygiene and closeout remediation surfaces;
- local-only operational evidence under `.octon/state/evidence/local/**`;
- publishable retained claim receipts under `.octon/state/evidence/runs/**`;
- disclosure artifacts under `.octon/state/evidence/disclosure/**`;
- generated read models under `.octon/generated/**`.

## Resolved Design Decisions

- Publishable receipts are required for hosted/shared closeout and any claim
  intended to leave the local machine; purely local debugging may remain
  local-only until promoted.
- Publishable evidence warns above 64 KiB and fails above 256 KiB for one
  receipt unless a schema-declared exception applies.
- Local evidence references use relative local paths or logical ids plus
  digests, never absolute machine paths.
- Redaction is manually declared and validator-assisted.
- Ignore behavior is scoped to `.octon/state/evidence/.gitignore` so local raw
  evidence can be ignored without mixing active proposal target families.

This source context is proposal-local input only. It is not runtime, policy,
evidence, closeout, or implementation authority.
