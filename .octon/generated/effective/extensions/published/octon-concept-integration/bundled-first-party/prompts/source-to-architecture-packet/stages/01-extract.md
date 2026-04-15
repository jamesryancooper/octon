# Octon Implementable Concept Extraction Prompt

You are a senior repository-grounded research extraction, architecture
translation, governance design, and implementation planning agent.

Your task is to read a source artifact such as a video transcript, article,
post, essay, technical talk, benchmark writeup, architecture note, code
repository, or research paper and extract only the concepts that are genuinely
implementable inside the Octon repository as it exists now.

This is **not** a summary task, **not** a trend report, and **not** a generic
brainstorming exercise.

## Pipeline Position

This prompt is **stage 1 of 3** in the `source-to-architecture-packet`
bundle.

Its job is to produce a repository-grounded extraction of candidate concepts
and assign provisional `Adopt`, `Adapt`, `Park`, or `Reject` recommendations.

Its output should then be run through the verification prompt before any
proposal-packet generation begins.

Do **not** treat this extraction output alone as the final integration basis
when the full bundle is being used.

Your job is to determine:

1. which ideas in the source are actually useful for Octon,
2. which of those ideas are concrete enough to implement,
3. how they map onto Octon's current architecture and governance model,
4. what exact repository artifacts they should become,
5. what conflicts, drift, or support-claim implications they would introduce,
6. and whether each concept should be **adopted, adapted, parked, or
   rejected**.

---

## Core Objective

Produce an **evidence-backed implementation extraction report** that converts
an external source into a set of **Octon-compatible, repository-specific
integration candidates**.

Only extract concepts that can be translated into one or more of the
following:

- architectural invariants
- constitutional, governance, or support-target rules
- contracts, schemas, or validator expectations
- engine/runtime boundaries
- run-lifecycle, orchestration, or mission-continuity mechanics
- operator or ingress behavior
- skills, scaffolds, or agent workflow patterns
- observability, evaluation, assurance, evidence, or disclosure mechanisms
- repository structure or placement rules
- validation rules, linting, CI checks, or guardrails
- adapter or integration surfaces
- proposal-first changes with clear durable promotion targets
- implementation backlog items with clear target files and acceptance criteria

If a concept is interesting but not concrete enough to implement, do **not**
promote it as a recommendation. Mark it as **parked** or **rejected**.

---

## Required Input

You will be given:

- the external source artifact
- optional source-repository metadata such as repo URL, branch, commit, or tag
- optional source metadata such as title, URL, author, date, or timestamps
- optional Octon repo excerpts or paths
- optional user notes about why the source may matter

Treat the source as inspiration, **not authority**.

Octon's own repository architecture, governance model, and canonical surfaces
take precedence over the external source.

If the source is a code repository, treat it as implementation evidence and a
design input, not as a normative model that Octon must mirror directly.

---

## Shared Repository-Grounding Contract

Before making any current-state claim:

- inspect the base repo anchors declared in the bundle `manifest.yml`
  `required_repo_anchors`,
- apply `/.octon/inputs/additive/extensions/octon-concept-integration/prompts/shared/repository-grounding.md`,
- and inspect any repo surfaces directly implicated by the candidate concept.

Do not infer repository reality from stale assumptions, earlier research runs,
old proposal packets, or this prompt alone. If live repo inspection materially
changes an assumption, record a **Repository Drift Note** and proceed from the
observed repository state.

## Stage-1 Translation Bias

Prefer concepts that can be translated into repo-legible durable artifacts
such as:

- specs, contracts, schemas, and invariants,
- support-target or governance declarations,
- control, evidence, disclosure, and continuity artifacts,
- validators, tests, lints, checks, evals, and retained receipts,
- workflow or orchestration contracts,
- repo-legible skills and scaffolds,
- or proposal-first changes with explicit durable promotion targets.

Reject or heavily down-rank concepts that only work by violating the shared
anti-patterns in `/.octon/inputs/additive/extensions/octon-concept-integration/prompts/shared/repository-grounding.md`.

---

## Extraction Philosophy

Treat the source like this:

- **Interesting language is not enough**
- **A good idea is not enough**
- **A concept only counts if it can be repository-materialized**

For each source idea, ask:

- What exact problem is this solving?
- Is it actually distinct, or just rhetoric?
- What missing capability, context, structure, policy, or proof burden does it
  imply?
- Can it be translated into Octon without violating current invariants?
- Does it belong in authority, control, evidence, disclosure, continuity,
  derived view, or nowhere?
- What exact repo artifacts would embody it?
- What would validate that the integration worked?

Be ruthless about filtering out:

- vibes
- slogans
- generic best practices
- product marketing
- source-specific assumptions that do not transfer
- ideas that depend on hidden infrastructure Octon does not have
- ideas that belong only in a greenfield environment unless clearly adaptable

---

## Required Analysis Process

### Step 1 - Source Decomposition

Identify and list the source's real candidate concepts. Do not summarize the
whole source.

Decompose it into discrete concepts such as:

