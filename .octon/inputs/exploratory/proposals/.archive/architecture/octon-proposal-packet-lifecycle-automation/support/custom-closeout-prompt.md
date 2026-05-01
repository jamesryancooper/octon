# Custom Closeout Prompt

Perform full closeout for the proposal packet at:

`.octon/inputs/exploratory/proposals/architecture/octon-proposal-packet-lifecycle-automation/`

## Required Closeout

1. Verify implementation and follow-up verification are clean.
2. Verify the implemented extension pack includes the full Proposal Program
   pattern and program route family.
3. Promote or archive the proposal using existing proposal lifecycle workflows.
4. Regenerate proposal registry only when all visible proposal packets are
   intended to participate in the registry projection.
5. Perform housekeeping before staging:
   - exclude incidental build/output/cache artifacts,
   - decide intentionally whether prompt scaffolding and skill logs belong,
   - preserve required generated outputs and evidence outputs.
6. Stage only intended changes.
7. Commit with an Octon-compliant Conventional Commit message.
8. Open a PR.
9. Investigate every failing check, job, and script.
10. Fix failures in a way that matches Octon's target architecture and live repo
   state.
11. Re-run checks until required checks pass.
12. Verify no unresolved PR review conversations remain.
13. Resolve every open review conversation.
14. Verify the working tree is clean and no further hygiene work is required.
15. Merge only when required checks are green and review conversations are
    resolved.
16. After merge, close local and remote branches.
17. Confirm local and origin are fully synced.

## Boundaries

- Do not merge with failing required checks.
- Do not merge with unresolved review conversations.
- Do not delete user work or unrelated untracked files.
- Do not treat GitHub comments, labels, checks, or dashboards as Octon
  authority except as retained closeout evidence when captured.
