# Disclosure and Support-Target Alignment

## Current-head fact pattern

The user-supplied evaluation identified a disclosure-family drift. At current HEAD, that drift is already fixed.

Current HEAD now shows:

- `/.octon/framework/constitution/contracts/disclosure/family.yml` uses `change_profile: atomic`
- the authored HarnessCard source is `/.octon/instance/governance/disclosure/harness-card.yml`
- the retained live release disclosure root is `/.octon/state/evidence/disclosure/releases/**`
- `/.octon/state/evidence/lab/harness-cards/**` is documented as historical only

That means the remaining problem is **not** disclosure-root migration. The remaining problem is **live claim width**.

## The actual remaining issue

`/.octon/instance/governance/support-targets.yml` still publishes a broader set of host adapters, locale envelopes, and compatibility tuples than the currently retained release disclosure proves.

The current authored and retained HarnessCard proves, at minimum, the repo-local consequential tuple centered on:

- host adapter: `repo-shell`
- model adapter: `repo-local-governed`
- compatibility tuple:
  - `MT-B`
  - `WT-2`
  - `LT-REF`
  - `LOC-EN`

The broader matrix still publishes additional host adapters and locale/context envelopes. Without matching release disclosure or retained proof, those envelopes are overclaimed if treated as live.

## Target rule

A live support claim may remain `supported` or meaningfully `reduced-live` only when retained proof exists for that envelope.

Where proof is missing, the clean-break fix is:

- demote the envelope to `experimental` or `unsupported`
- route it `stage_only` or `deny`
- or publish the proof in the **same atomic change**

This packet chooses the **truthful narrowing default**.

## Required atomic correction

### 1. Preserve the already-correct disclosure family

Do not reopen the disclosure-root migration. Keep the current disclosure family as-is except for regression-hardening comments/validator coverage if needed.

### 2. Narrow live support-target publication

In `/.octon/instance/governance/support-targets.yml`:

- keep the currently proved live consequential envelope supported
- demote every adapter/tuple/locale/context envelope that lacks retained proof to `experimental` + `stage_only` (or `unsupported` + `deny`, where appropriate)
- do not leave unproved envelopes as `supported`
- do not leave unproved host adapters described as meaningfully live merely because they are present in the declaration

### 3. Narrow the authored and retained HarnessCard claim text

In both:

- `/.octon/instance/governance/disclosure/harness-card.yml`
- `/.octon/state/evidence/disclosure/releases/2026-03-30-unified-execution-constitution-atomic-cutover/harness-card.yml`

rewrite the claim summary so it says, in substance:

- the live atomic model is run-contract-first, authority-artifactized, disclosure-canonical, and support-target-enforced
- the **currently proved** live envelope is the retained tuple actually backed by the release proof bundle

Do **not** imply broader adapter, locale, or cross-environment support than the retained proof bundle demonstrates.

### 4. Keep historical mirrors historical

Keep the current known-limits note that lab-local HarnessCard files remain non-live historical mirrors.

## Preferred narrowing pattern

The safest atomic default is:

- only the proved repo-local consequential envelope remains `supported`
- broader host-adapter surfaces like `studio-control-plane`, `github-control-plane`, and `ci-control-plane` become `experimental` + `stage_only` unless proof lands in the same change
- broader locale or extended-context envelopes become `experimental` + `stage_only` unless proof lands in the same change

This packet deliberately prefers a narrow truthful envelope over a broad aspirational envelope.

## Proof-first alternative

If maintainers already possess retained proof that was simply omitted from the current release disclosure packet, they may choose an evidence-first path instead:

1. add retained release/benchmark/scenario disclosure packets for the broader envelope
2. cite them from the authored HarnessCard
3. keep the broader support declaration only after the proof lands

This packet still remains valid; only the atomic path changes from "demote first" to "prove first".

## Validator contract

Add a support-target live-claim validator that fails when:

- a release HarnessCard claim summary implies broader support than the tuple and proof bundle it names
- an envelope remains `supported` without a matching retained disclosure/proof mapping
- a live disclosure root points canonical release disclosure back at lab-local mirror paths

## Expected end state

After promotion:

- current disclosure roots stay correct
- the published live support envelope is no broader than retained proof
- release disclosure language is truthful about the exact proved envelope
- broader declarations either become experimental/stage-only or arrive with proof in the same atomic change
