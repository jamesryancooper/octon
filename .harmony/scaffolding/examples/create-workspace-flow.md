# Example: `/create-workspace` Flow

A complete walkthrough of creating a workspace for `packages/ui-kit/`.

---

## 1. User Invokes Command

```text
/create-workspace @packages/ui-kit/
```

---

## 2. Agent Analyzes Directory

```bash
$ ls -la packages/ui-kit/
drwxr-xr-x  src/
drwxr-xr-x  __tests__/
-rw-r--r--  package.json
-rw-r--r--  tsconfig.json
-rw-r--r--  jest.config.js
-rw-r--r--  .eslintrc.js
-rw-r--r--  README.md
```

**Detection results:**

| Detected | Value |
|----------|-------|
| Type | Node/TypeScript code |
| Naming | PascalCase components, camelCase utils |
| Tests | Jest (`jest.config.js`, `__tests__/`) |
| Linting | ESLint (`.eslintrc.js`) |
| Entry point | `src/index.ts` |
| Setup | `pnpm install` (from package.json) |

---

## 3. Agent Asks Context Questions

> **Agent:** I detected this is a Node/TypeScript project with Jest tests and ESLint. Let me ask a few questions:
>
> 1. **Scope:** What is this directory for?
> 2. **In-scope work:** What types of work happen here?
> 3. **Out-of-scope:** What should NOT be done here?
> 4. **Quality checks:** Any additional checks beyond tests/lint?

**User answers:**

1. "Shared React UI component library for the design system"
2. "Creating components, writing tests, updating styles, documentation"
3. "App-specific components (belong in apps/), business logic"
4. "Storybook stories must exist for each component"

---

## 4. Agent Creates Structure

```text
packages/ui-kit/.workspace/
├── START.md
├── scope.md
├── conventions.md
├── progress/
│   ├── log.md
│   └── tasks.json
└── checklists/
    └── complete.md
```

---

## 5. Agent Shows Customizations

> **Agent:** Created `.workspace/` with these customizations:
>
> | File | Customization |
> |------|---------------|
> | `scope.md` | "Shared React UI component library for the design system" |
> | `conventions.md` | PascalCase for components, camelCase for utils |
> | `complete.md` | Jest tests, ESLint, TypeScript types, Storybook stories |
> | `START.md` | `pnpm install`, entry point `src/index.ts` |
> | `tasks.json` | "Document current components", "Identify missing tests" |
>
> **Next step:** Run the boot sequence in `START.md`

---

## 6. Resulting Files

See `examples/harmony-node-ts/` for the complete output.
