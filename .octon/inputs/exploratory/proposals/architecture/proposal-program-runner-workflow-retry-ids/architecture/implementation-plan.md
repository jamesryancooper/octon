# Implementation Plan

1. Identify how child route attempts are numbered and exposed to executor
   requests.
2. Make workflow leaf run ids include an attempt ordinal for retry dispatch.
3. Add explicit existing-run resume checks rather than reusing the same id by
   accident.
4. Record invocation evidence with parent run id, child id, route id, attempt
   ordinal, and workflow run id.
5. Add regression tests for duplicate workflow run-id collisions.
