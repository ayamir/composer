# Test Matrix

Use this file to design tests before or during implementation.

For behavior-changing tasks, update this before implementation whenever practical.

---

| Case | Input / Setup | Expected Result | Test Type | Status |
|---|---|---|---|---|
| Success path | Run setup in a clean repo with no existing project Claude settings | Installer creates git hooks, merges Claude hooks, and prints next steps | integration | planned |
| Invalid input | Run readiness validator when `.agent/task.md` and `.agent/plan.md` are still template-only but a code edit is attempted | Validator exits non-zero with actionable remediation text | integration | planned |
| Boundary case | Run setup twice | Installer stays idempotent and does not duplicate hook entries | integration | planned |
| Backward compatibility | Existing manual commands like `make agent-status` and `make agent-review` | Existing commands still work unchanged | integration | planned |
| Failure handling | Run stop validation with code diff but missing verification updates | Validator blocks completion and explains missing artifacts | integration | planned |

---

## Notes

<!-- Explain why some cases are not applicable. -->
