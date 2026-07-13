# Program Cutover Checklist

- [ ] RP-00 containment is accepted, implemented, and current before privileged work.
- [ ] RP-01 interface is frozen before RP-03; one issuer and one writer are proved.
- [ ] RP-02 isolation and RP-04 IPC/credential boundary pass before any broker effect.
- [ ] RP-05 true expected-old CAS and sealed ref gates plus RP-06 exact verifier,
      route, history, protected-PR, and `S -> Q` gates pass before production landing.
- [ ] RP-07 physical/signature gates precede RP-08 Class B admission.
- [ ] RP-08 full crash/result/UNKNOWN/mirror/conditional-cleanup matrix passes
      inside the frozen tuple with no route switching or false `cleaned` state.
- [ ] RP-09 prior-version activation and rollback pass before trust automation.
- [ ] RP-10/RP-11 non-authority/Harness binding pass before extensions or children.
- [ ] RP-12/RP-13 claims remain disabled until their own gates pass.
- [x] ROD-006 is accepted as no Octon-owned direct-main route; RP-00 must still
      encode and prove that posture. RP-14 independently reproduces exact-commit claims,
      and only passing claim-scoped evidence reaches its governed promotion route.
- [ ] RP-00 containment blocks unsafe current no-PR while preserving its
      classification and candidate; the current PR workflow is not assumed safe.
- [ ] RP-14 equal-floor proof meets zero-effect/prompt/false-escalation and
      preservation budgets, and no-PR latency is lower than protected PR.

These are future child gates, not parent authorization checkboxes.
