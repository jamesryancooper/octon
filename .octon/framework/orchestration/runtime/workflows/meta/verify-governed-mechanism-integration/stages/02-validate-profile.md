# Validate Profile

Run:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-governed-mechanism-integration-profile.sh --profile "$mechanism_profile_ref"
```

The profile must identify the mechanism, owners, product refs, doctrine or documentation refs, workflows, skills, commands, schemas, validators, generated projections, evidence roots, lifecycle hooks, extension boundaries, authority boundaries, and non-authority boundaries. Any intentionally absent surface must appear in `not_applicable` with a rationale.
