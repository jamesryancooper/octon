# Target Architecture

Proposal-program execution becomes ownership-aware before any mutating route runs.

## Target Behavior

- Capture start-of-run baseline state before route selection.
- Record route write leases with route id, child id when present, owned path set, excluded path set, evidence refs, and expiry semantics.
- Prefer isolated worktree execution when the current worktree contains unrelated residue or cannot prove ownership.
- Classify paths as owned, leased, foreign/manual, protected retained evidence, active control state, generated output, child-owned receipt, or ambiguous.
- Block mutation on ambiguous, protected, foreign/manual, generated-only, or child-owned receipt paths unless a separate owning route authorizes the action.

## Safety Properties

- A lease cannot widen beyond declared route scope.
- Classifier evidence is routing evidence only.
- Proposal inputs remain non-authoritative.
- Parent summaries cannot become child receipt authority.
