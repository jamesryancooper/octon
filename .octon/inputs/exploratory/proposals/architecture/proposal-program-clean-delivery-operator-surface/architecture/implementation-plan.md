# Implementation Plan

1. Add the clean-delivery command surface after route semantics are fixed in the accepted child packet.
2. Add route-graph preview output from the lifecycle runner without changing route authority.
3. Surface architecture-review dependencies as explicit route graph edges for architecture proposal packets.
4. Simplify delivery admission input discovery and binding without weakening profile or preflight validation.
5. Align route names, command names, docs, and runner messages.
6. Add regression fixtures covering full clean-delivery route shape and blocked/resume cases.

Each step is owned by its child packet. Parent sequencing does not authorize implementation or satisfy child evidence.
