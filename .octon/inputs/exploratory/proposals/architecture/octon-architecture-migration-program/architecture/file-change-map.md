# Parent File Change Map

The parent changes only its forty proposal-local files and its retained future
evidence target. It owns no child implementation target. Child durable targets
are discoverable from each child `proposal.yml`; the parent only records
coordination scopes in `resources/child-packet-index.yml` and exact source
ownership in `resources/source-ownership-map.md`.

The shared generated proposal registry is written later only by
`generate-proposal-registry.sh --write`. No runtime, workflow, provider,
credential, existing proposal, intake, reconciliation, Revision 2, `.github/**`,
or authoritative contract/source file is modified by program creation.
