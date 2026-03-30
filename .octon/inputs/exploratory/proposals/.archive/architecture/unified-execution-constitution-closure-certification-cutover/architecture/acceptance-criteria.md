# Acceptance Criteria

The cutover is acceptable only if **every** criterion below is true. Together
these criteria are the done gate for this closure certification packet.

## A. Claim boundary and ratification

1. A machine-readable closure manifest exists at the canonical governance path.
2. The closure manifest freezes the certified tuple as `MT-B / WT-2 / LT-REF /
   LOC-EN`.
3. The closure manifest freezes the certified adapters as `repo-shell` and
   `repo-local-governed`.
4. The closure manifest explicitly lists reduced, stage-only, experimental, and
   denied surfaces outside the certified claim.
5. HarnessCard claim wording matches the closure manifest exactly.
6. No release wording, README wording, or disclosure wording widens beyond the
   closure manifest.

## B. Authority de-hosting

7. No GitHub label, comment, check, or workflow-local state is authoritative by
   itself.
8. Consequential PR lane/blocker/manual-lane outcomes are emitted as canonical
   decision artifacts or grant bundles.
9. `.github/workflows/pr-autonomy-policy.yml` no longer makes hidden final
   authority decisions for the certified envelope.
10. Host adapter declarations and actual runtime behavior agree on
    non-authoritative boundaries.
11. CI binding surfaces remain projection-only or stage-only and never outrank
    canonical `.octon/**` authority.

## C. Universal run-bundle proof

12. Every consequential supported-envelope run binds `run-contract.yml` before
    side effects occur.
13. Every consequential supported-envelope run binds `run-manifest.yml`.
14. `runtime-state.yml` and `rollback-posture.yml` exist for the supported run.
15. Stage-attempt and checkpoint roots exist for the supported run.
16. Decision artifact and approval grant bundle exist for the supported run.
17. Evidence classification, replay pointers, external replay index,
    intervention log, measurement summary, and RunCard all exist.
18. The closure validator reads the bundle contract from the run contract and
    RunCard schema rather than from a prose allowlist.

## D. Executable support-target enforcement

19. A positive supported-envelope certification run succeeds.
20. That positive run emits the complete constitutional bundle.
21. At least one reduced tuple demonstrates `stage_only` behavior.
22. At least one unsupported tuple demonstrates `deny` behavior.
23. Missing required evidence on a supported tuple fails closed instead of
    silently widening support.
24. Certification outputs make it impossible to confuse reduced or denied
    surfaces with the fully realized claim.

## E. Disclosure parity

25. Every proof-plane reference in the certified RunCard resolves.
26. Every proof-bundle reference in the certified HarnessCard resolves.
27. Benchmark, support, and release claims point to retained evidence rather
    than only repo structure.
28. Known limits in RunCard and HarnessCard remain consistent with the bounded
    claim and exclusions.

## F. Shim independence

29. Historical shim surfaces in the contract registry are either projection-only,
    historical, subordinate, or retirement-conditioned.
30. Static audit proves no launcher, workflow, validator, ingress, or bootstrap
    path reads a historical shim as authority.
31. Projection shims may remain only where the registry explicitly allows them.
32. No certification-critical path depends on proposal-local or historical-shim
    surfaces.

## G. Build-to-delete evidence

33. At least one live deletion or demotion receipt exists under the retained
    build-to-delete publication root.
34. Every retained compensating mechanism has an owner.
35. Every retained compensating mechanism has a removal trigger.
36. Every retained shim or overlay has a retirement condition.

## H. Release blocking and closure posture

37. A release-blocking closure validator exists in canonical `.octon/**`
    surfaces.
38. The validator is wired into a repo-local release workflow as a downstream
    binding surface.
39. Failure in any positive, negative, disclosure, shim, or retirement gate
    blocks the release.
40. After promotion, the next evaluation for this claim is pass/fail
    certification against this packet’s gates, not another architecture review.
