---
title: Safety
description: Safety constraints for audit-freshness-and-supersession.
---

# Safety

- Read-only audit behavior; do not rewrite artifact metadata.
- Writes limited to designated report and log paths.
- Never delete or archive files during audit execution.
- Use deterministic age/anchor checks; avoid subjective freshness judgments.
- Escalate when authority for current-state artifacts is ambiguous.
