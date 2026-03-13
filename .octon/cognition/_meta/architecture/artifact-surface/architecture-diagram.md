# Artifact Surface Architecture Diagram

## Foundational Context

The Artifact Surface (HAS) is the canonical architecture for Octon's
foundational Artifact Plane. This diagram shows how it relates to the other
foundational planes:

```mermaid
flowchart TB
  subgraph Foundational["Octon Canonical Foundational Plane Model"]
    direction LR

    IN["Ingress Plane\n(commands)"]
    ORCH["Orchestration Plane\n(workflows)"]
    CAP["Capability Plane\n(skills)"]
    SVC["Service Plane\n(typed runtime interfaces)"]
    KRN["Execution Kernel Plane\n(engine runtime/run)"]
    ART["Artifact Plane\n(HAS + output evidence)"]
    ASN["Assurance Plane\n(gates + validation)"]
    CNT["Continuity Plane\n(active operational state)"]
    KNO["Knowledge Plane\n(durable context/decisions/evidence indexes)"]
  end

  IN --> ORCH --> CAP --> SVC --> KRN
  ORCH --> ART
  KRN --> ART
  ORCH --> CNT
  KRN --> CNT
  ART --> ASN
  KRN --> ASN
  ASN --> KNO
  CNT <--> KNO
  ART --> KNO
```

See [Foundational Planes Integration](../../../../continuity/_meta/architecture/three-planes-integration.md) for complete cross-plane architecture.

---

## Core Architecture (Build-Time)

```mermaid
flowchart TB
  subgraph Source["Source Layer (git-tracked)"]
    A1["content/** (public/internal/agent)"]
    A2[".octon/continuity/** (continuity artifacts)"]
    A3["assets/** (static assets)"]
    A4["content/_schemas/** (Zod schemas + migrations)"]
    A5["content/_meta/** (governance + taxonomy + locales)"]
  end

  subgraph Compiler["Compiler Layer (HAS CLI)"]
    B1["Discover + Parse"]
    B2["Validate (schemas + lifecycles)"]
    B3["Resolve refs + build graph"]
    B4["Normalize → IR"]
    B5["Index (SQLite + JSON + FTS + graph)"]
    B6["Render exports (web/app/email/agent packs)"]
  end

  subgraph Delivery["Delivery Layer (consumers)"]
    C1["Framework builds: Astro/Next/etc import JSON or query SQLite"]
    C2["Thin read-only API (optional) reads SQLite"]
    C3["Static search index (Pagefind)"]
    C4["Agent context packs / RAG bundles"]
  end

  A1 --> B1 --> B2 --> B3 --> B4 --> B5 --> B6
  A2 --> B1
  A3 --> B6
  A4 --> B2
  A5 --> B2
  B5 --> C1
  B5 --> C2
  B5 --> C4
  B6 --> C1
  B6 --> C3
```

## Extended Architecture (With Runtime Layer)

When boundary conditions are crossed (see [boundary-conditions.md](./boundary-conditions.md)), the architecture extends to include runtime layers:

```mermaid
flowchart TB
  subgraph Canonical["Canonical Layer (git)"]
    G1["content/** (canonical content)"]
    G2[".octon/continuity/** (continuity artifacts)"]
  end

  subgraph Compiled["Compiled Layer (HAG)"]
    H1[".octon/content/content.sqlite"]
    H2[".octon/content/content.json"]
    H3[".octon/content/graph.json"]
  end

  subgraph RuntimeRead["Runtime Read Layer (edge)"]
    R1["SQLite replica (Turso/D1/LiteFS)"]
    R2["CDN-cached JSON"]
    R3["Thin read-only API"]
  end

  subgraph RuntimeWrite["Runtime Write Layer (optional)"]
    W1["Server DB (Postgres/Supabase)"]
    W2["Live overrides / personalization"]
    W3["Real-time subscriptions"]
  end

  subgraph Consumers["Consumers"]
    C1["Web (SSG/SSR)"]
    C2["Mobile / App"]
    C3["Agents"]
    C4["Internal tools"]
  end

  G1 --> |"HAS build"| H1
  G2 --> |"HAS build"| H1
  H1 --> |"deploy/replicate"| R1
  H2 --> |"deploy"| R2

  R1 --> R3
  R3 --> C1
  R3 --> C2
  R3 --> C3
  R2 --> C1

  W1 --> |"overlay"| R3
  W2 --> W1
  W3 --> W1

  W1 --> |"sync-back (PR)"| G1
```

## Tiered Storage Model

```mermaid
flowchart LR
  subgraph Tier0["Tier 0: Build-Only"]
    T0["Git + HAG artifacts"]
  end

  subgraph Tier1["Tier 1: Edge Read"]
    T1["SQLite (Turso/D1/LiteFS)"]
  end

  subgraph Tier2["Tier 2: Central Read"]
    T2["Server DB (read replicas)"]
  end

  subgraph Tier3["Tier 3: Write"]
    T3["Server DB (primary)"]
  end

  T0 --> |"need global reads"| T1
  T1 --> |"need complex queries"| T2
  T2 --> |"need writes"| T3
  T3 --> |"sync-back"| T0
```

## Content Type Classification

```mermaid
flowchart TB
  subgraph ContentTypes["Content Classification"]
    direction TB

    subgraph Canonical["Canonical Content (content/)"]
      CC1["Entities: products, pricing, features"]
      CC2["Prose: docs, blog, ADRs"]
      CC3["Compositions: pages, emails, packs"]
    end

    subgraph Continuity["Continuity Plane Artifacts (.octon/continuity/)"]
      CA1["Tasks (tasks.json)"]
      CA2["Entities (entities.json)"]
      CA3["Next actions (next.md)"]
      CA4["Log (append-first)"]
      CA5["Run evidence (runs/)"]
      CA6["See: Continuity Plane docs"]
    end

    subgraph Runtime["Runtime Artifacts (optional)"]
      RC1["Live overrides"]
      RC2["Personalization data"]
      RC3["Session state"]
      RC4["A/B test variants"]
    end
  end
```
