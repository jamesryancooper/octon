# Missing-Proof and Overclaim Ledger

## Principle

When proof is absent, the clean-break correction is to **narrow the claim**, not to leave the overclaim in place.

## Ledger

| Claim surface | Current issue | Retained proof currently visible | Clean-break correction |
|---|---|---|---|
| `support-targets.yml` supported/reduced tuples beyond the retained release card | broader tuple publication than the release card proves | the release HarnessCard currently proves the repo-local consequential tuple centered on `MT-B / WT-2 / LT-REF / LOC-EN` with `repo-shell` + `repo-local-governed` | demote unproved tuples to `experimental` + `stage_only` or add proof in the same change |
| `support-targets.yml` `studio-control-plane` host adapter | published as supported without current retained release proof cited here | no explicit retained release disclosure packet in this packet's baseline | demote unless proof lands in the same atomic update |
| `support-targets.yml` `github-control-plane` host adapter | published as a live-ish reduced envelope without proof cited here | none cited in the current authored/release HarnessCard | demote unless proof lands in the same atomic update |
| `support-targets.yml` `ci-control-plane` host adapter | published as a reduced envelope without proof cited here | none cited in the current authored/release HarnessCard | keep stage-only and demote to experimental unless proof lands |
| `support-targets.yml` locale `LOC-MX` envelope | published as reduced without retained disclosure packet cited here | none cited in the current authored/release HarnessCard | demote unless proof lands |
| broad `.octon/**` portability wording | reads as broader live support than the release evidence proves | current release evidence is repo-local governed, not general cross-repo/cross-environment proof | rewrite docs to evidence-bounded language |

## Default decision policy

This packet defaults to:

- **truthful narrowing**
- **no silent support widening**
- **no live claim retained on the assumption that proof exists somewhere else**

If maintainers want a broader live envelope, they must publish the proof in the same atomic change.
