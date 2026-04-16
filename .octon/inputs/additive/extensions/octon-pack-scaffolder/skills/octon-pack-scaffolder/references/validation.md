# Validation

Success means:

- `target` maps to exactly one supported leaf scaffold
- no write escapes the target pack root
- created files match the documented output shape
- rerunning against matching content is idempotent
- conflicting content blocks the run explicitly
