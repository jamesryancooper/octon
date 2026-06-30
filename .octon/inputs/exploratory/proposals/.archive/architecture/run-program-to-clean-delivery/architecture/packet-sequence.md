# Packet Sequence

1. `run-program-clean-delivery-architecture`
2. `run-program-clean-delivery-runner-routing`
3. `run-program-clean-delivery-workflow-handoff`
4. `run-program-clean-delivery-evidence-metadata`
5. `run-program-clean-delivery-validators`
6. `run-program-clean-delivery-operator-surface`

The sequence is intentionally linear. Later packets depend on earlier boundary
and routing decisions so implementation cannot harden validators or operator
surfaces before the route authority model is clear.
