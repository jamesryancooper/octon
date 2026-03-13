# `.env.local.example` Convention

This file documents every environment variable required by `Settings` in
`config/settings.py`, with sensible defaults for local development against
docker-compose services.

## Format

```
KEY=value
```

One variable per line, no quotes, no comments inline. The file should be
directly copyable: `cp .env.local.example .env.local`.

## Standard Variables

```env
APP_ENV=local
```

## Infrastructure Variables (include based on declared dependencies)

### postgres
```env
POSTGRES_DSN=postgresql://postgres:postgres@localhost:5432/{{DB_NAME}}
```

### nats
```env
NATS_URL=nats://localhost:4222
```

### redis
```env
REDIS_URL=redis://localhost:6379/0
```

### temporal
```env
TEMPORAL_HOSTPORT=localhost:7233
```

### s3 / minio
```env
S3_ENDPOINT=http://localhost:9000
S3_ACCESS_KEY=minioadmin
S3_SECRET_KEY=minioadmin
S3_BUCKET={{PACKAGE_NAME}}-artifacts
```

## Rules

1. Every `Field(alias="...")` in Settings must have a line here.
2. Use docker-compose local defaults (matches `docker-compose.local.yml`).
3. Never commit real credentials — this file is a template.
4. The `.gitignore` should exclude `.env.*` but include `!.env.local.example`.
