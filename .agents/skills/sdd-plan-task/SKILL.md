---
name: sdd-plan-task
description: Create an implementation plan from an activated task request in this hub — produces a plan folder with manifest.yaml, specification.md, and stage instruction files ready for human approval.
---

## Identify the Task Request

Determine which task request to plan:

1. **If you mentioned a specific file** (e.g., "plan `agent-development/requests/3-migrate-prompts-to-skills.md`") — use that path directly.
2. **If you mentioned a task name or number** — find the matching file in `agent-development/requests/`.
3. **If unspecified** — run `bin/dev wf:next` to find the next actionable task, or list `agent-development/requests/` and ask which task to plan.

State which request you'll plan.

---

## Context to Read

1. **Agent specs** — all files in `agent-development/agent-specs/`
2. **Team config** — `config/teams.yaml`
3. **The task request** — the file specified above (including YAML frontmatter)
4. **Plan templates** — `agent-development/plans/_templates/manifest.yaml`, `specification.md`, `stage.md`
5. **Structural planning principles** — `common-specs/structural-planning-principles.md`
6. **Planning examples** — `agent-development/plans/_templates/EXAMPLES.md` (before/after transformations)
7. **Status reference** — `user-development/STATUS-REFERENCE.md`
8. **Relevant source code** — files/modules implied by the request's Implementation Details
9. **If part of an epic:** the epic's `epic.md`, `task-graph.md`, and `delivery.yaml`
10. **Past metrics (if available):** check `metrics/thunders/cycles/` for patterns from previous epics

---

## Context Freshness Check

Before producing the plan, verify that the architecture docs you're relying on are current:

1. **Identify referenced docs** — which files in `agent-specs/` or `documentation/<repo>/` describe the area you're about to modify?
2. **Check last-modified dates** — run `git log -1 --format="%ci" -- <doc-path>` for each
3. **Flag stale docs** — if a doc hasn't been updated in >90 days AND your plan touches that area:
   - Note it as an Open Question: "Doc `XX-name.md` may be outdated — verify during execution"
   - Add a documentation-update step to the plan's final stage
4. **Check amendment patterns** — if `metrics/thunders/cycles/` shows recurring `missing_dependency` or `infra_need` amendments for this repo, add a verification step for those areas to your plan

---

## Structural Planning Enforcement

> **Key principle:** Plans define **what to change and how to verify** — not how to implement.

### Negative Constraints (Do NOT Include)

When writing stage instruction files, you MUST NOT:

- ❌ Write complete function bodies with internal logic (loops, conditions, variable assignments)
- ❌ Include full code blocks that show implementation details (except pure TypeScript interfaces/types or schema definitions)
- ❌ Paste entire files or large sections of files ("The complete X should look like...")
- ❌ Include business logic calculations or data transformations
- ❌ Write out full commit message bodies (use templates: `type(scope): TICKET-ID description`)

**Example of over-coding (FORBIDDEN):**
```typescript
// ❌ Do NOT write this in a plan:
async function getVendorReviews(vendorId: string): Promise<Review[]> {
  const reviews = await this.reviewService.fetchByVendor(vendorId);
  if (!reviews || reviews.length === 0) {
    return [];
  }
  return reviews.filter(r => r.rating >= 3).sort((a, b) => b.createdAt - a.createdAt);
}
```

### Required Format (DO Include)

When writing stage instruction files, you MUST:

- ✅ Use AST-targeted verbs: Inject, Wrap, Delete, Rename, Append, Extract
- ✅ Include function signatures, TypeScript interfaces, API schemas, and database schema changes
- ✅ Describe structural mutations: "Inject method X into class Y with signature Z"
- ✅ Focus on contracts and boundaries between modules
- ✅ Specify verification commands for each change
- ✅ Include **Search keys** for every code-change step: 1–3 grep-ready symbol names (the primary target symbol and its direct dependencies) the executor can use to locate targets without relying on file paths

**Example of structural planning (REQUIRED):**
```markdown
### Step 2.1: Add Review Fetching Method

**Mutation:** Inject
**Target:** `VendorResolver` (class)
**Search keys:** `VendorResolver`, `ReviewService` — _(grep to locate class and its dependency)_
**Signature/Contract:** `async getVendorReviews(vendorId: string): Promise<Review[]>`
**File hint:** `src/vendor/` _(confirm with grep)_

Inject a new public async method into class `VendorResolver`. The method delegates to `ReviewService.fetchByVendor()` and returns the raw array (no filtering or sorting logic in the resolver layer). Verification: GraphQL query `{ vendor(id: "test") { reviews { id rating } } }` returns an array.

**Commit:** `feat(graphql): GPMP-XXXXX add vendor reviews resolver method`
```

### Self-Check Before Committing

Before creating the plan branch, ask yourself:

1. **Signature test:** Can I see any complete function bodies (with logic inside `{ }`) in my stage files? If yes, replace with signature + structural description.
2. **Code block test:** Do any of my code blocks exceed 10 lines (excluding pure type definitions)? If yes, extract the signature and describe the change structurally.
3. **Verification test:** Does each step include a concrete verification command or condition? If no, add it.
4. **AST verb test:** Do my step descriptions use structural verbs (Inject, Wrap, Delete, etc.) or implementation details ("loop through", "calculate", "set variable")? If the latter, revise.
5. **Token estimate:** Would the executing agent need to read 1000+ tokens to understand a single stage? If yes, focus on contracts and omit implementation details.

