# Validation Plan

| Proof | Method | Evidence transition |
| --- | --- | --- |
| Semantic closure/classification | static inspection and adversarial mutation matrix | `UNVERIFIED` → `STATICALLY_INSPECTED` / `ADVERSARIALLY_TESTED` |
| Inert exact install | dynamic execution | `UNVERIFIED` → `DYNAMICALLY_EXECUTED` |
| Candidate self-widening and wrong artifact/epoch/approval/provider | adversarial test | `UNVERIFIED` → `ADVERSARIALLY_TESTED` |
| Install/switch/health/receipt/reboot/disk-full kill points | fault injection | `UNVERIFIED` → `ADVERSARIALLY_TESTED` |
| Current provider assumptions | provider observation | `UNVERIFIED` → `PROVIDER_OBSERVED` |

Evidence binds exact old/new versions, commits, inventory, provider, epoch,
platform, fault point, selector history, health result, and rollback result.
