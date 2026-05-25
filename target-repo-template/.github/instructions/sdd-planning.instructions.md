---
applyTo: "sdd/plans/**"
---

# SDD Plan File Instructions

When working with plan files:

- Plans contain ONLY documentation (markdown, yaml). Never add source code.
- `manifest.yaml` must follow the schema: plan_metadata.status, stages[], etc.
- `specification.md` must use PENDING markers for unresolved questions
- Stage files must include: blast radius, verification commands, commit plan table
- Set plan_metadata.status to "pending-approval" when complete
