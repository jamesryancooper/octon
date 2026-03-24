# Archive Normalization Inventory

This inventory covers repair work inside the proposal archive that must be completed or explicitly excluded before the promoted proposal system can claim a clean archive boundary.

## Rules
- The main archive must contain only standard-conformant archived proposal packets.
- Every archived packet in the main registry must have `status: archived`.
- Archived packets must carry valid `archive.*` metadata.
- Implemented archives must keep promotion evidence.
- Historical imports may stay only under explicit `legacy-unknown` handling and may not re-enter active state without normalization.

## Repair Table
| Item | Current state | Required action | Exit evidence | Split trigger |
| --- | --- | --- | --- | --- |
| `mission-scoped-reversible-autonomy` | Archive path exists, but the visible manifest still looks active | Rewrite the packet into archived shape or temporarily remove it from the main registry | Archived manifest validates and registry rebuild passes | None unless packet contents are missing |
| `self-audit-and-release-hardening` | Archived lineage uses invalid `archived_from_status: proposed` | Recover the real prior state or reclassify as historical import | Valid `archived_from_status` and rebuilt registry | If the real prior state cannot be reconstructed |
| `harness-integrity-tightening` | Registry projects invalid `archived_from_status: proposed` | Repair the source packet and regenerate the registry | Registry entry validates | If the source packet cannot be found |
| `capability-routing-host-integration` | Registry entry exists without a fully visible packet | Reconstruct the archived packet or exclude it from the main registry | Complete packet exists and validates, or registry entry is removed | If packet reconstruction requires separate historical recovery |
| Legacy design imports | Mixed historical lineage from `.archive/.design-packages/**` | Normalize to standard packets or move to a separate historical-import projection | Every main-registry archived design entry resolves to a standard packet | If the import volume is large enough to justify a companion migration proposal |

## Handling Rule
If the repair set expands materially beyond the items above, open a companion migration proposal `proposal-registry-and-archive-normalization` and keep this architecture proposal focused on the durable contract, generator, validator, and workflow changes.
