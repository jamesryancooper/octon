# Acceptance Criteria

This proposal is ready to move from review to implementation use only when the
packet is complete, traceable, and grounded. The target architecture is ready
to be marked landed only when the durable implementation and evidence burden
below are satisfied.

## Packet-readiness gates

| Gate ID | Condition | Proof burden |
| --- | --- | --- |
| AC-11 | The packet conforms to the active proposal contract and is archive-ready without chat reconstruction. | Valid manifests, required docs, navigation files, `PACKET_MANIFEST.md`, `SHA256SUMS.txt`, complete source normalization. |
| AC-12 | The packet includes a profile selection receipt and a coherent cutover model consistent with Octon's pre-1.0 default. | `architecture/migration-cutover-plan.md`, `architecture/conformance-card.md`. |

## Implementation acceptance gates

| Gate ID | Condition | Evidence / validator burden | Blocking note |
| --- | --- | --- | --- |
| AC-01 | A canonical `repo-hygiene` governance policy exists under `instance/governance/policies/**`. | file exists, parses, and is covered by the hygiene validator | blocks implementation use |
| AC-02 | `repo-hygiene` is registered as an instance-owned command with docs and runner files. | command manifest entry, README, runner/helper files, syntax validation | blocks implementation use |
| AC-03 | The capability remains fail-closed and support-bounded. No new packs or support tiers are admitted. | policy review, support-target review remains unchanged, file-change map confirms no widening | blocks target-state closure |
| AC-04 | Existing retirement/drift/ablation governance is reused and explicitly wired for hygiene findings. | contract updates approved; no new registry/review plane exists | blocks target-state closure |
| AC-05 | High-confidence transitional residue detected by hygiene scans cannot proceed to closure without same-change registration or resolution. | validator logic + contract rules + baseline audit evidence | blocks target-state closure |
| AC-06 | Dependent repo-local workflow integrations exist and call the new validator/command. | `.github/workflows/**` changes land and run successfully | blocks operational live claim |
| AC-07 | A baseline repo-hygiene audit has been emitted under retained evidence roots. | audit summary, findings, blocking findings, summary | blocks target-state closure |
| AC-08 | Every blocking high-confidence finding from the baseline audit is fixed, registered, or explicitly reclassified by policy with rationale. | same-change registry/register updates and/or remediation PR evidence | blocks target-state closure |
| AC-09 | Closure-grade review packets can carry a `repo-hygiene-findings.yml` attachment and the closure validator recognizes it. | packet attachment schema and updated global closure validation | blocks closure claims |
| AC-10 | Two consecutive clean passes exist across architecture conformance, repo-hygiene enforcement/audit, and closure certification. | retained workflow evidence or equivalent CI proof | blocks closure claims |

## Ready-for-implementation rule

This proposal is ready for implementation use when:

- all packet-readiness gates are met;
- no in-scope source item remains untraced;
- the scope split between `.octon/**` promotion targets and dependent
  repo-local integrations is explicit and reviewable; and
- no hidden blockers remain in narrative prose.
