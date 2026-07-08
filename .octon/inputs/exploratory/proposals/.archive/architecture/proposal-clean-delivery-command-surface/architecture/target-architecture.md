# Target Architecture

The command surface exposes a clear operator entry point such as:

```text
octon lifecycle run-clean-delivery --target <program> --run-id <id> --max-steps <n>
```

or an equivalent approved command wrapper.

The command expands to the proposal-program lifecycle runner with:

- lifecycle set to `proposal-program`
- route execution enabled
- `target_outcome=cleaned` bound as a request
- bounded step controls
- route graph preview available before mutation
- resume behavior that uses existing run evidence

The command must not report `cleaned` unless the owning delivery, closeout, cleanup, sync, and terminal proof evidence passes.
