# Evidence Disclosure Tiers v1

This contract explains the operator-facing evidence disclosure model declared
in `/.octon/framework/constitution/contracts/retention/evidence-disclosure-tiers-v1.yml`.
The tier model narrows how retained evidence may be used for publication,
closeout, release disclosure, and generated read models. It does not replace
the canonical evidence store roots in
`/.octon/framework/engine/runtime/spec/evidence-store-v1.md`.

## Tier Model

Octon uses four stable disclosure tiers:

- `private_raw_evidence`: raw or sensitive replay material such as model I/O,
  traces, local captures, browser artifacts, high-volume telemetry, or other
  evidence that may be necessary for auditability but is not publishable by
  default.
- `repo_publishable_evidence`: claim-bearing receipts, summaries, digests,
  redacted excerpts, and pointers that can remain in the repository and support
  validation, support proof, closeout, or release claims.
- `operator_release_disclosure`: operator-facing and release-facing disclosure
  artifacts such as RunCard and HarnessCard outputs. These artifacts summarize
  retained evidence and remain subordinate to authority, control, and evidence
  roots.
- `generated_read_model`: generated summaries and projections under
  `/.octon/generated/**`. They help humans inspect state, but they are
  derived-only and cannot satisfy authority, policy, support, evidence, or
  closeout gates.

## Path Semantics

Canonical retained evidence remains under `/.octon/state/evidence/**`.
Control truth remains under `/.octon/state/control/**`. Generated views remain
under `/.octon/generated/**`.

The tier model classifies how an artifact may be used:

- private raw evidence may be retained or indexed, but it must not be copied
  into publishable or release disclosure surfaces without an explicit redaction,
  minimization, digest, locator, or summary step;
- repo-publishable evidence may carry claims when it links to canonical
  authority, control, evidence, or external-index roots;
- operator/release disclosure may summarize claim-bearing evidence, but it must
  show enough retained evidence references to let validators and operators trace
  the claim; and
- generated read models may mirror facts only with source traceability and
  freshness metadata, and they remain invalid as authority or evidence inputs.

## Promotion Rule

Private raw evidence is never promoted by raw copy into publishable evidence.
A publishable representation must be intentionally produced and must record the
provenance needed to rebind the representation to the retained raw evidence
when inspection is allowed. Acceptable representations include redacted
excerpts, digests, stable local evidence ids, content-addressed external-index
entries, and summaries tied to retained source refs.

Generated read models cannot be promoted into evidence or authority. A
disclosure artifact may cite a generated read model only as operator context
and only when the disclosure also cites the canonical retained evidence or
authority source behind the generated fact.

## Closeout And Release Use

Closeout and release claims may depend only on canonical authority, control,
retained evidence, and disclosure artifacts with the required tier
classification. Missing tier classification blocks the claim when the artifact
supports publication, closeout, support proof, release disclosure, or archive
readiness.

The tier model preserves existing evidence-store completeness. It adds a
publication and disclosure boundary; it does not weaken requirements for run
journal snapshots, authority receipts, replay pointers, proof-plane evidence,
disclosure artifacts, or support-target proof bundles.

## Failure Cases

Fail closed when any of the following occur:

- raw local evidence is copied directly into repo-publishable or release
  disclosure evidence without a redaction or pointer step;
- a generated read model is used as authority, policy, support proof, retained
  evidence, or closeout evidence;
- a disclosure claim lacks retained evidence references;
- a publishable evidence artifact cannot trace back to canonical retained
  evidence, authority, or control roots; or
- tier classification is missing for evidence used by a publication, closeout,
  support, release, or archive claim.

## Related Contracts

- `/.octon/framework/constitution/contracts/retention/evidence-disclosure-tiers-v1.yml`
- `/.octon/framework/engine/runtime/spec/evidence-store-v1.md`
- `/.octon/framework/engine/runtime/spec/operator-read-models-v1.md`
- `/.octon/framework/constitution/obligations/evidence.yml`
