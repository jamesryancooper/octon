# Operator Boot Simplification Plan

## Objective

Make Octon's boot/orientation path concise, canonical, and separable from
closeout, branch workflow, and compatibility mechanics.

## Current posture

Ingress and bootstrap are real architectural anchors. However, the ingress
manifest carries mandatory reads, optional orientation, adapter parity, branch
closeout, merge-lane, suppressed context, and deprecated fallback prompt concerns.
This is useful but too broad for a target-state boot surface.

## Target division

| Surface | Target responsibility |
| --- | --- |
| `/.octon/AGENTS.md` | Projected root ingress adapter. |
| `/.octon/instance/ingress/AGENTS.md` | Canonical internal agent ingress posture and mandatory read stance. |
| `/.octon/instance/ingress/manifest.yml` | Mandatory reads, optional orientation overlays, adapter parity targets. |
| `/.octon/instance/bootstrap/START.md` | Human/agent first-run boot sequence. |
| `/.octon/framework/orchestration/runtime/workflows/meta/closeout/**` | Branch closeout, merge-lane, and closure workflow rules. |
| `/.octon/instance/governance/retirement-register.yml` | Deprecated fallback prompt and compatibility shim retirement. |

## Target first-run path

```text
read .octon/README.md
read .octon/AGENTS.md
read .octon/instance/ingress/AGENTS.md
read .octon/instance/bootstrap/START.md
run octon doctor --architecture
run read-only orientation or first run contract
```

## Validator expectations

`validate-operator-boot-surface.sh` must fail when:

- ingress manifest contains branch closeout policy inline instead of refs;
- deprecated fallback prompt lacks retirement entry;
- mandatory reads point to proposal-local paths;
- generated read models appear in mandatory reads as authority;
- closeout workflow bypasses run-first lifecycle or authorization coverage.

## Acceptance

A new agent or human operator can understand the boot path without reading the
entire structural registry, and a closeout workflow can be validated separately
from orientation.
