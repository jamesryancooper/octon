# Promotion Safety Analysis

## Why this packet is promotion-safe

1. **It narrows, not widens, support.** The packet does not admit browser, API,
   MCP, GitHub, Studio, or frontier-governed support targets.
2. **It strengthens existing contracts.** The target is a v2 hardening of
   already-present runtime ledger/state/reconstruction concepts.
3. **It preserves authority boundaries.** Authored authority remains under
   framework/instance; live control remains under state/control; evidence remains
   under state/evidence; generated remains derived.
4. **It adds fail-closed validators.** Missing or malformed journals block
   closeout/admission instead of creating permissive behavior.
5. **It avoids a rival Control Plane.** The journal records authority and
   execution under the existing Control Plane; it does not make decisions on its
   own.
6. **It is reversible.** If v2 emission fails, support claims do not widen;
   runtime can retain v1 compatibility while v2 evidence is diagnosed.

## Promotion risk controls

- Add v2 beside v1 first.
- Require fixture evidence before making v2 mandatory.
- Keep generated outputs stale until rebuilt from canonical roots.
- Route all material append operations through runtime bus.
- Require support-target admission proof before claims change.
- Preserve v1 schemas for historical reconstruction.

## Non-promotion conditions

Do not promote if any of the following remain true:

- material side effects can occur without journal refs,
- runtime-state conflicts with journal without drift detection,
- evidence snapshot does not hash-match control journal,
- generated read model is accepted as authority,
- replay can execute live side effects without fresh grant,
- validators are not wired into architecture conformance.
