# Cutover Checklist

## Pre-merge

- [ ] Packet reviewed against the proposal standard and architecture-proposal standard
- [ ] Claim frozen to `MT-B / WT-2 / LT-REF / LOC-EN`
- [ ] Certified adapters frozen to `repo-shell` + `repo-local-governed`
- [ ] Closure manifest drafted
- [ ] HarnessCard wording aligned
- [ ] GitHub/CI authority de-hosting plan accepted
- [ ] Run-bundle validator drafted
- [ ] Positive and negative support-target fixtures identified
- [ ] Disclosure reference resolver drafted
- [ ] Shim audit drafted
- [ ] At least one build-to-delete receipt candidate identified

## Merge gate

- [ ] Positive supported-envelope certification passes
- [ ] Reduced tuple stages as expected
- [ ] Unsupported tuple denies as expected
- [ ] Missing-evidence fixture fails closed
- [ ] RunCard proof refs resolve
- [ ] HarnessCard proof refs resolve
- [ ] Shim-independence audit is clean
- [ ] Build-to-delete receipt exists and is retained

## Release gate

- [ ] Repo-local closure workflow invokes canonical `.octon/**` validator
- [ ] Publication bundle retained under the canonical evidence root
- [ ] Release wording matches the closure manifest exactly
- [ ] Known limits remain explicitly bounded in disclosure

## Post-release

- [ ] Certification result recorded in durable decision/evidence surfaces
- [ ] Packet archived after promotion lands
- [ ] Future review for this claim treated as certification maintenance only
