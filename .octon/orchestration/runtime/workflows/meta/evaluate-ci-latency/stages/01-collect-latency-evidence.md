# Step 1: Collect Latency Evidence

Gather the inputs needed for the CI latency report.

## Actions

1. Read the policy contract at `policy_path`.
2. Run the shared wrapper at `.octon/agency/_ops/scripts/ci/audit-ci-latency.sh`.
3. Confirm both Markdown and JSON outputs exist.
4. Capture the key input facts:
   - repository
   - window size
   - top-workflow depth
   - gate scope

## Output

- Raw evidence summary for required-path latency, workflow timing, step hotspots, and duplicate-work candidates.
