# Current-State Gap Analysis

## Existing partial coverage

- Support-target admissions and proof bundles partially cover live claim admission.
- Capability-pack registry partially covers capability grouping.
- Material side-effect inventory partially covers side-effect classes.
- Execution authorization covers material side effects.
- Egress and budget policy references exist through the authorization contract.
- Generated/effective handle discipline prevents generated support widening.
- Watcher/automation guidance prevents event hints from becoming authority.

## Missing v4 connector-specific coverage

- No operation-level connector schema.
- No operation-level trust dossier.
- No admission lifecycle specific to external connectors.
- No connector-specific quarantine/retirement state.
- No connector drift gate.
- No runtime/CLI connector posture inspection.
- No admission validator tying operation -> capability packs -> material effects -> support posture -> policy -> authorization.
- No connector execution receipt.
- No connector-specific generated read-model rules.
- No explicit mapping from MCP operations into Octon runtime material-effect model.

## Consequence if left unresolved

Octon cannot safely widen beyond repo-local support. Broad MCP/API/browser/tool work would either remain unusable or become unsafe.
