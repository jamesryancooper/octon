# Target Architecture

Common churn measurement should define producer entrypoint contracts:

- compare semantic input digests before writing;
- use stable ordering and stable serialization;
- avoid volatile timestamps in stable outputs;
- skip writes when output content is unchanged;
- emit compact churn metrics for changed files, rewrites, receipts, residue, `.tmp` size, runtime, token impact, validation coverage, freshness coverage, and evidence retrieval.

The common contract is a measuring and discipline surface. It does not own
producer-specific publication semantics.
