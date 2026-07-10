# Operator Disclosure

What changes for a human operator or agent when this packet is implemented, and
what deliberately does not.

## What Becomes Available

- Four companion architecture-review methods gain authored doctrine an operator
  can read before selecting them for a review:
  - **Architecture Tradeoff Review** (`tradeoff-review-method`) — choose among ≥2
    candidate designs; produces an ADR-ready recommendation.
  - **Failure-Mode Architecture Review** (`failure-mode-review-method`) — harden a
    chosen design against failure/drift/bypass/partial-execution/evidence-loss.
  - **Evolution/Fitness Architecture Review** (`evolution-fitness-review-method`) —
    keep a long-lived mechanism healthy with fitness functions and revisit cadence.
  - **Boundary/Authority Architecture Review** (`boundary-authority-review-method`)
    — verify where authority actually lives and what must never become authority
    (Octon-only in v1).
- Each doc is discoverable from the mechanism `README.md` References and from
  `naming.yml` `methods.catalog[].doc`.

## How To Select A Method (unchanged mechanism)

Method selection remains what `naming.yml` and `review-routing.yml` already
define: every review run selects exactly one method; **Balanced remains the
default** when none is selected. Selecting a method not in `naming.yml`
`methods.catalog` fails closed (`unknown_method`); a routing decision that selects
a method but omits the method record fails closed (`missing_method_record`). This
packet adds no new selection surface, command, or flag.

## What Does NOT Change

- No new review occasion, routed workflow mode, evidence root, lifecycle gate, or
  command facade. Companion methods are invoked within existing review routes and
  proposal-lifecycle contexts.
- No method output gains authority. Every method's output is retained evidence or
  proposal input; the **pre-integration architecture review support receipt
  remains the only lifecycle-gating review artifact**. A method report treated as
  implementation authority is out of contract.
- Readiness-audit and surface-architecture-audit doctrine are unchanged; the new
  docs cite them as boundaries and do not duplicate them.
- No report/routing-decision schema field is added here (that is the
  schema-extensions child); method-id recording in run evidence and advisory
  lifecycle text is the suite-integration child.

## Boundaries An Operator Should Know

- **Failure-Mode Review ≠ readiness verdict.** Use the Architecture Readiness Audit
  (and its mandatory failure-mode analysis) when you need a readiness score;
  Failure-Mode Review hardens a design and issues no readiness verdict.
- **Boundary/Authority Review ≠ single-unit classification.** Use the Surface
  Architecture Audit for a single unit's `contract-first`/`mixed`/
  `markdown-first`/`human-led` authority-model classification;
  Boundary/Authority Review reviews authority placement/containment across a
  design and escalates single-unit follow-ups to that audit.
