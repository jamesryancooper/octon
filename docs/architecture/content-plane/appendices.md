# Appendices

## Appendix A: Example content files

**A1) Continuity progress events (append-only NDJSON)**:

```json
{"ts":"2025-12-15T10:15:00Z","session_id":"abc123","actor":"agent:implementer","action":"analyzed-pricing-component","files_read":["src/components/Pricing.tsx"]}
{"ts":"2025-12-15T10:30:00Z","session_id":"abc123","actor":"agent:implementer","action":"created-pricing-card","files_written":["src/components/PricingCard.tsx"]}
```

**A2) CDR (Content Decision Record)**:
(Shape aligned with v1's CDR concept.)

```yaml
# content/internal/prose/decisions/CDR-001-pricing-model.yaml
$schema: harmony://schemas/cdr@1
type: cdr
id: CDR-001-pricing-model
surface: internal
status: accepted
title: "Switch to usage-based pricing"
date: 2025-01-15
risk_tier: high
decision_makers: [human:james, human:product-owner]
context: |
  Observed friction with flat monthly pricing.
decision: |
  Adopt usage-based pricing with a generous free tier.
consequences:
  - Update pricing entities and pages
  - Update billing terms snippet
related_content:
  - ref:pricing:widget-pro
  - ref:snippet:billing-terms
```

## Appendix B: Example schema definitions

**B1) Continuity backlog schema (Zod)**:

```ts
import { z } from "zod";

export const continuityBacklogSchema = z.object({
  type: z.literal("continuity-backlog"),
  id: z.literal("main"),
  surface: z.literal("agent"),
  status: z.literal("active"),
  items: z.array(
    z.object({
      item_id: z.string(),
      title: z.string(),
      status: z.enum(["todo", "doing", "blocked", "done"]),
      acceptance_criteria: z.array(z.string()).default([]),
      verification_evidence: z.array(z.string()).default([]),
      write_set: z.array(z.string()).default([]), // doc_keys or globs
    })
  ),
});
```

## Appendix C: Example queries

**C1) "What does this change affect?" (blast radius)**:

```sql
WITH changed AS (
  SELECT 'pricing' AS type, 'widget-pro' AS id, 'en' AS locale
)
SELECT r.src_type, r.src_id, r.src_locale
FROM refs r
JOIN changed c
  ON r.dst_type = c.type AND r.dst_id = c.id AND r.dst_locale = c.locale;
```

## Appendix D: Example CI workflow (GitHub Actions)

```yaml
name: Content Plane Validation
on: [pull_request]

jobs:
  content:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - uses: pnpm/action-setup@v4
        with:
          version: 9

      - run: pnpm install --frozen-lockfile

      - name: Validate content
        run: pnpm harmony-content validate

      - name: Build content artifacts
        run: pnpm harmony-content build

      - name: Convivial lint (warn or fail based on risk)
        run: pnpm harmony-content convivial

      - name: Upload reports
        uses: actions/upload-artifact@v4
        with:
          name: content-reports
          path: .harmony/reports/
```
