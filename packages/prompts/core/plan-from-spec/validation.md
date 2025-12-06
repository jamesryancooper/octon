# Validation Checklist for Plan-from-Spec Output

## Automated Checks

### Schema Validation
- [ ] Output is valid JSON
- [ ] All required fields present
- [ ] Step numbers are sequential starting from 1
- [ ] Dependencies reference valid step numbers
- [ ] No circular dependencies in step graph

### Consistency Checks
- [ ] All files mentioned in architecture appear in step files
- [ ] All new files have a "create" step
- [ ] Modified files appear in at least one step
- [ ] Test plan files appear in test steps

### Tier Compliance
- [ ] T1: Maximum 3 steps
- [ ] T2: Maximum 8 steps
- [ ] T3: Has human_required checkpoints for security-critical steps

### Dependency Validation
- [ ] Dependencies form a valid DAG
- [ ] Scaffold steps have no dependencies on implement steps
- [ ] Test steps depend on relevant implement steps
- [ ] No step depends on itself

## Red Flags

### Scope Creep
- [ ] Plan includes files not mentioned in spec
- [ ] Step count seems excessive for tier
- [ ] Architecture changes beyond spec scope

### Missing Coverage
- [ ] Spec requirements not covered by any step
- [ ] Test plan doesn't cover acceptance criteria
- [ ] Missing observability for changed paths

### Ordering Issues
- [ ] Implementation before types/interfaces
- [ ] Tests before implementation they test
- [ ] Config changes before feature implementation

## Human Spot-Check Guide

### Quick Checks (All Tiers)
- Does the step sequence make sense?
- Can each step be verified independently?
- Is rollback clear for each step?

### T3 Additional Checks
- [ ] Human checkpoints at appropriate risk boundaries
- [ ] Security-critical code has checkpoint before implementation
- [ ] Data migration steps have explicit human approval

