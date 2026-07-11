---
source_id: SRC-015
source_type: conversation-turn
sequence: 15
supplied_at: "2026-07-09T20:57:08.000Z"
turn_id: "019f48ab-85a9-7b50-bca6-dca303e54b3a"
capture_status: complete
disclosure_status: local-only
authority_mode: non-authoritative
---

# SRC-015: Final solo-maintainer decision calibration

## User Message

# Octon Final Decision Calibration

Act as a principal software architect, security-boundary reviewer, release engineer, and solo-maintainer operations advisor.

## Objective

Perform a final calibration of the proposed Octon public-distribution and delivery decisions.

Challenge the current recommendations rather than preserving them automatically. Produce the simplest operating model that remains secure, reproducible, maintainable, recoverable, and appropriate for a solo developer using AI as the primary development driver.

“Final” means the adopted operating baseline for the first public release and the next implementation phase. It does not mean the decisions can never change.

Do not redesign Octon broadly. Limit the review to calibrating the current distribution, publication, update, storage, licensing, provenance, and release decisions.

## Evidence and Authority Order

Evaluate evidence in this order:

1. Current repository and hosted-repository evidence
2. Non-negotiable architectural boundaries below
3. Sponsor operating constraints and preferences
4. Prior decision records and attached conversations
5. Current official platform documentation and established engineering practice

Treat prior recommendations as planning history, not authority.

When repository behavior conflicts with the intended model:

- identify the conflict;
- determine whether the implementation or the decision should change;
- do not assume existing behavior is correct merely because it exists.

Use current primary or official sources for time-sensitive GitHub, licensing, signing, security, and platform claims.

## Non-Negotiable Boundaries

Preserve these unless repository evidence proves them infeasible or internally contradictory:

- The full Octon development workspace and the public distribution are separate repositories.
- The public repository is populated only from a deterministic, allowlist-based `portable_dropin` export.
- The public repository does not inherit or expose workspace Git history.
- The public distribution contains only publication-cleared portable framework material and neutral bootstrap content.
- Project-specific instance authority, inputs, state, evidence, generated output, host projections, logs, archives, and local residue are excluded.
- The base public distribution ships with zero additive packs.
- Core updates may modify only explicitly core-owned paths.
- Core updates may not overwrite project-owned authority, inputs, state, evidence, generated output, host projections, or unrelated project files.
- Irreversible public publication and explicit risk acceptance require a deliberate human action.
- Non-authoritative or generated material is not automatically safe to publish.

## Current Sponsor Direction

Treat the following as strong operating preferences that may be revised only when a concrete risk, incompatibility, or disproportionate cost justifies it:

- Octon is currently a solo-maintainer project.
- Repository ownership will remain under a personal GitHub account for now.
- Intended repositories are:
  - private `octon-workspace`;
  - public `octon`;
  - archived `octon-legacy`.
- Public code contributions are not currently accepted.
- Tier 1 targets are:
  - Linux x86-64;
  - macOS ARM64;
  - Windows x86-64.
- Tier 2 preview targets are:
  - Linux ARM64;
  - macOS x86-64.
- The first release should contain the smallest dependency-closed, publication-cleared portable base that provides the promised Octon workflows.
- Raw operational evidence should remain under the maintainer’s local custody.
- Two-person release approval is not viable.
- AI and deterministic automation should perform repetitive analysis, validation, packaging, and release preparation.
- The maintainer remains the final publication and risk-acceptance authority.

## Guiding Principles

### Solo-First Development

Optimize for one maintainer.

Do not introduce organizational roles, approval structures, paid services, infrastructure, or recurring operational work that assumes a larger team unless a concrete first-release requirement makes them necessary.

Where human separation of duties is impractical, use:

- deterministic validation;
- protected automation;
- explicit ownership boundaries;
- staged release transitions;
- deliberate final human authorization;
- recoverable and auditable operations.

Do not describe nonexistent “Security,” “Legal,” or “Release Operations” teams as decision owners. Instead, identify:

- what the maintainer can decide directly;
- the exact question requiring specialist advice;
- the condition that makes specialist involvement necessary.

### Minimal Sufficient Complexity

> As simple as possible, as complex as necessary.

Every mechanism must address a named risk, requirement, or failure mode.

Prefer:

- standard licenses;
- GitHub-native controls;
- short-lived credentials;
- keyless signing;
- deterministic manifests;
- content hashes;
- small schemas and validators;
- reversible defaults.

Avoid:

- custom platforms;
- premature services;
- redundant approval layers;
- bespoke cryptography;
- speculative multi-maintainer governance;
- controls whose recurring maintenance exceeds their current risk reduction.

