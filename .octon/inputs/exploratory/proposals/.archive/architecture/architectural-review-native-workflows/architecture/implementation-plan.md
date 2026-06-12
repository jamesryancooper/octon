# Implementation Plan

1. Create workflow directories with `workflow.yml`, `README.md`, and stage
   files following current workflow conventions.
2. Define workflow inputs for subject path, review mode, proposal packet, target
   mechanism, and evidence root.
3. Emit reports and support receipts using schemas from the schemas child.
4. Add workflow validators and fixture runs.
5. Preserve `architecture-readiness-audit` as the canonical workflow slug.
6. Retain implementation, conformance, and drift/churn receipts before closeout.

## Strict Receipt Requirements

Workflow outputs must include schema-backed support receipts with validator refs
and evidence refs. Workflow reports alone cannot satisfy lifecycle gates.
