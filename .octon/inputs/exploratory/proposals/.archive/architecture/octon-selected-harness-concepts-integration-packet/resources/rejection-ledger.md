# Rejection ledger

## Selective dependency internalization

- **Disposition:** `defer`
- **Why:** The concept is not closure-ready as a usable Octon capability on current repository evidence.
- **Current evidence considered:** .octon/framework/governance/decisions/adr/ADR-012-agent-platform-interop-native-first.md; .octon/framework/governance/decisions/adr/ADR-013-filesystem-interfaces-interop-native-first.md
- **What would be needed to revisit it:** Measured benefit, ownership plan, rollback path, and license/security review.

## Unbounded domain access / approval bypass

- **Disposition:** `reject`
- **Why:** The concept is constitutionally incompatible with Octon’s authority model and execution boundary.
- **Current evidence considered:** .octon/framework/constitution/charter.md; .octon/framework/constitution/charter.yml; .octon/framework/constitution/normative-precedence.md; .octon/framework/constitution/epistemic-precedence.md; .octon/framework/constitution/fail-closed-governance.md; .octon/framework/governance/decisions/adr/ADR-038-strict-engine-capabilities-authority-boundary.md; .octon/state/control/execution/approvals/**; .octon/state/control/execution/revocations/**; .octon/state/control/execution/exceptions/**
- **What would be needed to revisit it:** Negative tests proving sandboxing/isolation never substitutes for authorization are sufficient.

