# Evidence Plan

## Evidence classes

| Evidence class | Required artifact |
|---|---|
| Contract evidence | promoted token and consumption schemas |
| Inventory evidence | material side-effect inventory validation output |
| Authority evidence | decision artifact, grant bundle, token mint record |
| Control evidence | token state under Run control root |
| Consumption evidence | token consumption receipt |
| Runtime journal evidence | token lifecycle item/event |
| Bypass evidence | negative bypass test result |
| Support proof | support-target proof bundle update |
| Closure evidence | closure certification and two-pass validation output |

## Representative fixture set

- `allow_repo_mutation_with_valid_token`
- `deny_repo_mutation_without_token`
- `deny_wrong_kind_token_for_repo_mutation`
- `deny_forged_token_not_in_ledger`
- `deny_expired_token`
- `deny_revoked_token`
- `deny_consumed_single_use_token`
- `deny_wrong_scope_token`
- `deny_missing_journal_write`
- `stage_only_boundary_sensitive_without_live_support`

## Evidence retention rule

Transport artifacts, stdout, CI caches, or generated summaries do not satisfy token proof unless reindexed into canonical retained evidence roots.
