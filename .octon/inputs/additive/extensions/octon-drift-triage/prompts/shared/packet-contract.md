# Packet Contract

This file is the single source of truth for the `octon-drift-triage` report
package contract.

## Destination

Default destination:

`/.octon/inputs/exploratory/reports/<YYYY-MM-DD>-octon-drift-triage-<input-slug>/`

Refresh destination:

`--packet-path <path>`

## Required Files

- `packet.yml`
- `README.md`
- `reports/changed-paths.md`
- `reports/check-selection.md`
- `reports/check-results.md`
- `reports/ranked-remediation.md`
- `plans/remediation-plan.md`
- `prompts/maintainer-remediation-prompt.md`

Optional:

- `support/raw-check-output/<check-id>.txt`

## `packet.yml` Contract

`packet.yml` must define:

- `schema_version`
- `packet_id`
- `generated_at`
- `input_mode`
- `changed_paths`
- `diff_base`
- `diff_head`
- `mode`
- `selected_checks`
- `recommended_bundles`
- `repo_hygiene`
- `ranking_model_version`
- `remediation_items`

Allowed values:

- `schema_version`: `octon-drift-triage-packet-v1`
- `mode`: `select` | `run`

## Field Shapes

- `selected_checks[]`
  - `check_id`
  - `family_id`
  - `status`
  - `command`
  - `report_ref`
- `recommended_bundles[]`
  - `bundle_id`
  - `status`
  - `command`
- `repo_hygiene`
  - `selected`
  - `mode`
  - `status`
- `remediation_items[]`
  - `item_id`
  - `priority`
  - `score`
  - `affected_paths`
  - `governing_checks`
  - `why_selected`
  - `recommended_actions`
  - `report_refs`

## Output Rule

- The packet is a planning and reporting artifact only.
- It must never be described as canonical authority.
- It must clearly distinguish selected checks from executed checks.
