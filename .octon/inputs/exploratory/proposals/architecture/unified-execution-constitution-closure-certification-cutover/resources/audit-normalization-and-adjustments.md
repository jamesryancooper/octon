# Audit Normalization and Adjustments

This note records the adjustments applied before the supplied audit and closure
materials were turned into this packet’s working baselines.

## 1. Broad claim narrowed to a bounded supported claim

The supplied material correctly observed that Octon has implemented most of the
important target-state surfaces. The normalization applied here is that the
release claim is narrowed from a broad “fully unified execution constitution” to
an explicit supported-envelope claim.

Why:

- the repository already distinguishes supported, reduced, experimental, and
  denied surfaces
- the current HarnessCard claim is already anchored to a narrower compatibility
  tuple than the broad narrative wording suggests

## 2. GitHub and CI are treated as downstream bindings, not certified authority

The supplied closure certification text correctly identified residual GitHub
workflow logic as the most likely reason an auditor would reopen the question.
This packet preserves that finding and tightens it:

- GitHub/CI may remain as projection or binding surfaces
- they are not part of the authoritative promotion target set for this active
  packet
- they must call into canonical `.octon/**` validators or artifact
  materializers rather than acting as final authority themselves

## 3. Active proposal scope kept `octon-internal`

The Octon proposal standard forbids active proposals from mixing `.octon/**` and
non-`.octon/**` promotion targets in one packet. Because this packet needs to be
active and standards-compliant, its promotion targets remain `.octon/**` only.

Adjustment made:

- repo-local `.github/workflows/**` surfaces are documented as downstream
  non-authoritative bindings instead of proposal promotion targets

## 4. “Big-bang, clean-break, atomic” normalized to the certified claim

The cutover posture is preserved, but normalized to the claim that can be
certified now:

- one bounded claim
- one merge path
- one certification release
- no follow-on architecture packet for the same claim

This does **not** mean every reduced or unsupported surface becomes supported in
this release.

## 5. Audit language shifted from architecture diagnosis to certification gates

The original audit contained a wide architectural diagnosis. For this packet,
that diagnosis is converted into a smaller set of **claim-blocking gates**:

- claim boundary
- host authority
- run-bundle proof
- support-target execution
- disclosure parity
- shim independence
- retirement evidence

That conversion is what makes the next round a certification round.
