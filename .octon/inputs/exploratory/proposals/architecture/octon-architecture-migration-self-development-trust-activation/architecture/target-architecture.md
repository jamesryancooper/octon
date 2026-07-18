# Target Architecture

A semantic trust inventory names every direct and indirect authority-bearing
surface: evaluator/policy/configuration, launcher, broker, verifier, store and
migrations, evidence signer/head, Harness compiler, provider adapters,
activation/health/rollback logic, build inputs, and generated sources that can
affect them. Epoch zero and change classification use the installed previous
version and immutable inventory, never candidate code.

Ordinary changes follow the already proved Class B/PR policy. A trust change may
land only as an inert content-addressed version containing its exact artifacts,
dependency closure, policy/provider identities, proof envelope, and rollback
candidate. The currently active version independently verifies the envelope,
classifier result, epoch, approvals, exact artifact, compatibility, and
pre-registered rollback before atomically switching one selector. Bounded health
checks either confirm the new version or automatically restore the exact prior
certified version. Crash/reboot/disk-full states resolve to one selector and
auditable receipt, never a mixed version.

Safe state SI-07 allows inert landing and disabled or explicitly confirmed
activation. Safe-automatic activation is a separate claim requiring the full
adversarial gate, the accepted ROD-003 boundary, and later promotion acceptance.
ROD-003 fixes a small content-addressed semantic epoch-zero inventory, one-time
human trust anchor/bootstrap, and exact scope/artifact-version/time/budget/
verifier/health/rollback preauthorization. Inventory encoding and indirect-
change detection, health windows, canaries, and rollback durations remain
reversible engineering and proof choices. Candidate-HEAD authority, same-change
self-certification, post-merge detection as prevention, and unverified rollback
are prohibited. RP-09 consumes RP-06 publication, RP-07 authentic evidence, and
RP-08 recovery; it does not redefine them.

`activation-authority-v1` is an exact-version decision/grant envelope issued
only by RP-01 authority. RP-09 consumes that envelope and cannot mint, widen,
substitute, or self-satisfy it; activation fails closed when its RP-01 issuer,
version, epoch, or scope binding is absent or mismatched.

## Exact Selected Mechanisms

`resources/trust-activation-design-and-dependency-receipt.yml` freezes the
RP-01/RP-06/RP-07/RP-08 packet digests and selects RFC-8785 canonical JSON plus
SHA-256 for semantic inventory/version manifests; an immutable same-filesystem
`$OCTON_HOME/versions/sha256-<digest>/` install; and two alternating checksummed
selector records whose highest valid monotonic generation is active. Candidate
code has no selector or activation-authority writer.

Epoch zero uses the same closure algorithm and one one-time, human-approved
RP-01 bootstrap receipt stored outside candidate/selector state. The prior
installed version performs a read-only/effect-denied canary, then requires 60
successful ten-second probes over 600 seconds. One critical or three
consecutive ordinary failures trigger exact prior-version rollback and status
within 30 seconds; failure keeps effects disabled. Active, rollback, latest
three certified, and unresolved-evidence versions remain pinned.

The RP-09-owned `activation-authority-v1` file is only the strict wire schema
projection for an RP-01-issued envelope. It has no defaults, wildcard scope,
issuer, epoch advancement, renewal, or authorization behavior. A selector
generation requires one current, unrevoked, single-use envelope matching exact
issuer/version/epoch/subject/inventory/scope/provider/health/rollback digests.