### Velocity Through Agentic Automation

Use AI and deterministic automation to:

- inventory and classify files;
- prepare provenance records;
- detect excluded paths;
- scan for secrets and sensitive material;
- generate manifests and SBOMs;
- compare exported trees;
- run compatibility and rollback tests;
- prepare release candidates and decision summaries.

AI output is review input, not authority.

AI must not independently:

- approve publication;
- accept legal or provenance uncertainty;
- waive failed security controls;
- authorize destructive migration;
- classify ambiguous material as safe without evidence.

Prefer deterministic validation over AI judgment wherever the rule can be expressed mechanically.

### Complexity Calibration

For each proposed control, classify it as:

- `first-release-required`
- `post-release-required`
- `defer-until-trigger`
- `remove`

Also assign a decision disposition:

- `keep`
- `simplify`
- `strengthen`
- `defer`
- `remove`

A first-release blocker must:

- prevent a concrete material failure;
- have an objective acceptance test;
- have a clear condition for becoming unblocked.

Do not make something a release blocker merely because it represents ideal future maturity.

### Focus Through Absorbed Complexity

> Build features, not infrastructure.

Move repeated complexity into stable:

- kits;
- schemas;
- manifests;
- templates;
- validators;
- release profiles;
- generated receipts.

Prefer one-time automation that removes recurring cognitive load.

Use established platform functionality when it provides equivalent protection. Do not build internal infrastructure merely to reproduce GitHub or standard ecosystem capabilities.

## Required Evaluation

Evaluate every current decision concerning:

- repository ownership and topology;
- legacy-repository disposition;
- public contribution policy;
- supported platforms and support tiers;
- first-release package scope;
- licensing and generated-template licensing;
- AI-assisted and third-party provenance;
- trademark posture;
- artifact signing and supply-chain trust;
- evidence storage;
- retention and evidence compaction;
- publication credentials;
- release authorization;
- public-repository protections;
- `portable_dropin`;
- downstream installation, updates, rollback, and recovery.

For every decision:

1. State the concrete risk or requirement.
2. State the simplest adequate control.
3. Confirm, revise, simplify, defer, or reject the current recommendation.
4. Identify implementation cost as `low`, `medium`, or `high`.
5. Identify recurring maintenance cost as `low`, `medium`, or `high`.
6. Describe the residual risk after the control is implemented.
7. Determine whether the decision is easily reversible.
8. Assign work to:
   - deterministic automation;
   - AI-assisted review;
   - maintainer judgment;
   - external specialist, only when genuinely necessary.
9. Define an objective acceptance test.
10. Identify the trigger that would justify a more advanced model later.

Prefer a simpler alternative whenever it provides materially equivalent protection.

## Specific Calibration Questions

Resolve explicitly:

1. Whether personal-account ownership is sufficient for the first release and what account-recovery controls it requires.
2. Whether `octon-legacy` should remain public, become private, or depend on exposure findings.
3. How the public repository should communicate that external code contributions are not currently accepted.
4. Whether all three Tier 1 platforms should block the first release.
5. Whether the proposed portable base is small enough for a solo maintainer to clear and maintain.
6. Whether one license is sufficient or designated copy-out templates require separate treatment.
7. How AI-assisted material should be recorded without creating unmaintainable file-level bureaucracy.
8. Whether a lightweight trademark policy is necessary before release and what can be deferred.
9. Whether GitHub-native attestations, checksums, SBOMs, and immutable releases provide sufficient initial signing trust.
10. Whether any separately managed signing key is justified now.
11. How locally retained evidence is protected against machine loss without introducing a hosted evidence service.
12. Which evidence classes should be compacted, retained raw, or deleted.
13. Whether a GitHub App is justified for cross-repository publication or whether a simpler credential model provides equivalent protection.
14. What solo-maintainer release ceremony provides sufficient deliberate authorization without pretending there is a second reviewer.
15. Which controls genuinely block release and which are merely desirable improvements.

## Repository Evidence to Verify

At minimum, verify current behavior and constraints in:

- `.octon/octon.yml`
- `.octon/framework/**`
- `.octon/framework/orchestration/runtime/_ops/scripts/export-harness.sh`
- `.octon/framework/scaffolding/runtime/**`
- `.octon/framework/scaffolding/runtime/templates/octon/**`
- `.octon/framework/constitution/contracts/retention/**`
- `.octon/framework/orchestration/runtime/_ops/scripts/write-run.sh`
- `.gitignore`
- `CODEOWNERS`
- `.github/workflows/release-please.yml`
- `.github/workflows/runtime-binaries.yml`
- current GitHub repository visibility, protections, security settings, environments, tags, and releases

