---
schema_version: repo-hygiene-cleanup-summary-v1
run_id: lifecycle-proposal-program-1781198406218-b170b223-20260611T173341Z
program_run_id: lifecycle-proposal-program-1781198406218-b170b223
route: receipt-backed-authorization
active_run_id: lifecycle-proposal-program-1781198406218-b170b223
classification_before:
  cleanup_candidates: 310
  protected_referenced: 4
  manual_review: 2
  git_status_digest: sha256:89c6446f0adb1f4b94a0395a2602f158d1537ef718382778b685e229a17ed8a9
  classification_digest: sha256:20d0cd2999a0414efb6c853d067d245e72f1cde0c6b19d9cb4b751b445ac4fcf
  cleanup_path_set_digest: sha256:83b8553e6d776a1394868a791e7d4301a846d7e754c4df8aacb07c1395e10afd
  protected_paths_digest: sha256:34e2aafde9137f1b8f13ae04413ec2db8d26bbe629768b30dd46bdec1af7371f
  manual_review_paths_digest: sha256:88677f4604a31fd1f4f08265784e5f2e4ea028d7ffd7ac164d3b50343ff56489
authorization_receipt_ref: .octon/state/evidence/runs/skills/repo-hygiene-cleanup/lifecycle-proposal-program-1781198406218-b170b223-20260611T173341Z/authorization.json
authorization_receipt_digest: sha256:4c27d6da387fffbb4723b878b2015d6f665b2a33223d802c70ed31768906c83f
deleted_cleanup_candidates: 310
classification_after:
  cleanup_candidates: 0
  protected_referenced: 5
  manual_review: 2
  git_status_digest: sha256:6f7d0a190c3ebe76287076c95ba388c0cdd25a89f530e549b15429c6c6079559
  classification_digest: sha256:d9f1977454df7c2504cb221fc7f7ff62cf1164dd8d05caea979fb38fce9b995a
  cleanup_path_set_digest: sha256:e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855
  protected_paths_digest: sha256:5d30293afc1cdbec8d6ae60803987723a08bac76fbe608bcda56ef4ad9b67d20
  manual_review_paths_digest: sha256:88677f4604a31fd1f4f08265784e5f2e4ea028d7ffd7ac164d3b50343ff56489
local_evidence_ref: .octon/state/evidence/local/runs/skills/repo-hygiene-cleanup/lifecycle-proposal-program-1781198406218-b170b223-20260611T173341Z/
local_digests:
  dry_run: sha256:7efca2c46cad0fd74b6c439028ed5782614283144a9afd3894e311167c0fe388
  authorize_log: sha256:3549b382c089960eb0a27be8c61391583acbbce85fadd703bf7a6498e9895504
  delete_log: sha256:cbc6b2955905e7b101f9cd9ae9f3b007bc12b76750d960d17870a65d953ad0b5
  post_cleanup_summary: sha256:6d5d20eeb2eec8b98e3816611e40f3fe8f197ab45388c9d7270e2d4941eb1d8c
retained_protected_count: 5
retained_manual_review_count: 2
redaction_posture: summary-only; raw helper path lists retained local-private
blocker: none
---

# Repo Hygiene Cleanup Summary

The repo-hygiene helper classified local Octon runner residue for active
program run `lifecycle-proposal-program-1781198406218-b170b223`, emitted a
validating `repo-hygiene-cleanup-authorization-v1` receipt, and consumed that
receipt to remove exactly 310 cleanup candidates.

The post-cleanup classifier reported zero cleanup candidates. Protected
active-run state and manual-review retained evidence were not deleted.
