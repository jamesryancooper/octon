# Migration Reports

Generated migration evidence bundles live here.

## Contract

- Migration evidence uses date-prefixed bundle directories:
  - `YYYY-MM-DD-<slug>/`
- Each bundle directory must include:
  - `bundle.yml`
  - `evidence.md`
  - `commands.md`
  - `validation.md`
  - `inventory.md`
- Canonical migration records (plans and index) live in:
  - `/.octon/instance/cognition/context/shared/migrations/`
- Migration policy doctrine/banlist/exceptions live in:
  - `/.octon/framework/cognition/practices/methodology/migrations/`
