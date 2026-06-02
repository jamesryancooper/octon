# Repo Hygiene Cleanup Run

schema_version: repo-hygiene-cleanup-run-v1
run_id: 20260602T212500Z
route: receipt-backed
policy_ref: .octon/instance/governance/policies/repo-hygiene.yml
helper_ref: .octon/framework/assurance/runtime/_ops/scripts/cleanup-local-run-artifacts.sh
authorization_ref: .octon/state/evidence/runs/skills/repo-hygiene-cleanup/20260602T212500Z/cleanup-authorization.json

## Summary

- cleanup_candidates_authorized: 28
- cleanup_candidates_deleted: 28
- protected_referenced_retained: 44
- manual_review_retained: 5
- raw_evidence_not_published: true

## Digests

- initial_git_status_digest: sha256:e76bd9d4d34eac4c68f6ad96073b6714f94ded1f2831b6c5ade75ba79ffcd5ec
- initial_classification_digest: sha256:e405fe5354124ca2f5628f7cd2e80171d8c9504faa7effa3eae8734da1172a7f
- cleanup_path_set_digest: sha256:e3d996421d93372e956e572f43d2f69cfde8d8ad45541f626be9c339fbeda872
- protected_paths_digest: sha256:01b6d078677c6ed4ac4eb27aead78723289f3374a764d736a725b4072c12bc32
- manual_review_paths_digest: sha256:af7a039728fc15ac7a25404aa7f8dadaf483eaf72ad535cf5b6f4dbb8919ee11

## Post-Cleanup Classification

- cleanup_candidates_remaining: 0
- protected_referenced_remaining: 44
- manual_review_remaining: 6
- post_cleanup_git_status_digest: sha256:616df857dc507be179c3e868ff1aad3e5b7ee10b55b47812af0f19d8e6f206a0
- post_cleanup_classification_digest: sha256:45ac0aa0cd7a24edc32750f81b893523e65862fa2a58cb6ecd6d29e18c781427

## Disposition

The helper removed only untracked, unreferenced local publication-run residue
covered by the authorization receipt. Protected referenced publication
evidence and manual-review retained evidence were not deleted.
