# Bind Profile

Resolve `proposal_path`, `mechanism_id`, `mechanism_profile_ref`, `mode`, and `run_id`.

Fail closed unless:

- `proposal_path` is a repo-local proposal packet path.
- `mechanism_profile_ref` is repo-relative, exists on disk, and does not traverse outside the repository.
- `mechanism_id` matches the mechanism identifier in the profile.
- `mode` is one of `implementation`, `closeout`, or `archive`.

Record whether terminal freshness is required. Terminal freshness is required for `closeout` and `archive` modes.
