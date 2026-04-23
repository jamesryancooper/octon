# Repository Baseline Audit

## Finding 1 — Octon already has the correct architectural identity

The repository identifies Octon as a Constitutional Engineering Harness whose
execution core is the Governed Agent Runtime. The `.octon/` class-root model
separates authored framework/instance authority, raw inputs, mutable state,
retained evidence, and generated read models.

Implication: the packet must not rename Octon, collapse the harness into the
runtime, or invent a parallel control plane.

## Finding 2 — Existing runtime constitutional contracts already define a run event ledger

The runtime contract family already contains:

- `run-event-ledger-v1.schema.json`,
- `run-event-v1.schema.json`,
- `runtime-state-v1.schema.json`,
- `state-reconstruction-v1.md`.

The state reconstruction contract already states the core principle this proposal
builds on: runtime-state and mutable run-control files are derived views over the
canonical run event ledger plus bounded side artifacts; if reconstructed fact
conflicts with mutable files, the ledger wins and the mismatch is a drift
incident.

Implication: the proposal should strengthen and implement the existing ledger,
not introduce a new unrelated journal abstraction.

## Finding 3 — Engine runtime already names the necessary execution surfaces

The runtime README and spec directory already describe:

- run-first CLI surfaces,
- control/evidence root binding,
- execution authorization,
- run lifecycle,
- runtime event schemas,
- evidence store,
- operator read models,
- authorization-boundary coverage,
- replay/telemetry/runtime services.

Implication: the missing step is not conceptual invention; it is alignment,
enforcement, and validation across these surfaces.

## Finding 4 — Support targets already require runtime event evidence

The instance support-targets file uses a bounded-admitted-finite support claim
mode and keeps frontier/browser/API/GitHub/Studio surfaces stage-only or non-live.
It also lists runtime event ledger evidence among requirements for staged or
supported adapters.

Implication: Run Journal hardening improves support-target realism without
widening support claims.

## Finding 5 — Fail-closed and evidence obligations already support the step

Current obligations already fail closed on missing run lifecycle roots,
unsupported action classes, missing authorization-boundary coverage, missing
evidence, and generated read models consumed as authority.

Implication: this proposal should add validators and runtime behavior that make
those obligations operational for Run Journal integrity.

## Finding 6 — Current gap is implementation realization

The key gap is that current contracts are split across constitutional and engine
surfaces and are not yet visibly unified into one runtime append/reconstruct/
replay/validate substrate. The same execution event may be described by a
constitutional run event, engine runtime event, lifecycle transition, evidence
artifact, and operator read model without a single strong event ontology tying
all of them together.

Implication: add v2 contracts, runtime spec alignment, append-only writer,
reconstruction, evidence snapshot, and validators.
