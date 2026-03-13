# Commands

All commands were executed from:
`/Users/jamesryancooper/Projects/octon`

## 01) Agency Contract Validation

```bash
bash .octon/agency/_ops/scripts/validate/validate-agency.sh
```

Result: PASS (`errors=0 warnings=0`)

## 02) Workflow Contract Validation

```bash
bash .octon/orchestration/runtime/workflows/_ops/scripts/validate-workflows.sh
```

Result: PASS (`errors=0 warnings=0`)

## 03) Skill Contract Validation (Strict)

```bash
bash .octon/capabilities/runtime/skills/_ops/scripts/validate-skills.sh --strict
```

Result: PASS (`All checks passed!`)

## 04) Harness Structure Validation

```bash
bash .octon/assurance/runtime/_ops/scripts/validate-harness-structure.sh
```

Result: PASS (`errors=0 warnings=0`)

## 05) Alignment Validation (Harness + Agency + Workflows + Skills)

```bash
bash .octon/assurance/runtime/_ops/scripts/alignment-check.sh --profile harness,agency,workflows,skills
```

Result: PASS (`Alignment check summary: errors=0`)

## 06) Runtime Artifact Sync (Required by Harness Validator)

```bash
bash .octon/cognition/_ops/runtime/scripts/sync-runtime-artifacts.sh
```

Result: PASS (updated generated runtime artifacts and removed drift)
