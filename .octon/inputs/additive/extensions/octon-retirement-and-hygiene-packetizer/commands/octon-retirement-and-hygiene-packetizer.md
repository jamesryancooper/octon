# Octon Retirement And Hygiene Packetizer

Run the `octon-retirement-and-hygiene-packetizer` family dispatcher.

Dispatcher behavior:

- normalizes composite retirement and hygiene planning inputs
- resolves one published route from `context/routing.contract.yml`
- returns the route receipt immediately when `dry_run_route=true`
- dispatches only to non-authoritative planning flows

Default resolved route:

- no narrower planning inputs -> `scan-to-reconciliation`

Leaf commands:

- `/octon-retirement-and-hygiene-packetizer-scan-to-reconciliation`
- `/octon-retirement-and-hygiene-packetizer-audit-to-packet-draft`
- `/octon-retirement-and-hygiene-packetizer-registry-gap-analysis`
- `/octon-retirement-and-hygiene-packetizer-ablation-plan-draft`
