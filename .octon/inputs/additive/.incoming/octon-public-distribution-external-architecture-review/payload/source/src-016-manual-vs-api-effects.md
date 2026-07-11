---
source_id: SRC-016
source_type: conversation-turn
sequence: 16
supplied_at: "2026-07-09T21:13:21.000Z"
turn_id: "019f48ba-5eb4-7481-ad44-f12f53072529"
capture_status: complete
disclosure_status: local-only
authority_mode: non-authoritative
---

# SRC-016: Manual versus API-capable effects

## User Message

What cannot be implemented via the implementation of a proposal program and must be done manually? For instance, can any of the Repository ownership items be done via the GitHub API using Codex, or must it be done manually via the GitHub interface?


## Assistant Message 1 (commentary)

I’ll separate technical capability from governance permission. Many GitHub changes can be made through `gh` or the REST API, but they should be applied in a distinct operator-authorized step rather than inside an autonomous proposal program.

## Assistant Message 2 (final_answer)

## Short Answer

Most of the work can be implemented by a proposal program.

Most GitHub repository administration can also be performed by Codex through `gh`, Git, or the GitHub REST API. It does **not** generally require the GitHub web interface.

The important distinction is:

- **Automation capability:** Can an API perform the action?
- **Authority:** Is the proposal program allowed to perform it without stopping for you?

Repository creation and configuration can be API-driven after an explicit checkpoint. Account recovery, ambiguous risk decisions, and final public publication should remain deliberate maintainer actions.

## Automation Categories

| Category | Proposal program role | Execution |
|---|---|---|
| Repository-local implementation | Implement completely | Codex edits, tests, and commits normally |
| Reversible GitHub administration | Generate and validate an operations plan | Codex may apply it through the API after your explicit approval |
| High-impact repository migration | Prepare exact commands and rollback | Codex may execute after a dedicated authorization checkpoint |
| Judgment or risk acceptance | Gather evidence and make a recommendation | You decide |
| Account security or secret custody | Document required steps | You perform them |
| Final public publication | Prepare and validate the candidate | You invoke the final publish action |

## Repository Ownership Operations

| Operation | API/CLI capable? | Recommended operator |
|---|---:|---|
| Check whether names are available | Yes | Proposal program/Codex |
| Create private `octon-workspace` | Yes | Codex after approval |
| Push workspace history into `octon-workspace` | Yes, using Git | Codex after approval |
| Rename current `octon` to `octon-legacy` | Yes | Codex after exposure-review approval |
| Archive `octon-legacy` | Yes | Codex after you approve its disposition |
| Change legacy visibility | Yes | Codex can execute, but you decide based on findings |
| Create new empty public `octon` | Yes | Codex after approval |
| Configure repository description, issues, discussions, and merge policy | Yes | Codex |
| Create branch and tag rulesets | Yes | Codex; GitHub exposes repository ruleset APIs ([ruleset documentation](https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/managing-rulesets/about-rulesets)) |
| Configure Actions permissions and SHA pinning | Yes | Codex ([Actions permissions API](https://docs.github.com/en/rest/actions/permissions)) |
| Enable secret scanning and push protection | Yes, where available | Codex |
| Enable private vulnerability reporting | Yes | Codex ([repository API](https://docs.github.com/en/rest/repos/repos)) |
| Enable immutable releases | Yes | Codex; GitHub provides `PUT /repos/{owner}/{repo}/immutable-releases` |
| Populate public repository from `portable_dropin` | Yes, using Git | Maintainer-authorized publication command |
| Trigger the final release workflow | Technically yes | You should invoke it manually |

The repository REST API supports creation, rename, archive, visibility, security, vulnerability-reporting, and immutable-release administration ([GitHub repository endpoints](https://docs.github.com/en/rest/repos/repos)).

## What Must Remain Manual

### Account Security

You should personally configure:

- Passkeys or security keys
- Two-factor authentication
- Recovery codes
- Backup email and account-recovery methods
- Hardware-key custody

These are personal authentication secrets, not repository configuration. Codex should not receive or store recovery codes or passkey material. GitHub recommends multiple authenticators for recovery resilience ([GitHub passkey guidance](https://docs.github.com/en/authentication/authenticating-with-a-passkey/managing-your-passkeys)).

### Human Judgments

Automation can prepare evidence, but you must decide:

- Whether exposure findings permit `octon-legacy` to remain public
- Whether identified material is yours to publish
- Whether ambiguous provenance is acceptable
- Whether a possible trademark conflict is material
- Whether a failed control may be waived
- Whether destructive cleanup or evidence deletion is authorized
- Whether the exact release candidate should become public

A specialist becomes necessary only when an actual ambiguity or conflict is found.

### Secret And Backup Custody

Codex can implement backup scripts and verify restoration, but you must control:

- Backup encryption credentials
- Recovery keys
- Physical removable media
- Revocation of non-GitHub credentials
- Any password-manager or hardware-token setup

### Final Publication

Codex can:

- Build the export
- Scan it
- Produce the manifest and digest
- Push a generated candidate branch after an explicit checkpoint
- Validate the public PR
- Build a draft release
- Prepare the exact publication command

You should personally invoke the final command or GitHub workflow that makes the release public. Manual does not require the web interface; running a command such as this yourself is sufficient:

```bash
gh workflow run publish-release.yml \
  --ref main \
  -f version=vX.Y.Z \
  -f commit=<approved-public-commit> \
  -f manifest_sha256=<approved-digest>
```

The proposal program must stop before this action.

## Recommended Proposal-Program Boundary

The implementation program should produce:

1. All repository-local code, schemas, validators, workflows, documentation, and tests.
2. An idempotent GitHub bootstrap script.
3. A declarative GitHub operations plan containing:
   - current state;
   - desired state;
   - API operation;
   - reversibility;
   - rollback;
   - expected result.
4. A `--dry-run` mode that performs no external mutation.
5. A verification command that reads GitHub settings back through the API.
6. A separate operator runbook for repository creation, rename, archive, and public initialization.

Execution should then work as follows:

```text
Proposal program implements and validates
    ↓
Program emits GitHub operations plan and digest
    ↓
You approve that exact plan
    ↓
Codex applies approved GitHub API operations
    ↓
Codex verifies actual versus desired settings
    ↓
You manually authorize the first public push and final release
```

## Practical Division

**Codex can execute after approval:**

- Create and configure repositories
- Rename and archive the legacy repository
- Push the workspace into its private repository
- Create rulesets and security settings
- Enable immutable releases
- Configure Actions
- Initialize the empty public repository
- Verify every resulting setting

**You must personally perform or decide:**

- GitHub account security and recovery setup
- Exposure and provenance risk acceptance
- Secret and encryption-key custody
- Legacy visibility when findings exist
- The first public-content authorization
- The final release publication

So, repository ownership setup is mostly API-automatable. The GitHub interface is optional except for personal account-security operations. The proposal program should build the automation, while actual external mutations occur through an explicit, separately authorized operator phase.

