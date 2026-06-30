# Implementation Plan

1. Review hygiene and run-health read-model tests to identify writes into tracked generated projection paths.
2. Add generator options or test harness configuration for temporary output roots when needed.
3. Move test fixtures into fixture-owned locations and keep generated projection checks read-only.
4. Add post-test status assertions for tracked generated run-health projections.
5. Retain evidence that the tests pass and leave generated projections unchanged.
