# Glossary Reference

**Required when capability:** `domain-specialized`

## Core Terms

| Term | Definition | Example |
|------|------------|---------|
| cardinality estimate | Planner estimate of row counts | Impacts join strategy |
| sequential scan | Full table scan strategy | Chosen when index is non-selective |
| index-only scan | Query satisfied using index without table fetch | Reduced IO for covered queries |
| transaction isolation | Visibility guarantees between concurrent transactions | Read committed vs serializable |
| autovacuum | Background maintenance daemon in Postgres | Automatic cleanup and stats updates |
