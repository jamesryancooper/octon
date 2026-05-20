# Octon Drift Triage

Run the `octon-drift-triage` remediation bundle.

Behavior:

- normalizes changed-path inputs from explicit paths, Git diff refs, or an
  existing packet
- selects existing read-only validators and recommendation bundles from the
  pack-authored routing table
- returns a ranked remediation packet in `mode=select`
- optionally runs the selected direct checks plus conditional
  `repo-hygiene.sh scan` in `mode=run`
- never publishes outputs or writes to `state/control/**`

Defaults:

- `mode=select`
- `alignment_mode=auto`
- `diff_head=HEAD` when `diff_base` is present and `diff_head` is omitted
- when no explicit inputs are given, changed paths come from
  `git diff --name-only HEAD --` plus `git ls-files --others --exclude-standard`

Input notes:

- `--changed-paths` accepts comma-separated or newline-separated repo-relative
  paths.
- `--diff-head` requires `--diff-base`.
- `--packet-path` refreshes an existing packet. If it is the only input, the
  bundle reloads `packet.yml` from that packet and reuses the stored input set.

Output:

- default package root:
  `/.octon/inputs/exploratory/reports/<YYYY-MM-DD>-octon-drift-triage-<input-slug>/`
- required artifacts:
  `packet.yml`, `README.md`, `reports/changed-paths.md`,
  `reports/check-selection.md`, `reports/check-results.md`,
  `reports/ranked-remediation.md`, `plans/remediation-plan.md`,
  `prompts/maintainer-remediation-prompt.md`
- optional raw check captures under `support/raw-check-output/` in `mode=run`

The prompt bundle manifest is the source of truth for bundle inventory,
alignment defaults, repo anchors, and managed artifact names.
