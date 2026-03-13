# Pillar & Convivial Alignment

## Octon pillars

**Direction through Validated Discovery**:

- Risk tiers are explicit and enforced (low→critical).
- High-impact content requires CDRs/ADRs and impacted-surface reporting.

**Focus through Absorbed Complexity**:

- Developers and agents interact with a single CLI + file conventions; the compiler absorbs indexing/validation complexity.

**Velocity through Agentic Automation**:

- The Plan→Diff→Explain→Test loop applies to content (v1's "Content PDEX").
- No authenticated CMS boundary; agents can directly edit and PR.

**Trust through Governed Determinism**:

- Schemas + refs + deterministic build outputs + CI gates prevent "it worked locally" content drift.
- `agent_editable` + risk-tier enforcement bounds agent behavior.

**Continuity through Institutional Memory**:

- `/.octon/continuity/` artifacts are owned by the [Continuity Plane](../../../../continuity/_meta/architecture/continuity-plane.md) but indexed by Artifact Surface build pipeline.
- Provenance captured in envelopes; decisions become queryable documents across planes.
- See [Foundational Planes Integration](../../../../continuity/_meta/architecture/three-planes-integration.md) for cross-plane relationships.

**Insight through Structured Learning**:

- Quality checks (readability, SEO completeness, broken refs) + content metrics (lead time, change-fail rate) are build artifacts.

## Convivial alignment

Octon's content infrastructure must make **attention-respecting content** the easiest path and add friction for dark patterns, without turning into a heavy governance product.

**Required mechanisms:**

- **Convivial lint**: detect manipulative patterns (artificial urgency, FOMO, guilt-tripping, deceptive CTAs). v1 provides a concrete pattern list and reporting approach.
- **Amplification awareness**: shared/reused content has higher scrutiny because a single snippet can propagate harm widely ("amplification problem").
- **Stricter gates for shared content**: shared blocks default to `risk_tier: high` and require human review.

**Normative convivial rules:**

- Any document referenced by >N compositions (default N=10) SHOULD be treated as "amplifying" and escalated to at least `risk_tier: high`.
- Any PR touching `risk_tier >= high` content MUST include a short "Convivial Impact Assessment" checklist (v1 proposes this explicitly).
- Convivial lint MUST be "warn by default, block on critical":

  - Warnings for marketing copy (human decision)
  - Errors for deceptive/illegal patterns or content inside critical/legal domains
