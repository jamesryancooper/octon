# Step 1: Validate Request

## Actions

1. Require `profile` and `output_dir`.
2. Allow only `repo_snapshot` or `pack_bundle`.
3. Reject `full_fidelity` and direct the operator to normal Git clone semantics.
4. Require `pack_ids` when `profile=pack_bundle`.
5. Confirm the output directory is empty or does not exist yet.

## Output

- validated export request with explicit profile and destination
- hard-stop error for unsupported profiles or missing `pack_ids`
