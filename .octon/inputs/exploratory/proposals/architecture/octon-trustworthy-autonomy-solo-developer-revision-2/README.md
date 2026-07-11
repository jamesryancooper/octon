# Octon Trustworthy Autonomy Without Solo-Developer Bureaucracy — Revision 2

Status: **in review**. This packet is candidate architecture lineage. It
authorizes no implementation, grant, effect, merge, deployment, or trust-root
activation.

## Outcome

Revision 2 selects a proportional model:

- reversible candidate work runs autonomously in a disposable,
  credentialless project sandbox;
- durable but ordinarily reversible effects cross a typed, brokered boundary
  and are automatically authorized when policy permits;
- irreversible, externally consequential, and trust-root effects require an
  explicit operator activation or a deliberately configured high-assurance
  policy;
- one canonical authority engine owns decisions and grants; downstream
  components may validate, narrow, deny, reserve, perform, and attest, but may
  not create competing authorization semantics.

The design treats safety and throughput as coequal architecture requirements
inside the constitutional fail-closed envelope. It rejects controls that add
operator work without a measurable reduction in meaningful risk.

## Source Limitation

No artifact carrying the stated Revision 1 title or its distinctive phrases
was found in the searched exploratory proposal tree. The operator's Revision 2
assignment is therefore the available correction ledger. Current facts were
rechecked only where needed to resolve its decisions; the packet does not
reconstruct Revision 1 from memory or repeat an open-ended exploratory review.

## External Architecture Review Handoff

An external architect should begin with
`support/external-architect-handoff.md` and return either the provided
`support/external-architect-review-response-template.md` or an equivalent
structured response. The handoff records the current `revisions required`
disposition, nine open implementation-readiness findings, review questions,
evidence status, and the required decision-by-decision response contract.

## Reading Order

1. `proposal.yml`
2. `architecture-proposal.yml`
3. `navigation/source-of-truth-map.md`
4. `architecture/target-architecture.md`
5. `architecture/authority-and-failure-model.md`
6. `architecture/governance-and-enforcement.md`
7. `architecture/trusted-computing-base.md`
8. `architecture/identity-evidence-merge-self-development.md`
9. `architecture/workspace-project-and-harness-factory.md`
10. `architecture/performance-and-workflows.md`
11. `architecture/decisions.md`
12. `architecture/acceptance-criteria.md`
13. `architecture/implementation-plan.md`
14. `resources/evidence-appendix.yml`
15. `support/implementation-grade-completeness-review.md`

The core reading order above describes the packet. The shorter external-review
reading order and architect response contract are maintained in the handoff.

## Scope Split

This packet promotes only into `.octon/**`. GitHub workflows, rulesets, and
GitHub App installation are provider or repo-local projections. Their
implementation must use a separate repo-local Change (and a linked proposal if
that Change requires one); this packet defines their contract but does not mix
`.github/**` into its promotion targets.

## Formal Gate

The packet may be reviewed and its twelve decisions approved independently.
Acceptance and implementation authorization still require the repository's
strict pre-integration architecture review. No executable implementation
prompt is emitted before that gate and operator acceptance.
