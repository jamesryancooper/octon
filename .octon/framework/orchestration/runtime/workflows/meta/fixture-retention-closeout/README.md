# Fixture Retention Closeout

`fixture-retention-closeout` is the evidence-only route for retaining a temporary proposal fixture as intentional validation residue.

The route derives fixture identity from `fixture_path/proposal.yml` fields, including `proposal_id`, `proposal_kind`, `promotion_targets`, `status`, and `lifecycle.temporary`. It does not hardcode fixture ids or paths. It writes a workflow-owned `fixture-retention-closeout-receipt-v1` receipt only after validating source evidence refs and the current retained path set.

This route never performs archive relocation, proposal status mutation, generated publication edits, Git mutation, residue deletion, or repo-hygiene deletion. Generated artifact refs are derived-only non-authority. The receipt is consumable by terminal/worktree hygiene only when exact path-set match, current digest match, route version match, owner scope, purpose, and freshness checks pass.

The receipt does not authorize archive-ready or cleaned claims. It only allows unrelated packet terminal/worktree hygiene to treat the exact retained fixture paths as nonblocking while arbitrary foreign residue still fails closed.
