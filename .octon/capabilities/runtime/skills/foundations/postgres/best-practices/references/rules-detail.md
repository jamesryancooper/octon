---
title: Rules Reference
description: PostgreSQL best practices rules organized by category and impact.
---

# PostgreSQL Best Practices Rules

35+ rules across 7 categories, prioritized by impact.

---

## 1. Query Performance (CRITICAL)

### Rule 1.1: Avoid N+1 Queries

**Impact:** CRITICAL — N+1 patterns cause linear scaling of database round-trips.

**Bad:**
```sql
-- In application code: for each user, fetch their orders
SELECT * FROM users;
-- Then for EACH user:
SELECT * FROM orders WHERE user_id = $1;
```

**Good:**
```sql
-- Single query with JOIN
SELECT u.*, o.*
FROM users u
LEFT JOIN orders o ON o.user_id = u.id;

-- Or batch fetch
SELECT * FROM orders WHERE user_id = ANY($1::int[]);
```

### Rule 1.2: Use Appropriate Indexes for WHERE Clauses

**Impact:** CRITICAL — Missing indexes cause full table scans.

**Bad:**
```sql
-- No index on email column
SELECT * FROM users WHERE email = 'user@example.com';
```

**Good:**
```sql
CREATE INDEX idx_users_email ON users(email);
SELECT * FROM users WHERE email = 'user@example.com';
```

**Verify with:** `EXPLAIN ANALYZE` — look for `Seq Scan` on large tables.

### Rule 1.3: Use LIMIT for Paginated Queries

**Impact:** CRITICAL — Unbounded queries can return millions of rows.

**Bad:**
```sql
SELECT * FROM events ORDER BY created_at DESC;
```

**Good:**
```sql
SELECT * FROM events
ORDER BY created_at DESC
LIMIT 50 OFFSET 0;

-- Better: cursor-based pagination
SELECT * FROM events
WHERE created_at < $1
ORDER BY created_at DESC
LIMIT 50;
```

### Rule 1.4: Avoid SELECT *

**Impact:** CRITICAL — Fetches unnecessary columns, wastes I/O and memory.

```sql
-- Bad
SELECT * FROM users;

-- Good
SELECT id, name, email FROM users;
```

### Rule 1.5: Use Prepared Statements for Repeated Queries

**Impact:** CRITICAL — Reduces parse/plan overhead for frequently executed queries.

```sql
PREPARE user_by_id (int) AS
  SELECT id, name, email FROM users WHERE id = $1;

EXECUTE user_by_id(42);
```

### Rule 1.6: Avoid Functions in WHERE on Indexed Columns

**Impact:** CRITICAL — Prevents index usage.

```sql
-- Bad: index on created_at won't be used
SELECT * FROM orders WHERE EXTRACT(YEAR FROM created_at) = 2026;

-- Good: range query uses index
SELECT * FROM orders
WHERE created_at >= '2026-01-01' AND created_at < '2027-01-01';
```

---

## 2. Schema Design (CRITICAL)

### Rule 2.1: Use Appropriate Data Types

**Impact:** CRITICAL — Wrong types waste storage and prevent validation.

| Data | Use | Avoid |
|------|-----|-------|
| UUIDs | `uuid` | `varchar(36)` |
| Booleans | `boolean` | `integer`, `varchar` |
| Timestamps | `timestamptz` | `timestamp`, `varchar` |
| Money | `numeric(12,2)` | `float`, `double precision` |
| JSON data | `jsonb` | `json`, `text` |
| IP addresses | `inet` | `varchar` |

### Rule 2.2: Always Add NOT NULL Constraints Where Applicable

**Impact:** CRITICAL — NULLs complicate queries and introduce three-valued logic.

```sql
-- Bad
CREATE TABLE users (
  name text,
  email text
);

-- Good
CREATE TABLE users (
  name text NOT NULL,
  email text NOT NULL UNIQUE
);
```

### Rule 2.3: Use Foreign Key Constraints

**Impact:** CRITICAL — Prevents orphaned records and enforces referential integrity.

