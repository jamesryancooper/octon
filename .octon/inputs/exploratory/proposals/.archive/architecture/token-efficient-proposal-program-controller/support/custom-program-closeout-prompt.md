# Custom Program Closeout Prompt

```yaml
verdict: pass
generated_at: "2026-06-08T18:03:54Z"
generator_route_id: "generate-program-closeout-prompt"
program_packet_path: ".octon/inputs/exploratory/proposals/architecture/token-efficient-proposal-program-controller"
child_receipt_summary_count: 12
child_authority_preserved: yes
```

Close out the token-efficient parent program only after confirming that
parent-local aggregate conformance and drift/churn receipts pass. Child packet
evidence remains child-owned authority and must not be replaced by parent
summary text.

The closeout receipt must record:

- `verdict`
- `closed_at`
- `archive_authorized`
- `archive_disposition`
- `child_authority_preserved`
- `selected_git_route`
- worktree hygiene counts and evidence
- cleanup summary
- next route condition
