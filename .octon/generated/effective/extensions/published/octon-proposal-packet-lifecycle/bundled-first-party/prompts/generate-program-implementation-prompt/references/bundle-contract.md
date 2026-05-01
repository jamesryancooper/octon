# Bundle Contract

Aggregate implementation may coordinate child packets, but it must not broaden
one child packet to cover another unless the parent sequence explicitly
requires a coordinated changeset.
