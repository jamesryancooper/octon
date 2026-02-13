# Content Plane Overview

Harmony should adopt a **flat-file-first "content compiler"**: **files in git are the source of truth**, and a deterministic build pipeline compiles them into a **queryable Content Graph** (SQLite + JSON + dependency graph) and **multi-destination outputs** (web/app/email/agent context). This approach keeps the "content is just code" agent ergonomics (agents can read/write without an authenticated API boundary) while directly addressing the legitimate "you can't delete the underlying problems" CMS arguments—**queryability, reuse, collaboration friction, and multi-destination delivery**—at build time rather than via a runtime CMS product.  

**Final recommendation:** ship **Harmony Content Plane (HCP)**: a content compiler/toolchain that turns typed flat files into a **Harmony Content Graph (HCG)** and destination-specific renders. This preserves simplicity and reversibility (git), reduces agent friction, and avoids "CMS creep" via strict boundaries.

When build-time-only delivery is insufficient (e.g., content must update without deployment, personalization is required, or real-time collaboration is needed), an **optional runtime content layer** can extend the canonical model—see [runtime-content-layer.md](./runtime-content-layer.md) for the hybrid architecture.  

## Key architectural decisions

- **Source of truth is git-tracked files** (YAML/JSON + Markdown), treating "markdown in git" as **an input format**, not "the system."
- **Document envelope + typed blocks** for high-reuse content; keep prose simple when reuse isn't needed.
- **Explicit references** (`ref:<type>:<id>[@locale]`) + build-time resolution; no magical string-grep workflows.
- **Build-time indexes** (SQLite + JSON + dependency graph) enable semantic querying and blast-radius/impact analysis without runtime CMS infrastructure.  
- **Three content surfaces** (public, internal, agent-facing) share the same infrastructure; "surface" is a **metadata concern** and also optionally represented in folder layout for clarity.
- **Continuity artifacts are first-class**: `.continuity/` artifacts (backlog, plan, handoff, progress, decisions) are validated, indexed, referenced, and exported to agent context—with specialized lifecycle rules (append-only logs, session-scoped briefs).
- **Runtime layer is optional**: when boundary conditions are crossed, a tiered runtime layer (edge read → central read → write) can extend canonical content without replacing the source of truth.  

## Top things this enables

- **Agent-native authoring** without the CMS authentication boundary Lee called out (agents can "grep" and change content directly), but with guardrails and schemas.
- **Schema-aware querying** like "top 3 finance case studies by date" and "products with price > $100 in stock" (i.e., *not grep*).
- **Reuse with control** (pricing in 3 places / legal text in 47 pages solved via canonical entities + references).
- **Deterministic multi-destination publishing** via an Intermediate Representation (IR) compiled once and rendered many ways.
- **Continuity as infrastructure**: agent runs leave structured trails (backlog, decisions, progress events) that are queryable and safely reusable.

## Top things this explicitly avoids

- Building a full CMS product (WYSIWYG, workflow engine, scheduling, RBAC, hosted DB sync).
- Real-time collaborative editing as a dependency (CRDT/Google-Docs-style). We mitigate instead via file granularity + leasing + orchestration.
- Runtime content mutation/authoring APIs as a default (unless boundary conditions are crossed—see [runtime-content-layer.md](./runtime-content-layer.md and [boundary-conditions.md](./boundary-conditions.md) for escalation paths).
