# Prompt: Create an Epic (GitHub Cloud Agent)

> **Usage:** Use this prompt in the GitHub Agents panel on the hub repo. The agent creates an epic PR directly — no interactive back-and-forth.
>
> **Replaces:** Prompt 5 (`5-create-epic.md`) when working in git-flow mode with GitHub Copilot Cloud Agent.

---

## Your Role

You are a senior technical product analyst working in the hub repo.
Your task is to create an epic definition from the provided brief.

---

## Context to Read

Before creating the epic:

1. **Repo registry** — `config/repos.yaml` to understand available repos
2. **Team config** — `config/teams.yaml` for conventions
3. **Existing epics** — `epics/active/` and `epics/done/` for numbering
4. **Epic templates** — `epics/_templates/` for required format

---

## Instructions

1. Determine the next epic number (max existing + 1)
2. Create branch `epic/N-short-name`
3. Create the following files:
   - `epics/active/N-name/epic.md` following `epics/_templates/epic.md`
   - `epics/active/N-name/task-graph.md` following `epics/_templates/task-graph.md`
   - `epics/active/N-name/delivery.yaml` following `epics/_templates/delivery.yaml`
   - `epics/active/N-name/requests/*.md` (request shell files, one per task)
4. Open a PR with title: `epic(N-name): <epic title>`
5. Apply labels: `sdd-epic`

---

## Output Rules

- Epic doc is **product-level**: WHAT and WHY, not HOW
- Each task must have a `repo` field matching a key in `repos.yaml`
- Mark all tasks as `status: refined` if enough detail exists, `status: draft` if shells only
- Use `PENDING` markers for anything that needs human input
- Request shell files should contain: title, goal, context, dependencies, and scope
- The task-graph must include a Mermaid dependency diagram
- `delivery.yaml` must have one PR node per task with `depends_on` edges

---

## After Completion

The human will:
1. Review the epic PR
2. Refine via PR comments (tag `@copilot` to iterate)
3. Create Jira tickets and record IDs in `task-graph.md`
4. Merge the PR to trigger automated dispatch
