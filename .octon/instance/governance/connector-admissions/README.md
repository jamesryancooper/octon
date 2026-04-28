# Connector Admissions

Machine-readable connector admissions live under:

`/.octon/instance/governance/connector-admissions/<connector-id>/<operation-id>/admission.yml`

Admissions are authored instance governance. In the current v4 MVP,
stage-only and observe-only admission can be recorded for planning and posture
checks. Live effectful connector admission is blocked until support posture,
capability mapping, egress, credential posture, rollback/compensation,
evidence, Decision Request, authorization, and effect-token requirements are
satisfied.

This README is explanatory only; it is not an admission record.
