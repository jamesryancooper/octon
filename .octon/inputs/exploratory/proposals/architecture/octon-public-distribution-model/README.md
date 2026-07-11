# Octon Public Distribution Model

_Status: In review; implementation-grade complete; not accepted or authorized for implementation._

This parent program translates the adopted public-distribution baseline into ten
independent sibling architecture packets. The initial nine-packet decomposition
was split at self-hosting migration because canonical proposal rules prohibit a
single active packet from mixing `.octon/**` and root repository promotion
targets.

## Verdict

**Confirmed evidence:** Octon's class-root architecture substantially supports
the target model, but current profiles, exporter, bootstrap, evidence semantics,
Git tracking, release automation, and hosted settings do not implement it.

**Sponsor decision:** The private workspace and public distribution remain
separate repositories. The public repository receives only an exact,
allowlist-generated `portable_dropin` tree with synthetic history.

**Recommendation embodied by this program:** Implement the target through
gated-parallel children, preserve solo-maintainer operation, and keep every
irreversible publication or risk-acceptance action human-authorized.

## Program Boundary

The parent coordinates dependencies, blocker coverage, manual gates, and
aggregate closeout. Each child retains its own manifest, review, implementation,
promotion targets, validation, rollback, and archive authority.

No implementation, GitHub mutation, repository migration, evidence deletion,
credential action, push, or publication is performed by this program packet.

