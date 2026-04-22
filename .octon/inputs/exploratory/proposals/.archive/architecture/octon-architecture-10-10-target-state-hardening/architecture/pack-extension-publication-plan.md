# Pack, Extension, and Publication Plan

## Objective

Make capability packs and extension packs strategically useful without allowing
manual drift, raw input authority, generated authority, or support-claim widening.

## Target pack lifecycle

1. **Framework contract** — portable pack definition under
   `framework/capabilities/packs/**`.
2. **Instance governance selection** — repo-owned intent under
   `instance/governance/capability-packs/**`.
3. **Runtime admission** — current admitted runtime route under
   `instance/capabilities/runtime/packs/admissions/**` or generated projection
   from a canonical admission decision.
4. **Generated effective** — runtime-facing compiled view under
   `generated/effective/capabilities/**` with publication receipt and freshness.
5. **Run binding** — request/grant/receipt cite pack id, admission id, support
   tuple, output envelope, evidence expectation, and route.

## Target extension lifecycle

1. Raw additive extension material remains under `inputs/additive/extensions/**`.
2. Desired selection lives under `instance/extensions.yml`.
3. Active/quarantine truth lives under `state/control/extensions/{active.yml,quarantine.yml}`.
4. Generated runtime-effective outputs live under `generated/effective/extensions/**`.
5. Publication receipts live under `state/evidence/validation/publication/**`.
6. Freshness or publication failure denies runtime use.

## Normalization changes

- Reduce manual duplication by generating runtime admission projections from
  canonical governance intent plus state/control admission decisions.
- Normalize extension active-state dependency locks into grouped, content-addressed
  dependency manifests.
- Update skill/service docs so generated host projections are the steady-state
  model; remove symlink-era ambiguity unless retained as labeled compatibility.
- Add publication freshness gates for generated/effective capability and extension
  outputs.

## Validator expectations

`validate-publication-freshness-gates.sh` must fail when:

- generated/effective output lacks receipt;
- output dependency hash differs from active source/control graph;
- raw additive input is directly referenced by runtime;
- generated/cognition summary is used as pack/extension authority;
- quarantine state is bypassed;
- unadmitted pack appears in live support route.

## Acceptance

The pack/extension system is target-state valid when it improves boundary control
and operator legibility while reducing manual registry drift.
