# Assumptions and Blockers

## Assumptions

1. A host-scoped Octon home is architecturally acceptable when treated as
   operational truth rather than repo authority.
2. Repo-local desired requirements should remain authored under `instance/**`.
3. A shared provisioning command belongs in the framework command lane.
4. The first concrete consumer should be `repo-hygiene`.

## Explicit blockers

### B-01 — Host-scoped runtime state is outside proposal promotion targets

The actual install cache and provisioning receipts are not repo-relative
surfaces, so they cannot appear in `proposal.yml` `promotion_targets`.

Resolution in this packet:

- treat them as host-scoped runtime state governed by repo-local contracts and
  validator expectations, not as promotion targets.

### B-02 — No current host-home contract exists

The live repo has no canonical host-tool home or tool registry today.

Resolution in this packet:

- propose the full contract family and cutover model rather than trying to
  retrofit behavior implicitly into `/init`.

## Non-blocking concerns

- Initial tool contracts will likely cover only the first wave of tools, not
  every external analyzer Octon may ever use.
- Some OS-specific installer adapters may need iterative hardening after the
  core architecture lands.
