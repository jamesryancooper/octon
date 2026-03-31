# Risks, Trade-Offs, and Open Questions

## Trade-off 1 — truthful narrowing may look like regression

Demoting published adapters or locale envelopes can look like a loss of capability. In reality, it is a gain in truthfulness if retained proof is absent.

## Trade-off 2 — evidence-first vs demotion-first

Some maintainers may prefer to keep a broader live envelope and add proof in the same atomic change. This packet allows that, but defaults to demotion because proof should be visible before the claim remains live.

## Trade-off 3 — external deliverable formatting vs in-repo package validity

The original source material framed the packet as markdown-first, but the
in-repo package needs canonical YAML manifests to satisfy deterministic proposal
validation and discovery rules. This repository copy therefore uses real YAML
manifest files.

## Open question 1 — how strict should the support-target validator be?

A very strict validator will require explicit proof mapping for any envelope left `supported` or `reduced`. That is the constitutionally safest path, but maintainers may want a transitional warning mode while backfilling proof for low-risk envelopes. This packet recommends fail-closed for supported publication and stage-only for anything else.

## Open question 2 — should the family semantic split be standardized across all family contracts?

This packet recommends one explicit semantic split:

- live selector
- historical activation lineage

If maintainers want that to become a formal family-contract convention, they should consider adding it to the constitutional family pattern or validator documentation after this remediation lands.

## Open question 3 — should repo-local follow-ons be bundled later?

Once this octon-internal packet lands, the root README and CODEOWNERS follow-ons are still worth doing. The right mechanism is a separate `repo-local` packet or direct repo-local corrective patch.
