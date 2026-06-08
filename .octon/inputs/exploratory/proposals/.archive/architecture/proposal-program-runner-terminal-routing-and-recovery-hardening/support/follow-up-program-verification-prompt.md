# Program Verification Prompt

```yaml
verdict: pass
generated_at: "2026-06-08T17:38:13Z"
generator_route_id: "generate-program-verification-prompt"
program_packet_path: ".octon/inputs/exploratory/proposals/architecture/proposal-program-runner-terminal-routing-and-recovery-hardening"
child_receipt_summary_count: 9
child_authority_preserved: yes
```

Verify the terminal-routing parent program after implementation by checking
the archived child packet set, parent implementation orchestration run
receipt, aggregate child receipt state, dependency closure, and worktree
hygiene.

Required aggregate outputs:

- `support/program-implementation-orchestration-conformance-review.md`
- `support/program-post-implementation-orchestration-drift-churn-review.md`

The verification loop must summarize child outcomes only. It must not replace
child-owned implementation receipts, validation verdicts, closeout receipts,
archive metadata, or promotion evidence.
