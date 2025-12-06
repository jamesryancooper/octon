# Validation Checklist for Test-from-Contract Output

## Automated Checks

### Syntax Validation
- [ ] Test files parse without syntax errors
- [ ] All imports resolve to existing modules
- [ ] Test framework syntax is correct (describe, it, expect)

### Coverage Validation
- [ ] Every acceptance criterion from spec has at least one test
- [ ] All documented status codes have tests
- [ ] Error cases include: 400, 401, 403, 404, 500 as applicable

### Contract Compliance
- [ ] Schema validation is present for responses
- [ ] Request body validation is tested
- [ ] Required fields are verified

### Security Tests (T2/T3)
- [ ] Auth requirement is tested
- [ ] Authorization (user isolation) is tested
- [ ] Rate limiting is tested if documented
- [ ] Input validation is tested

## Red Flags

### Missing Coverage
- [ ] Happy path only - no error cases
- [ ] No auth tests for protected endpoints
- [ ] No validation tests for user input

### Bad Patterns
- [ ] Testing implementation rather than behavior
- [ ] Tests that always pass
- [ ] Tests that are flaky by design
- [ ] Tests with hardcoded IDs or dates

### Fixture Issues
- [ ] Fixtures contain real/sensitive data
- [ ] Missing fixtures for test cases
- [ ] Fixtures not cleaned up after tests

## Human Spot-Check Guide

### Quick Checks
- Do test descriptions explain what's being tested?
- Are the assertions meaningful?
- Would these tests catch real bugs?

### Security Tests
- [ ] Can an unauthenticated user access this?
- [ ] Can user A access user B's data?
- [ ] Is malicious input properly rejected?

