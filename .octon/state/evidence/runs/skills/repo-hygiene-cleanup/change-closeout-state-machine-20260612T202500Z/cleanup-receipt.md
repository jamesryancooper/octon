# Repo Hygiene Cleanup Receipt

schema_version: repo-hygiene-cleanup-publishable-receipt-v1
run_id: change-closeout-state-machine-20260612T202500Z
created_at: 2026-06-12T20:26:54Z
route: authorization-receipt
authorization_ref: .octon/state/evidence/runs/skills/repo-hygiene-cleanup/change-closeout-state-machine-20260612T202500Z/authorization.json
authorization_sha256: sha256:60aae7de57bc6c68b80ceab225ae045be6d3cab9db0032ca13b766f173dd5528
authorization_result: approved
deleted_count: 206
retained_protected_count: 44
retained_manual_review_count_before_cleanup: 0
cleanup_candidates_after_cleanup: 0
protected_referenced_after_cleanup: 44
manual_review_after_cleanup: 1

## Digest Set

- pre-cleanup git status digest: `sha256:174a2d81e82eac4164b18249e7de34ed6cf13ad68a73adf9bcb2251da764bb33`
- pre-cleanup classification digest: `sha256:a4061f4f797bd75a9b846a368a09f333bb3dcbe6cc497e8b21d7047a88aa29f0`
- cleanup path-set digest: `sha256:2634b0e94fe6d5b722468d87cf3f35102a8d2c05060364e38d6013329105eb3a`
- protected paths digest: `sha256:5622aaf2b5e6a8d844d4a6fb1b57017897ba0b3e92feb6861082cf3393f94a09`
- manual-review paths digest before cleanup: `sha256:e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855`
- post-cleanup git status digest: `sha256:0ee11c746e9b515bfd83b621a2a9da49d63e4dcbd922d3fbb30eea930f5d59c4`
- post-cleanup classification digest: `sha256:c09739817bb9affd39e30c89a3cb033dbb87d54c5b760ea73331b8198fc2e9a6`
- post-cleanup cleanup path-set digest: `sha256:e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855`
- post-cleanup manual-review paths digest: `sha256:28990092f1f673cbff854c6805adb19dc170630e794b1193974eeefd532f934b`

## Evidence Posture

The helper removed only untracked, unreferenced cleanup candidates covered by
the validating authorization receipt. It retained referenced validation
receipts and the newly created cleanup authorization evidence. The
authorization evidence is routed through the direct-main closeout Change as
publishable closeout evidence.

Raw helper output and exact path listings are retained locally under:

`.octon/state/evidence/local/runs/skills/repo-hygiene-cleanup/change-closeout-state-machine-20260612T202500Z/`

Local-private raw logs:

- `authorize.log` digest: `sha256:19e043d6129c6638e2e0ecc29a1eeda6728014cf96378da12ea5f221da50b798`
- `cleanup.log` digest: `sha256:171d9936c64c93dbc57e4e18543af8f3d03f4746af02294c9922b8f3b4fef6d2`

Local-private raw logs are not runtime authority, archive authority, or
hosted/shared closeout proof.