Inspect other paths only when needed to validate a dependency, boundary, or publication path.

## Required Deliverables

### 1. Final Verdict

Provide a concise verdict on whether the calibrated model is:

- appropriately simple;
- secure enough for first publication;
- feasible for one maintainer;
- ready to become the implementation baseline.

### 2. Decision Register

Use this schema:

| Decision | Final position | Disposition | Timing | Risk addressed | Implementation cost | Maintenance cost | Operator | Residual risk | Escalation trigger | Acceptance test |
|---|---|---|---|---|---|---|---|---|---|---|

`Timing` must be one of:

- `first-release-required`
- `post-release-required`
- `defer-until-trigger`
- `remove`

`Operator` must identify one or more of:

- deterministic automation
- AI-assisted review
- maintainer
- external specialist

### 3. Changes From the Current Decision Set

List:

- decisions retained;
- decisions simplified;
- decisions strengthened;
- decisions deferred;
- decisions removed.

Explain any material change from the current recommendation.

### 4. Final Recommended Decision Package

Provide one unambiguous current decision for every evaluated topic.

Do not present multiple equal alternatives unless a genuine sponsor choice remains unavoidable.

### 5. First-Release Blockers

Provide the smallest sufficient blocker set.

For each blocker include:

- failure prevented;
- validation mechanism;
- objective unblock condition.

### 6. Deferred Controls

List every deferred control with:

- why it is unnecessary now;
- the concrete adoption, threat, scale, or operational trigger that would activate it.

### 7. Solo-Maintainer Release Workflow

Provide a concise end-to-end workflow covering:

1. private workspace preparation;
2. deterministic export;
3. public-tree validation;
4. public-repository update;
5. release-candidate build;
6. maintainer review;
7. deliberate publication;
8. verification and rollback.

Keep the workflow short enough to operate routinely.

### 8. Specialist Questions

Do not say only “consult Legal” or “Security must approve.”

For each specialist question provide:

- the exact unresolved issue;
- why architecture cannot resolve it;
- whether it blocks release;
- the condition under which specialist involvement becomes necessary.

### 9. Implementation Handoff

Provide a short ordered implementation sequence, not a new architecture roadmap.

Each step must identify:

- the decision it implements;
- its dependency;
- its acceptance test.

## Constraints

- Begin read-only.
- Do not modify files, Git history, repository settings, remotes, releases, or credentials.
- Do not publish or migrate material.
- Do not inspect human-led ideation content.
- Do not expose sensitive content.
- Do not make unsupported legal or intellectual-property conclusions.
- Do not treat private hosting as sufficient protection.
- Do not treat generated or non-authoritative material as publication-safe.
- Do not require a second human approver.
- Do not recommend an organization solely to imitate enterprise governance.
- Do not recommend paid infrastructure without identifying the requirement that justifies it.
- Do not reopen the established private-workspace/public-mirror boundary without evidence of infeasibility.
- Do not let AI approve publication, waive controls, or accept unresolved provenance.
- Do not allow workspace Git history to become the public-distribution mechanism.

## Definition of Done

The calibration is complete only when:

- every topic has one clear current decision;
- every first-release blocker addresses a concrete failure and has an objective test;
- every deferred control has an activation trigger;
- recurring solo-maintainer burden is explicitly assessed;
- duplicate or ceremonial controls have been removed;
- the release workflow is feasible without a second person;
- AI and deterministic automation responsibilities are clearly separated;
- remaining specialist questions are precise rather than generic;
- the result can be adopted directly as the implementation decision baseline.

## Assistant Message 1 (commentary)

I’ll re-verify the repository and hosted GitHub state, then calibrate each control against a solo-maintainer cost test. I’ll keep the established workspace/export boundary fixed and reduce anything that does not prevent a concrete first-release failure.

## Assistant Message 2 (commentary)

The repository still presents two different operating models at once: its class-root documentation supports the intended boundary, while its current exporter, bootstrap, retention implementation, and release workflow bypass or blur it. I’m now measuring which gaps truly block publication versus which can be deferred without weakening the first release.

## Assistant Message 3 (commentary)

A key simplification is emerging: the first release does not need external evidence infrastructure, a second signing key, or multi-person governance. It does need a much smaller export contract than “all of framework,” because the current framework contains thousands of files and hundreds of executables with no publication-clearance ledger or dependency-closure model.

## Assistant Message 4 (commentary)

The solo-first calibration changes three earlier recommendations materially: use an explicit maintainer-run publication command instead of a GitHub App initially; use one manual publish action instead of a self-approval environment ceremony; and defer external evidence storage entirely while correcting the framework’s current false “external immutable” claims.

