# External Evidence Localization

This governed subroute preserves terminal or explicitly inactive operational
evidence outside the repository before exact, separately authorized cleanup.
The platform application-data archive root is selected by
`evidence-localization.yml`; callers cannot provide a destination.

```bash
python3 .octon/framework/assurance/runtime/_ops/scripts/evidence-localization.py prepare-request --draft draft.json --output request.json
python3 .octon/framework/assurance/runtime/_ops/scripts/evidence-localization.py localize --request request.json
python3 .octon/framework/assurance/runtime/_ops/scripts/evidence-localization.py verify --archive-id archive-...
python3 .octon/framework/assurance/runtime/_ops/scripts/evidence-localization.py authorize-cleanup --archive-id archive-... --request request.json --authorization cleanup.json
python3 .octon/framework/assurance/runtime/_ops/scripts/evidence-localization.py cleanup --authorization cleanup.json
python3 .octon/framework/assurance/runtime/_ops/scripts/evidence-localization.py retrieve --archive-id archive-... --output /review/path
```

Localization freezes and verifies an exact inventory without mutating sources.
`prepare-request` compiles the complete tracked source-to-reference map in one
bounded scan; admission recomputes that map and rejects stale or incomplete
requests.
Cleanup is a separate phase and fails on stale fingerprints, expiry, active
state, archive drift, or path-set mismatch. External archives and compact local
receipts are retained evidence only: they are not runtime, proposal, policy,
landing, lifecycle, or effect authority.
