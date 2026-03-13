# Audit Reports

Generated bounded-audit evidence bundles live here.

## Contract

- Audit evidence uses date-prefixed bundle directories:
  - `YYYY-MM-DD-<slug>/`
- Each bundle directory must include:
  - `bundle.yml`
  - `findings.yml`
  - `coverage.yml`
  - `convergence.yml`
  - `evidence.md`
  - `commands.md`
  - `validation.md`
  - `inventory.md`
- `bundle.yml` must declare:
  - `kind: audit-evidence-bundle`
  - `id: <directory-name>`
  - pointers:
    - `findings: findings.yml`
    - `coverage: coverage.yml`
    - `convergence: convergence.yml`
    - `evidence: evidence.md`
    - `commands: commands.md`
    - `validation: validation.md`
    - `inventory: inventory.md`
- Canonical audit records (plans and index) live in:
  - `/.octon/cognition/runtime/audits/`
- Audit policy doctrine lives in:
  - `/.octon/cognition/practices/methodology/audits/`
