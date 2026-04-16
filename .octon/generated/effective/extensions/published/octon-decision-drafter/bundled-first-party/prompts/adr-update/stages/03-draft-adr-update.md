# Draft ADR Update

Draft the ADR update in the requested output mode.

## Required Shape

- include the label `Draft / Non-Authoritative`
- cite the diff basis and retained evidence basis
- prefer addendum-style text that can be reviewed and applied by a human

## Output Mode Rules

- `inline`: return a suggested ADR addendum with placement guidance
- `patch-suggestion`: return a suggested edit only when `draft_target_path`
  points to the resolved ADR file
- `scratch-md`: write scratch support material only under the generic skill
  checkpoint and run-evidence roots

Never auto-edit the ADR file, decision index, or decision evidence bundle.
