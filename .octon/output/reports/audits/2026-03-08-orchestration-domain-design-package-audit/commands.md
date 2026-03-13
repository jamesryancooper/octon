# Commands

Representative commands used to gather evidence:

```bash
rg --files .design-packages/orchestration-domain-design-package
sed -n '1,220p' .design-packages/orchestration-domain-design-package/README.md
sed -n '1,220p' .design-packages/orchestration-domain-design-package/implementation-readiness.md
sed -n '1,260p' .design-packages/orchestration-domain-design-package/assurance-and-acceptance-matrix.md
sed -n '1,260p' .design-packages/orchestration-domain-design-package/normative-dependencies-and-source-of-truth-map.md
sed -n '1,260p' .design-packages/orchestration-domain-design-package/canonicalization-target-map.md
sed -n '1,260p' .design-packages/orchestration-domain-design-package/lifecycle-and-state-machine-spec.md
sed -n '1,260p' .design-packages/orchestration-domain-design-package/routing-authority-and-execution-control.md
sed -n '1,260p' .design-packages/orchestration-domain-design-package/evidence-observability-and-retention-spec.md
sed -n '1,260p' .design-packages/orchestration-domain-design-package/operator-and-authoring-runbook.md
sed -n '1,260p' .design-packages/orchestration-domain-design-package/contracts/*.md
sed -n '1,220p' .design-packages/orchestration-domain-design-package/surfaces/*.md
sed -n '1,220p' .octon/orchestration/_meta/architecture/specification.md
sed -n '1,220p' .octon/orchestration/practices/workflow-authoring-standards.md
sed -n '1,220p' .octon/orchestration/practices/mission-lifecycle-standards.md
sed -n '1,220p' .octon/orchestration/governance/incidents.md
sed -n '1,240p' .octon/continuity/_meta/architecture/continuity-plane.md
sed -n '1,220p' .octon/continuity/runs/README.md
rg --files .design-packages/orchestration-domain-design-package | rg -v '\.md$'
[ -e .octon/continuity/decisions ] && echo exists || echo missing
find .design-packages/orchestration-domain-design-package -type f | wc -l
```