If any answer suggests over-coding, revise the plan before committing.

---

## Your Task

Produce a complete plan folder in `agent-development/plans/<N-task-name>/`.

After producing the plan:
1. **Create a feature branch** from `main` following the naming convention in `config/teams.yaml`
2. **Commit the plan folder** to the branch
3. **Push the branch and open a draft PR** using the `gh` CLI:
   ```bash
   gh pr create --draft --title "plan: <ticket-id> <short-description>" --body "Plan for review. See specification.md for details."
   ```

The folder must contain:

### 1. `manifest.yaml`

- Populate all fields from the template
- Set `plan_metadata.status: pending-approval`
- Set `plan_metadata.approval.status: pending`
- Set `plan_metadata.complexity` from the request's frontmatter
- Set `plan_metadata.api_checkpoint` from the request's frontmatter
- Define 2-5 stages with blast radius, verification commands, and rollback plans
- Per-stage `complexity` using Fibonacci scale
- Per-stage `api_checkpoint: true` if that stage changes observable API behavior
- For standalone tasks (no epic): fill the `delivery` section with planned branch name

### 2. `specification.md`

- Fill YAML frontmatter (plan_id, title) — **do NOT add a `status` field** (approval lives only in `manifest.yaml`)
- Populate all body sections from the template
- Write thorough Open Questions for anything you cannot decide autonomously
- Include the File Manifest with all files across all stages
- Include the **Symbol Index** table — one row per code symbol touched across all code-change stages (classes, functions, interfaces). The executing agent uses this as its code map before starting execution. Omit symbols from spec/doc-update stages.
- Include API Checkpoint details in relevant stage summaries (the curl/GraphQL command and expected response shape — these are approved at plan time)

### 3. Stage instruction files

- One file per stage following `stage.md` template
- Include a commit plan (table of: commit message, files, purpose)
- Each stage should have **multiple commit units** if the work is decomposable
- Step-by-step instructions with file paths, code snippets, shell commands
- "Spec & doc review" steps in the last stage only (or inline for single-stage)

---

## Constraints

- Blast radius MUST stay within the request's scope
- If you find a missing dependency, write it as an Open Question
- Every `.ts` source change needs a corresponding test update or new test
- Prisma schema changes get their own stage
- Multiple commits per stage are expected — plan them explicitly in the commit table
- Follow structural planning principles (see `common-specs/structural-planning-principles.md`):
  - Use AST-targeted verbs (Inject, Wrap, Delete, Rename, Append, Extract) in stage instructions
  - Include signatures and contracts; omit function bodies and business logic
  - Verification commands over narrative validation descriptions

### Architecture Documentation Rule

Every plan MUST include a documentation assessment and, when applicable, doc update steps:

1. **Assess impact:** Determine if the plan changes observable behavior, data flow, component patterns, API interfaces, or introduces new modules/patterns.

2. **Update the relevant detailed doc** (NOT the overview):
   - If a relevant doc exists in `architecture-documentation/` (repo-local) or `documentation/<repo>/` (hub fallback), update it with the new patterns/changes.
   - If no relevant doc exists and the change introduces a **new architectural area**, create a new numbered doc (e.g., `20-new-area.md`) following the existing naming convention.

3. **Keep `application-overview.md` lean:**
   - The overview in `agent-specs/application-overview.md` is a **mandatory read** for every agent session. It MUST NOT grow with implementation details.
   - It should only contain: purpose, core workflow summaries (2–3 sentences each), and **pointers** to the detailed docs (`**Architecture doc:** \`XX-name.md\``).
   - If your plan introduces a new workflow or module that deserves mention in the overview, add only a short summary + pointer — never inline the detail.

4. **Include doc updates in the plan stages:**
   - Add a "Documentation update" step in the final stage (or as a dedicated commit in the commit table).
   - List which doc files will be created or modified.
   - The commit message should be: `docs: update architecture-documentation for <feature/area>`

This rule applies to ALL repos — whether they use their own `sdd/` + `architecture-documentation/`, or the hub's `fallback-sdd/` + `documentation/<repo>/`.

---

## Output

**Self-check:** Before creating the branch, review your stage files against the "Self-Check Before Committing" questions above. Revise any over-coded sections to be structural (signatures + AST verbs).

Write all plan files directly. Then:

1. **Create the branch** from `main` following the naming convention in `config/teams.yaml`
2. **Commit the plan folder** to the branch
3. **Push and open a draft PR:**
   ```bash
   gh pr create --draft --title "plan: <ticket-id> <short-description>" --body "Plan for review. See specification.md for details."
   ```
4. **Remind me:**
> "Draft PR is open at `<pr-url>`. Review `specification.md`, resolve any `PENDING` questions by editing the files directly or commenting on the PR, then set `manifest.yaml` → `approval.status: approved` when ready to execute."
