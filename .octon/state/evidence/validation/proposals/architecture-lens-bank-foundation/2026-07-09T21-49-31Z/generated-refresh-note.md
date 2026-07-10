# Generated Projection Refresh Note

Run: `20260709-arms-program-clean-delivery-04-architecture-lens-bank-foundation`

The Architectural Review Mechanism has **no generated methodology index that
enumerates the mechanism directory's file list**. A search of `.octon/generated`
for references to `architecture-lens-bank`, `lens-bank.yml`, or
`balanced-architecture-review-method` returned only:

- unrelated per-proposal `proposal-artifact-index.yml` files and a runs index
  that mention the `architectural-review` family slug in passing, not a file
  index of the methodology directory; and
- `.octon/generated/effective/.../octon-concept-integration/.../shared/architecture-review-method.md`,
  a derived extension prompt projection that references the review method
  conceptually and is refreshed only through canonical publication — never
  hand-edited.

Conclusion: **no generated refresh was required** for this child. Per the
file-change map and the implementation prompt §3.7, no `generated/**` path was
hand-edited. If a future methodology index is introduced, it must be refreshed
only through the canonical publication script.
