# Implementation Plan

1. Add `generate-retained-run-evidence-index.sh` under the assurance runtime
   scripts directory.
2. Make the script accept `--package`, `--run-id`, `--write`, optional
   `--root`, and optional deterministic `--generated-at`.
3. Validate the target proposal packet before writing:
   - status is `implemented`;
   - `support/proposal-review.md` exists and is accepted;
   - `support/implementation-run.md` has `verdict: pass`;
   - `support/implementation-conformance-review.md` has `verdict: pass`;
   - `support/post-implementation-drift-churn-review.md` has `verdict: pass`;
   - `support/validation.md` exists.
4. Write retained materialization evidence and the retained-run evidence index
   with digest-bound refs.
5. Validate the written index with
   `validate-retained-run-evidence-index.sh --index <index>`.
6. Add a focused test covering:
   - valid index materialization;
   - missing child implementation verdict failure;
   - digest drift failure after source tampering.
7. Record implementation, conformance, drift, and validation receipts in this
   packet's `support/` directory.

No dependency changes are required.
