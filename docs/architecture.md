# Architecture Notes

Use this file to describe the architecture of the project for humans and agents.

Keep it concise and current. Agents should read this before making cross-module or cross-service changes.

---

## 1. System Overview

Describe what the system does.

Example:

```text
This service receives requests from ..., validates ..., persists ..., and calls ...
```

---

## 2. Major Modules

| Module | Responsibility | Key Files |
|---|---|---|
| API layer | HTTP/gRPC handlers, request validation | |
| Service layer | Business orchestration | |
| Repository layer | Database access | |
| Integration layer | External service clients | |
| Config | Runtime configuration | |

---

## 3. Request Flow

Describe the main request flow.

```text
Client -> API Handler -> Service -> Repository -> Database
                         -> External Client
```

---

## 4. Important Invariants

List invariants agents must not break.

Examples:

- Public API response format must remain backward compatible.
- Request ID must be propagated through logs and downstream calls.
- Database writes must be idempotent for retryable operations.
- Authorization must happen before business mutation.

---

## 5. Risk Areas

List areas where agent changes need extra care.

Examples:

- concurrency
- cache invalidation
- retries and idempotency
- transaction boundaries
- permission checks
- schema compatibility
- external API compatibility
