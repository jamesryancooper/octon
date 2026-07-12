# Bypass and Threat Analysis

## Trust boundaries

| Boundary | Adversary or failure | Current bypass | Target control | Required negative proof |
|---|---|---|---|---|
| Authorization to launch | Candidate/lifecycle request | unattended plus self-produced proof | Exact guard-consuming spawn API | Missing/forged/stale/revoked/mismatched guard denies |
| Scope | Crafted resource | Reverse and sibling-prefix match | Canonical typed equality/descendant | Parent, sibling, dot-dot, symlink, case fixtures |
| Candidate to host | Model/tool code | Shared HOME/env/repo/network posture | Native sandbox, fresh HOME, allowlists | Keychain, config, process, filesystem, network escape |
| Candidate to canonical Git | Candidate Git command | Shared common Git state | Independent disposable Git database | Ref/object/config mutation invisible to canonical |
| Candidate to durable effect | Git/gh/provider SDK | Ambient credential/helper | Broker-only credentials and IPC | Raw push/merge/deploy/protected read fails |
| Repo to privileged Git | Hook/filter/helper/include/driver | Ambient Git config | Sanitized empty configuration and command allowlist | All executable extension sentinels untouched |
| Candidate to verifier | Workflow/script modification | Candidate produces required context | Immutable signed verifier identity | Candidate edits/duplicate contexts cannot satisfy |
| Broker to effect | Crash/retry/race | No transactional operation state | Reservation/attempt/unknown/reconcile/terminal | Kill at every transition, target movement |
| Writer to evidence | Rewrite/rechain/rollback | Hash-only local chain | Direct-observer signatures and monotonic checkpoint | Rechain, wrong signer, old snapshot fail |
| Aggregator to proof | Manufactured pass/approval | Synthetic proof planes/referenced tests | Signed imported results only | Missing/failing result blocks closeout |
| Candidate to activator | Self-modified gate/rollback | Candidate-mutable validation artifacts | Previous-version verifier and inert exact version | Gate/key/policy/rollback mutation denies |
| Dependency outage | Broker/verifier/provider failure | Potential manual ambient fallback | Narrow degraded state | Work preserved; no credential exposure/direct-main |

## Git-specific attack surface

The sanitized adapter must neutralize repository, worktree, user, system, and
environment-controlled:

- hooks and core.hooksPath;
- aliases and shell aliases;
- include/includeIf and URL rewriting;
- credential helpers and askpass;
- clean/smudge/filter-process and attributes;
- diff/merge/textconv drivers;
- fsmonitor and pager/editor;
- submodule URLs, recursive behavior, and protocols;
- remote helpers and protocol.ext;
- SSH command/config, proxy commands, and environment;
- Git LFS and other filter processes;
- replace refs, graft-like behavior, alternates, object quarantine, and shared
  object directories;
- repository config ownership/safe-directory behavior.

The broker should avoid checking out candidate content where possible. It
imports/verifies exact objects, validates ancestry and tree identity, and
performs only the narrow ref update.

## Provider-specific threats

- pull_request_target plus candidate checkout;
- candidate workflow replacement;
- duplicated required context names;
- wrong event/workflow identity satisfying a context;
- workflow token permission expansion;
- long-lived PAT leakage;
- target movement after authorization;
- delayed/duplicate workflow delivery;
- auto-merge state drift;
- environment administrator bypass;
- unpinned third-party actions.

The minimum proof uses local broker publication and an independent verifier.
The optional remote worker is excluded until the local architecture is proven.

