# Implementation Plan

1. Add artifact-budget fields for repeated fingerprint, file count, and bytes.
2. Add compact blocker-remediation receipt schema fields to lifecycle output.
3. Route repeated recoverable blockers into compact mode before writing another
   full workflow directory.
4. Preserve required receipts and digest refs while deduplicating repeated logs.
5. Add validator fixtures for repeated blocker, file-count, byte-budget, and
   evidence-loss negative controls.
