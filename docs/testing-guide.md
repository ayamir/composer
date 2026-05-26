# Testing Guide

This file explains how agents and humans should test this repository.

Keep commands up to date.

---

## 1. Test Commands

Update these commands for your project.

```bash
# Unit tests
go test ./...

# Focused Go test
go test ./path/to/pkg -run TestName -count=1

# Rust tests
cargo test --workspace

# Python tests
pytest

# Integration tests
make integration-test
```

---

## 2. Testing Strategy

For behavior changes:

1. Update `.agent/test-matrix.md`.
2. Prefer TDD.
3. Add a failing test first when practical.
4. Implement the minimal fix.
5. Run focused tests.
6. Run broader relevant tests.
7. Update `.agent/verification-report.md`.

---

## 3. What Counts as Evidence

For backend services, evidence should usually include:

- command output
- request payload
- response payload
- database query result
- log excerpt
- trace ID
- metrics snapshot
- generated report file

Do not claim that behavior is verified without evidence.

---

## 4. Integration Test Report Format

A good integration test report should include:

```md
## Scenario

## Preconditions

## Steps

## Expected Result

## Actual Result

## Evidence

## Conclusion

## Not Verified
```

---

## 5. Flaky Tests

If a test is flaky:

1. Record it in `.agent/verification-report.md`.
2. Do not hide the failure.
3. Include logs or error output.
4. Explain whether the flake appears related to the current change.
