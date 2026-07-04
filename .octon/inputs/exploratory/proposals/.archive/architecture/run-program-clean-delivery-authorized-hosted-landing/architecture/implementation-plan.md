# Implementation Plan

1. Add authorization-consuming execution flag semantics to hosted no-PR landing.
2. Bind the flag to current receipt validation rather than new chat approval.
3. Validate live refs, exact SHA, checks, no-PR status, provider controls,
   rollback handle, and final sync plan immediately before mutation.
4. Retain execution and final sync evidence.
5. Add negative controls for stale receipts, ref drift, provider denial,
   failed checks, missing rollback, and force-push requirements.
