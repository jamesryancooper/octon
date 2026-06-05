# Implementation Plan

This packet proposes future work only.

1. Inventory validators used by proposal-program lifecycle gates.
2. Add recovery diagnostic fields to the smallest relevant validator outputs.
3. Cover enum drift, stale receipts, stale review digests, publication
   freshness drift, generated projection drift, and child registry errors.
4. Add negative diagnostics for hard blockers with no repair hint.
5. Add tests that assert diagnostic shape and compactness.
