# Revocation Control Roots

`state/control/execution/revocations/**` is the canonical live control family
for normalized authority revocations.

Revocations apply to grants or requests only after they materialize into this
control family. External comments or labels may signal revocation intent, but
they do not revoke authority on their own.
