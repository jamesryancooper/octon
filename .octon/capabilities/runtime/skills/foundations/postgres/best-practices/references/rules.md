---
title: Rules Reference
description: Concise PostgreSQL best-practice guardrails by category and impact.
version: "1.0.1"
---

# PostgreSQL Best Practices Rules

Compact activation-safe rules. Use `rules-detail.md` when detailed examples are required.

## Query Performance (Critical)

- Eliminate N+1 access patterns with joins, batching, or prefetch plans
- Index columns used in frequent `WHERE`, `JOIN`, and ordering predicates
- Use explicit projection instead of `SELECT *`
- Bound result sets with `LIMIT`/pagination contracts
- Avoid non-sargable predicates on indexed columns

## Schema Design (Critical)

- Use precise data types; avoid generic text/numeric fields by default
- Add `NOT NULL` and domain constraints when invariants are required
- Enforce referential integrity with foreign keys
- Normalize by default; denormalize only with measured justification

## Index Strategy (High)

- Prefer composite indexes that match query predicate order
- Use partial indexes for hot filtered subsets
- Use covering indexes when index-only scans materially improve latency
- Remove low-value indexes that increase write amplification
- Use GIN/GiST for JSONB and full-text access patterns

## Migration Safety (High)

- Treat DDL as staged rollout: add/backfill/switch/cleanup
- Create large indexes concurrently in production environments
- Require rollback or forward-fix plans for every migration
- Validate migration runtime against production-scale data

## Connection and Workload Management (Medium)

- Use pooling with bounded connection counts
- Set statement and lock timeout defaults
- Keep transactions short and side-effect focused
- Route read-heavy traffic to replicas when consistency permits
- Monitor saturation, waits, and long-running transactions

## Security and Governance (Medium)

- Use parameterized queries exclusively
- Apply least-privilege roles and rotate credentials
- Use row-level security where tenant isolation requires it
- Audit high-risk data access and administrative actions
- Encrypt or externalize secrets; never store plaintext credentials

## Advanced Patterns (Low)

- Partition large tables only when data/retention shape warrants it
- Use materialized views for expensive repeated aggregations
- Use `LISTEN/NOTIFY` for lightweight event propagation only
- Use `pg_stat_statements` for query-level performance baselining
- Use advisory locks for application-level coordination with timeouts
