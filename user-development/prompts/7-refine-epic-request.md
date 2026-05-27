# Prompt: Refine an Epic Request (Interactive)

> **Usage:** Copy this prompt into a new agent conversation. Provide the path to the request shell file you want to refine. The agent will guide you through a technical refinement session before writing the full request document and creating the Jira ticket.

---

## ⚠️ CRITICAL RULE

**Do NOT write or modify any files until I explicitly tell you that the refinement is complete and I'm ready for you to write the request.** Your job during the conversation is to ask implementation-level questions, surface technical challenges, and help me make decisions. Only produce the final request file when I say so.

---

## Input

**Request shell to refine:** `epics/active/<N-epic-name>/requests/<N-task.md>`

---

## Your Role

You are a senior software engineer preparing to hand off a well-defined task. The product decisions are made (in the epic). Your job is to refine the *implementation scope* — identifying patterns, mapping files, surfacing edge cases, and making technical decisions.

By the time you write the request, it should be so well-defined that the planning agent has zero ambiguity.

---

## Context to Read (Before Starting)

Before your first response, silently read:

1. **The parent epic** — `epics/active/<N-epic-name>/epic.md`
2. **The task graph** — `epics/active/<N-epic-name>/task-graph.md`
3. **The request shell** — the file specified in Input above
4. **Repo registry** — `config/repos.yaml` (to understand the target repo's stack and conventions)
5. **Agent specs** — `agent-development/agent-specs/` or `fallback-sdd/<repo>/agent-development/agent-specs/`
6. **Team config** — `config/teams.yaml`
7. **Jira ticket templates** — `config/jira-ticket-templates.md`
8. **Request template** — `agent-development/pending/_TEMPLATE-request.md`
9. **Relevant source code** — read the files/modules this task will touch in the target repo
10. **Predecessor outputs** — if dependencies exist, check completed plans/PRs for their results
11. **Contracts** — if cross-repo, check `contracts/` for interface specs
12. **Status reference** — `user-development/STATUS-REFERENCE.md`

---

## Conversation Flow

### Phase 1: Technical Assessment

1. **"Here's the current state"** — file paths in the target repo, patterns, relevant types
2. **"Here's what this task changes"** — delta between current and desired state
3. **"Cross-repo context"** — what this task provides to/consumes from other repos
4. **"Technical decisions I need input on"** — move into questions

### Phase 2: Technical Interrogation

Ask implementation-focused questions in batches of 3-5:

| Category | Example |
|---|---|
| Pattern selection | "Two patterns exist: [A] and [B]. Tradeoffs — which?" |
| Blast radius | "Component imported by 4 parents. Update all call-sites or just the component?" |
| Code reuse | "Existing helper does 70%. Reuse and extend, or write fresh?" |
| Testing strategy | "No tests exist. Add for existing behavior first, or only new?" |
| API checkpoint | "This changes the response shape. Should this stage pause for API verification?" |
| Error handling | "If API returns unexpected data — fail silently or throw?" |
| Cross-repo contract | "This endpoint is consumed by repo-b. Change contract or adapter?" |
| Complexity estimate | "I estimate this as Fibonacci 5. Does that match your sense?" |
| Acceptance criteria | "I'm thinking these scenarios define 'done' — anything missing?" |

### Phase 3: Acceptance Criteria Draft

Before writing, explicitly propose acceptance criteria:

1. **List 3-8 specific acceptance criteria** in verifiable format:
   - Use "Given / When / Then" for behavioral criteria
   - Use checkbox-style for state-based criteria
   - Each criterion must be independently testable
   - Include cross-repo integration criteria if applicable
2. **Ask:** "Do these acceptance criteria capture everything? Anything to add or modify?"

### Phase 4: Confirm Scope

Before writing, summarize:
1. Files created / modified / not touched (in target repo)
2. Key decisions made
3. Acceptance criteria (final list)
4. Cross-repo impacts (contracts, dependencies)
5. Anything deferred to later tasks
6. Complexity estimate (Fibonacci)
7. Whether `api_checkpoint` should be true

Ask: "Does this scope look right? Should I write the request?"

### Phase 5: Write (only when I say so)

1. **Overwrite the request shell** at `epics/active/<N-epic-name>/requests/<N-task.md>`
2. **Use the full template** from `agent-development/pending/_TEMPLATE-request.md`
3. **Fill frontmatter completely:**
   - `status: refined`
   - `complexity: <fibonacci>`
   - `target_repo: <repo-key>`
   - `hub_epic: <epic-folder-name>`
   - `last_updated: <today>`
4. **Include ALL sections with full content:**
   - **Goal** — clear end-state description
   - **Context** — current state, what changes, how it fits the epic, target repo
   - **Requirements** — numbered, concrete, verifiable (expanded from shell)
   - **Cross-Repo Context** — dependencies, contracts, what other repos expect
   - **Implementation Details** — files, patterns, signatures, algorithms
   - **Deliverables** — checklist of tangible outputs
   - **Acceptance Criteria** — the verified criteria from Phase 3
   - **Agent Checklist** — runnable verification steps (including hub sync)
5. **Embed decisions** from our conversation into Implementation Details
6. **Update `task-graph.md`** frontmatter — change this task's status from `draft` to `refined`

### Phase 6: Jira Ticket Creation

After the request file is written, proceed to create the Jira ticket:

1. **Ask:** "Should I create the Jira ticket now?"
2. If yes:
   - Read `config/teams.yaml` for project settings (issue type, project key)
   - Read `config/jira-ticket-templates.md` for the content template
   - Create the ticket using the **Standard Task Ticket** template (or **Experiment Task Ticket** if applicable)
   - Populate with:
     - Title from the request
     - Context (epic link, target repo, dependencies including cross-repo, current state)
     - Goal from the request
     - Requirements from the request
     - Full acceptance criteria from the request
     - Dev notes (target repo, key files, patterns)
     - Cross-team information (if cross-repo deps exist)
     - Design links (from epic references)
     - Product brief link (from epic references)
   - Set Epic Link to the parent epic's Jira ticket
   - Set "Blocks" / "Is Blocked By" dependency links based on `task-graph.md`
   - Record ticket ID back into:
     - The request file's frontmatter (add `jira_ticket` field)
     - The `task-graph.md` frontmatter for this task
3. If no: leave `jira_ticket: null` for manual creation later.

---

## Output Quality Bar

The finished request must be detailed enough that:
- The planning agent (Prompt 1) produces a plan without asking clarifying questions
- The executing agent (Prompt 2) implements without making architectural decisions
- A human reviewer approves the plan quickly because all ambiguity was resolved here
- The Jira ticket (if created) is self-contained — any team member can understand the task without opening the hub repo

## Acceptance Criteria Quality Bar

Each acceptance criterion must be:
- **Specific** — not "it works correctly" but "returns 200 with `{ awards: [...] }` shape"
- **Testable** — someone can verify pass/fail without ambiguity
- **Independent** — each criterion can be verified separately
- **Complete** — together they cover the happy path, error cases, and edge cases identified during refinement
- **Cross-repo aware** — if this task's output is consumed by another repo, include an integration criterion
