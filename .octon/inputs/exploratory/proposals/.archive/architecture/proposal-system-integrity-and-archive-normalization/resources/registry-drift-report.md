# Registry Drift Report

Baseline: visible repo state inspected on 2026-03-24.

## Goal
Identify where `/.octon/generated/proposals/registry.yml` and the visible proposal package tree do not currently behave like a clean projection.

## Active Surface
- Active registry entries observed in the inspected baseline: `studio-graph-ux-design-package` and `migration-rollout`.
- No active-package drift is asserted here beyond the absence of deterministic registry rebuild or reverse validation.

## Archived Drift Findings
| Id | Drift class | Current signal | Why it matters | Required action |
| --- | --- | --- | --- | --- |
| `mission-scoped-reversible-autonomy` | manifest/path mismatch | Registry projects the package as archived and implemented, but the visible archived manifest remains `status: accepted` with no archive block | Archive state cannot be trusted | Normalize the archived manifest or remove the entry from the main registry until repaired |
| `self-audit-and-release-hardening` | invalid lifecycle lineage | Archived packet uses `archived_from_status: proposed` | Value is outside the defined lifecycle | Replace with a valid prior state or reclassify as historical import |
| `harness-integrity-tightening` | invalid lifecycle lineage in registry | Registry projects `archived_from_status: proposed` | Projection contains an impossible lifecycle state | Repair the source packet and rebuild the registry |
| `capability-routing-host-integration` | orphan or incomplete archive packet | Registry points to an archived proposal path, but the visible archive package is incomplete and the expected `proposal.yml` is not available in the visible tree | Discovery can point at non-usable packets | Reconstruct the packet or remove it from the main registry |
| Archived design imports with `legacy-unknown` origin | historical-import leakage | Registry projects archived design entries whose `original_path` values point at older `.archive/.design-packages/**` lineage while the visible archive tree is not normalized into the same standard packet shape | The main registry mixes normalized packets with historical remnants | Normalize them into standard archive packets or split them into a separate historical-import projection |

## Target Rule
The main proposal registry must only project one existing, standard-conformant proposal package per entry. If the repo wants to retain incomplete historical lineage, that lineage should be normalized or split into a clearly separate historical view rather than mixed into the main proposal registry.

## Proposed Implementation
1. Add deterministic registry rebuild from manifests.
2. Add reverse validation so every registry entry resolves to exactly one valid proposal package.
3. Fail closed on orphaned entries, path mismatches, kind mismatches, status mismatches, duplicate ids, and invalid archive metadata.
4. Normalize or exclude the inventory above before turning the new checks on by default.
