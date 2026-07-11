---
source_id: SRC-012
source_type: conversation-turn
sequence: 12
supplied_at: "2026-07-09T19:34:29.000Z"
turn_id: "019f485f-d9a1-7e33-9126-8ce378d06361"
capture_status: complete
disclosure_status: local-only
authority_mode: non-authoritative
---

# SRC-012: Human decisions in plain language

## User Message

In plain language, what am I deciding:

Human Decisions
**Open question:** Sponsor must approve organization/repository names, current-repository disposition, public contribution intake, supported platforms, and first-release scope.
**Open question:** Security, Legal, and Release Operations must approve exposure findings, publication license/notice, provenance exceptions, trademark posture, trust roots, storage provider, retention, credential model, and release authorization. Architecture cannot resolve these by itself.

Give me suggestions to help me make a decision.


## Assistant Message 1 (final_answer)

You are deciding **what Octon will publish, where it will live, who may change or release it, and what level of risk is acceptable**. Some choices are product/governance decisions you can make; others need specialist sign-off.

## Decisions You Own

| Decision | What it means | Suggested choice |
|---|---|---|
| Repository ownership and names | Which GitHub organization controls Octon and what the private and public repositories are called. | Use an organization, not a personal account. Suggested names: private `octon-workspace`; public `octon`; current repository renamed `octon-legacy`. |
| Current repository disposition | What happens to the repository whose history is already public. | Freeze releases, perform the exposure review, then archive it as a clearly labeled legacy repository. Do not reuse it as the new public distribution repository. Security may recommend making it private, but that cannot retract existing copies. |
| Public contributions | Whether outsiders can directly submit code to the generated public mirror. | Initially make it an issue-and-patch intake surface. Maintainers apply accepted changes to the private canonical workspace and republish them. Directly merging public PRs would conflict with the mirror model. Revisit this if community contribution becomes a major goal. |
| Supported platforms | Which systems you promise to test, document, release, and fix. | Tier 1: Linux x86-64, macOS ARM64, Windows x86-64. Tier 2 preview: Linux ARM64 and macOS x86-64. Promote Tier 2 only after installation, update, interruption, and rollback tests are reliable. |
| First-release scope | How much of Octon goes into version 1. | Ship the complete **publication-cleared portable framework closure**, neutral bootstrap templates, wrappers, and required runtime binaries. Ship zero packs and no live instance, inputs, state, evidence, generated output, or host projections. |
| Contribution future | Whether the public mirror may eventually become canonical public source. | Keep the generated-mirror model for the first releases. Record a later decision point after operating experience and community demand are known. |

## Approvals You Need

| Decision | What it means | Suggested default |
|---|---|---|
| Exposure findings | Whether anything already public requires credential revocation, notification, repository restriction, or other response. | Freeze publication until Security completes the review. Revoke any exposed credential immediately; do not wait for Git cleanup. |
| Publication license | What others may legally do with Octon. | Ask Legal to evaluate Apache-2.0 as the default because it provides an explicit patent grant. Use one simple project-wide license where possible, plus a third-party notices file. |
| Provenance exceptions | Whether files with uncertain origin may ship. | Allow no exceptions in the first release. Quarantine or exclude unresolved files until provenance and publication permission are established. |
| Trademark posture | Whether the Octon name and branding may be reused independently of the code. | Keep trademark permission separate from the software license and publish short, practical usage guidelines. Legal must approve the wording. |
| Signing trust | What evidence convinces an installer that an artifact is authentic. | Use GitHub OIDC/Sigstore attestations tied to the public repository and protected workflow. Publish checksums and an offline verification bundle. Add a separate offline organizational key only if air-gapped users require it. |
| Evidence storage | Where private raw evidence is retained. | Do not make external evidence storage a first-release dependency. Keep evidence local initially. Later adopt a provider-neutral, encrypted object store with versioning or object lock and tested recovery. |
| Retention periods | How long logs, evidence, receipts, and release records are retained. | Starting policy: caches 7–30 days; CI artifacts 30–90 days; raw operational evidence according to project need; release evidence for the supported release lifetime plus a defined recovery period; governance receipts durably retained. Security and Legal set final periods. |
| Publication credentials | What automation is allowed to write to the public repository. | Use a narrowly scoped GitHub App with short-lived tokens. Do not use personal access tokens or place public publishing credentials in the workspace. |
| Release authorization | Who can approve a public release. | Require a protected release environment, separation between exporter and approver, and two-person approval for initial releases. Do not move or replace published version tags. |

## Recommended Decision Package

A sensible initial resolution is:

1. Create an organization-owned private `octon-workspace`.
2. Create a new organization-owned public `octon` repository with unrelated history.
3. Rename and archive the current repository after exposure review.
4. Treat the public repository as a generated mirror with issue/patch intake only.
5. Support three Tier 1 platforms and two preview platforms.
6. Ship the cleared portable framework closure with zero packs.
7. Permit no provenance exceptions for the first release.
8. Use Apache-2.0 as the license candidate, subject to Legal approval.
9. Use GitHub App credentials, protected environments, checksums, SBOMs, and OIDC/Sigstore attestations.
10. Keep operational state and raw evidence local until a real external storage policy is approved.

## What Blocks Release

The public release should not proceed without:

- Completed exposure review
- Approved license and notices
- File-level framework publication clearance
- New private and public repository identities
- Working deterministic `portable_dropin` export
- Protected publication credentials and authorization
- Verified checksums, provenance, and rollback behavior

External evidence storage, advanced community contributions, and a minimized runtime package can be deferred without blocking the first release.

