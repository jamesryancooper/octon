# Risk Register

| Risk | Impact | Mitigation |
| --- | --- | --- |
| Treating proof-gated delegation as permission to automate unclear authority. | Automation could bypass unresolved governance decisions. | Require typed human-only boundaries and fail closed on ambiguity, stale evidence, scope mismatch, or unsupported replay. |
| Replacing approval artifacts too broadly. | Existing canonical control truth could be weakened. | Preserve current approval, exception, and revocation infrastructure until child packets define validated replacements. |
| Generated or read-model output becomes de facto authority. | Derived projections could silently mint permission. | Keep generated outputs and read models evidence/projection-only; validators must reject authority misuse. |
| External irreversible effects are over-delegated. | Material external harm may be non-recoverable. | Require token, rollback or compensation, egress, irreversibility, and authority-zone proof; otherwise require typed human exception. |
| Contract fields become ceremonial. | Automation becomes approval theater without humans. | Require negative-control tests for missing proof, stale evidence, contradictory evidence, scope mismatch, and receipt absence. |
| Migration scope becomes too broad for one implementation. | Review and validation become unmanageable. | Use this packet only as architecture, then create a parent program with child packets by domain. |
