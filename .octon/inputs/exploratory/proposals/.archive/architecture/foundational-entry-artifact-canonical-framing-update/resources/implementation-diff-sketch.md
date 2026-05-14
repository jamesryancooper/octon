# Implementation Diff Sketch

_Status: In-review proposal packet artifact_


This packet does not include a literal patch because promotion should happen inside the live repository with local validation. The intended diff classes are:

1. README opening paragraph replacement.
2. README capabilities table wording adjustment.
3. AGENTS behavioral sentence replacement.
4. `.octon/README.md` one-paragraph framing addition.
5. Ingress one-paragraph framing addition.
6. Bootstrap one-paragraph framing addition.
7. Glossary term additions.
8. Architecture specification target framing addition.

No runtime specs, schemas, crates, state/control, state/evidence, generated, or input promotion surfaces should be changed by this packet implementation except retained promotion evidence after landing.
