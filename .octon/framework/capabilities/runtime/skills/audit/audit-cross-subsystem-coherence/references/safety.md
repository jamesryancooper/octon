---
title: Safety
description: Safety constraints for audit-cross-subsystem-coherence.
---

# Safety

- Read-only audit behavior; never modify source contracts.
- Writes limited to designated report and log paths.
- Do not auto-remediate conflicts; report evidence only.
- Fail closed on missing scope roots or unreadable contract files.
- Escalate when findings imply irreversible architectural changes.
