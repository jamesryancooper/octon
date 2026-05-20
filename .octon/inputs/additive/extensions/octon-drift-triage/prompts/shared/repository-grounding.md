# Repository Grounding

Use this grounding order for `octon-drift-triage`:

1. constitutional and workspace authority surfaces
2. extension boundary and publication rules
3. current repo state and changed paths
4. additive routing and ranking files for this pack
5. current generated effective extension and capability views as rebuildable
   publication evidence

## Non-Authority Rule

- `inputs/additive/extensions/**` is additive source input only
- `inputs/exploratory/reports/**` is a report workspace only
- `generated/effective/**` is rebuildable publication output only
- none of the above surfaces mint policy or runtime authority

## Triage-Specific Rule

The routing and ranking logic for this feature is authored under:

- `context/check-routing.yml`
- `context/ranking-model.yml`

Read those files directly when selecting checks or computing ranks.