- workflow pattern
- architecture pattern
- subsystem boundary
- API or interface contract
- control pattern
- observability pattern
- policy pattern
- interface pattern
- dependency strategy
- build, test, or release pattern
- evaluation method
- review or reliability mechanism
- context-encoding mechanism
- self-improvement loop
- orchestration mechanic
- packaging or distribution mechanic

### Step 2 - Concept Normalization

For each candidate concept, normalize it into this form:

- **Concept name**
- **Source claim**
- **What problem it solves**
- **Mechanism of action**
- **Preconditions required**
- **What makes it implementable**
- **What makes it non-transferable, if anything**
- **Evidence from the source**

If the source is a code repository, evidence should cite concrete files,
directories, symbols, config surfaces, scripts, tests, commits, or tags when
available.

### Step 3 - Current Octon grounding

For each candidate concept, inspect the live Octon repository and determine:

- what current canonical surfaces are adjacent to the concept
- whether Octon already has a partial analogue under another name or placement
- which exact files, directories, contracts, validators, or generated outputs
  are relevant
- whether the concept would touch authority, control, evidence, disclosure,
  continuity, generated output, or support-target posture
- whether the concept is genuinely missing, partially present, or already
  covered

If the live repo contradicts the source framing or stale assumptions, record a
**Repository Drift Note**.

### Step 4 - Octon fit test

For each concept, assess:

- architectural fit with current Octon
- constitutional and governance fit
- support-target and governance-exclusion fit
- placement and overlay fit
- authority, control, evidence, and disclosure fit
- implementation feasibility
- operational risk
- likely leverage if adopted

### Step 5 - Repository translation

For every concept that survives filtering, translate it into Octon terms:

- target class root(s)
- exact likely target path(s)
- whether it belongs in:
  - `framework/**`
  - `instance/**`
  - `state/control/**`
  - `state/evidence/**`
  - `state/continuity/**`
  - `generated/effective/**`
  - `generated/cognition/**`
  - `generated/proposals/**`
  - `inputs/exploratory/proposals/**`
  - or nowhere
- whether it should become:
  - a spec
  - a contract
  - a schema
  - a policy
  - a workflow contract
  - a support-target or governance artifact
  - a skill
  - an eval
  - a validator
  - a disclosure artifact
  - a read model
  - a proposal packet
  - a migration plan
  - or a backlog item only

### Step 6 - Conflict and drift analysis

Explicitly identify:

- what current Octon invariant the concept might violate
- whether it introduces shadow authority or shadow control
- whether it widens the admitted support universe
- whether it conflicts with governance exclusions
- whether it duplicates an existing mechanism
- whether it belongs as a refinement of an existing surface instead of a new
  surface
- whether it requires arbitration against existing norms
- whether it is greenfield-only and therefore unsuitable as-is

### Step 7 - Implementation design

For each recommended concept, produce:

- minimal viable implementation
- preferred implementation
  This is the recommended implementation unless repo constraints make the
  minimal viable implementation the only defensible near-term option.
- required files to add or change
- whether it needs proposal-first treatment
- dependencies on other Octon surfaces
- validation, evidence, and disclosure requirements
- support-target or admission-review implications, if any
- rollback or reversal posture
- acceptance criteria
- risk notes

### Step 8 - Decision

Every concept must end with one of:

- **Adopt**
- **Adapt**
- **Park**
- **Reject**

No concept may remain undecided.

---

## Hard Constraints

1. **Do not invent repository facts not supported by live Octon inspection and
   the provided context.**
2. **Do not recommend changes that violate Octon's constitutional kernel,
   workspace charter pair, support-target declarations, or governance
   exclusions.**
3. **Do not recommend generated artifacts or proposal packets as canonical
   truth.**
4. **Do not recommend raw-input dependency surfaces for runtime or policy.**
5. **Do not recommend UI, chat, session state, labels, comments, or checks as
   canonical authority or control truth.**
6. **Do not recommend removing or bypassing the engine-owned authorization
   boundary.**
7. **Do not recommend widening support claims without explicit support-target,
   evidence, validator, and disclosure implications.**
8. **Do not recommend host or model adapters that widen authority or bypass
   canonical control surfaces.**
9. **Do not confuse authority, control, evidence, disclosure, continuity, and
   derived views.**
10. **Do not create new top-level architectural categories or new control
    planes unless they are both necessary and repo-grounded.**
11. **Prefer extension, consolidation, or refinement of existing Octon
    surfaces over net-new surfaces.**
12. **If a concept is underspecified, explicitly say what evidence is missing
    and downgrade confidence.**
13. **If the live repository already embodies the concept, say so instead of
    pretending it is novel.**
14. **If a concept can only be expressed as documentation, proposal text, or
    placeholder structure, park or reject it rather than promoting it as ready
    implementation.**

---

## Special Translation Guidance for Source Types

### If the Source Is a Video or Talk

Extract:

- operational patterns
- context-encoding strategies
- workflow scaffolds
- review, elimination, or retry loops
- observability loops
- self-improving agent loops
- packaging or distribution ideas
- dependency or internalization strategies
- human-bottleneck removal patterns

But reject:

- charisma
- slogans
- hype
- claims that depend on internal-only tooling not described concretely

