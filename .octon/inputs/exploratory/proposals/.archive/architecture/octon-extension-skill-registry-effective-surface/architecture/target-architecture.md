# Target Architecture

## Goal

Extend the effective extension publication model so extension-contributed skill
registry metadata has a first-class generated representation, parallel to the
existing routing-oriented command and skill exports.

## Proposed Landing

- add a generated effective extension skill registry or equivalent structured
  metadata section under the existing effective extension family
- teach `publish-extension-state.sh` to emit the new metadata from pack-local
  `skills/registry.fragment.yml`
- extend the extension publication validator to verify the new metadata
- keep capability routing consuming only the effective generated surface rather
  than rediscovering raw pack registry metadata directly

## Non-Negotiables

- no direct runtime reads from raw extension pack paths
- no authored authority in generated effective outputs
- no new capability-pack family or support-target widening
