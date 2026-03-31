# Target-State Architecture

## Architectural thesis

Octon's **live** architecture after this remediation is not a new execution model. It is the existing March 30, 2026 atomic clean-break model with its remaining post-cutover drift removed.

The target state therefore has five high-value properties:

1. **One live model selector**  
   Every active constitutional family, not only the charter manifest, resolves the live model through the same March 30 atomic cutover receipt.

2. **One authored-authority boundary**  
   No bootstrap, orientation, or ingress document widens authored authority beyond `framework/**` and `instance/**`.

3. **One live disclosure model**  
   Authored HarnessCard source lives under `instance/governance/disclosure/**`; retained live release disclosure lives under `state/evidence/disclosure/releases/**`; lab-local HarnessCard files remain historical mirrors only.

4. **One proof-bounded live support envelope**  
   Support, adapter, locale, and portability claims remain no broader than retained disclosure and proof actually published at current HEAD.

5. **One regression-resistant validation surface**  
   Validators fail closed if active family semantics drift, orientation docs widen authority, or live claims outrun proof.

## Core target-state claims

### Claim 1 — the atomic clean-break live model remains singular

The March 30, 2026 atomic clean-break receipt remains the only supported live constitutional model selector. Earlier March 28–29 phase receipts remain valid historical activation lineage only.

### Claim 2 — the disclosure fix already landed stays landed

Current HEAD already shows the correct live disclosure model:

- disclosure family `change_profile: atomic`
- authored HarnessCard source under `instance/governance/disclosure/**`
- retained live release disclosure under `state/evidence/disclosure/releases/**`
- lab-local HarnessCard files explicitly historical

The target state preserves this and adds validation so it cannot silently regress.

### Claim 3 — support claims become truthful by construction

A support-target declaration is allowed to describe possible envelopes and fail-closed behavior, but a **live support claim** exists only when a retained disclosure packet and proof bundle back it.

The target state therefore distinguishes clearly between:

- **proved live envelope**
- **declared but unproved experimental/stage-only envelope**
- **unsupported/denied envelope**

### Claim 4 — portability becomes profile-driven intent, not unbounded live promise

Octon may keep the architectural goal of portability and self-containment through profile-driven export and authored-core reuse, but it may no longer describe that goal as if it were already a proved live support claim across repositories, adapters, locales, or environments that lack retained proof.

### Claim 5 — subordinate governance surfaces become durable and reviewable

Binding subordinate governance text may remain subordinate to the constitutional kernel, but it still requires durable ownership identifiers. Placeholder owners such as `@you` are not durable governance identifiers.

## End-state design rules

1. Active family manifests must separate **live selector** from **historical lineage**.
2. Orientation docs must be able to explain raw additive packs without ever calling them authored authority.
3. A release HarnessCard may summarize only the envelope it actually proves.
4. If proof is absent in the same atomic change, claims must narrow rather than linger aspirationally.
5. Validator coverage must attach to the existing assurance/runtime gate path, not to an optional side channel.

## Result

After promotion, Octon will still be the same governed autonomous engineering harness, but with a materially stronger constitutional story:

- no ambiguous live-model selector
- no remaining raw-input authority leak in bootstrap orientation
- no silent overclaim in live support or portability framing
- no placeholder owners on binding subordinate governance surfaces
- no easy path for these exact drift classes to reappear unnoticed
