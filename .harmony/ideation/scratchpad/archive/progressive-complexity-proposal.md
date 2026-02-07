Analysis: Two-Tiered vs. Progressive Complexity Architecture
Based on exploring the documentation, I see a tension that's already partially resolved in the current design—but incompletely.

Current State
The architecture claims two archetypes (Atomic/Complex) but actually implements a progressive complexity spectrum:


Atomic → Atomic+examples → Minimal Complex → Growing → Typical → Enterprise → Domain Expert
The "two-tiered" framing is misleading because:

"Complex" spans a 7x token range (2K → 15K+)
Pattern-triggered files create a continuous spectrum within Complex
The graduation path is explicitly documented as incremental
The Core Question
Should we formalize what already exists implicitly—a single progressive complexity model—rather than maintain the Atomic/Complex dichotomy?

Arguments For Progressive-Only Architecture
Reduces cognitive load: One mental model instead of "which archetype + where on the spectrum"

Matches reality: The pattern-triggered approach already creates progression. Archetypes add a categorization layer that doesn't drive different behavior.

Removes artificial boundary: The Atomic → Complex graduation is described as "gains one coordination need" but this is fuzzy. When does a JSON formatter with 10 error types graduate?

Simplifies the template: Instead of "choose your archetype then customize," it becomes "start minimal, add as patterns emerge"

Aligns with the design philosophy: "Descriptive not prescriptive" sits uneasily with upfront archetype selection

Arguments For Keeping Two-Tiered
Anchoring value: "Atomic" vs "Complex" gives authors an immediate mental model before diving into pattern nuances

Default behavior clarity: Atomic skills have clear defaults (SKILL.md only). Without archetypes, what's the starting point?

Documentation scope: The archetype determines initial context loading. Progressive complexity doesn't inherently answer "how much to load first"

Validation rules differ: Atomic skills shouldn't have checkpoints.md. The archetype enforces this.

My Recommendation
Reframe from archetypes to complexity tiers with a default starting point.

Instead of "Atomic vs Complex," use:


# Complexity Tiers (pick one)
tier: minimal    # SKILL.md only (~2K tokens) - Default
tier: standard   # + 1-3 reference files (~4-7K tokens)  
tier: extended   # + 4-6 reference files (~8-12K tokens)
tier: expert     # + domain knowledge (~12-15K+ tokens)
Key changes:

minimal becomes the default (what Atomic was)
Tiers are descriptive thresholds, not prescriptive categories
Pattern-triggered files remain—tiers just describe where you land
No "graduation ceremony" from Atomic to Complex—just natural growth
What this preserves:

Clear starting point (minimal)
Progressive disclosure (load SKILL.md first, then refs as needed)
Pattern-based file addition (unchanged)
Token budgets (mapped to tiers)
What this eliminates:

"Archetype selection" as a decision point
The fuzzy Atomic → Complex boundary
The "Complex is really 5 different things" problem
Questions for You
Does the tier model resonate, or do you see value in the Atomic/Complex naming that I'm missing?

Should tiers be explicit (author declares in manifest) or computed (derived from actual file count/tokens)?

Is there a discovery/routing implication I haven't considered? (e.g., agents treating Atomic skills differently)