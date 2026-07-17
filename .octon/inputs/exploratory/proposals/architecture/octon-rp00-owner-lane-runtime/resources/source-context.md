# Source Context

The accepted RP-00 containment packet requires a sealed single-owner GitHub
cutover with strict pre-issuance authorization, one fine-grained PAT, exact
identity and capability admission, a canonical ordered operation manifest,
conditional provider mutations, durable completed-prefix and owner-lane
attestation artifacts, no-resend recovery, credential terminalization, and a
retirement receipt before SI-00.

On 2026-07-17 the implementation sequence froze an exact 135-target candidate,
then landed the first inert owner-lane precursor and rebased/refroze RP-00 as
commit `46e9900ce8a8b0c9f9d2e6ed1f5239985807f0cc`, tree
`5dfc97a4eda2b6d91503761b7b7dbe362d736b52`, parent
`66a226b7751822ea8becf431dafeb5b4f5900d99`. The candidate remains
unreferenced; the primary HEAD, index, and dirty worktree remain unchanged.

The provider phase stopped before credential issuance. A live preflight against
the landed precursor proved that its preserved safety mechanisms were usable,
but that its artifact order was impossible to satisfy truthfully: authorization
depended on a post-admission manifest, the complete credential tuple was not
bound, and fixed suffix requests required the provider-assigned pull-request
number before creation. The retained blocker receipt is
`.octon/state/evidence/runs/workflows/20260716-architecture-migration-program-orchestration-resume-leased-codex/children/octon-architecture-migration-containment/owner-lane-live-preflight-20260717T175757Z.md`.

A subsequent domain-architecture audit recorded the same three critical
findings as `RP00-OWNER-LANE-TEMPORAL-BINDING-001`,
`RP00-OWNER-LANE-CREDENTIAL-BINDING-002`, and
`RP00-OWNER-LANE-POST-PR-CONSTRUCTION-003`. Its report is
`.octon/state/evidence/validation/analysis/2026-07-17-domain-architecture-audit-rp00-owner-lane-live-protocol-20260717T182324Z.md`.

The user then selected and separately authorized the durable correction: a
staged executor inside Octon's existing runtime/authority boundary, with an
independent pre-issuance operation plan, explicit nonsecret capture metadata,
runtime-generated observed evidence, and completed-prefix-bound typed suffix
construction. No credential or provider effect is authorized by this packet.

GitHub's official credential-revocation API accepts fine-grained PATs in an
unauthenticated `POST /credentials/revoke`, returns `202` on acceptance, and
rejects authenticated calls. The protocol treats that acceptance as nonterminal
and requires a subsequent genuine same-token identity `401`.

This document preserves context; it is not runtime or provider authority.
