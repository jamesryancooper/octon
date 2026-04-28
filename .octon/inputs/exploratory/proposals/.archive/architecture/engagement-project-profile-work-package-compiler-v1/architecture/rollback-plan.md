# Rollback Plan

## Rollback posture

This proposal is additive. It creates a new compiler layer and does not replace run lifecycle, execution authorization, context-pack builder, support targets, or mission contracts.

## Rollback triggers

Rollback or disable the compiler if:

- it writes project code during preflight;
- it marks non-admitted connectors live;
- it bypasses `octon run start --contract` for material execution;
- it uses generated/read-model outputs as authority;
- it depends on proposal-local files after promotion;
- validators cannot distinguish control truth from retained evidence;
- run-contract candidates omit required run-contract v3 fields;
- unsupported surfaces are not fail-closed.

## Rollback actions

1. Disable new CLI commands or route them to prepare-only diagnostics.
2. Keep new schema files only as draft/experimental if already promoted; mark inactive in registry if registry supports status.
3. Remove or quarantine generated Engagement read models.
4. Preserve retained evidence under `state/evidence/**` for forensic continuity.
5. Do not delete canonical run evidence or existing run lifecycle artifacts.
6. Revert instance policies for evidence profiles and preflight lane if they create invalid authorization behavior.
7. Restore existing run-first workflow as the only material execution entrypoint.

## Safe fallback

The safe fallback is current Octon behavior: use bootstrap/ingress, run preflight doctor checks, create or inspect a canonical run contract manually, then enter through `octon run start --contract`.
