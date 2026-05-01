# Source Context

## User Goal

Automate the current manual proposal packet lifecycle for creation,
explanation, implementation prompt generation, verification prompt generation,
correction prompt generation, and full closeout.

## Approved Automation Direction

The user accepted the "Proposal Packet Lifecycle Automation" direction and then
requested that the proposal packet be scoped to the "whole universe" rather
than a narrow MVP.

## Manual Prompt Set Inputs

The manual prompt set supplied by the user contains these prompt classes:

1. audit-aligned proposal packet creation,
2. concise proposal packet creation,
3. architecture evaluation proposal packet creation,
4. highest-leverage next-step proposal packet creation,
5. proposal packet closeout,
6. executable implementation prompt generation,
7. evaluation prompt update after architecture changes,
8. proposal packet explanation,
9. follow-up verification prompt creation.

## Normalized Source Requirements

- Preserve full source context and evaluation/audit lineage inside packet resources.
- Generate complete Octon-aligned proposal packets, not generic memos.
- Ground every packet in live repository state.
- Respect proposal standards, manifests, templates, validators, and registry rules.
- Map every audit or verification finding to remediation and closure criteria.
- Support atomic clean-break implementation where the selected packet requires it.
- Generate packet-specific implementation prompts.
- Generate packet-specific follow-up verification prompts.
- Generate targeted correction prompts for unresolved findings.
- Repeat verification and correction until clean or explicitly deferred.
- Generate custom closeout prompts aligned to the completed implementation.
- Perform full closeout including archival, housekeeping, staging, commit, PR,
  CI remediation, review conversation resolution, merge, branch cleanup, and sync.
- Keep prompts and generated artifacts non-authoritative.

## Source Interpretation

The manual prompts are guidance, not authority. They reveal the desired
lifecycle and quality bar, but the automation must derive exact current
repository rules from live Octon proposal standards, extension pack contracts,
validators, and generated publication surfaces.
