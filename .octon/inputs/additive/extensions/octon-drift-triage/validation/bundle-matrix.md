# Validation Matrix

`octon-drift-triage` has one bundle, `octon-drift-triage-remediation-packet`.

## Coverage Matrix

| Scenario | Inputs | Expected direct checks | Expected bundle recommendations | Repo-hygiene |
|---|---|---|---|---|
| `extension-publication` | extension pack + `instance/extensions.yml` | `validate-extension-pack-contract`, `validate-extension-publication-state`, `validate-runtime-effective-state` | `alignment-check-harness` | no |
| `ingress-ssot` | ingress + charter | `validate-bootstrap-ingress`, `validate-bootstrap-projections`, `validate-ssot-precedence-drift` | `alignment-check-harness` | no |
| `repo-hygiene-governance` | repo-hygiene workflow + drift review | `validate-repo-hygiene-governance` | `alignment-check-harness` | conditional scan |
| `unmatched` | unrelated path | none | `alignment-check-harness` | no |

## Packet Fixtures

| Fixture | Mode | Purpose |
|---|---|---|
| `validation/fixtures/packets/select-mode-demo` | `select` | validates required report layout without raw check captures |
| `validation/fixtures/packets/run-mode-demo` | `run` | validates required report layout with raw check captures |

## Executable Tests

- `validation/tests/test-routing-matrix.sh`
  verifies the routing table against representative changed-path fixtures
- `validation/tests/test-packet-contract.sh`
  verifies the packet contract against representative packet fixtures
