# Rollback Plan

Rollback removes the new pre-integration gate validators and workflow
references, then reruns proposal lifecycle validation. Existing conformance and
drift/churn validators must remain in place.
