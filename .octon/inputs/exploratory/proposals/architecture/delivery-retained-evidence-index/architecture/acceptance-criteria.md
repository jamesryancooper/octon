# Acceptance Criteria

- Index includes refs, digests, disclosure tier, route, outcome, validator results, and non-authority classification.
- Detailed local sink content remains private/local and is not promoted as authority.
- Index is retained under state/evidence/runs/** or the canonical delivery evidence root.

## Safety Acceptance

- No parent evidence replaces child-owned evidence.
- No PR fallback is introduced.
- No protected retained evidence is deleted.
- No generated output is hand-edited.
