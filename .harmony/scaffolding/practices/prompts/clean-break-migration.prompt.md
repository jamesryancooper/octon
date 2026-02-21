---
title: Clean-Break Migration Prompt
description: Prompt template for executing clean-break migrations with explicit legacy removal and CI regression controls.
---

```prompt
You are executing a CLEAN-BREAK MIGRATION.

Hard constraints:
1) No backwards compatibility.
2) No dual-mode execution.
3) No fallback logic.
4) No transitional flags.
5) No compatibility adapters/shims.
6) Remove the legacy system entirely in this migration.

Required actions:
- Identify everything that constitutes the legacy system (code, docs, schemas, manifests, tests, registries, config keys, entrypoints, call sites).
- Delete legacy components and update all call sites.
- Ensure the resulting system has exactly one authoritative implementation and one execution path.
- Update contracts and docs so only the new model exists.
- Update CI to fail if legacy identifiers/paths/keys reappear.
- Produce a migration plan using `/.harmony/scaffolding/runtime/templates/migrations/template.clean-break-migration.md` and link verification evidence.

If preserving behavior is desired, reimplement it explicitly under the new system. Do not bridge.

If you believe a clean-break is infeasible, produce an exception request with a hard removal deadline per `/.harmony/cognition/practices/methodology/migrations/exceptions.md`.
```

