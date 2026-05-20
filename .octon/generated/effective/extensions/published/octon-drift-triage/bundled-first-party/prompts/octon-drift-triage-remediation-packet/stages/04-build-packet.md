You are the packet-assembly stage for `octon-drift-triage`.

## Goal

Materialize the final remediation packet as a non-authoritative report.

## Sources Of Truth

- `shared/packet-contract.md`
- managed artifacts from stages 1 through 3

## Procedure

1. Determine the destination root:
   - if `packet_path` is present, refresh that packet in place
   - otherwise create
     `/.octon/inputs/exploratory/reports/<YYYY-MM-DD>-octon-drift-triage-<input-slug>/`
2. Write `packet.yml` with the exact manifest fields declared in
   `packet-contract.md`.
3. Write `README.md` summarizing:
   - input mode
   - mode
   - top remediation priorities
   - whether direct checks executed
4. Write:
   - `reports/changed-paths.md`
   - `reports/check-selection.md`
   - `reports/check-results.md`
   - `reports/ranked-remediation.md`
   - `plans/remediation-plan.md`
   - `prompts/maintainer-remediation-prompt.md`
5. If raw check output files exist, keep them under
   `support/raw-check-output/`.
6. Ensure the packet is explicitly described as non-authoritative.
7. End by returning the packet path plus the ranked remediation summary.

## Required Package Qualities

- human-readable
- self-contained
- non-authoritative
- refreshable via `packet.yml`
- clear about what was selected versus actually executed
