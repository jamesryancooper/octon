# Repository Hygiene and Transitional-Surface Retirement

This is a temporary, implementation-scoped architecture proposal for
`repository-hygiene-and-retirement`. It translates the user-supplied
repository-hygiene requirements plus the live Octon repository into one
manifest-governed packet that can be reviewed, handed off, archived, and later
promoted without relying on chat history.

## Packet purpose

This packet defines the Octon-native architecture needed to govern repository
hygiene in a Rust + Shell repository without collapsing cleanup into a generic
memo or a language-mismatched tool recommendation. The target state is a
composed capability family that:

- detects static dead Rust code;
- detects unused Rust dependencies;
- detects orphaned shell scripts and wrappers;
- detects stale generated outputs and other repository bloat;
- detects migration leftovers, compatibility shims, helper-authored
  projections, historical mirrors, and other sunsettable transitional
  surfaces; and
- routes every destructive or retention decision through Octon's existing
  build-to-delete governance spine rather than a parallel control plane.

## Scope summary

In scope:

- architecture and governance for repository hygiene and retirement;
- packet-local normalization of the user requirements into source items;
- the authoritative Octon surfaces that would be created or modified under
  `.octon/**`;
- dependent repo-local workflow integrations that must exist for complete
  implementation; and
- the validation, evidence, and closure burden required before the capability
  can be claimed as landed.

Out of scope:

- applying the implementation to the repository now;
- certifying that the repository currently contains zero dead code or zero
  bloat; and
- irreversible history rewriting, packfile pruning, or other ACP-4 style
  deletion work.

## Source-input summary

The packet normalizes four user-provided source inputs:

1. the initial Rust + Shell cleanup request;
2. the follow-up requirement covering migration leftovers, shims, and similar
   transitional residue;
3. the detailed repository-hygiene capability-spec request;
4. the current architecture-proposal packet generation contract.

No external audit file was supplied. Instead, this packet derives a comparable
baseline of in-scope source items by reconciling those user inputs against the
live repository's current constitutional, governance, proposal, retirement,
capability, CI, and runtime surfaces.

## What this packet does

- normalizes all in-scope source items into one traceable register;
- grounds every material claim in live repo evidence;
- defines the target architecture, file-level change program, validation plan,
  migration/cutover model, and closure criteria;
- preserves the boundary between durable authority, proposal-local authority,
  retained evidence, and derived views; and
- makes explicit where the active proposal contract constrains packet scope.

## What this packet does not do

- it does not implement the proposed changes;
- it does not create a new live authority plane;
- it does not treat copied resources or generated views as authority; and
- it does not hide unresolved scope tensions, especially the active proposal
  rule that forbids mixing `.octon/**` and non-`.octon/**` promotion targets in
  one active proposal.

## Reading order

1. `proposal.yml`
2. `architecture-proposal.yml`
3. `README.md`
4. `PACKET_MANIFEST.md`
5. `navigation/source-of-truth-map.md`
6. `resources/input-baseline-and-source-normalization.md`
7. `resources/source-register.md`
8. `architecture/current-state-gap-map.md`
9. `architecture/target-architecture.md`
10. `architecture/source-to-remediation-matrix.md`
11. `architecture/file-change-map.md`
12. `architecture/implementation-plan.md`
13. `architecture/migration-cutover-plan.md`
14. `architecture/validation-plan.md`
15. `architecture/acceptance-criteria.md`
16. `architecture/closure-certification-plan.md`
17. `architecture/follow-up-gates.md`
18. `architecture/conformance-card.md`
19. `resources/risk-register.md`
20. `resources/assumptions-and-blockers.md`
21. `resources/evidence-plan.md`
22. `resources/rejection-ledger.md`
23. `navigation/artifact-catalog.md`
24. `SHA256SUMS.txt`

## Promotion targets summary

This active proposal uses `promotion_scope: octon-internal`, so its official
promotion targets are confined to `.octon/**`. That is intentional. The live
proposal standard forbids mixing `.octon/**` and non-`.octon/**` promotion
families inside one active proposal. Repo-local workflow edits under
`.github/workflows/**` are therefore modeled here as dependent implementation
integrations rather than promotion targets.

## Resource bundle summary

- `resources/source_inputs/**` contains faithful packet-local reproductions of
  the user-provided source material.
- `resources/repo_evidence/**` contains copied or excerpted live repo evidence
  used materially in the packet.
- `resources/*register*.md`, `resources/*plan*.md`, and
  `resources/assumptions-and-blockers.md` preserve normalization,
  traceability, risks, evidence burden, and explicit deferred edges.

## Governing thesis

> Octon should solve repository hygiene by adding one repo-native,
> fail-closed, evidence-backed capability family that detects dead surfaces and
> routes destructive decisions into the existing retirement/build-to-delete
> spine — not by creating a second governance plane and not by importing a
> Python-centric Ruff/Vulture pattern into a Rust + Shell repository.
