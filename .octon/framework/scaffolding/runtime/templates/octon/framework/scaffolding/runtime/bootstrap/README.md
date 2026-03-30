# Bootstrap Assets

Canonical repo-bootstrap assets used by `/init`.

## Contents

- `init-project.sh` - canonical bootstrap implementation
- `AGENTS.md` - canonical authored AGENTS source rendered to `/.octon/AGENTS.md`
- `BOOT.md` - optional recurring startup checklist template
- `BOOTSTRAP.md` - optional one-time bootstrap checklist template
- `alignment-check` - root shim template
- `objectives/` - workspace charter starter packs rendered canonically to `/.octon/instance/charter/workspace.{md,yml}` and mirrored to the compatibility shims at `/.octon/instance/bootstrap/OBJECTIVE.md` and `/.octon/instance/cognition/context/shared/intent.contract.yml`
- `manifest.yml` - bootstrap bundle metadata for projection and validation

`/.octon/AGENTS.md` is the projected ingress surface. Repo-root `AGENTS.md`
and `CLAUDE.md` are valid only as a symlink to `/.octon/AGENTS.md` or a
byte-for-byte parity copy.
