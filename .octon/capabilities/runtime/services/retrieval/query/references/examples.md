# Query Examples

## Generate local test snapshots

```bash
./impl/make-test-snapshot.sh
```

## Run fixture pack

```bash
./impl/run-fixtures.sh
```

## Run baseline evaluation

```bash
./impl/evaluate-baseline.sh
```

## Run route A/B evaluation (Phase 4)

```bash
./impl/evaluate-routes.sh
```

## Validate adapter contracts

```bash
./impl/validate-adapters.sh
```

## Retrieve (deterministic fixture-friendly path)

```bash
echo '{
  "command": "retrieve",
  "query": "feature flag rollout gates",
  "index": { "snapshot": "indexes/test-snapshot" },
  "strategy": { "use": ["keyword","graph"], "fuse": "rrf", "top_k": 8 }
}' | ./impl/query.sh
```

## Ask (includes semantic scoring)

```bash
echo '{
  "command": "ask",
  "query": "Where are rollout gates defined and what changed in v2?",
  "index": { "snapshot": "indexes/test-snapshot" },
  "strategy": { "use": ["keyword","semantic","graph"], "fuse": "rrf", "top_k": 12 },
  "evidence": { "max_excerpts": 6, "max_chars_per_excerpt": 320 }
}' | ./impl/query.sh
```

## Explain (decision trace)

```bash
echo '{
  "command": "explain",
  "query": "Why did chunk doc:abc#c:00042 rank first?",
  "index": { "snapshot": "indexes/test-snapshot" },
  "strategy": { "use": ["keyword","graph"], "fuse": "weighted", "top_k": 10, "weights": { "keyword": 0.7, "graph": 0.3 } }
}' | ./impl/query.sh
```

## Retrieve with hierarchical route

```bash
echo '{
  "command": "retrieve",
  "query": "governance posture escalation pathways",
  "index": { "snapshot": "indexes/test-snapshot" },
  "strategy": { "use": ["keyword","graph"], "fuse": "rrf", "route": "hierarchical", "top_k": 8 }
}' | ./impl/query.sh
```

## Retrieve with memory clues

```bash
echo '{
  "command": "retrieve",
  "query": "rollout gates migration policy",
  "index": { "snapshot": "indexes/test-snapshot" },
  "strategy": { "use": ["keyword"], "fuse": "rrf", "route": "flat", "top_k": 8 },
  "memory": { "enabled": true, "max_clues": 3 }
}' | ./impl/query.sh
```

Fixture guidance:

- Phase 1 fixtures assert deterministic stages only (`keyword`, `graph`,
  `fusion`, `citation`).
- Semantic quality is evaluated in Phase 3 baselines, not locked to fixture
  score values.
- Fixture files follow `{case}.fixture.json` with `input`, `expected_output`,
  and `metadata`.
