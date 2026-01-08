# Content Plane Problem Severity Matrix

**Rating scale:** Non-issue | Minor friction | Significant hurdle | Dealbreaker

|  # | Core problem                                       | Final severity for Harmony | Why (Harmony context)                                                             | HCP mitigation                                                                                  |
| -: | -------------------------------------------------- | -------------------------- | --------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------- |
|  1 | Editorial interfaces without git knowledge         | **Non-issue** (default)    | Harmony's primary editors are devs + agents; non-git SMEs are edge cases.         | GitHub web editor; agent-mediated edits; optional git-backed UI later.                          |
|  2 | Real-time collaboration & merge conflicts on prose | **Significant hurdle**     | Conflicts are semantic; with parallel agents it can thrash even in small teams.   | Bundle granularity; lease-based coordination; append-only logs per session; CI overlap checks.  |
|  3 | Structured data that must be queryable             | **Significant hurdle**     | Grep can't answer real content questions; agents need queryable state.            | Zod validation + build-time SQLite/JSON index + query helpers.                                  |
|  4 | Content reuse without denormalization              | **Significant hurdle**     | "Pricing in 3 places / legal in 47 pages" becomes painful fast.                   | Canonical entities + explicit references + IR composition + impact graph.                       |
|  5 | Multi-destination publishing                       | **Significant hurdle**     | Harmony explicitly needs web/app/email/agent outputs; "markdown=page" breaks.     | IR compiled once → destination renderers.                                                       |
|  6 | AI agent-facing content                            | **Non-issue** if designed  | Agents love files; the risk is unvalidated output—solved with schemas + gates.    | Agent artifacts are first-class content types; schemas + lifecycle rules + provenance.          |
|  7 | The "building a CMS" trap                          | **Significant hurdle**     | Knut's "six months" warning is real; bespoke tooling can sprawl.                  | Hard boundaries, "compiler not product," adopt tools not UI, quarterly "tooling budget" check.  |
