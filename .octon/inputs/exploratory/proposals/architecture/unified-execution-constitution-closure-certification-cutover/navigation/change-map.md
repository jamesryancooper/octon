# Change Map

## Intended promotion targets (authoritative `.octon/**` surfaces)

- `.octon/instance/governance/closure/`
- `.octon/instance/governance/disclosure/harness-card.yml`
- `.octon/instance/governance/support-targets.yml`
- `.octon/framework/assurance/governance/`
- `.octon/framework/constitution/contracts/registry.yml`
- `.octon/framework/engine/runtime/adapters/host/`
- `.octon/state/control/execution/runs/`
- `.octon/state/evidence/disclosure/`
- `.octon/state/evidence/validation/publication/build-to-delete/`

## Required downstream binding surfaces (non-authoritative; not promotion targets)

- `.github/workflows/pr-autonomy-policy.yml`
- `.github/workflows/unified-execution-constitution-closure.yml`

These files may be updated to invoke canonical `.octon/**` validators and
artifact materializers. They remain **binding surfaces**, not authorities.

## Change zones

1. **Claim boundary and disclosure**
   - freeze the certified claim in one closure manifest
   - align HarnessCard wording and known limits with that manifest
2. **Authority de-hosting**
   - remove any host-native final authority decision from supported surfaces
   - move lane/blocker/manual-lane decisions into canonical artifacts
3. **Run-bundle proof**
   - make the complete consequential run bundle a blocking proof contract
4. **Executable support targets**
   - add positive and negative certification tests from support-targets
5. **Disclosure parity**
   - fail the release when RunCard or HarnessCard references do not resolve
6. **Shim independence and retirement**
   - prove historical shims are non-authoritative
   - record at least one deletion or demotion receipt

## No-change zones

- The constitutional kernel remains singular; no second constitution or
  alternate precedence chain may be introduced.
- The packet does **not** widen support beyond the already declared envelope.
- External or irreversible workloads remain denied by default.
- Locale widening, extended-context widening, and experimental model widening
  are explicitly out of scope.
- The packet does not reintroduce persona-backed memory, hidden control planes,
  or summary-only substitutes for canonical evidence.
