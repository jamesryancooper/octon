# Source Context

The accepted RP-00 containment packet requires a sealed single-owner GitHub
cutover with strict pre-issuance authorization, one fine-grained PAT, exact
identity and capability admission, a canonical ordered operation manifest,
conditional provider mutations, durable completed-prefix and owner-lane
attestation artifacts, no-resend recovery, credential terminalization, and a
retirement receipt before SI-00.

On 2026-07-17 the implementation sequence froze the exact current 135-target
candidate as commit `c11b73b38c3825bb177b269826677b8255ab1445`, tree
`9c6002867ea0f5ae7e76d4d90f1edeabeb0d4ea9`, parent
`40fe9d0b4d1f41c69c4d2e3585c772c96a324023`. Closed-world discovery reported
531 writers and 918 launchers with exact `D_w = M_w` and `D_l = M_l = A_l`.
The commit was deliberately left unreferenced and the primary HEAD/index/
worktree remained unchanged.

The provider phase stopped before credential issuance. The live repository had
the artifact names only in proposal prose and control-plane documentation; it
had no executable trusted credential capture or owner-lane consumer. The
GitHub host adapter remained a non-authoritative protected-CI projection, live
connector effects were denied, and the only protected-CI command used ambient
`gh`. The program controller classified the child as `missing-evidence`, so
`lifecycle program approve` had no current approval blocker to consume.

The user then selected the durable fix: implement a separately reviewed
precursor inside Octon's existing runtime/authority boundary, not an ad hoc
script or parallel connector, and continue with that fix.

GitHub's official credential-revocation API accepts fine-grained PATs in an
unauthenticated `POST /credentials/revoke`, returns `202` on acceptance, and
rejects authenticated calls. The protocol treats that acceptance as nonterminal
and requires a subsequent genuine same-token identity `401`.

This document preserves context; it is not runtime or provider authority.
