---
source_id: SRC-014
source_type: conversation-turn
sequence: 14
supplied_at: "2026-07-09T20:01:04.000Z"
turn_id: "019f4878-32b6-7132-8f72-44e9a2780d4f"
capture_status: complete
disclosure_status: local-only
authority_mode: non-authoritative
---

# SRC-014: Solo-maintainer decision calibration input

## User Message

Below is where I currently stand on each item. Make adjustments if needed considering the size and scope of this project and the fact that I am a solo developer using AI as my main development driver for this open-source project.

---

Repository ownership and names - I'm a solo developer and will use a personal account for now. I agree with the suggested names: private octon-workspace; public octon; current repository renamed octon-legacy.

Current repository disposition - Freeze releases, perform the exposure review, then archive it as a clearly labeled legacy repository. Do not reuse it as the new public distribution repository. Security may recommend making it private, but that cannot retract existing copies.

Public contributions - We are not accepting public contributions currently.

Supported platforms - Tier 1: Linux x86-64, macOS ARM64, Windows x86-64. Tier 2 preview: Linux ARM64 and macOS x86-64. Promote Tier 2 only after installation, update, interruption, and rollback tests are reliable.

First-release scope - Ship the complete **publication-cleared portable framework closure**, neutral bootstrap templates, wrappers, and required runtime binaries. Ship zero packs and no live instance, inputs, state, evidence, generated output, or host projections.

Contribution future - Keep the generated-mirror model for the first releases. Record a later decision point after operating experience and community demand are known.

Exposure findings - Freeze publication until Security completes the review. Revoke any exposed credential immediately; do not wait for Git cleanup.

Publication license - Determine what's best and typical for a solo-developer open-source project of this type and scope.

Provenance exceptions - Allow no exceptions in the first release. Quarantine or exclude unresolved files until provenance and publication permission are established.

Trademark posture - Decide on the best proactive posture for this considering the size and scope of the project.

Signing trust - Decide on the best proactive posture for this considering the size and scope of the project.

Evidence storage - As it stands, I want to keep evidence local indefinitely.

Retention periods - We can use the recommended policy as the starting default. "Starting policy: caches 7–30 days; CI artifacts 30–90 days; raw operational evidence according to project need; release evidence for the supported release lifetime plus a defined recovery period; governance receipts durably retained. Security and Legal set final periods." Maybe we should have a compaction preservation for high-value items that no longer need to be retained in full but could be helpful as summarized past background/context.

Publication credentials - Decide on the best posture for this considering the size and scope of the project. 

Release authorization - This is a solo-developer project and requiring two-person approval is not viable. Decide on the best posture for this considering the size and scope of the project.

---

Use my answers as general guidance on how I want to address each item but don't take it as the final answer. Determine the best and final answer for each based on the general direction I want to take, the size and scope of the project, and the fact that this is an solo developer open-source project. Determine what is best based on this.

Update final decisions, Recommended Decision Package, and What Blocks Release based the final decisions.





## Assistant Message 1 (commentary)

I’m adjusting the earlier enterprise-style controls into a solo-maintainer model. The main change is replacing human separation of duties with protected automation, staged releases, and one explicit final human approval, while keeping specialist review only for genuine legal or security exceptions.

## Assistant Message 2 (final_answer)

## Overall Adjustment

Your direction is sound. For a solo, AI-driven project, the model should emphasize:

- Strong automation instead of multiple human approvers
- One deliberate human publication decision
- A small first-release surface
- Low-maintenance security mechanisms
- No controls that imply nonexistent Security, Legal, or Release teams

You remain the decision authority. AI may prepare, scan, test, and package releases, but it should not make the final publication decision.

## Final Decisions

