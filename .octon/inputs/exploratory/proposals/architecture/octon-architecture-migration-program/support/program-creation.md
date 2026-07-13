# Program Creation Receipt

- creation_id: `20260712-octon-architecture-migration-program-creation`
- creator: `octon-proposal-lifecycle-create-program`
- created_at: `2026-07-12`
- program_packet_path: `.octon/inputs/exploratory/proposals/architecture/octon-architecture-migration-program/`
- child_packet_count: `15`
- workgroup_count: `14`
- execution_mode: `gated-parallel`
- seed_reference_child: `octon-architecture-migration-containment`
- child_registry_digest: `sha256:aca7fc963d8d4fa0a8445b51afbcf39c132993d4b15e6d6a55fc81a5fa218f8b`
- child_authority_preserved: `yes`
- child_authority_preserved_basis: the v2 registry declares only sibling paths;
  the human index, exact sequence, child contract, source map, and closeout plan
  require child-owned lifecycle receipts and forbid parent substitution
- lifecycle_status: `draft`
- creation_route: current canonical templates/create-packet and create-program
  contracts were materialized directly because the checked-in compatibility
  runner used a stale template path, the current source runtime retired
  `workflow run`, and the isolated last-compatible runner was denied by live
  authority before proposal writes
- route_deviation_effect: disclosed creation-route deviation only; no alternate
  proposal format/lifecycle, status elevation, generated-registry hand-edit, runtime write,
  or fabricated workflow receipt
- verdict: `program-created-draft`

This parent-local receipt proves creation and registry binding only. It does not
satisfy child reviews, implementation, validation, promotion, closeout, archive,
or support claims.
