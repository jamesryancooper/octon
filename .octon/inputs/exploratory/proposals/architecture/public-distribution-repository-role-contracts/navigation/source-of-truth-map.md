# Source Of Truth Map

| Concern | Current source | Proposed durable source | Authority |
| --- | --- | --- | --- |
| Proposal intent | This packet | None | Non-authoritative planning input |
| Parent sequencing | `.octon/inputs/exploratory/proposals/architecture/octon-public-distribution-model/resources/child-packet-index.yml` | None | Program coordination only |
| Current repository evidence | Paths cited in this packet | Current repository at review time | Evidence, not correctness |
| Future behavior | Existing implementation surfaces | Declared promotion targets after governed promotion | Durable only after promotion |
| Repository-role boundaries | This packet | `public-distribution-topology.md` and `core-path-ownership-v1.yml` after governed promotion | This child owns role, path, and update-authority invariant definitions only |
| portable_dropin admission and root-profile validation | `public-distribution-portable-dropin-export` | That child's declared promotion targets after governed promotion | Export-child-only; this packet may reserve the role name but may not admit it |
| Adoption/update behavior and project-owned hash proof | `public-distribution-downstream-core-delivery` | That child's declared promotion targets and retained evidence after governed promotion | Downstream-child-only; this packet states the invariant but does not implement or prove operations |
| Human gates | Parent external-effects boundary | Maintainer decision record or platform action receipt | Human authority |
| Generated views | Existing generated roots | Rebuilt outputs | Never authority |
