# Target Architecture

The target state has two coordinated parts.

1. Product feature documentation accurately covers the current implemented
   product-facing and cross-surface mechanisms.
2. Proposal delivery and terminal closeout include a feature-catalog drift gate
   that checks whether implementation work changed product feature obligations.

The gate runs after implementation evidence exists and before archive-ready or
delivery-complete claims. It must classify findings as missing catalog entry,
missing feature note, under-documented, status mismatch, or probably not a
product feature.

The gate produces a retained receipt that records affected feature ids,
evidence refs inspected, required documentation action, validation results, and
authority notes. The receipt is evidence only and cannot update docs by itself.

The gate blocks closeout when a product-facing feature is new, materially
changed, removed, retired, renamed, split, merged, downgraded, or stale in the
catalog without accurate catalog coverage and validation.
