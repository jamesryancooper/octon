# Risk Register

Proposal: `change-closeout-state-machine`

| Risk | Impact | Mitigation |
| --- | --- | --- |
| State-machine contract duplicates default work-unit route policy. | Conflicting closeout truth. | Make the state machine reference and operationalize existing routes instead of redefining route selection. |
| `Publish Changes` becomes a competing workflow concept. | Blurs publication, landing, and generated/effective output semantics. | Reserve publication for route status or generated/effective operations. |
| Cleanup classifier over-deletes user-owned work. | Data loss or authority violation. | Require evidence-backed deletion and fail closed on ambiguous ownership. |
| Branch cleanup deletes rollback-needed branches. | Lost recovery path or audit gap. | Require origin/main containment, no-open-PR proof, rollback/discard posture, and local/remote cleanup evidence. |
| Hosted no-PR landing is overclaimed. | Main integration is reported without provider or exact-SHA evidence. | Require pushed source branch, exact source-SHA checks, provider permission, fast-forward/update proof, origin/main equality, rollback handle, and final sync. |
| Receipt schema changes are too broad. | Churn and difficult adoption. | Add optional structured evidence first, then require it only for completed or cleaned claims. |
| Proposal-local packet is treated as authority. | Violates inputs non-authority model. | Keep all durable behavior in promotion targets and validate proposal-path dependency boundaries. |
| Generated/effective publication is triggered accidentally. | Unscoped derived-output churn. | Exclude generated/effective publication scripts unless the implementation Change explicitly includes them. |
