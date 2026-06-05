# Final Report

Validate any supplied Markdown report, structured evaluator output, and optional
review-finding records with `validate-lifecycle-postmortem.sh`.

Record final postmortem status under the lifecycle-postmortem evidence root.
Validation failures block the postmortem evidence from being treated as usable
post-run assurance evidence, but they do not mutate lifecycle authority.
