---
title: Alignment Check
description: Run profile-based harness alignment validations through a single command.
access: human
argument-hint: "--profile <aspect>[,<aspect>...] [--dry-run] [--list-profiles]"
---

# Alignment Check `/alignment-check`

Run repeatable alignment checks by profile.

## Usage

```text
/alignment-check --list-profiles
/alignment-check --profile commit-pr
/alignment-check --profile skills,workflows
/alignment-check --profile all
```

## Parameters

| Parameter | Required | Description |
|---|---|---|
| `--profile` | Yes* | Comma-separated profile list to run. |
| `--list-profiles` | No | Print available profiles and exit. |
| `--dry-run` | No | Print planned checks without executing them. |

\* `--profile` is required unless `--list-profiles` is used.

## Implementation

Run:

```bash
bash .harmony/assurance/runtime/_ops/scripts/alignment-check.sh --profile <aspect[,aspect...]> [--dry-run]
```

List profiles:

```bash
bash .harmony/assurance/runtime/_ops/scripts/alignment-check.sh --list-profiles
```

## Output

- Profile-by-profile pass/fail status for each validator step
- Final summary with total error count

## References

- **Runner:** `.harmony/assurance/runtime/_ops/scripts/alignment-check.sh`
- **Commit/PR validator:** `.harmony/assurance/runtime/_ops/scripts/validate-commit-pr-alignment.sh`
- **Quality baseline:** `.harmony/assurance/README.md`