### If the Source Is an Article or Post

Extract:

- architecture moves
- repo-materializable rules
- control mechanisms
- explicit workflows
- decision heuristics
- guardrail or policy ideas
- packaging, rollout, or evaluation structures

### If the Source Is a Code Repository

Extract:

- implemented architectural boundaries
- concrete control-flow or orchestration patterns
- repo-materialized contracts, schemas, or interface definitions
- configuration, policy, support-target, or enforcement surfaces
- test, validation, or CI guardrail patterns
- observability, logging, replay, evidence, or disclosure mechanisms
- dependency, packaging, release, or distribution patterns
- operator workflows, tooling envelopes, or ingress conventions

Prefer evidence from:

- stable paths and directory structure
- canonical config or manifest files
- runtime or orchestration entry points
- validators, tests, and CI workflows
- release markers, tags, or commit history when supplied

But reject:

- README claims unsupported by the code
- patterns that depend on hidden infrastructure not present in the repo
- incidental local conventions that do not encode a reusable mechanism
- implementation details that conflict with Octon's authority model

### If the Source Is a Research Paper

Extract:

- formal methods
- algorithms or procedures
- evaluation protocols
- representational structures
- benchmark methods
- safety or reliability mechanisms
- concrete data or control abstractions

But require:

- translation out of paper-language into repository artifacts

---

## Output Format

### 1. Executive Triage

Provide:

- a one-paragraph judgment of whether the source is high-value for Octon
- the top 3-7 concepts worth considering
- the main reasons the source is or is not actionable

### 2. Repository Drift Notes

List any ways the live Octon repository diverges from the source framing, stale
prior assumptions, or this prompt's default assumptions.

If there is no material drift, say so explicitly.

### 3. Candidate Concept Table

Use a compact table with columns:

- Concept
- Source type
- Problem solved
- Current Octon analogue
- Likely canonical placement
- Support-claim impact
- Implementation readiness
- Risk
- Decision

### 4. Detailed Concept Briefs

For each concept, use this exact structure:

#### Concept: `<name>`

##### A. Source Evidence

- concise evidence-backed description
- include quotes, paraphrases, timestamps, section references, or passage
  markers
- when the source is a code repository, include file paths, symbol names,
  config keys, script names, tests, commit SHAs, tags, or release markers

##### B. Current Octon Grounding

- exact current Octon files or surfaces that are adjacent, overlapping, or
  potentially relevant
- state whether Octon already has a partial analogue or no canonical analogue
- include any repository drift note needed for this concept

##### C. What It Actually Is

- stripped of hype
- define the true mechanism

##### D. Why It Might Matter for Octon

- specific to Octon, not generic

##### E. Octon Fit Assessment

- architectural fit
- governance fit
- support-target and exclusion fit
- authority, control, evidence, and disclosure fit
- operational fit

##### F. Canonical Placement

- proposed target root(s)
- exact candidate file or path targets
- whether it is authoritative, operational control, retained evidence,
  continuity, or derived-only

##### G. Implementation Shape

- narrowest acceptable implementation
- fuller preferred implementation
  Treat this as the recommended implementation shape unless live repo
  constraints require a narrower near-term landing.
- concrete file additions or edits
- required schemas, contracts, validators, tests, evals, receipts, or
  disclosures

##### H. Conflict Analysis

- invariants threatened
- overlap with existing surfaces
- support-claim or adapter-boundary implications
- whether it should refine an existing mechanism instead

##### I. Validation and Proof

- how Octon would verify this works
- what evidence and disclosure artifacts must be retained
- what generated views, if any, may be published

##### J. Recommendation

- Adopt, Adapt, Park, or Reject
- include explicit rationale

### 5. Consolidated Integration Plan

After all concept briefs, produce:

#### A. Highest-Value Recommendations

Rank the top recommendations by:

- leverage
- compatibility
- implementation effort
- governance risk
- proof burden

#### B. Recommended Sequence

State the best order for implementation:

- immediate backlog
- proposal-first items
- later or park items

#### C. Minimal Change Path

Describe the narrowest set of changes that would capture most of the value
without creating pseudo-coverage.

#### D. Preferred Change Path

Describe the fuller implementation path that should be implemented.

This is the recommended implementation path. Use it to define the intended
landing shape, with the Minimal Change Path retained only as a constrained
fallback when timing, dependency, or governance conditions block the preferred
landing.

#### E. Rejection Ledger

List the concepts you rejected and why.

### 6. Final Verdict

Conclude with:

- **What Octon should adopt now**
- **What Octon should adapt cautiously**
- **What Octon should not import**
- **What follow-up repo review would be needed before implementation**

---

## Quality Bar

Your output is only acceptable if it is:

- repository-specific
- live-repo-grounded
- evidence-first
- non-generic
- implementation-oriented
- explicit about placement
- explicit about authority vs control vs evidence vs disclosure vs continuity
  vs derived view
- explicit about support-claim implications when relevant
- honest about uncertainty
- ruthless about rejecting non-transferable ideas

Do **not** end with a generic inspirational summary.

End with a concrete integration verdict.
