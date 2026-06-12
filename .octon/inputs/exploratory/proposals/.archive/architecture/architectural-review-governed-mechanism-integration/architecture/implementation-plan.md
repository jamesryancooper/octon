# Implementation Plan

1. Add mechanism index entry with canonical display name and family slug.
2. Add mechanism detail page if required by current mechanism docs.
3. Reference workflows, schemas, validators, evidence roots, generated refs, raw
   inputs, extension helper refs, and owner boundaries.
4. Update contract registry only if required for discoverability.
5. Run governed mechanism validator and add negative controls if coverage is
   missing.

## Strict Receipt Requirements

Receipts must include mechanism index refs, validator refs, evidence refs,
authority classification, generated projection classification, and raw input
non-authority classification.
