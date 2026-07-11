# Acceptance Criteria

## AC-01

Given the exact reviewed revision, the inventory enumerates every blob reachable from every ref at that revision, in a deterministic order that yields identical output on rerun, and records its scope digest without reading ignored local residue. No blob is excluded by any undeclared selection policy.

## AC-02

Representative credential and restricted-content fixtures fail closed, while reports contain only redacted identifiers, classes, counts, paths when safe, and content digests.

## AC-03

The transition readiness command performs no Git or GitHub mutation and rejects unresolved material findings or a receipt whose maintainer decision record is incomplete. The maintainer decision record is the required field set of the `legacy-exposure-readiness-v1` receipt schema — disposition, credential actions, timestamp, and reviewed revision — and the gate rejects when any field is absent.

## AC-04

The runbook requires immediate revoke or rotation before repository cleanup when a credential is confirmed exposed.

## AC-05

A legacy disposition receipt records public-archive, restricted, or deferred outcome without claiming that earlier public copies were retracted.

## AC-06

The exposure inventory covers every enabled hosted-repository surface at the
reviewed repository identity, including Git refs and blobs, releases and
assets, Actions runs/logs/artifacts/caches, issues and pull-request discussion,
deployments and environments, packages, LFS objects, attachments, wiki, and
Pages. Each surface is recorded as scanned, absent, disabled, inaccessible, or
explicitly dispositioned; an inaccessible enabled surface blocks a clean
exposure verdict rather than being silently omitted.

## AC-07

Before the original `owner/octon` name can be reused, a transition receipt
enumerates known clones, remotes, automation, webhooks, deploy keys, and stored
repository URLs; proves every known workspace writer now targets the private
workspace identity; records a negative stale-endpoint push test; and carries
the maintainer's explicit acceptance of the residual unknown-clone risk.

## Aggregate Gate

All criteria above must pass on the exact reviewed implementation revision.
A general statement that tests pass is insufficient; evidence must identify
the behavior, boundary, negative case, and retained receipt.
