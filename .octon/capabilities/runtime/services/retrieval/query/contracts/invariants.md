# Query Invariants

1. `command` MUST be one of `ask`, `retrieve`, or `explain`.
2. Keyword, graph, fusion, and citation stages are deterministic for identical request payload + snapshot artifacts.
3. Semantic scoring is agent-interpreted and may vary by model/runtime; semantic score values are not fixture-locked.
4. Every citation `chunk_id` MUST appear in `candidates`.
5. Every evidence record MUST reference a valid citation locator and chunk ID.
6. Missing required artifacts for enabled required signals MUST return `status=error` with a typed error code.
7. Missing artifacts for optional signals MUST return `status=partial` and list degraded signals in diagnostics.
8. Core contracts remain native-first: no adapter keys or provider-specific terms are allowed in core input/output schemas.
9. `guide.md` is design context only; `SERVICE.md` and contract artifacts are authoritative.
10. Fixture coverage remains behavior-family complete: `ask`, `retrieve`, and `explain` each include positive, negative, and edge fixtures.
11. `ask` responses MUST include non-empty `answer` when `status` is not `error`.
12. Advanced routes (`hierarchical`, `graph_global`) MUST require `graph` in `strategy.use`.
13. Provider-specific terms and backend-specific mappings are confined to `adapters/` and MUST NOT appear in core service files.
14. Advanced route requests MUST fail closed with typed errors when required route artifacts are unavailable.
15. Diagnostics MUST emit `route_applied` and it MUST only be `true` when the requested route path executed successfully.
