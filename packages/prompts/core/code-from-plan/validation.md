# Validation Checklist for Code-from-Plan Output

## Automated Checks

### Syntax Validation
- [ ] All TypeScript/JavaScript files parse without syntax errors
- [ ] JSON files are valid JSON
- [ ] YAML files are valid YAML

### Import Validation (Critical)
- [ ] All imports reference existing files or packages
- [ ] No imports from hallucinated modules
- [ ] Import paths match codebase conventions (@harmony/, relative, etc.)
- [ ] No circular imports created

### Type Validation
- [ ] No `any` types without explicit justification
- [ ] All function parameters have types
- [ ] Return types are explicit for exported functions
- [ ] Generic types have constraints where appropriate

### Pattern Compliance
- [ ] Follows detected architecture pattern (hexagonal, etc.)
- [ ] Matches naming conventions from codebase
- [ ] Uses existing utility functions rather than reimplementing
- [ ] Error handling matches codebase patterns

### Safety Checks
- [ ] No hardcoded secrets or API keys
- [ ] No console.log statements (use structured logging)
- [ ] No synchronous file operations
- [ ] Feature flag check present if specified in plan

## Red Flags (Triggers Review)

### Hallucination Indicators
- [ ] Imports from packages not in package.json
- [ ] Calls to functions not defined in codebase or this step
- [ ] References to types that don't exist
- [ ] File paths that don't match project structure

### Scope Creep
- [ ] Files modified that aren't in step.files
- [ ] Functionality beyond step description
- [ ] Refactoring unrelated code

### Missing Requirements
- [ ] Success criteria not achievable with generated code
- [ ] Missing error handling for obvious failure modes
- [ ] Missing tests for test-type steps

## Human Spot-Check Guide

### Quick Checks
- Does the code do what the step says?
- Are there any obvious bugs or logic errors?
- Does the code style match the rest of the codebase?

### Security-Sensitive Steps
- [ ] Auth checks in correct places
- [ ] Input validation present
- [ ] No sensitive data in logs
- [ ] Rate limiting where expected