## Assistant Message 5 (commentary)

The blocker set is now down to six groups, all with mechanical pass conditions. Organization migration, a GitHub App, independent signing keys, external evidence storage, formal trademark registration, Tier 2 gating, vendored mode, and automated instance migrations are not first-release requirements.

## Assistant Message 6 (final_answer)

## Final Verdict

The calibrated model is **appropriately simple, feasible for one maintainer, and suitable as the implementation baseline**.

It is **not ready for publication yet**. The architecture is sound, but six implementation blocker groups remain. The main calibration result is that Octon does not need an organization, GitHub App, second signer, hosted evidence service, second reviewer, or formal trademark registration for its first release.

## Verified Current State

| Finding | Verified conflict |
|---|---|
| CAL-001 Critical | The current repository is public, not the intended private workspace. Repository-level secret scanning and push protection report disabled, and releases remain mutable ([repository API](https://api.github.com/repos/jamesryancooper/octon)). |
| CAL-002 Critical | [`export-harness.sh`](/Users/jamesryancooper/Projects/octon/.octon/framework/orchestration/runtime/_ops/scripts/export-harness.sh:91) copies the working tree with `cp -R`, includes instance material, and invokes source-mutating publication scripts. |
| CAL-003 High | `portable_dropin`, a core lock, resolver, cache, transactional updater, and rollback implementation do not exist. The current profile validator rejects new profile names ([validator](/Users/jamesryancooper/Projects/octon/.octon/framework/assurance/runtime/_ops/scripts/validate-root-manifest-profiles.sh:107)). |
| CAL-004 High | Bootstrap is Bash-only, requires an existing `.octon`, writes project configuration into `framework/**`, and its template manifest declares required files that are absent ([init-project.sh](/Users/jamesryancooper/Projects/octon/.octon/framework/scaffolding/runtime/bootstrap/init-project.sh:840), [manifest.json](/Users/jamesryancooper/Projects/octon/.octon/framework/scaffolding/runtime/templates/octon/manifest.json:8)). |
| CAL-005 High | [`write-run.sh`](/Users/jamesryancooper/Projects/octon/.octon/framework/orchestration/runtime/_ops/scripts/write-run.sh:1079) emits synthetic “external immutable” locators and digest strings without an external object or real content hash. |
| CAL-006 High | [`release-please.yml`](/Users/jamesryancooper/Projects/octon/.github/workflows/release-please.yml:38) requires a PAT and commits generated/state material from the workspace release branch. Runtime packaging downloads `yq` without verifying its digest ([runtime-binaries.yml](/Users/jamesryancooper/Projects/octon/.github/workflows/runtime-binaries.yml:76)). |
| CAL-007 Release blocker | The 4,052-file framework has no root license, publication-clearance ledger, provenance inventory, or dependency-closed portable-base manifest. |
| CAL-008 Post-release | Git tracks roughly 398 MiB of state and 22 MiB of generated output. [`.gitignore`](/Users/jamesryancooper/Projects/octon/.gitignore:53) contains extensive exceptions that preserve this high-churn model. |

Keep the five class roots, framework/instance ownership split, generated non-authority, zero-pack base, and separate public mirror. Those boundaries remain correct ([shared-foundation.md](/Users/jamesryancooper/Projects/octon/.octon/framework/cognition/_meta/architecture/shared-foundation.md:28)).

## Decision Register

| Decision | Final position | Disposition | Timing | Risk addressed | Implementation cost | Maintenance cost | Operator | Residual risk | Escalation trigger | Acceptance test |
|---|---|---|---|---|---|---|---|---|---|---|
| Personal ownership | Personal account is sufficient. Register two passkeys in separate failure domains and retain recovery codes offline. No organization or paid plan is required. | `strengthen` | `first-release-required` | Account compromise or lockout | low | low | maintainer | One person remains the ownership bottleneck. Reversible by repository transfer. | Second maintainer, institutional ownership, funding, or succession requirement | Secondary passkey works; recovery material exists offline; 2FA is active. GitHub recommends multiple devices for device-bound passkeys ([GitHub passkeys](https://docs.github.com/en/authentication/authenticating-with-a-passkey/managing-your-passkeys)). |
| Repository topology | Private `octon-workspace`, new public `octon`, and renamed `octon-legacy`; public `octon` has synthetic history. | `keep` | `first-release-required` | Workspace history disclosure | medium | low | deterministic automation, maintainer | Repository-role confusion remains possible. Partly reversible after publication. | None; this is the standing boundary | No shared Git ancestry; workspace has no public push remote; public tree matches an export manifest. |
| Legacy repository | Keep `octon-legacy` public and archived only if exposure review clears it. Otherwise restrict visibility after immediate credential revocation and incident disposition. | `strengthen` | `first-release-required` | Continuing exposure | medium | low | deterministic automation, AI-assisted review, maintainer, external specialist on a finding | Existing copies cannot be recalled. Not fully reversible. | Active secret, private data, contractual material, or plausible license restriction found | Signed inventory and disposition cover history, tags, releases, Actions artifacts, issues, and PR attachments. |
| Contributions | Do not accept external code contributions. State this in README and `CONTRIBUTING.md`; keep Issues and private vulnerability reporting. | `keep` | `first-release-required` | Contributor expectations and mirror drift | low | low | maintainer | Unsolicited PRs may still appear. Easily reversible. | Capacity and sustained demand to review external code | Public docs state the policy and security-reporting route; no workflow grants external PR code secrets or write access. |
| Platform tiers | Linux x86-64, macOS ARM64, and Windows x86-64 all block release. Tier 2 targets build only when passing and never block. | `keep` | `first-release-required` | Unsupported Tier 1 claims | high | medium | deterministic automation, maintainer | User environments exceed CI coverage. Reversible by an explicit support-tier change. | A Tier 1 target becomes unsustainable; demote it publicly rather than waive tests | Clean install, bootstrap, verify, update, interruption, and rollback pass on all three Tier 1 targets. |
| Portable-base scope | Define a component manifest for only the constitutional kernel, required runtime, bootstrap, validation, update machinery, and essential documentation. Do not export all `framework/**` by path. | `strengthen` | `first-release-required` | Unreviewable size and hidden dependencies | high | medium | deterministic automation, AI-assisted review, maintainer | Undeclared runtime dependency may remain. Additive expansion is reversible. | A later capability is proven essential to the base | Every exported path has a component and dependency reason; clean-room scenarios pass with everything else absent. |
| `portable_dropin` | Export an exact commit into an empty stage using an allowlist; never read untracked/ignored files, mutate source, or copy Git history. One manifest marks paths `installable` or `public-repo-only`. | `strengthen` | `first-release-required` | Sensitive-path and residue leakage | high | low | deterministic automation, AI-assisted review, maintainer | Exporter defects remain possible. Versioned and reversible. | New artifact component or publication class | Two builds produce identical digests; denylist injection tests fail closed; public tree equals the manifest. |
| Licensing | Apache-2.0 for core source, docs, prompts, schemas, and binaries; MIT-0 for explicitly designated copy-out templates. Use standard licenses only. Add third-party notices only when required. | `keep` | `first-release-required` | Ambiguous reuse and scaffold obligations | medium | low | deterministic automation, AI-assisted review, maintainer, external specialist on ambiguity | Rights cannot be inferred from a license declaration. Published grants are not retractable. | Non-original, employer/client, vendor, or contract-derived material | Every export path maps to Apache-2.0, MIT-0, or a cleared third-party entry; zero unknowns. Both are standard approved licenses ([Apache-2.0](https://www.apache.org/licenses/LICENSE-2.0), [MIT-0](https://opensource.org/license/mit-0)). |
| AI and third-party provenance | Record provenance by component and release, with path-level overrides only for exceptions. AI-assisted work is one normal category; unknown origin blocks export. | `simplify` | `first-release-required` | Unmaintainable file-level records and copied material | medium | low | deterministic automation, AI-assisted review, maintainer | Similarity to unknown source may escape detection. Reversible before publication. | External contributions, vendor imports, or copied examples begin | All exported paths inherit a provenance record; external dependencies and exceptions are explicit; no `unknown` entries. |
| Trademark | Perform a documented name search and add one README sentence reserving official Octon identity. Do not require `™`, a separate policy, or registration now. Apache-2.0 already withholds trademark permission. | `simplify` | `first-release-required` | Avoidable naming conflict and false endorsement | low | low | AI-assisted review, maintainer, external specialist only on a conflict | A conflict may be missed. Easily reversible before material adoption. | Similar software/AI marks found, commercial activity, impersonation, or registration intent | Search USPTO, GitHub, package registries, and general web; record results and resolve plausible conflicts ([USPTO search guidance](https://www.uspto.gov/trademarks/search)). |
| Signing and trust | Public CI emits SHA-256 checksums, an SBOM, and GitHub/Sigstore attestations from the public commit; enable immutable releases. No separate signing key. | `simplify` | `first-release-required` | Artifact substitution and opaque provenance | medium | low | deterministic automation, maintainer | Trust depends on GitHub, the account, and workflow identity. Mechanism is reversible; published releases are not. | Independent registry, regulated adopter, or true air-gap trust requirement | Fresh download verifies checksum and attestation against repository/workflow identity; SBOM matches payload; release is immutable. GitHub supports public attestations and immutable releases ([attestations](https://docs.github.com/en/enterprise-cloud%40latest/actions/how-tos/secure-your-work/use-artifact-attestations/use-artifact-attestations), [immutability](https://docs.github.com/en/code-security/how-tos/secure-your-supply-chain/establish-provenance-and-integrity/prevent-release-changes)). |
| Evidence semantics | Raw evidence remains `local-private`. Disable unsupported external storage mode and emit real content hashes only. No external evidence service. | `strengthen` | `first-release-required` | False durability and replay claims | medium | low | deterministic automation, maintainer | Local evidence can be lost. Reversible through a later backend version. | Multi-machine operation, multiple maintainers, remote replay, or recovery objective | No run claims `external-immutable`; every retained pointer has a real SHA-256 and reachable local object. |
| Local backup | Use the maintainer’s encrypted system backup plus one disconnected encrypted backup. Do not build this into Octon infrastructure. | `simplify` | `post-release-required` | Machine loss | low | low | maintainer | Correlated physical loss or stale backup. Easily replaceable. | Recovery-time requirement or multiple machines | Restore one raw artifact and its compact receipt from backup. |
| Retention policy | Ephemeral caches: disposable; successful routine evidence: 30 days; failed-run evidence: 90 days after resolution; release/security evidence: while claim remains live plus 90 days; compact governance/release receipts: indefinite. | `simplify` | `first-release-required` | Unbounded storage and premature deletion | low | low | deterministic automation, maintainer | A class may be misassigned. Policy is reversible; deletion is not. | Regulatory data, legal hold, or project-specific recovery need | Every evidence class resolves to one retention rule; deletion refuses active holds and unclassified material. |
| Compaction and Git cleanup | Add deterministic dry-run compaction later. AI may draft summaries; only the maintainer authorizes deletion. Migrate state/generated/host projections out of Git forward, without rewriting history. | `defer` | `post-release-required` | Churn and local disk growth | medium | low | deterministic automation, AI-assisted review, maintainer | Summaries lose raw detail; deletion is irreversible. | Evidence exceeds 10 GB or monthly cleanup exceeds 30 minutes | Idempotent dry-run; capsule contains hashes, scope, result, limitations, and deletion decision; clean clone rebuilds derived outputs. |
| Publication credentials | Do not create a GitHub App yet. Use normal maintainer `gh`/SSH authentication from a separate public-repository checkout. Store no cross-repository PAT and keep no public push remote in the workspace. | `simplify` | `first-release-required` | Long-lived automation credential leakage | low | low | deterministic automation, maintainer | Maintainer credential retains account-level importance. Easily reversible. | Publication must become unattended or CI-driven, or another maintainer joins | Publish command validates destination, displays export digest, and requires explicit `--authorize <digest>` before pushing a public branch. |
| Release authorization | Merge builds a draft candidate automatically. The maintainer reviews its manifest and invokes one separate manual publish workflow for the exact commit. No second reviewer or self-approval environment ceremony. | `simplify` | `first-release-required` | Accidental irreversible release | medium | low | deterministic automation, maintainer | A compromised maintainer account can still authorize release. Reversible only through a new corrective version. | Additional maintainer or higher-assurance adopter | Merge never creates a public release; only manual publish does; authorization record includes commit, version, and manifest digest. |
| Public protections | Require PRs and status checks but zero review count; prohibit force-push/deletion/bypass; protect tags; enable secret scanning/push protection; pin Actions; use least-privilege `GITHUB_TOKEN`; fix or remove placeholder `CODEOWNERS`. | `strengthen` | `first-release-required` | Direct mutation, secret leakage, and workflow compromise | medium | low | deterministic automation, maintainer | Account takeover remains possible. Settings are reversible. | Additional writers or public contributions | API assertions verify every setting; negative workflow tests cannot write from untrusted PRs. Public rulesets are available for personal public repositories ([GitHub rulesets](https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/managing-rulesets/about-rulesets)). |
| Downstream install/update | Commit exact core lock and project authority; materialize framework locally from a verified release. Provide `install`, `verify`, `update`, and `rollback`; stage atomically, journal interruption, and hash project-owned paths. | `keep` | `first-release-required` | Non-reproducible or destructive updates | high | medium | deterministic automation, maintainer | OS file-lock behavior and schema evolution remain. Partly reversible through lock rollback. | First incompatible instance-schema transition | Tier 1 fault-injection tests restore the previous lock/tree and prove all project-owned hashes unchanged. |
| Offline and migrations | Support installation from a previously downloaded local artifact. Defer committed vendoring, internal mirrors, and automatic instance migration. | `defer` | `defer-until-trigger` | Premature modes and migration complexity | low | none | deterministic automation, maintainer | Air-gapped projects lack a polished workflow. Reversible. | Actual air-gapped adopter or second incompatible schema release | No implementation now; trigger creates a separately accepted requirement and tests. |

## Changes From the Previous Decision Set

**Retained:** personal ownership, three repositories, no public contributions, all three Tier 1 targets, zero packs, local evidence, Apache-2.0 core licensing, GitHub-native attestations, checksums, SBOMs, immutable releases, and project-owned update boundaries.

**Simplified:**

- GitHub App replaced by an explicit maintainer-run publish command.
- Self-review environment approval removed as ceremonial duplication.
- AI provenance moved from file-level records to component/release inheritance.
- Full trademark policy replaced by basic clearance and one identity statement.
- Evidence retention reduced to five operational classes.
- `portable_dropin` produces one component-tagged public tree; public CI builds the install archive from it.

**Strengthened:**

- All Tier 1 platforms genuinely gate release.
- Export reads an exact Git tree, not the working tree.
- Public branch publication requires local validation before anything is pushed.
- Unsupported external-evidence claims must be removed.
- Public PR, tag, secret, token, and release protections are objective API-validated gates.

**Deferred:** organization ownership, public contributions, GitHub App, independent signing key, formal trademark registration, external evidence service, scheduled compaction, Tier 2 gating, vendored mode, internal mirrors, and automatic instance migrations.

**Removed:** two-person approval, stored publication PAT, self-approval deployment ceremony, custom cryptography, blanket external storage, empty `NOTICE` files, and per-file AI labels.

## Final Recommended Decision Package

1. Operate under the personal account with two independent passkeys and offline recovery material.
2. Use private `octon-workspace`, new public `octon`, and conditionally public archived `octon-legacy`.
3. Accept no external code contributions; retain issue and vulnerability reporting.
4. Gate release on all three Tier 1 platforms; keep Tier 2 non-blocking.
5. Ship only a manifest-defined portable base with zero packs.
6. License core under Apache-2.0 and designated copy-out templates under MIT-0.
7. Record provenance by component/release; unresolved origin blocks export.
8. Perform basic name clearance; defer formal trademark policy and registration.
9. Use checksums, SBOM, GitHub attestations, protected tags, and immutable releases; use no separate key.
10. Keep raw evidence local, truthfully labeled and content-hashed; use ordinary encrypted backups.
11. Apply simple class-based retention; add compaction and Git cleanup after release.
12. Publish public-tree branches manually from a separate checkout; use no PAT or GitHub App initially.
13. Build draft candidates automatically but require one explicit manual publication action.
14. Protect public main and tags mechanically without pretending a second reviewer exists.
15. Ship exact-lock installation, core-only update, interruption recovery, and rollback on all Tier 1 targets.

## First-Release Blockers

| Blocker | Failure prevented | Validation | Objective unblock condition |
|---|---|---|---|
| B1 Exposure and repository roles | Existing sensitive material or workspace history enters the new public surface | Full legacy inventory, secret/sensitivity scan, repository ancestry check | Legacy disposition signed; credentials revoked where needed; new public repo has synthetic history |
| B2 Portable-base clearance | Uncleared, unlicensed, or unnecessary framework material ships | Component/dependency/provenance/license manifests plus clean-room scenarios | Every exported path classified; zero unknowns; basic name search resolved |
| B3 Deterministic export | Working-tree residue or excluded roots become public | Double-build digest comparison and denylist injection suite | Exact-commit export passes; no mutation; public tree equals manifest |
| B4 Tier 1 delivery | Installation or updates fail or overwrite project material | Linux/macOS/Windows clean install and fault-injection matrix | All Tier 1 tests pass; project-owned hashes unchanged; rollback succeeds |
| B5 Truthful local evidence | Octon claims evidence exists externally when it does not | Evidence schema and runtime negative tests | No unsupported storage class or synthetic digest can be emitted |
| B6 Public and release controls | Direct mutation, credential leakage, or unreviewed release | GitHub settings assertions; public CI; checksum/SBOM/attestation verification; manual publish test | All controls active; immutable test release verifies; merge alone cannot publish |

## Deferred Controls

| Control | Why unnecessary now | Activation trigger |
|---|---|---|
| GitHub organization | No shared ownership or team policy exists | Second maintainer, funding, succession, or institutional ownership |
| GitHub App | Publication is deliberate and maintainer-run | Unattended cross-repository publication becomes necessary |
| Independent signing key | GitHub/Sigstore is sufficient for current distribution | Independent registry, regulation, or real air-gap trust |
| Formal trademark policy/registration | No contribution ecosystem or commercial brand enforcement | Name conflict, impersonation, commercial use, or material adoption |
| External evidence backend | One maintainer and one operational custody boundary | Multiple machines/operators, remote replay, or defined recovery objective |
| Scheduled compaction service | Manual deterministic cleanup is sufficient initially | Evidence exceeds 10 GB or monthly cleanup exceeds 30 minutes |
| Tier 2 release gating | Preview targets are not promised support | Two stable release cycles plus meaningful user demand |
| Vendored/internal-mirror mode | Local artifact installation covers basic offline use | Actual air-gapped or policy-constrained adopter |
| Automatic instance migration | No incompatible released schema lineage exists yet | Second incompatible instance schema must be supported |
| Public contributions | No review capacity has been allocated | Maintainer explicitly allocates capacity and contribution governance |

## Solo-Maintainer Release Workflow

1. Prepare and validate an exact private-workspace commit; AI prepares the review summary.
2. Build `portable_dropin` twice from that commit and compare digests.
3. Run secrets, sensitivity, license, provenance, dependency, and denylist checks locally.
4. Review the manifest, then manually authorize pushing it into a separate public-repository branch.
5. Public CI independently validates tree parity; review and merge the generated PR.
6. Public CI builds a draft release candidate with checksums, SBOM, and attestations.
7. Review the candidate, then manually publish the exact commit and manifest digest.
8. Verify from a fresh Tier 1 environment. On failure, preserve the immutable release, publish an advisory, and issue a corrected version; downstream rollback uses the previous lock.

## Specialist Questions

| Exact question | Why architecture cannot answer it | Blocks release? | When specialist involvement is necessary |
|---|---|---|---|
| Does any exported material belong to an employer, client, vendor, or third party, or carry incompatible obligations? | Ownership and contractual rights require factual/legal interpretation | Only for affected unresolved material | Clearance inventory finds non-original or contract-associated content |
| Does a discovered prior use of “Octon” create a meaningful software/AI naming conflict? | Likelihood-of-confusion analysis is jurisdictional and fact-specific | Only when a plausible conflict is found | Basic search finds a similar active mark/product |
| Does a legacy exposure require notification, takedown, or incident handling beyond revocation? | Impact depends on the secret/data type and external obligations | Yes when such exposure is found | Active secret, personal data, private client work, or restricted material appears |
| Do local evidence records become subject to regulated retention or deletion duties? | This depends on actual data subjects, jurisdiction, and use | No under the current local development scope | Octon begins processing user, customer, health, financial, employment, or similarly regulated data |

No blanket legal or security consultation is a release requirement when these triggers are absent.

## Implementation Handoff

| Order | Implements | Dependency | Acceptance |
|---|---|---|---|
| 1 | Freeze and exposure-review the current public repository | None | B1 legacy disposition completed |
| 2 | Establish account recovery and three repository roles | Step 1 | Distinct identities, no public workspace remote, no shared public ancestry |
| 3 | Define portable-base components, licensing, and provenance | Step 1 | B2 clearance reaches zero unknowns |
| 4 | Implement exact-commit `portable_dropin` and validators | Step 3 | B3 deterministic and negative tests pass |
| 5 | Complete neutral cross-platform init, lock, updater, journal, and rollback | Steps 3–4 | B4 Tier 1 matrix passes |
| 6 | Replace unsupported external evidence mode with truthful local-private storage | Step 3 | B5 negative tests pass |
| 7 | Create the public tree, contribution docs, rulesets, security settings, and release workflow | Steps 2 and 4 | B6 settings and draft-release tests pass |
| 8 | Run clean public, private, and local-artifact pilots | Steps 5–7 | Install, verify, update, rollback, and release verification pass |
| 9 | Perform the first deliberate publication | All blockers | Exact approved digest is immutable and independently verifiable |
| 10 | Migrate high-churn tracking, configure backup, and implement compaction | After release | Clean-clone rebuild and restore tests pass |

## Coverage And Done Gate

Observed-mode review covered the requested manifests, framework profile and size, exporter, bootstrap/templates, retention contracts, evidence writer/schema, Git tracking policy, release workflows, repository settings, environments, protections, and releases. Human-led ideation contents were not inspected. Full framework publication clearance and full legacy-history exposure scanning were not performed; they are blocker work.

The calibration is complete and can be adopted as the implementation baseline. The publication done gate remains **failed** until B1–B6 pass.

No files, Git state, remotes, settings, credentials, or releases were changed. Pre-existing untracked material under excluded input/state/evidence roots was not inspected.

