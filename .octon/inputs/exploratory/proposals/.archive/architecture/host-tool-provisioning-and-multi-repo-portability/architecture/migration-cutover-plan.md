# Migration and Cutover Plan

## Profile Selection Receipt

| Field | Receipt |
| --- | --- |
| `release_state` | `pre-1.0` |
| `change_profile` | `atomic` |
| repository default | `atomic` unless a hard gate requires `transitional` |
| hard-gate assessment | none found; no existing governed host-tool provisioning plane exists |
| chosen cutover model | clean-break promotion of the contract family, requirements surface, provisioning command, and validator |
| transitional exception note | none |
| rationale | this is a new subsystem with no competing canonical predecessor, so a single coherent landing is preferable |

## Cutover model

The architecture is atomic in repo surfaces and iterative in runtime use.

Atomic landing:

- framework host-tool contract family
- repo requirement surface
- provisioning command
- validator and bootstrap docs

Iterative runtime use:

- host tool installs may occur later on each machine as needed;
- actual host caches remain external runtime state, not proposal promotion outputs.

## No-partial-compliance rule

Octon may not claim this subsystem landed while only one of the following
exists:

- tool contracts without repo requirements;
- repo requirements without a provisioning command;
- provisioning command without a validator;
- bootstrap docs that still imply `/init` silently provisions host tools.
