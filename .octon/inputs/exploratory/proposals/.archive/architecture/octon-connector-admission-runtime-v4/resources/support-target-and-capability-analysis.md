# Support-Target and Capability Analysis

## Support posture

The live support-targets model is already the correct anchor for capability expansion:
- default route deny;
- bounded-admitted-finite claims;
- proof bundle root;
- support dossier root;
- support card projection root;
- generated support matrix cannot widen support.

## Capability posture

The live registry includes `browser` and `api`, but they are not generally live. This proposal does not make them live. It defines the admission path by which individual operations could later become observe-only, read-only, stage-only, or live-effectful.

## Required invariant

No connector operation can make a new live claim unless:

1. support-target tuple exists;
2. support-target admission exists;
3. trust dossier exists;
4. proof bundle exists;
5. support card projection exists;
6. validators pass;
7. generated/effective artifacts are current and resolver-verified;
8. execution authorization grants material operation.

## Generated support no-widening

Generated support cards and matrices may expose operator status but cannot widen admission. This packet adds connector generated views only as read models.
