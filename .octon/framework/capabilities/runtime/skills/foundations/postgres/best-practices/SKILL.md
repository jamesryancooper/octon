---
name: postgres-best-practices
description: >
  Reference knowledge skill for PostgreSQL performance optimization, schema
  design, and query best practices. Provides 35+ rules across 7 categories,
  prioritized by impact from critical (missing indexes, N+1 queries, unsafe
  migrations) to incremental (advanced patterns, monitoring). Apply when
  writing, reviewing, or optimizing PostgreSQL queries, schemas, or
  database configurations.
license: MIT
compatibility: Designed for Claude Code and similar AI coding assistants.
metadata:
  author: Octon Framework (informed by Supabase Engineering)
  created: "2026-02-09"
  updated: "2026-02-10"
skill_sets: [specialist]
capabilities: []
allowed-tools: Read Glob Grep Write(_ops/state/logs/*)
---

# Postgres Best Practices

Comprehensive performance optimization and correctness guide for PostgreSQL databases.

## When to Use

Use this skill when:

- Writing new SQL queries, schemas, or migrations
- Reviewing existing database code for performance issues
- Diagnosing slow queries, lock contention, or connection issues
- Designing new tables, indexes, or constraints
- Planning data migrations or schema changes
- Working with Supabase, RDS, or any PostgreSQL-backed system

## Quick Start

```
/postgres-best-practices target="src/db/"
```

## How to Apply

When this skill is activated:

1. Read the target code to understand the current database patterns
2. Load `references/rules.md` for the full rule set
3. Check against applicable rules, prioritizing CRITICAL and HIGH impact first
4. Report violations with rule references, impact level, and corrected examples
5. For new code, apply the patterns proactively during generation

## Rule Categories

| # | Category | Impact | Rules | Key Focus |
|---|----------|--------|-------|-----------|
| 1 | Query Performance | CRITICAL | 6 | Avoid N+1, use indexes, eliminate sequential scans on large tables |
| 2 | Schema Design | CRITICAL | 5 | Normalization, constraints, appropriate types, foreign keys |
| 3 | Index Strategy | HIGH | 5 | Composite indexes, partial indexes, covering indexes, avoid over-indexing |
| 4 | Migration Safety | HIGH | 5 | Non-locking migrations, backward compatibility, rollback plans |
| 5 | Connection Management | MEDIUM | 5 | Pooling, timeouts, transaction scope, prepared statements |
| 6 | Security | MEDIUM | 5 | Row-level security, parameterized queries, least privilege, audit logging |
| 7 | Advanced Patterns | LOW | 5+ | Partitioning, materialized views, LISTEN/NOTIFY, pg_stat analysis |

## Boundaries

- Reference knowledge only — apply rules to code, do not rewrite the rules
- Cite rules by section and number when reporting violations (e.g., "Rule 1.3: Avoid N+1 Queries")
- Do not modify database files unless explicitly asked to refactor
- Migration safety rules (section 4) apply to all production databases
- Prioritize CRITICAL and HIGH rules over MEDIUM and LOW

## When to Escalate

- Rules conflict with project-specific database architecture decisions
- Performance issue requires EXPLAIN ANALYZE output for diagnosis
- Migration involves data transformation on tables with >1M rows
- Schema change affects multiple services or requires coordinated deployment

## References

- [Rules](references/rules.md) — Full rule set with SQL examples (35+ rules across 7 categories)
