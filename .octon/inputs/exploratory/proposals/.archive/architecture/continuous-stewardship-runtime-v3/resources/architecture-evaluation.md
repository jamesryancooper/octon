# Architecture Evaluation

## Why v3 Is the Correct Next Layer

V1 makes Octon safe to start by compiling a governed first run candidate. V2
makes Octon safe to continue across a bounded mission. V3 must make Octon safe
to remain available over time without allowing indefinite execution.

The existing mission-control lease, autonomy budget, and circuit breaker schemas
already show Octon favors leased, budgeted, breaker-controlled autonomy rather
than perpetual loops. V3 extends that principle above missions with finite
stewardship epochs.

## Why Not Infinite Loops

An infinite agent loop conflicts with Octon's controlled autonomy posture. It
would create work without a trigger, bypass idle as a valid state, risk scope
creep, and blur closure. V3 instead uses recognized triggers, admission
decisions, finite epochs, mission handoff, and renewal gates.

## Why Stewardship Program and Epoch Are the Right Abstractions

A Stewardship Program represents long-term care without authorizing execution.
A Stewardship Epoch creates a finite operating window so recurring care does not
become unbounded work. Together they allow indefinite service availability while
keeping every work unit bounded.

## Why Campaigns Remain Optional

Campaigns solve multi-mission coordination, not continuous care. V3 should only
emit campaign candidates when campaign promotion criteria are met. Overloading
campaigns as stewardship would violate existing campaign boundaries.

## Product Simplification

Operators see `octon steward status`, `observe`, `admit`, `idle`, `renew`, and
`close`, not raw run queues or proof bundles. Internally, the same authority,
control, evidence, continuity, generated-read-model, run lifecycle, mission, and
authorization boundaries remain intact.
