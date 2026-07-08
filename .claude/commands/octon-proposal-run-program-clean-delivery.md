# Program - Run Clean Delivery

Request proposal-program clean-delivery continuation through the existing
proposal-program lifecycle runner:

```text
/octon-proposal-run-program-clean-delivery <program-packet-path> --run-id <id> [--max-steps <n>] [--max-child-concurrency <n>] [--executor auto|codex|mock]
```

This operator alias expands to the canonical command surface:

```text
/proposal-program-clean-delivery target=<program-packet-path> run-id=<id> [max-steps=<n>] [max-child-concurrency=<n>] [executor=auto|codex|mock]
```

That surface previews the non-authoritative route graph first, then invokes:

```text
octon lifecycle run --lifecycle proposal-program --target <program-packet-path> --run-id <id> --execute-routes --invocation-authority unattended --set target_outcome=cleaned
```

## Authority Boundary

This command is an alias and request surface only. It does not create an
independent lifecycle contract, workflow id, skill authority, closeout rule,
archive rule, cleanup rule, Git mutation rule, branch cleanup rule, generated
publication rule, receipt schema, profile schema, terminal proof rule, or
target-owned evidence substitute.

`target_outcome=cleaned` remains a request. Cleaned delivery can be claimed only
by the owning delivery, closeout, archive, Change closeout, landing, sync,
cleanup, and terminal-proof evidence after those canonical routes pass.
