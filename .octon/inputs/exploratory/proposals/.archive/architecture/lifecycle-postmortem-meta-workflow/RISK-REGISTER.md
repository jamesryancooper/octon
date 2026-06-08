# Risk Register

| Risk | Impact | Mitigation |
| --- | --- | --- |
| Workflow mutates lifecycle state | Second control plane | Limit write scope to retained evidence and validate no authority refs are mutated. |
| CLI command accepts unsafe run id | Path traversal or wrong evidence binding | Sanitize run id and require canonical run roots. |
| Workflow runs before evidence is ready | Low-quality postmortem | Require terminal or explicitly inspectable lifecycle states and evidence map completeness. |
| Postmortem becomes required everywhere | Process burden | Keep optional by default and require separate policy for mandatory classes. |
