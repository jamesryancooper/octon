# Run Packet Implementation

Re-read the packet manifests, source-of-truth map, artifact catalog,
implementation plan, acceptance criteria, implementation-grade completeness
receipt, proposal review receipt, and `support/executable-implementation-prompt.md`.
Refuse to proceed unless the packet is accepted and:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-review-gate.sh --package <proposal_path> --require-implementation-authorization
```

passes with a fresh accepted review receipt, zero open blocking findings, and
`implementation_prompt_authorized: yes`.

Execute only the durable promotion work declared by the packet and its
executable implementation prompt. Preserve class boundaries: proposal packet
material is implementation input and provenance only; durable authority,
control, evidence, generated projections, and instance enablement must land in
their declared repository classes. Do not widen promotion targets, support
claims, capabilities, authority ownership, or product semantics without routing
to packet revision or a linked proposal.

After durable changes land, update the packet's `support/implementation-run.md`
receipt, implementation conformance receipt, post-implementation drift/churn
receipt, validation receipt, and checksums when present. The implementation-run
receipt must include at least `verdict`, `implemented_at`, and
`promotion_evidence_count`; use `verdict: pass` only when durable promotion
work has landed and promotion evidence is available.

If the packet declares governed mechanism integration gates, also create or
update `support/governed-mechanism-integration-evaluation.yml` after durable
changes land and validate it with
`validate-governed-mechanism-integration-receipt.sh --receipt <proposal_path>/support/governed-mechanism-integration-evaluation.yml --package <proposal_path>`.
The receipt must classify proposal-local support files, generated outputs,
current-state architecture review evidence, lifecycle postmortem evidence,
host state, chat, tool state, dashboards, and model memory as non-authority.

Run structural, subtype, implementation-readiness, implementation-conformance,
and post-implementation drift validators, plus all validators declared by the
packet and affected durable surfaces. Leave `proposal.yml#status` as
`accepted`; the separate `promote-proposal` lifecycle route owns rewriting the
packet to `implemented`. Report `blocked`, `deferred`, or
`needs-packet-revision` with evidence when implementation cannot cleanly enable
promotion.
