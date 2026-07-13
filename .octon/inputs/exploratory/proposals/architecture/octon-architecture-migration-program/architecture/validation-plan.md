# Program Validation Plan

Creation validation runs the base, architecture, and implementation-readiness
validators for the parent and all fifteen children; program structure,
child-readiness, draft review, architectural review receipt, registry freshness,
YAML/catalog, DAG, identifier coverage, target-family, Revision 2 digest, and
write-allowlist checks complete the floor.

Structural success is distinct from lifecycle readiness. Draft completeness,
accepted review, strict architecture authorization, implementation, provider,
adversarial, fault, dogfood, support promotion, conformance, and archive gates
are expected to remain blocked. The validation report records exact commands,
exit meaning, and limitations without manufacturing receipts.

Future proof uses only the evidence classifications declared by reconciliation:
`DECLARED`, `STATICALLY_INSPECTED`, `DYNAMICALLY_EXECUTED`,
`ADVERSARIALLY_TESTED`, `CONFIGURATION_DERIVED`, `DEPLOYMENT_LOCAL`,
`PROVIDER_OBSERVED`, `ARCHITECTURAL_INFERENCE`, and `UNVERIFIED`.

The Git lifecycle floor additionally tests malicious candidate configuration and
head code, absent/wrong/expired/revoked grants, wrong repository/source/target,
wrong `O/S/V`, policy and harness drift, duplicate or circular check contexts,
target and source-ref races, true provider CAS under mandatory protections,
multi-commit admission, inherited-red baseline correction, full PR review state,
base/head movement, `S -> Q` equivalence, lost provider responses, no retry while
`UNKNOWN`, closed-unmerged preservation, conditional-delete races, local mirror
ordering, false `cleaned` claims, and raw-evidence exclusion.

RP-14 runs equal-floor no-PR and PR cohorts and records p50/p95 end-to-end and
mediated latency, prompt count, route confusion matrix, unauthorized effects,
recovery time, preservation proofs, setup/onboarding time, intervention time,
and monthly administration burden. Current run IDs and ruleset observations are
bounded baseline evidence only, never implementation proof.
