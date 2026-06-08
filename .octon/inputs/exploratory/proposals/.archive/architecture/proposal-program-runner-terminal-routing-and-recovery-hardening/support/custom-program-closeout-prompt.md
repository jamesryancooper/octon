# Program Closeout Prompt

```yaml
verdict: pass
generated_at: "2026-06-08T17:38:13Z"
generator_route_id: "generate-program-closeout-prompt"
program_packet_path: ".octon/inputs/exploratory/proposals/architecture/proposal-program-runner-terminal-routing-and-recovery-hardening"
child_receipt_summary_count: 9
child_authority_preserved: yes
```

Close out the terminal-routing parent only after confirming the parent
aggregate conformance and drift/churn receipts pass and preserve child
authority.

The closeout receipt must include `verdict`, `closed_at`,
`archive_authorized`, `child_authority_preserved`, selected git route,
worktree hygiene fields, cleanup summary, and next route condition. Parent
closeout must authorize only the separate `archive-proposal` route and must not
archive or mutate child packet state.
