---
disclosure_status: externally-shareable-after-maintainer-review
authority_mode: non-authoritative
external_transmission_approved: false
---

# Portable Dropin Specification

This is the adopted proposal baseline, not current runtime authority.

## Source Contract

- Input is one exact, reachable Git commit.
- Only tracked Git objects are eligible.
- Untracked and ignored files are never export source.
- The exporter does not mutate the source tree, generated outputs, refs,
  remotes, or publication state.
- Staging starts empty.

## Selection Contract

Every output path must have:

- component identity;
- dependency-closure membership;
- provenance status;
- license coverage;
- sensitivity and publication clearance;
- one class: `installable` or `public-repository-only`.

Unknown, ambiguous, uncleared, restricted, quarantined, or denylisted paths fail
closed. The base closure contains zero packs.

## Manifest Contract

The canonical sorted manifest records, for every file:

- path;
- component;
- output class;
- mode;
- size;
- SHA-256.

It also records the source commit, clearance input digests, and aggregate tree
digest without volatile timestamps affecting reproducibility.

## Denylist Invariants

At minimum, reject live instance, input, state, evidence, generated,
host-projection, pack, log, cache, archive, report, proposal, scratch, and Git
history paths. Reject traversal, unsafe links, devices, case collisions, and
platform-reserved names.

## Verification

Two builds from the same inputs are byte-identical. Public-tree parity rejects
both extra and missing files. A source fingerprint proves export caused no
workspace mutation.

External architect question: Is this boundary sufficient even if a cleared file
contains sensitive transformed content, and what additional taint analysis is
required?

Sources: `SRC-003`, `SRC-009`, `SRC-015`, and `SRC-018`.

