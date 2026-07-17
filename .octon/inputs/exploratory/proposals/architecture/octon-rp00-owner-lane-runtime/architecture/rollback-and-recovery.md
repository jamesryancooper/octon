# Rollback and Recovery

Before live credential capture, rollback is a file-level revert of the inert
correction. After capture, code rollback cannot erase credential or provider
state. Preserve every exact artifact and journal and recover forward:

- **capture before envelope:** re-present only the exact same credential and
  metadata under the original authorization/plan/one-attempt lock; otherwise
  record credential-unresolved and block replacement;
- **envelope before admission:** resume only the remaining exact admission
  probes or terminalize; no repository mutation;
- **admission mismatch:** terminalize through the existing lifecycle envelope;
- **pre-send failure:** no request is claimed; preserve stage and terminalize;
- **pre-send without response:** outcome-unknown, never resend that digest;
- **PR-create ambiguity:** perform only separately authorized authoritative
  reconciliation; never create again;
- **zero/multiple/substituted PR or template mismatch:** preserve candidate and
  prefix, do not create marker or merge, terminalize;
- **revocation preprobe 401:** treat terminal only under the exact lifecycle
  binding and prior-phase rule;
- **revocation sent or response unknown:** never resubmit, wait the sealed
  interval, use only the remaining exact postprobe;
- **absent genuine 401, destruction, FIFO removal, or empty census:** record
  `RP00-CREDENTIAL-UNRESOLVED` and block replacement, SI-00, closeout, and DAG
  continuation.

Artifact writes are create-only or exact-byte idempotent. Conflicting bytes,
phase regression, later-phase artifact without predecessors, different
credential handle, or changed plan/candidate/evidence root is unsafe and never
repaired by overwrite. Rollback never restores direct-main, weakens provider
protection, fabricates evidence, or deletes the journal.
