# Operator Disclosure

## Accepted Baseline And Governed Configuration

ROD-004 already accepts the small private trust baseline:

- one operator-controlled signer family;
- immutable release refs/digests and explicit capability grants;
- an empty deny-by-default source allowlist until intentional admission; and
- denial of unknown, unsigned, revoked, incompatible, capability-mismatched, or
  mutable-source material.

Exact future sources, public signer material, pins, rotations, recovery changes,
and admission-policy updates use governed configuration routes; they are not new
architecture decisions. Private/external import remains unavailable until an
intentional admission is configured and proved. No secret key material enters
repository storage.

## Intended Solo Experience

After setup, the operator runs one explicit import against an approved
immutable release. Octon reports one of:

- `available` — signature/content/policy checks passed, but the release is not
  selected or active;
- `selected, not active` — desired exact pin exists but publication is blocked;
- `active` — the exact published generation is current and Harness-bindable;
- `quarantined` — a concise source/signer/content/compatibility/capability or
  dependency reason blocks it; or
- `revoked` — new use is denied and restore/disable posture is shown.

Normal status distinguishes available, selected, and active so a successful
import cannot be mistaken for authorization or execution.

## Failure Presentation

Report pack/source/version, immutable ref/payload fingerprint, the first
operator-meaningful failed gate, affected dependencies, whether current/core
work remains usable, preserved exact releases, and the shortest safe command to
inspect, correct trust/pin, quarantine/revoke, retry import, or request restore.

Do not display signature bytes, secret/keychain data, raw schema rows, packet
IDs, generated-path internals, or suggest bypassing source/signer/revocation,
compatibility, capability, or pin checks.

## Restore Experience

The operator or existing recovery route names an exact retained prior
generation. Octon reports each current revalidation gate and either publishes a
new generation or disables the extension. It never says "rolled back" merely
because old files were copied or a pointer changed.

## Maintenance and Unsupported Surfaces

Normal maintenance is limited to explicit import/pin changes, compact trust-key
rotation/revocation, status, and rare restore. There is no marketplace account,
public catalog, ratings, subscription, background update service, arbitrary
URL installer, dependency browser, or package-manager administration.

## Claim Honesty

This draft creates no current private-extension or Solo Local support claim.
FD-021 becomes eligible only after the accepted ROD-004 baseline is encoded,
PO-FD-021/UE-012 adversarial proof,
and claim-scoped dogfood. Bundled-first-party compatibility does not prove
private signed import, and a valid signature does not prove authorization.
