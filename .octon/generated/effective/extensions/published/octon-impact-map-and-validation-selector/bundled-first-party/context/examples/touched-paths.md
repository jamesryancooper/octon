# Example: Touched Paths

Input:

```text
/octon-impact-map-and-validation-selector \
  --validation-depth minimal \
  --strictness credible-minimum \
  README.md,.octon/instance/ingress/AGENTS.md
```

Expected route:

- `touched-paths`

Expected result shape:

- authoritative-doc trigger coverage is included in the selected validation set
- the next step remains explicit and canonical