```sql
CREATE TABLE orders (
  id serial PRIMARY KEY,
  user_id integer NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  total numeric(12,2) NOT NULL
);
```

### Rule 2.4: Use Check Constraints for Domain Validation

**Impact:** HIGH — Enforces data quality at the database level.

```sql
CREATE TABLE products (
  price numeric(12,2) NOT NULL CHECK (price >= 0),
  status text NOT NULL CHECK (status IN ('draft', 'active', 'archived'))
);
```

### Rule 2.5: Normalize to Third Normal Form by Default

**Impact:** HIGH — Denormalize only with measured evidence of read performance need.

---

## 3. Index Strategy (HIGH)

### Rule 3.1: Use Composite Indexes for Multi-Column Queries

**Impact:** HIGH — Column order matters; put equality conditions first.

```sql
-- Query: WHERE status = 'active' AND created_at > '2026-01-01'
-- Good: equality column first
CREATE INDEX idx_orders_status_created ON orders(status, created_at);
```

### Rule 3.2: Use Partial Indexes for Filtered Queries

**Impact:** HIGH — Smaller, faster indexes for common query patterns.

```sql
-- Only index active users (most queries filter by active)
CREATE INDEX idx_users_active_email ON users(email)
WHERE active = true;
```

### Rule 3.3: Use Covering Indexes for Index-Only Scans

**Impact:** HIGH — Include columns to avoid heap lookups.

```sql
CREATE INDEX idx_orders_user_total ON orders(user_id) INCLUDE (total, created_at);
```

### Rule 3.4: Avoid Over-Indexing

**Impact:** MEDIUM — Each index slows writes and uses storage.

**Guideline:** Maximum 5-7 indexes per table. Profile write performance if exceeding this.

### Rule 3.5: Use GIN Indexes for JSONB and Full-Text Search

**Impact:** HIGH — Required for efficient JSONB containment and text search queries.

```sql
CREATE INDEX idx_products_metadata ON products USING gin(metadata);
CREATE INDEX idx_articles_search ON articles USING gin(to_tsvector('english', title || ' ' || body));
```

---

## 4. Migration Safety (HIGH)

### Rule 4.1: Never Add NOT NULL Without a Default in Production

**Impact:** HIGH — Requires full table rewrite; locks the table.

```sql
-- Bad: locks table, may timeout
ALTER TABLE users ADD COLUMN verified boolean NOT NULL;

-- Good: add with default, no lock
ALTER TABLE users ADD COLUMN verified boolean NOT NULL DEFAULT false;
```

### Rule 4.2: Create Indexes Concurrently

**Impact:** HIGH — Standard CREATE INDEX locks the table for writes.

```sql
-- Bad: blocks writes
CREATE INDEX idx_users_email ON users(email);

-- Good: non-blocking
CREATE INDEX CONCURRENTLY idx_users_email ON users(email);
```

### Rule 4.3: Use Multi-Step Migrations for Column Renames

**Impact:** HIGH — Direct rename breaks running application code.

1. Add new column
2. Backfill data
3. Update application to write to both columns
4. Update application to read from new column
5. Drop old column

### Rule 4.4: Always Include a Rollback Plan

**Impact:** HIGH — Migrations should be reversible.

```sql
-- Up
ALTER TABLE users ADD COLUMN display_name text;

-- Down
ALTER TABLE users DROP COLUMN display_name;
```

### Rule 4.5: Test Migrations Against Production-Size Data

**Impact:** HIGH — A migration that takes 1 second on dev may take 1 hour on production.

---

## 5. Connection Management (MEDIUM)

### Rule 5.1: Use Connection Pooling

**Impact:** MEDIUM — PostgreSQL forks a process per connection; unbounded connections crash the server.

Use PgBouncer, Supabase Pooler, or application-level pooling. Target: max 20-50 connections for most applications.

### Rule 5.2: Set Statement Timeouts

**Impact:** MEDIUM — Runaway queries can lock tables and exhaust connections.

```sql
SET statement_timeout = '30s';
```

### Rule 5.3: Keep Transactions Short

**Impact:** MEDIUM — Long transactions hold locks and prevent vacuum.

