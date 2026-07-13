# Operator Experience And Disclosure

## Normal Experience

Healthy evidence handling is automatic. The operator does not choose an
internal signer, route, retention class, checkpoint, or compaction action for
routine admitted work. A single status surface summarizes:

- broker/verifier identity and key-epoch health without exposing key material;
- latest trusted checkpoint/head sequence and freshness;
- ordinary quota, pinned volume, and compaction backlog;
- physical terminal reserve allocation/verification;
- raw-local and project-Git projection counts; and
- current block, preserved work, and one repair action when unhealthy.

Routine health produces no confirmation prompt. A genuine ROD-001 policy
change, irrecoverable key/anchor ambiguity, or explicit pin/retention override
is an operator decision and must state consequences before action.

## Failure Disclosure

When evidence is unavailable or unverifiable, the operator sees:

1. the exact dependency (`broker signer`, `verifier signer`, `anchor`,
   `terminal reserve`, `checkpoint`, `pin`, `compaction`, or `projection`);
2. the affected transition and why it is blocked;
3. which candidate work, raw evidence, pins, and trusted head remain preserved;
4. whether new consequential admission is denied; and
5. the narrow repair/recovery route allowed by ROD-001.

The surface must not request approval to weaken signing, accept a stale head,
delete pinned data, or substitute Git history.

## Claim Disclosure

- `signed` means a supported cryptographic algorithm verified against the exact
  admitted public key, role, epoch, and canonical payload.
- A signed broker observation proves the broker signed its stated direct facts;
  a signed verifier observation proves the verifier signed its stated direct
  facts.
- A signature does not itself prove authorization, remote causation,
  non-repudiation against all local administrators, or completeness beyond the
  checkpoint's explicit manifest/classification.
- The monotonic head detects restoration/fork within the admitted local anchor
  threat model; unsupported platform or anchor guarantees must be disclosed.
- Git-retained checkpoints/pointers are evidence copies, not authority and not
  the signature mechanism.
- Missing required evidence means blocked/incomplete, never successful.

## Data And Maintenance Disclosure

Raw provider/model payloads remain local and bounded by declared quotas and
retention windows; project Git receives only classified minimal signed
checkpoints/pointers by default. Status exposes raw bytes/inodes/count, pinned
volume, reserve headroom, oldest eligible range, and next automatic compaction.
Monthly burden measurement includes key rotation/recovery rehearsal, quota/pin
administration, failed compaction repair, and backup verification.

## Unsupported Remainder

This packet does not claim:

- distributed/public transparency or cross-organization non-repudiation;
- multi-operator/federated signing quorum;
- remote cloud KMS/HSM or hardware monotonic counters on every platform;
- signing of every informational event;
- raw-evidence durability after an operator chooses a shorter policy window;
- automatic recovery from irretrievable key and anchor loss; or
- live support outside the separately admitted local platform/filesystem/key
  tuple and retained proof.

Unsupported conditions remain explicit and cannot be promoted through a
generic `signed` or `tamper-proof` claim.
