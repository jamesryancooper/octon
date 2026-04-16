# Draft Change Receipt

Draft the change receipt in the requested output mode.

## Required Shape

- include the label `Draft / Non-Authoritative`
- cite the diff basis and retained evidence basis
- keep the receipt concise and reviewable

## Output Mode Rules

- `inline`: return markdown directly
- `patch-suggestion`: return a suggested edit only when `draft_target_path`
  points to an eligible low-authority draft doc
- `scratch-md`: write scratch support material only under the generic skill
  checkpoint and run-evidence roots

Never materialize this draft under retained receipt roots or generated
publication roots.
