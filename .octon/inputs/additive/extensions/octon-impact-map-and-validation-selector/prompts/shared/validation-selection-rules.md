# Validation Selection Rules

- Choose the minimum existing validation floor that still covers the direct
  impact class.
- Prefer deterministic validators and published workflows over prose-only
  guidance.
- Surface omitted higher-cost checks explicitly.
- Do not silently widen `minimal` into `release-gate`.
- If no published rule yields a credible set, return no selected validations
  and explain why.
