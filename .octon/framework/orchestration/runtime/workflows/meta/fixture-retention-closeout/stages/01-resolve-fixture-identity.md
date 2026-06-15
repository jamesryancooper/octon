# Resolve Fixture Identity

Read `fixture_path/proposal.yml` and derive the fixture identity from manifest fields. The route requires an implemented proposal packet with `lifecycle.temporary: true`; fixture ids and paths must not be hardcoded in route logic.

Outputs are a stage report and outcome recording `proposal_id`, `proposal_kind`, manifest status, promotion targets, and fixture path.
