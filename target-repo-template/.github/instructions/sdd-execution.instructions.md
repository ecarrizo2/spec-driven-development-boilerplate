---
applyTo: "src/**,lib/**,test/**"
---

# SDD Execution Instructions

When implementing code from an approved plan:

- Read the plan at `sdd/plans/<task>/specification.md` FIRST
- Follow stage instructions in order (1-stage.md, 2-stage.md, ...)
- Only modify files listed in the stage's blast_radius.write
- Commit after each logical unit with conventional commit format
- Run verification after each stage: lint, typecheck, test
- If tests fail: fix (max 2 attempts) or stop and request help via PR comment
- Never skip verification steps
