# Source Of Truth Map

| Concern | Current source | Proposed durable source | Authority |
| --- | --- | --- | --- |
| Proposal intent | This packet | None | Non-authoritative planning input |
| Parent sequencing | `.octon/inputs/exploratory/proposals/architecture/architecture-review-method-suite-program/resources/child-packet-index.yml` | None | Program coordination only |
| Method catalog and default | `.octon/framework/cognition/practices/methodology/architectural-review/naming.yml` (v2) | Same (owned by taxonomy-and-routing child) | Landed dependency; consumed, not changed here |
| Method selection semantics | `.octon/framework/cognition/practices/methodology/architectural-review/review-routing.yml` (v2, `method_selection`) | Same (owned by taxonomy-and-routing child) | Landed dependency; consumed, not changed here |
| Lens bank | `.octon/framework/cognition/practices/methodology/architectural-review/lens-bank.yml` + `architecture-lens-bank.md` | Same (owned by lens-bank-foundation child) | Landed dependency; consumed, not changed here |
| Method / lens evidence fields | `.octon/framework/constitution/contracts/assurance/architectural-review-report-v2.schema.json` and `-routing-decision-v2.schema.json` | Same (owned by schema-extensions child) | Landed dependency; consumed, not changed here |
| Selected-method run evidence | Not recorded today | Existing v2 routing-decision/report artifact under the existing architectural-review run-evidence root, written by the review workflow contracts after promotion | Evidence, never authority |
| Pre-integration gating artifact | `architectural-review-support-receipt-v1.schema.json` | Unchanged (remains v1, method-free) | Only lifecycle-gating review artifact; unchanged |
| Feature description | `.octon/framework/product/features/architectural-review-mechanism.md` | Same file, extended navigation-only after promotion | Navigation; authorizes nothing |
| Governed mechanism record | `.octon/framework/cognition/_meta/architecture/governed-cross-surface-mechanisms/mechanisms/architectural-review-mechanism.md` + `index.yml` | Same files, extended after promotion | Governed mechanism navigation record |
| Per-occasion method advisory | Absent | Feature note + mechanism entry + workflow configure stages (in-scope surfaces); lifecycle prompts consult by reference | Advisory; gates unchanged; never authority |
| Workflow method-id assertion | `validate-architectural-review-workflows.sh` (no method check today) | Same validator, extended with method-recording and receipt-method-free checks | Deterministic validation |
| Generated views | `.octon/generated/**` (registry, effective routing, artifact index) | Rebuilt outputs via canonical publishers | Never authority |
| Human gates | Parent program acceptance and per-child review gate | Maintainer review/acceptance receipts at this packet's path | Human authority |
