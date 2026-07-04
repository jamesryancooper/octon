# Target Architecture

Run-health projections are diagnostic read models by default. Validators and
retry loops write speculative projections to scratch or local-private retained
state and deduplicate them under retention limits.

A projection becomes durable publishable evidence only when an owning route
promotes it by path and digest because it is needed to prove lifecycle,
validation, closeout, archive, delivery, or disclosure claims. Promotion
receipts record source refs, freshness, owning route, allowed consumers, and
non-authority classification.
