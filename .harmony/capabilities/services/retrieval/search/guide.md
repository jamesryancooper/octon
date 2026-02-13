# Search — External Sources

- **Purpose:** Harvest external web/API sources into clean, LLM‑ready artifacts with provenance, advancing Harmony’s interoperable, governed knowledge flows.
- **Responsibilities:** discovering sources and mapping/crawling URLs; scraping/searching and extracting Markdown/JSON with metadata/links; handling anti‑bot/proxies/dynamic content and custom headers; snapshotting content and change history with provenance; batching large URL sets with retries/backoff.
- **Integrates with:** Plan/Agent (orchestration), Ingest (downstream normalization), Dep (release notes/advisories), Stack (architecture rationales).
- **I/O:** URLs/APIs → `sources/**` snapshots (md/json/html/metadata); handed to Ingest as inputs for `ingest/*.jsonl` builds.
- **Wins:** Citable, LLM‑ready external evidence on demand; removes scraping/anti‑bot complexity from other services.
- **Harmony alignment:** Ensures interoperability and provenance via consistent, reproducible snapshots with citations; exposes hooks so downstream gates can verify evidence.
- **Implementation Choices (opinionated):**
  - FireCrawl: web search/scrape/crawl/map to Markdown/JSON/HTML/screenshots; handles anti‑bot and dynamic content.
  - httpx: call FireCrawl and source APIs with retries/timeouts and HTTP/2.
  - urllib.robotparser (stdlib): robots.txt compliance before fetch/crawl.
  - PyGithub: GitHub releases/tags/advisories when API structure beats page scrape.
- **Common Qs:**
  - *Search vs crawl vs API?* Prefer FireCrawl for web search/scrape/crawl; use source APIs (e.g., GitHub) when structured fields are needed.
  - *Determinism?* Timestamped snapshots + content hashes enable reproducible runs and change tracking.
  - *Rate limits/robots?* Respect robots, per‑source caps, and exponential backoff; batch with concurrency limits.
