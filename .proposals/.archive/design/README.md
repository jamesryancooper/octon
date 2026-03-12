# Design Package Archive

`/.design-packages/.archive/` stores archived manifest-governed design packages.

Archived packages remain temporary, non-canonical implementation material. They
stay here only as historical reference after implementation or historical
retention.

Rules:

- every archived package must live at `/.design-packages/.archive/<package-id>/`
- every archived package must have a root `design-package.yml`
- the package manifest remains the lifecycle authority
- `/.design-packages/registry.yml` must project every archived package
- live implementation targets must not depend on archived package paths
