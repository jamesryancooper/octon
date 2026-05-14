# Cutover Checklist

_Status: In-review proposal packet artifact_


## Cutover scope

This cutover is documentation/framing only.

## Steps

1. Apply README change.
2. Apply root `AGENTS.md` change.
3. Apply `.octon/AGENTS.md` parity change.
4. Apply `.octon/README.md` change.
5. Apply ingress/bootstrap wording change.
6. Apply glossary additions.
7. Apply architecture specification framing paragraph.
8. Run validators.
9. Retain promotion evidence.
10. Archive or remove proposal packet after durable promotion lands.

## Cutover gates

- No runtime files changed except documentation references if explicitly promoted.
- No generated/input surfaces used as durable authority.
- No follow-on packet capability described as live.
