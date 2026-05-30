# Target Architecture

_Status: Parent target-state summary_

Octon should have a dedicated architecture/governance index for governed
cross-surface mechanisms, separate from the product feature catalog.

## Target Documentation Shape

- Product docs continue to use `product features`.
- Architecture and governance docs use `governed cross-surface mechanisms`.
- Runtime and operator docs use concrete runtime terms such as `lifecycle`,
  `workflow`, `route`, `state machine`, `receipt`, command names, and skill
  names.
- The mechanism index names every required surface class and boundary for each
  mechanism.
- Product feature catalog entries remain navigation-only.

## Target Authority Shape

- Authored authority remains under `framework/**` and `instance/**`.
- Mutable operational truth remains under `state/control/**`.
- Retained evidence remains under `state/evidence/**`.
- Generated-effective artifacts remain resolver-verified non-authority handles.
- Generated cognition remains operator read-model and navigation/visibility
  only.
- Raw inputs remain non-authoritative lineage or publication input.
- Compatibility surfaces remain compatibility-only.

## Target Validation Shape

Validators must detect:

- product catalog authority overclaims;
- mechanism index runtime-authority overclaims;
- `state/control/**` mislabeled as retained evidence;
- generated-effective authority confusion;
- operator read-model authority confusion;
- lifecycle interaction receipts treated as authorization;
- parent program evidence satisfying child receipts;
- retired terminology outside compatibility notes.
