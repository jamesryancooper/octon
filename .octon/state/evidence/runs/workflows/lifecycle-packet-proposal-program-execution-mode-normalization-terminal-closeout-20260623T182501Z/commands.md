# Lifecycle Commands

Plan again:

```sh
octon lifecycle plan --lifecycle proposal-packet --target /Users/jamesryancooper/Projects/octon-proposal-program-execution-mode-normalization-closeout/.octon/inputs/exploratory/proposals/architecture/proposal-program-execution-mode-normalization
```

Selected route:

- route_id: `proposal-packet-terminal-closeout`
- route_type: `workflow`

Handoff:

The lifecycle runner selected and gated this route. For non-mock executors, it did not invoke the prompt bundle or workflow leaf.

Workflow route entry surface:

```sh
octon workflow run proposal-packet-terminal-closeout --set proposal_path=/Users/jamesryancooper/Projects/octon-proposal-program-execution-mode-normalization-closeout/.octon/inputs/exploratory/proposals/architecture/proposal-program-execution-mode-normalization
```

Add any other required `--set` inputs declared by that workflow contract before running it.
