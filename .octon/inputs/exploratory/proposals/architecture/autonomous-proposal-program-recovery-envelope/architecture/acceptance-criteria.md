# Acceptance Criteria

- Envelope can autonomously run low-risk routes such as generated refresh, review refresh, lifecycle-residue classification, evidence-index materialization, and diagnostics.
- Envelope stops before archive, push, landing, cleanup deletion, branch deletion, PR creation or merge, external publication, and cleaned claim.
- Every autonomous recovery action retains route evidence and reruns the failed gate plus surrounding gate set.

## Safety Acceptance

- No parent evidence replaces child-owned evidence.
- No PR fallback is introduced.
- No protected retained evidence is deleted.
- No generated output is hand-edited.
