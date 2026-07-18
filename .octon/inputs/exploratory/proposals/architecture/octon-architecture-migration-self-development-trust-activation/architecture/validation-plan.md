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

Static proposal gates additionally verify all 19 parent/child targets, accepted
dependency digests, the RP-01-only issuer boundary, RFC-8785/SHA-256 closure,
same-filesystem immutable install, two-slot selector recovery, zero defaults or
wildcards, and that future UE/provider/fault evidence is not claimed executed.
Dynamic activation proof must exercise 10-second probes for 600 seconds, 60
successes, one-critical/three-ordinary triggers, 30-second rollback, version
pins, slot tear/reboot/disk-full, bootstrap replay, and every wrong-envelope
field before safe-automatic activation or promotion.
