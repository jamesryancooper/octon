---
name: octon-proposal-lifecycle-run-program-verification-and-correction-loop
description: Run the program verification-and-correction convergence bundle.
license: MIT
compatibility: Octon proposal lifecycle extension.
metadata:
  author: Octon Framework
  created: "2026-04-30"
  updated: "2026-04-30"
skill_sets: [executor, verifier]
capabilities: [self-validating]
allowed-tools: Read Glob Grep Write(/.octon/inputs/exploratory/proposals/*) Write(/.octon/state/control/skills/checkpoints/*) Write(/.octon/state/evidence/runs/skills/*)
---

# Program - Run Verification And Correction Loop

The loop must include the implementation-grade completeness gate outcome and cannot close
clean while any program packet lacks a passing completeness receipt.

When a child packet is implemented, the loop must also include packet-level
implementation conformance and post-implementation drift/churn gate outcomes. Missing
or failing post-implementation receipts keep the program open unless the child
records an explicit blocked/deferred report outcome or rejected, superseded, or
historical archive disposition.

Run parent and child verification, targeted corrections, and re-verification
until the program reaches a declared terminal state.

On aggregate pass, write parent-local
`support/program-implementation-orchestration-conformance-review.md` and
`support/program-post-implementation-orchestration-drift-churn-review.md` with `verdict:
pass` and `child_authority_preserved: yes` only when child manifests, receipts,
promotion targets, validation verdicts, archive metadata, and terminal outcomes
remain child-owned.

If parent-local `support/lifecycle-residue-cleanup.md` reports
`worktree_hygiene_verdict: blocked`, `closeout_blocking: true`, or
`archive_blocking: true`, check the lifecycle interaction returns supplied to
the route and the default parent return path:
`.octon/state/evidence/runs/workflows/<run-id>/lifecycle-interactions/parent-closeout-worktree-return.json`.
Accept that residue as resolved only when the return validates with
`validate-lifecycle-interaction-receipts.sh --return <return-ref>`, the returned
`closeout-worktree-report-v1` validates with
`validate-closeout-worktree-wrapper.sh --report <report-ref>`, and the report
contains parent handoff authorization to
`preserve-and-exclude-from-lifecycle-closeout-blocking` for the current cleanup
receipt/classifier digest, residue fingerprint, and retained path set. In that
case the aggregate receipts may record `verdict: pass` with a
`resolved-by-validated-parent-closeout-worktree-return` hygiene disposition when
all other aggregate gates pass. This disposition does not authorize deletion,
cleanup, archive relocation, Git mutation, publication edits, `cleaned` claims,
or child-owned evidence.
