# Domain Glossary

Use this file to store business and domain knowledge.

Do not overload `AGENTS.md` or `CLAUDE.md` with large amounts of domain knowledge. Agents should read this file when they touch business rules.

---

## Terms

| Term | Meaning | Notes |
|---|---|---|
| ExampleEntity | Describe the business entity | Add lifecycle or invariants |
| ExampleStatus | Describe the status | Add allowed transitions |
| ExamplePolicy | Describe the policy | Add edge cases |

---

## State Machines

Document important state transitions.

Example:

```text
Created -> Pending -> Completed
Created -> Cancelled
Pending -> Failed
```

Invalid transitions:

```text
Completed -> Pending
Cancelled -> Completed
```

---

## Business Rules

Add rules that must be preserved.

Examples:

1. Duplicate requests with the same idempotency key must return the original result.
2. Permission checks must happen before mutation.
3. Retryable failures should not create duplicate records.
4. Historical data must remain readable after code changes.

---

## External Dependencies

| Dependency | Purpose | Failure Behavior |
|---|---|---|
| ExampleService | Used for ... | Timeout should ... |
