# Proposal Program Delivery Operator Alias

This child packet adds an optional operator alias remembered as "Run Program to Clean Delivery".

The alias must delegate to the canonical `proposal-program-delivery` wrapper. It must not define an independent workflow, lifecycle contract, closeout route, archive route, cleanup route, or terminal proof rule.

## Boundary

Host projection publication for the alias is intentionally out of this child and belongs to the repo-local host projection child. This child owns only the canonical Octon alias source.
