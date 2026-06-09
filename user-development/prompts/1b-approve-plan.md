> **🎯 Preferred invocation:** In Zed or Claude Code, describe what you want —
> the `sdd-approve-plan` skill activates automatically. In VS Code, use `/sdd-approve-plan`.
>
> **📋 Fallback:** Copy-paste the content below into any agent conversation.

---

# Prompt: Approve a Plan

> **Usage:** Copy this prompt into a new agent conversation. Point it at the plan to approve. The agent checks for unresolved questions, stamps the approval fields, and commits the change.

---

## Identify the Plan

Determine which plan to approve:

1. **If you mentioned a specific folder** — use that path directly.
2. **If you mentioned a task name or number** — find the matching folder in `agent-development/plans/`.
3. **If unspecified** — list `agent-development/plans/` (exclude `_templates`) and ask which plan to approve.

State which plan you'll approve.

---

## Pre-Approval Checks

Before updating any fields:

1. Read `manifest.yaml` — confirm `plan_metadata.approval.status` is `pending` or `changes-requested`. If already `approved`, ask the human to confirm this is an intentional re-approval.
2. Read `specification.md` — scan the **Open Questions** section for any remaining `PENDING` markers in `Human decision:` fields.
   - **If PENDING markers remain:** STOP. List each unresolved question and ask the human to provide decisions before proceeding.
3. Identify the approver:
   - Check `config/teams.yaml` for a `lead` or `approver` field.
   - If not set, ask: "Approving as whom? (name or GitHub handle)"

---

## Status Updates

Edit `manifest.yaml` — set all four fields:

```yaml
plan_metadata:
  status: approved              # transition from: pending-approval
  approval:
    status: approved            # transition from: pending | changes-requested
    approved_by: "<name>"       # from config or user input
    approved_at: "<YYYY-MM-DD>" # today's date
```

Leave `approval.notes` unchanged (preserve any review comments already there).

**If the plan is part of an epic:** also update `task-graph.md` — set this task's status from `planned` to `approved`.

---

## Commit and Push

1. Stage `manifest.yaml` (and `task-graph.md` if updated)
2. Commit: `plan(approve): set approval.status to approved [<ticket-id>]`
3. Push to the current branch

---

## Confirm

After pushing:

> "Plan `<plan-folder>` approved by `<name>` on `<today>`. Branch `<branch>` is ready for execution — open a **fresh session** on this branch and run `sdd-execute-plan` to begin."
