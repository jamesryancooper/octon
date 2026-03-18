# Glossary Reference

**Required when capability:** `domain-specialized`

## Core Terms

| Term | Definition | Example |
|------|------------|---------|
| render waterfall | Sequential data/render chain that delays paint | Nested await-dependent components |
| code splitting | Loading bundles only when needed | Route-level lazy chunks |
| memoization | Reusing computed/render output when inputs unchanged | `useMemo` and `memo` usage |
| hydration mismatch | Client/server markup divergence | Runtime warnings and re-render |
| re-render churn | Excessive component re-execution | Unstable props causing updates |
