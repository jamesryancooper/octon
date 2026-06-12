# Child Packet Contract

Each child packet must:

- own its own `proposal.yml` and `architecture-proposal.yml`;
- declare concrete durable promotion targets;
- include target architecture, acceptance criteria, implementation plan,
  source-of-truth map, artifact catalog, implementation-grade completeness
  receipt, and scaffold receipt;
- preserve `release_state: pre-1.0` and `change_profile: atomic`;
- keep proposal-local artifacts non-authoritative;
- never rely on parent summaries to satisfy implementation, validation,
  conformance, drift/churn, promotion, or closeout receipts;
- produce child-owned retained evidence before claiming implementation;
- preserve generated outputs as derived-only and publish them through existing
  scripts.

## Parent Contract

The parent may coordinate sequence, dependencies, common naming, common
authority boundaries, and aggregate validation reporting. It may not:

- create child receipts;
- approve child implementation;
- mutate child lifecycle status as a substitute for child review;
- authorize closeout;
- promote durable child targets;
- archive implemented children without child-owned conformance and drift/churn
  receipts.

## Child Review Bar

Before any child becomes accepted or implementation-authorized, it must pass the
proposal standard, architecture proposal validation, implementation-readiness
validation, and the native Pre-Integration Architecture Review gate once that
gate exists.
