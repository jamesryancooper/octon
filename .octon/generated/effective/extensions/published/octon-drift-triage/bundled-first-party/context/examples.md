# Usage Examples

These examples illustrate the intended v1 operating patterns for
`octon-drift-triage`.

## 1. Extension Publication Drift

Command:

```text
/octon-drift-triage --changed-paths ".octon/inputs/additive/extensions/octon-drift-triage/pack.yml,.octon/instance/extensions.yml"
```

Expected behavior:

- selects extension publication validators
- recommends `alignment-check --profile harness`
- emits a packet without `repo-hygiene`

## 2. Ingress And Constitutional Drift

Command:

```text
/octon-drift-triage --changed-paths ".octon/instance/ingress/AGENTS.md,.octon/framework/constitution/CHARTER.md" --mode run
```

Expected behavior:

- selects bootstrap and SSOT validators
- ranks ingress and constitutional remediation above ordinary extension drift
- emits raw validator output captures because `mode=run`

## 3. Repo-Hygiene Governance Drift

Command:

```text
/octon-drift-triage --changed-paths ".github/workflows/repo-hygiene.yml,.octon/instance/governance/contracts/drift-review.yml" --mode run
```

Expected behavior:

- selects `validate-repo-hygiene-governance.sh`
- conditionally runs `repo-hygiene.sh scan`
- adds review-trigger weight for drift/retirement governance

## 4. Packet Refresh

Command:

```text
/octon-drift-triage --packet-path ".octon/inputs/exploratory/packages/2026-04-15-octon-drift-triage-demo"
```

Expected behavior:

- reloads stored inputs from `packet.yml`
- refreshes the packet in place
- preserves the packet as a non-authoritative report package

## 5. Fallback

Command:

```text
/octon-drift-triage --changed-paths "docs/example-notes.md"
```

Expected behavior:

- selects no direct checks
- emits the fallback `alignment-check --profile harness` recommendation
- still builds a packet rather than failing empty