```sql
-- Bad: transaction open for minutes during external API call
BEGIN;
  SELECT * FROM orders WHERE id = 1 FOR UPDATE;
  -- ... call external API ...
  UPDATE orders SET status = 'shipped' WHERE id = 1;
COMMIT;

-- Good: fetch data, call API, then short transaction
SELECT * FROM orders WHERE id = 1;
-- ... call external API ...
BEGIN;
  UPDATE orders SET status = 'shipped' WHERE id = 1 WHERE status = 'processing';
COMMIT;
```

### Rule 5.4: Use Read Replicas for Read-Heavy Workloads

**Impact:** MEDIUM — Offload reporting and analytics to replicas.

### Rule 5.5: Monitor Connection Usage

**Impact:** MEDIUM — Track active connections to detect leaks.

```sql
SELECT count(*) FROM pg_stat_activity WHERE state = 'active';
```

---

## 6. Security (MEDIUM)

### Rule 6.1: Always Use Parameterized Queries

**Impact:** CRITICAL (security) — Prevents SQL injection.

```sql
-- Bad: string interpolation
query(`SELECT * FROM users WHERE email = '${email}'`);

-- Good: parameterized
query('SELECT * FROM users WHERE email = $1', [email]);
```

### Rule 6.2: Implement Row-Level Security (RLS)

**Impact:** HIGH (security) — Enforces access control at the database level.

```sql
ALTER TABLE documents ENABLE ROW LEVEL SECURITY;

CREATE POLICY documents_owner ON documents
  FOR ALL
  USING (owner_id = current_setting('app.user_id')::int);
```

### Rule 6.3: Use Least-Privilege Database Roles

**Impact:** MEDIUM — Application should not connect as superuser.

```sql
CREATE ROLE app_user WITH LOGIN PASSWORD '...' NOSUPERUSER NOCREATEDB;
GRANT SELECT, INSERT, UPDATE ON ALL TABLES IN SCHEMA public TO app_user;
```

### Rule 6.4: Audit Sensitive Operations

**Impact:** MEDIUM — Log access to PII, financial data, and admin actions.

### Rule 6.5: Never Store Secrets in the Database Unencrypted

**Impact:** HIGH (security) — Use `pgcrypto` or application-level encryption for sensitive data.

---

## 7. Advanced Patterns (LOW)

### Rule 7.1: Use Table Partitioning for Large Tables

**Impact:** LOW (until needed) — Partition by time range for tables exceeding ~100M rows.

```sql
CREATE TABLE events (
  id bigserial,
  created_at timestamptz NOT NULL,
  data jsonb
) PARTITION BY RANGE (created_at);

CREATE TABLE events_2026_q1 PARTITION OF events
  FOR VALUES FROM ('2026-01-01') TO ('2026-04-01');
```

### Rule 7.2: Use Materialized Views for Expensive Aggregations

**Impact:** LOW — Pre-compute expensive queries that can tolerate staleness.

```sql
CREATE MATERIALIZED VIEW monthly_stats AS
  SELECT date_trunc('month', created_at) AS month, count(*), sum(amount)
  FROM orders GROUP BY 1;

-- Refresh periodically
REFRESH MATERIALIZED VIEW CONCURRENTLY monthly_stats;
```

### Rule 7.3: Use LISTEN/NOTIFY for Real-Time Updates

**Impact:** LOW — Lightweight pub/sub without external message brokers.

### Rule 7.4: Use pg_stat_statements for Query Performance Analysis

**Impact:** LOW — Essential for identifying slow queries in production.

```sql
CREATE EXTENSION IF NOT EXISTS pg_stat_statements;
SELECT query, calls, mean_exec_time, total_exec_time
FROM pg_stat_statements ORDER BY total_exec_time DESC LIMIT 20;
```

### Rule 7.5: Use Advisory Locks for Application-Level Coordination

**Impact:** LOW — Lightweight distributed locking without table locks.

```sql
SELECT pg_advisory_lock(hashtext('process-batch-42'));
-- ... do exclusive work ...
SELECT pg_advisory_unlock(hashtext('process-batch-42'));
```
