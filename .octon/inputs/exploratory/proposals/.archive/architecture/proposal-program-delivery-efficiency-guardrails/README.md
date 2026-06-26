# Proposal Program Delivery Efficiency Guardrails

This proposal turns the operator-free lifecycle delivery postmortem into enforceable Octon delivery gates.

The problem is not a lack of written rules. The failed run showed that delivery order, preflight readiness, receipt compatibility, clean-worktree routing, and postmortem closeout were still too dependent on prompt discipline. That let expensive work begin before machine gates proved the route was ready.

This packet proposes a single architecture change set for proposal-program delivery:

- enforce canonical child-before-parent delivery order by default;
- require an explicit retained override receipt when an operator asks for a different order;
- add a consolidated delivery readiness preflight before expensive lifecycle continuation;
- default stale or dirty delivery sources to clean route-owned worktrees with classified include paths;
- move child validation receipt pass semantics into shared reusable validator logic;
- require formal lifecycle postmortem closeout for long, blocked, or recovered proposal-program runs.

The intended durable result is shorter proposal-program runs, earlier blocker discovery, fewer stale-evidence loops, and safer delivery from clean current bases.
