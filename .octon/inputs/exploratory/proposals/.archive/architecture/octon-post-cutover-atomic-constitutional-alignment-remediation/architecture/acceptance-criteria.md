# Acceptance Criteria

## Global atomic rule

The accepted implementation is the one that produces **one truthful live model**, not the one that preserves the broadest prior wording.

## Criterion set A — live constitutional model

All of the following must be true:

- `/.octon/framework/constitution/charter.yml` still points at the March 30 atomic cutover receipt
- every active `contracts/*/family.yml` points at the same live receipt or carries an explicitly equivalent live-selector field
- no active family presents a March 28 or March 29 phase receipt as the only obvious live selector

## Criterion set B — authored-authority boundary

All of the following must be true:

- `/.octon/instance/bootstrap/START.md` no longer lists `inputs/additive/extensions/**` as instance-native authority
- no orientation doc under `.octon/**` lists a raw `inputs/**` path as authored authority
- the extension-publication chain remains explained correctly

## Criterion set C — disclosure and support truthfulness

All of the following must be true:

- the disclosure family still resolves canonical live HarnessCard roots to governance + release disclosure roots
- lab-local HarnessCard mirrors remain explicitly historical only
- no live HarnessCard text implies support broader than the tuple and proof bundle it cites
- every envelope left `supported` is backed by retained proof
- every unproved envelope is demoted to `experimental`/`stage_only` or `unsupported`/`deny` unless proof lands in the same atomic change

## Criterion set D — documentation and subordinate governance durability

All of the following must be true:

- `.octon/**` claim docs distinguish broad architectural portability intent from current proof-backed live support
- no binding subordinate governance file under `/.octon/framework/cognition/governance/**` uses `@you` or `@teammate`
- the preferred durable identifier is `octon-maintainers` unless the ownership registry changes in the same atomic update

## Criterion set E — regression resistance

All of the following must be true:

- `alignment-check.sh` invokes the new validators
- publication gating fails closed on the new validator set
- validation receipts exist for the merge candidate

## Final target-state claim criteria

Octon may claim a fully aligned live atomic execution constitution only when:

1. the live constitutional model is singular across charter and active family manifests
2. the authored-authority boundary is singular across kernel, architecture, README, ingress, and bootstrap orientation
3. disclosure roots remain canonical under governance + retained release/run evidence roots
4. live support claims remain no broader than retained proof
5. portability prose is evidence-bounded rather than aspirationally live
6. subordinate binding governance surfaces use durable ownership identifiers
7. validator coverage makes recurrence fail closed
