# Explain Packet

Read `proposal.yml`, the subtype manifest, source-of-truth map, target
architecture or equivalent subtype docs, implementation plan, validation plan,
acceptance criteria, promotion targets, and support artifacts. Explain the
packet in repository-grounded terms and distinguish durable promoted outputs
from proposal-local analysis, generated support prompts, generated registry
projections, runtime control state, and retained evidence.

The explanation must cover: the problem the packet solves; the target state;
what becomes durable if promoted; which repository surfaces change or are
created; how the promoted output improves Octon; and what follow-on work is
prepared but not implemented. Where the packet concerns runtime architecture,
use Octon's governed-runtime lens: deterministic workflow or run state,
engine-owned authorization, effect-token and evidence discipline, generated
and input non-authority, and agents or tools only as bounded admitted activity
inside governed execution. Do not expand the packet into later workflow,
agent-node, connector, durable-coordination, or external integration work unless
the packet itself declares those promotion targets.
