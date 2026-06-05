# Target Architecture

The validator child adds:

- `validate-lifecycle-postmortem.sh`;
- a shell test harness;
- positive and negative fixtures;
- a functional suite registration;
- an instance runtime assurance registration.

## Validation Rules

The validator should check:

- report has all required sections;
- structured output uses schema version
  `lifecycle-postmortem-evaluation-v1`;
- final judgment is one allowed value;
- invariant evaluation is present for Octon lifecycle subjects and appears
  before quality scoring;
- invariant ratings are only Pass, Partial, Fail, Unknown, or Not Applicable;
- invariant rows include applicability, enforcement mechanism, evidence, gap,
  blocking status, and required correction fields;
- Unknown invariant ratings are not treated as Pass;
- material Fail or Partial invariant ratings include blocking or corrective
  disposition when they concern authority, generated or raw-input truth,
  runtime authorization, evidence retention, support-proof requirements,
  second control planes, or force-fit integration;
- invariant validity/evolution review is present for Octon lifecycle subjects
  after redesign pressure and before final recommendations;
- invariant validity/evolution rows include protected property, current
  validity, enforcement quality, evidence quality, scope quality,
  conflict/duplication, hack pressure, recommendation, and required change;
- invariant validity/evolution recommendations are only Keep, Clarify,
  Strengthen, Relax, Split, Merge, Reclassify, Replace, Remove, or Add;
- non-Keep invariant recommendations include a required change and
  change-control bar;
- relaxation, removal, narrowing, downgrading, or addition recommendations use
  high or very high scrutiny;
- invariant recommendations are classified as proposed evidence, not approved
  invariant changes;
- every major finding has evidence refs;
- evidence refs are non-empty and resolve under allowed roots or are explicitly
  marked unavailable with known limits;
- generated and input refs are not classified as authority;
- non-authority statement is present;
- follow-up recommendations do not claim approval;
- optional `review-finding-v1` records validate when emitted.

## Negative Controls

Fixtures must fail when:

- generated output is treated as authority;
- raw input is treated as authority;
- evidence refs are missing or unresolved;
- final judgment is outside the enum;
- report lacks patch-versus-redesign reasoning;
- report omits Octon invariant evaluation for an Octon lifecycle;
- report treats Unknown invariant evidence as Pass;
- report records an invariant failure without evidence gap or required
  correction;
- report records a material invariant failure without blocking status.
- report omits invariant validity/evolution review for an Octon lifecycle;
- report uses an invalid invariant recommendation category;
- report omits required change for a non-Keep invariant recommendation;
- report recommends relaxing, removing, narrowing, downgrading, or adding an
  invariant without a high or very high change-control bar;
- report claims the evaluator approved or enacted an invariant change.
