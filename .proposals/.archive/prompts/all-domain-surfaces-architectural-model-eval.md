# Domain Surface Architectural Model Evaluation

You are an architectural design expert agent operating inside the Octon repository.

Your task is to evaluate every Octon domain surface and ensure the repository follows one consistent architectural model:

- structured, machine-readable contracts drive execution
- Markdown files provide executable instruction content that agents consume under those contracts
- human-readable overview docs are derived, generated, or clearly non-authoritative
- no domain should rely on prose-first Markdown as the canonical execution contract

Use the recent orchestration migration as the reference example for the target pattern.

Reference example

Octon orchestration previously used a human-first, markdown-first model:

- canonical authority lived in `WORKFLOW.md` and numbered step Markdown files
- the same Markdown served as both the human guide and the execution source

Octon orchestration now uses a unified contract-first model:

- canonical authority lives in `workflow.yml`
- `stages/` contains canonical executor-facing stage assets
- `README.md` is generated human-readable guidance and is not authoritative
- machine-readable contract + stage assets drive execution
- no separate peer human-first vs AI-first orchestration surfaces remain

Treat that migration as the design exemplar, but do not cargo-cult the exact filenames into every domain if the domain needs a different contract shape. Preserve the principle, not superficial naming.

Core architectural principle to enforce

For each Octon domain, the architecture should converge toward this pattern:

1. One canonical surface per runtime unit
2. One or more structured machine-readable contracts that define:
   - identity
   - discovery
   - inputs/outputs
   - execution semantics
   - dependencies
   - constraints
   - validation expectations
3. Markdown instruction assets may exist, but only as:
   - executor-facing instruction content under the contract, or
   - human-readable derived/reference material
4. Human-readable Markdown must not be the canonical execution contract
5. Temporary design artifacts must never be treated as canonical authority
6. Validation must target the structured contract first, and Markdown drift second

Your scope

Audit all major Octon domains and their runtime/governance/practices surfaces as needed:

- `.octon/agency/`
- `.octon/capabilities/`
- `.octon/cognition/`
- `.octon/orchestration/`
- `.octon/scaffolding/`
- `.octon/assurance/`
- `.octon/continuity/`
- `.octon/ideation/`
- `.octon/output/`
- `.octon/engine/`

What to do

1. Identify the canonical execution-bearing surfaces in each domain.
2. Determine whether each surface is currently:
   - contract-first
   - mixed
   - markdown-first
3. For each domain, assess whether execution depends primarily on:
   - machine-readable contract data
   - Markdown interpretation
   - implicit conventions
4. Find all cases where Markdown is still acting as canonical authority rather than subordinate instruction/reference content.
5. Find split-surface designs that create unnecessary “human system vs agent system” duplication.
6. Determine the correct target architecture per domain using this rule:
   - preserve domain-specific needs
   - standardize on contract-first authority
   - keep Markdown only as executor-facing instruction assets or non-authoritative human docs
7. Propose the minimal robust architectural changes needed to align every domain with the unified model.
8. Where appropriate, specify:
   - canonical contract files
   - instruction-asset directories
   - generated/non-authoritative human-readable docs
   - discovery/index files
   - validator responsibilities
   - migration sequencing
9. Call out domains that already conform and should not be changed beyond small cleanup.
10. Explicitly distinguish:

- principles that must be universal
- implementation details that may differ by domain

Important constraints

- Do not assume every domain should literally use `workflow.yml`, `stages/`, and `README.md`.
- Do enforce that every execution-bearing domain must be contract-first.
- Do not treat historical design packages, scratchpads, or temporary artifacts as canonical.
- Prefer the smallest robust unification, not maximum abstraction.
- Avoid introducing parallel human-first and AI-first surfaces when one unified surface would suffice.
- If a domain is intentionally human-led and non-executable, say so explicitly and explain what “alignment” means there.
- Distinguish runtime authority, governance authority, and explanatory documentation.

Required outputs

Produce a complete architecture review with these sections:

1. Executive Summary
   - overall assessment
   - strongest areas
   - most serious misalignments

2. Unified Model
   - define the common Octon-wide architectural rule set
   - identify which parts are invariant across domains

3. Domain-by-Domain Assessment
   For each domain:
   - current canonical surface(s)
   - current authority model
   - whether it is contract-first, mixed, or markdown-first
   - key violations or drift risks
   - recommended target shape

4. Findings
   - prioritized findings with severity
   - exact paths
   - why each issue violates the unified model

5. Recommended Architecture
   - target end-state architecture across Octon
   - per-domain contract/instruction/doc split
   - where generated docs should exist
   - how validators should enforce the model

6. Migration Plan
   - atomic vs transitional recommendation
   - rationale based on repo facts
   - per-domain workstreams
   - validation and audit updates required

7. Acceptance Criteria
   - concrete repo-level conditions that would prove Octon is fully aligned to the unified model

8. Non-Goals / Keep-As-Is Decisions
   - what should remain domain-specific
   - what should not be normalized

Quality bar

Be opinionated, concrete, and architecture-first.
Do not give generic framework advice.
Ground every recommendation in Octon’s actual repository structure.
Use the orchestration migration as the example of the target model:
machine-readable contracts drive execution; Markdown stage assets provide agent-consumable instruction content under those contracts; human-readable docs are non-authoritative.

If you recommend changes, make them precise enough that an implementation agent could execute them directly.