| Area | Final decision |
|---|---|
| Repository ownership | Use your personal GitHub account for now. Create private `octon-workspace`, public `octon`, and rename the current repository `octon-legacy`. Consider an organization only when another maintainer, funding, or ownership-transfer requirement appears. |
| Account resilience | Treat your personal account as critical infrastructure. Register at least two passkeys or security keys on separate devices and retain recovery codes offline. GitHub warns that losing every recovery method can permanently lock the account ([GitHub account recovery](https://docs.github.com/en/authentication/securing-your-account-with-two-factor-authentication-2fa/recovering-your-account-if-you-lose-your-2fa-credentials)). |
| Current repository | Freeze releases and complete the exposure review first. If cleared, rename and archive it publicly as `octon-legacy`. If sensitive material is found, revoke credentials immediately and decide whether to restrict visibility; previous public copies remain outside your control. |
| Public contributions | Do not accept code contributions initially. Keep Issues for bug reports and add private vulnerability reporting. State in `CONTRIBUTING.md` that the repository is a generated distribution mirror and external PRs are not currently accepted. |
| Contribution review point | Reconsider contributions after the first stable release and at least six months of operating experience, or when sustained community demand appears. |
| Supported platforms | Tier 1: Linux x86-64, macOS ARM64, Windows x86-64. Their install, update, interruption, and rollback tests block releases. Tier 2: Linux ARM64 and macOS x86-64; publish preview assets only when their tests pass, but failures do not block a release. |
| First-release scope | Ship the smallest dependency-closed, publication-cleared **portable base** that delivers installation, bootstrap, execution, update, and rollback. Do not equate this with all current `framework/**`. Ship zero packs and no project-local material. |
| Main license | Use `Apache-2.0` for Octon framework code, documentation, prompts, schemas, and runtime material. It is permissive and contains explicit copyright and patent licensing terms ([Apache guidance](https://www.apache.org/legal/apply-license)). |
| Scaffold templates | Use `MIT-0` for specifically designated neutral files intended to be copied into downstream projects, subject to final license validation. This avoids requiring generated projects to retain Octon attribution; MIT-0 appears on the current OSI-approved license list ([OSI licenses](https://opensource.org/licenses)). |
| License records | Publish `LICENSE`, `NOTICE`, `THIRD_PARTY_NOTICES`, and machine-readable SPDX classifications. Preserve any third-party license requirements. Do not invent a custom project license. |
| Provenance | Permit no unknown-origin exceptions in the first release. Classify material as maintainer-authored, AI-assisted and reviewed, third-party cleared, or unresolved. AI assistance is not itself a blocker; unresolved external origin is. |
| Trademark | Perform a documented name-conflict search before launching the new repository. Publish a lightweight `TRADEMARKS.md`: truthful references and compatibility claims are allowed, but forks may not imply endorsement or present themselves as official Octon. |
| Trademark registration | Do not pursue registration initially unless the clearance search finds risk, commercial use begins, or adoption makes the brand materially valuable. You may use `Octon™`; do not use `®` without registration ([USPTO guidance](https://www.uspto.gov/trademarks/basics/what-trademark)). |
| Signing trust | Use GitHub artifact attestations backed by Sigstore, plus `SHA256SUMS` and an SBOM. Build and attest artifacts from the public repository commit. Artifact attestations are available for public repositories on current GitHub plans ([GitHub attestations](https://docs.github.com/en/enterprise-cloud%40latest/actions/how-tos/secure-your-work/use-artifact-attestations/use-artifact-attestations)). |
| Additional signing keys | Do not introduce a separately managed PGP or signing key initially. It creates disproportionate custody and rotation work. Add one later only if air-gapped consumers require an independent trust root. |
| Release immutability | Enable immutable releases, protect version tags, and never replace an existing release asset or move a version tag. GitHub supports repository-level release immutability for future releases ([GitHub release immutability](https://docs.github.com/en/code-security/how-tos/secure-your-supply-chain/establish-provenance-and-integrity/prevent-release-changes)). |
| Evidence storage | Keep raw operational evidence under your custody indefinitely as the storage model. Use encrypted machine-local storage plus at least one encrypted, disconnected backup. “Local” should not mean “only one copy on one machine.” |
| Hosted evidence | Commit only compact, reviewed receipts needed to justify releases or governance decisions. Do not commit raw logs, traces, prompts, transcripts, or run evidence. |
| Publication credentials | Use a GitHub App installed only on public `octon` for cross-repository export PRs. Installation tokens expire after one hour, and GitHub recommends Apps over PATs for automation ([GitHub App practices](https://docs.github.com/en/enterprise-cloud%40latest/apps/creating-github-apps/about-creating-github-apps/best-practices-for-creating-a-github-app)). |
| Release credentials | In the public repository, use the built-in `GITHUB_TOKEN` with job-level least permissions and `id-token: write` only for attestation. Keep workflow defaults read-only. Do not use a personal access token for routine publication. |
| Secret protection | Enable personal push protection, public-repository secret scanning, and local/CI secret scanning in the private workspace. Public repositories receive free GitHub secret scanning, but local scanning is still required for unsupported secret patterns ([GitHub secret-scanning scope](https://docs.github.com/en/code-security/reference/secret-security/secret-scanning-scope)). |
| Release authorization | Replace two-person approval with a protected, two-stage solo release ceremony: automation creates a validated public PR; you review and merge it; a separate manual action publishes the exact public commit. |
| Release environment | Use a protected `release` environment with yourself as the sole reviewer, self-review permitted, branch/tag restrictions enabled, and administrator bypass disabled. GitHub environments support this workflow for public repositories ([GitHub environments](https://docs.github.com/en/actions/reference/workflows-and-actions/deployments-and-environments)). |
| Emergency releases | Permit an explicit emergency path that still runs all security and artifact-integrity checks. Record the reason, affected version, and follow-up work in a release receipt. |

The licensing and trademark recommendations are architecture and operating-policy choices, not legal opinions. Seek professional review if the provenance audit finds copied, vendor-derived, contract-restricted, or otherwise ambiguous material.

## Evidence Retention and Compaction

Use these defaults:

| Material | Default retention |
|---|---|
| Rebuildable caches | Remove after 14 days unused |
| Routine local run state and logs | 30 days, then compact or delete |
| Failed or high-impact run evidence | 180 days, then review |
| CI transport artifacts | 30 days |
| Release-candidate artifacts | 90 days |
| Published checksums, SBOMs, attestations, and release receipts | Indefinite |
| Governance decisions and compact receipts | Project lifetime |
| Security-incident evidence | Until resolved, plus a separately documented retention period |
| Evidence needed for reproducibility | Retain raw while the corresponding claim or release remains supported |

A compacted **evidence capsule** should retain:

- Evidence identifier and classification
- Date, scope, and purpose
- Relevant result or decision
- Source and artifact hashes
- Tool and version information
- Redacted summary
- Reason raw material was retained or deleted
- Any remaining local pointer

Compaction is not equivalent to retaining the original evidence. Raw material should be deleted only after the capsule is verified and no release, incident, recovery, or governance requirement still depends on it.

## Recommended Decision Package

1. Continue under your personal GitHub account, protected by multiple passkeys and offline recovery information.
2. Establish `octon-workspace`, `octon`, and `octon-legacy` as distinct repository roles.
3. Keep `octon` as a generated mirror with no external code contributions initially.
4. Ship a dependency-closed portable base, not the entire current framework by path.
5. License core Octon under `Apache-2.0` and designated copy-out templates under `MIT-0`.
6. Require publication clearance for all exported material, including AI-assisted content.
7. Use a lightweight trademark policy and defer formal registration.
8. Use GitHub/Sigstore attestations, checksums, SBOMs, protected tags, and immutable releases.
9. Use a narrowly scoped GitHub App for private-to-public publication and `GITHUB_TOKEN` for public releases.
10. Keep raw evidence local with encrypted offline redundancy and compact high-value receipts.
11. Replace two-person approval with validated automation, a reviewed export PR, and a separate manual publication action.
12. Revisit organization ownership, contributions, independent signing keys, and trademark registration only when project adoption justifies their maintenance cost.

## What Blocks the First Release

The first release is blocked until all of these are complete:

1. Current public history, releases, artifacts, and credentials have been reviewed for exposure.
2. Any exposed credential has been revoked.
3. The three repository roles have been established without shared public workspace history.
4. The portable base has an explicit dependency-closed allowlist.
5. Every exported file has an accepted provenance and license classification.
6. The Octon name has received a documented basic conflict search.
7. `LICENSE`, `NOTICE`, `THIRD_PARTY_NOTICES`, `SECURITY.md`, `CONTRIBUTING.md`, and `TRADEMARKS.md` are ready.
8. `portable_dropin` produces deterministic public output and rejects excluded material.
9. Tier 1 installation, update, interruption, and rollback tests pass.
10. The GitHub App, public rulesets, release environment, secret scanning, attestations, SBOM, checksums, and immutable releases are operational.
11. A clean public-repository tree has passed final secret, sensitivity, license, provenance, and denylist validation.
12. You have manually reviewed and approved the exact first-release commit and artifact manifest.

The following do **not** need to block the first release:

- Moving to a GitHub organization
- Accepting public contributions
- Passing Tier 2 platforms
- External or cloud evidence storage
- Formal trademark registration
- A separate PGP or organizational signing key
- Additive packs
- A second human release approver

