# Evidence Plan

## Purpose

Define the evidence burden for landing host-tool provisioning correctly.

## Evidence families

| Evidence family | Root | Purpose |
| --- | --- | --- |
| proposal validation | repo-local validator output | packet correctness |
| provisioning receipts | `$OCTON_HOME/state/evidence/provisioning/host-tools/**` | prove actual install, verify, repair, or quarantine actions |
| repo run evidence | `/.octon/state/evidence/runs/**` | prove which resolved tool ids, versions, and paths were used by repo commands |
| multi-repo integration evidence | test outputs and retained receipts | prove shared cache plus independent desired state |

## Minimum evidence requirements

- at least one successful provisioning receipt for a mandatory tool;
- repo-local run evidence for one integrated consumer such as `repo-hygiene`;
- validator output showing no repo-local binary cache leakage;
- multi-repo test showing shared cache reuse.
