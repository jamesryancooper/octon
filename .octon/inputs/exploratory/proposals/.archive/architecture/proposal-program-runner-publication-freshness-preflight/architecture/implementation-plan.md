# Implementation Plan

1. Identify route-dispatch points that already fail on freshness drift.
2. Add pre-dispatch freshness classification for runtime route bundle,
   extension catalog, pack routes, and capability routing surfaces.
3. Emit one retained blocker with exact canonical recovery commands or route
   actions.
4. Replan after recovery and verify freshness cleared.
5. Add tests for stale and fresh states.
