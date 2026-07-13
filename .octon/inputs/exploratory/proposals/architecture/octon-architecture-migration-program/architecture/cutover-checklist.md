# Program Cutover Checklist

- [ ] RP-00 containment is accepted, implemented, and current before privileged work.
- [ ] RP-01 interface is frozen before RP-03; one issuer and one writer are proved.
- [ ] RP-02 isolation and RP-04 IPC/credential boundary pass before any broker effect.
- [ ] RP-05/RP-06 exact Git/verifier/publication gates pass before production landing.
- [ ] RP-07 physical/signature gates precede RP-08 Class B admission.
- [ ] RP-08 full crash/reconciliation/PR-fallback matrix passes inside the exact tuple.
- [ ] RP-09 prior-version activation and rollback pass before trust automation.
- [ ] RP-10/RP-11 non-authority/Harness binding pass before extensions or children.
- [ ] RP-12/RP-13 claims remain disabled until their own gates pass.
- [x] ROD-006 is accepted as no Octon-owned direct-main route; RP-00 must still
      encode and prove that posture. RP-14 independently reproduces exact-commit claims,
      and only passing claim-scoped evidence reaches its governed promotion route.

These are future child gates, not parent authorization checkboxes.
