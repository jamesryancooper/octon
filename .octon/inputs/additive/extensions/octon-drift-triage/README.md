# Octon Drift Triage

`octon-drift-triage` is a first-party additive extension pack that turns
changed paths into a ranked remediation packet for Octon maintainers.

## Interface

- Command: `/octon-drift-triage`
- Skill: `octon-drift-triage`
- Prompt bundle: `octon-drift-triage-remediation-packet`

Arguments:

```text
[--changed-paths <csv>] [--diff-base <ref>] [--diff-head <ref>] [--packet-path <path>] [--mode select|run] [--alignment-mode auto|always|skip]
```

Defaults:

- `mode=select`
- `alignment_mode=auto`
- `diff_head=HEAD` when `diff_base` is set and `diff_head` is omitted
- current worktree diff plus untracked files when no explicit inputs are given

## Inputs

V1 accepts:

- explicit changed paths
- Git diff refs
- an existing triage packet path for refresh
- any additive combination of the above

If `packet_path` is supplied without fresh changed-path inputs, the bundle
reloads `packet.yml` from that packet and reuses its stored inputs.

Examples live in:

- `context/examples.md`

## Output

The bundle materializes a non-authoritative report under:

`/.octon/inputs/exploratory/reports/<YYYY-MM-DD>-octon-drift-triage-<input-slug>/`

The output package always contains:

- `packet.yml`
- `README.md`
- `reports/changed-paths.md`
- `reports/check-selection.md`
- `reports/check-results.md`
- `reports/ranked-remediation.md`
- `plans/remediation-plan.md`
- `prompts/maintainer-remediation-prompt.md`

When `mode=run`, the packet may also include:

- `support/raw-check-output/<check-id>.txt`

## Boundaries

- Additive only. Feature logic stays under `inputs/additive/extensions/**`.
- The packet is a planning/report artifact, not a runtime, policy, or closure
  authority surface.
- V1 selects existing checks, optionally runs read-only checks, and ranks
  remediation. It does not apply patches, publish outputs, or write to
  `state/control/**`.
- `repo-hygiene` is conditional and scan-only. V1 never runs
  `enforce`, `audit`, or `packetize`.

## Validation

Validate the pack and its publication path with:

```bash
bash .octon/framework/assurance/runtime/_ops/scripts/validate-extension-pack-contract.sh
bash .octon/framework/orchestration/runtime/_ops/scripts/publish-extension-state.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-extension-publication-state.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-extension-local-tests.sh
bash .octon/framework/capabilities/_ops/scripts/publish-capability-routing.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-capability-publication-state.sh
bash .octon/framework/capabilities/_ops/scripts/publish-host-projections.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-host-projections.sh
```

Pack-local fixtures and tests live under `validation/**`.

The validation matrix for representative scenarios lives in:

- `validation/bundle-matrix.md`

## Publication Readiness

The pack is publication-ready when:

- `/.octon/instance/extensions.yml` enables `octon-drift-triage`
- `/.octon/generated/effective/extensions/**` publishes the pack and prompt
  bundle
- `/.octon/generated/effective/capabilities/**` publishes the command and skill
- `/.{claude,cursor,codex}/` projections include `octon-drift-triage`
- the validation commands above pass against the current published state
