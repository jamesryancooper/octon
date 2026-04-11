# Conformance Card

| Dimension | Selected posture |
| --- | --- |
| proposal id | `host-tool-provisioning-and-multi-repo-portability` |
| proposal kind | `architecture` |
| architecture scope | `repo-architecture` |
| decision type | `new-surface` |
| release state | `pre-1.0` |
| change profile | `atomic` |
| promotion scope | `octon-internal` |
| durable authority posture | repo-local `/.octon/**` only |
| actual install posture | host-scoped outside repo |
| bootstrap posture | `/init` remains repo-only |
| consumer proof point | `repo-hygiene` |
| multi-repo posture | shared host cache, independent repo desired state |
| residual caveat | host-scoped state is runtime truth, not proposal promotion target |
