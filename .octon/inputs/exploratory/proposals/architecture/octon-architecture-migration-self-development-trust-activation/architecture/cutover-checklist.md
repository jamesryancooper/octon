# Cutover Checklist

- [ ] RP-06/RP-07/RP-08 and frozen RP-01 epoch interfaces pass.
- [ ] Semantic inventory and conservative classifier are complete.
- [ ] Inert install and exact artifact/envelope verification pass.
- [ ] Prior certified version and rollback are pre-verified.
- [ ] Selector/health/reboot/disk-full kill matrices pass with one active version.
- [ ] UE-001/UE-009/UE-015 and FD-017/FD-018 gates pass.
- [ ] The accepted ROD-003 epoch-zero inventory, one-time human trust anchor,
      and exact scope/artifact-version/time/budget/verifier/health/rollback
      preauthorization are bound; safe automatic activation stays disabled and
      unclaimed until proof and later promotion acceptance.
- [ ] SI-07 passes; safe-automatic remains disabled unless separately admitted.

Any failure leaves the candidate inert and the prior version active.
