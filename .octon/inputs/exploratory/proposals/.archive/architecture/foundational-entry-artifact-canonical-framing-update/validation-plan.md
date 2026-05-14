# Validation Plan

_Status: In-review proposal packet artifact_


| Validation | Purpose | Existing/proposed command |
|---|---|---|
| Repository path inspection validation | Confirm inspected files/paths and absent items | Manual inspection record + future `validate-entry-framing-inspection.sh` |
| Proposal standard validation | Validate proposal layout and manifest fields | `/.octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh` |
| Architecture proposal validation | Validate architecture subtype requirements | `validate-architecture-proposal-standard.sh` if present, else proposed |
| Packet manifest completeness | Ensure all required files exist | `PACKET_MANIFEST.md` self-audit |
| SHA256 verification | Verify files match checksum list | `sha256sum -c SHA256SUMS.txt` |
| Markdown link validation | Ensure local links resolve | proposed `validate-markdown-links.sh` |
| Scope discipline validation | Ensure no runtime schemas/behavior are implemented | proposed `validate-framing-packet-scope.sh` |
| Non-goal enforcement | Check later packet items are signposts only | proposed `validate-non-goals.sh` |
| Authority/control/evidence placement | Ensure no authority placed in proposal/generated/input/external systems | architecture conformance validator |
| Generated/input non-authority | Ensure generated/input surfaces are not promoted as control/evidence | proposed non-authority validator |
| Wording/terminology validation | Prefer canonical terms, constrain compatibility terms | proposed `validate-foundational-framing-terms.sh` |
| README framing validation | Check README introduces governed workflow runtime | proposed `validate-readme-framing.sh` |
| AGENTS framing validation | Check agents as bounded activities, parity preserved | proposed `validate-agents-framing.sh` |
| Future-capability overclaim validation | Ensure follow-on packets are future work only | proposed `validate-future-capability-overclaims.sh` |
| Durable Object non-authority | Ensure Durable Objects are only future live coordination adapters | proposed `validate-durable-coordination-non-authority.sh` |
| MCP/tool non-permission | Ensure tools/connectors are not permission | proposed `validate-connector-tool-non-permission.sh` |
| External workflow non-authority | Ensure external engines are not authority | proposed `validate-external-workflow-non-authority.sh` |
| Acceptance checklist | Confirm packet completion | `acceptance-criteria.md` checklist |
