# V4 Architecture Evaluation

## Selected highest-leverage step

The selected step is **Connector Admission Runtime + Connector Trust Dossier**.

## Why this is highest leverage

A fully realized v4 depends on safe interaction with external systems. Portfolios, releases, cross-repo work, campaign rollups, browser/API/MCP tooling, and organizational workflows all require connector operations. Without a connector admission layer, every later v4 capability either remains passive coordination or risks bypassing Octon's governance model.

Connector admission is the narrowest step that unlocks multiple future v4 paths while strengthening, rather than weakening, existing controls.

## Why not Stewardship Portfolio first

A portfolio can coordinate multiple programs, but without safe connector/external-operation admission it remains mostly a reporting layer. It would not solve the core v4 risk: external operations becoming shortcuts around support, policy, authorization, and evidence.

## Why not Release Envelope first

Release governance is important, but release systems are connectors to environments, CI/CD providers, hosting services, and external infrastructure. A release envelope should be built on top of connector admission, not before it.

## Why not Campaign Promotion Runtime first

The repo currently states campaigns are no-go/deferred without live multi-mission coordination pressure. A v4 campaign runtime should wait until real portfolio or multi-program pressure appears.

## Why not Cross-Repo Engagement first

Cross-repo work requires per-repo authority, profiles, work packages, rollback/compensation, and often connector operations through GitHub/CI/service APIs. Connector admission is a prerequisite.

## Why the abstraction is correct

The connector-operation abstraction is narrow enough to reason about:
- one operation;
- one side-effect class;
- one capability mapping;
- one support posture;
- one policy path;
- one authorization/evidence trail.

This prevents broad trust-by-connection and keeps external work inside Octon's runtime boundary.

## Product benefit

Operators get a simple posture view:
- observe-only;
- read-only;
- stage-only;
- live-effectful;
- quarantined;
- retired;
- denied.

They do not need to understand every support-target proof detail, but those details remain canonical and inspectable.

## Governance benefit

The model preserves:
- support-target finite admissions;
- material-effect authorization;
- generated no-widening;
- retained evidence;
- rollback/compensation;
- human Decision Requests for high-risk operations.
