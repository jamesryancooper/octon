# Target Architecture

The target architecture is a producer-first churn reduction model.

Each generator, publisher, validator, lifecycle writer, and cleanup route must
make unchanged-input behavior explicit. Where a producer emits generated,
projected, validation, or local scratch outputs, it should avoid rewriting
unchanged files, compact repeated retained evidence without losing retrieval,
and expose metrics that make churn visible.

Runtime-facing `.octon/generated/effective/**` outputs remain freshness-gated
and traceable. Generated outputs and host projections remain non-authoritative.
Retained evidence remains durable unless an owning cleanup route classifies
exact files as stale or unreferenced.

The parent program does not implement the architecture. It coordinates child
packets that can later implement producer-specific changes.
