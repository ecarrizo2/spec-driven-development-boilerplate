---
name: sdd-refine-request
description: Interactively refine an epic task shell into a fully specified request — maps implementation files, surfaces edge cases, produces acceptance criteria, and optionally creates the Jira ticket.
---

## ⚠️ CRITICAL RULE

**Do NOT write or modify any files until I explicitly tell you that the refinement is complete and I'm ready for you to write the request.** Your job during the conversation is to ask implementation-level questions, surface technical challenges, and help me make decisions. Only produce the final request file when I say so.

---

## Identify the Request Shell

Before starting, determine which request shell to refine:

1. **If you mentioned a specific file** (e.g., "refine `epics/3-storefront-redesign/requests/2-add-vendor-card.md`") — use that path.
2. **If you mentioned a task name or number within an epic** — find the matching shell in the epic's `requests/` folder.
3. **If unspecified** — list `epics/<active-epic>/requests/` and ask which shell to refine. If no epic is active, run `bin/dev status` to find active epics.

Confirm the shell file and verify it has `status: draft` or `status: refined` (if re-refining) before proceeding.

---

## Your Role

You are a senior software engineer preparing to hand off a well-defined task. The product decisions are made (in the epic). Your job is to refine the *implementation scope* — identifying patterns, mapping files, surfacing edge cases, and making technical decisions.

By the time you write the request, it should be so well-defined that the planning agent has zero ambiguity.

---

## Context to Read (Before Starting)

Before your first response, silently read:

1. **The parent epic** — `epics/<N-epic-name>/epic.md`
2. **The task graph** — `epics/<N-epic-name>/task-graph.md`
3. **The request shell** — the file specified in Input above
4. **Agent specs** — all files in `agent-development/agent-specs/`
5. **Team config** — `config/teams.yaml`
6. **Structural planning principles** — `common-specs/structural-planning-principles.md`
7. **Jira ticket templates** — `config/jira-ticket-templates.md` (hub-level file; canonical for all repos — no repo-level overrides).
8. **Request template** — `agent-development/requests/_TEMPLATE-request.md`
9. **Relevant source code** — read the files/modules this task will touch
10. **Predecessor outputs** — if dependencies exist, check `plans/` for their results
11. **Status reference** — `user-development/STATUS-REFERENCE.md`

---

## Conversation Flow

### Phase 1: Technical Assessment

1. **"Here's the current state"** — file paths, patterns, relevant types
2. **"Here's what this task changes"** — delta between current and desired state
3. **"Technical decisions I need input on"** — move into questions

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
| Complexity estimate | "I estimate this as Fibonacci 5. Does that match your sense?" |
| Acceptance criteria | "I'm thinking these scenarios define 'done' — anything missing?" |

### Phase 3: Acceptance Criteria Draft

Before writing, explicitly propose acceptance criteria:

1. **List 3-8 specific acceptance criteria** in verifiable format:
   - Use **EARS notation** for system and API-level criteria (preferred) — see [`common-specs/writing-specs.md`](../../common-specs/writing-specs.md) for the five patterns and Marketplace examples
   - Use "Given / When / Then" for UI and behavioral flow criteria
   - Use checkbox-style for state-based criteria
   - Each criterion must be independently testable
2. **Ask:** "Do these acceptance criteria capture everything? Anything to add or modify?"

### Phase 4: Confirm Scope

Before writing, summarize:
1. Files created / modified / not touched
2. Key decisions made
3. Acceptance criteria (final list)
4. Anything deferred to later tasks
5. Complexity estimate (Fibonacci)
6. Whether `api_checkpoint` should be true

Ask: "Does this scope look right? Should I write the request?"

---

### Implementation Details Quality Bar

When refining the Implementation Details section, apply this quality bar:

| Dimension | Good (Structural) | Bad (Over-Specified) |
|---|---|---|
| **Scope** | Lists affected files/modules and their boundaries | Lists step-by-step procedures |
| **Contracts** | Defines signatures, interfaces, schemas | Includes internal variable names and logic flow |
| **Symbols** | Names the key classes, methods, and interfaces the planner will grep for (e.g., `VendorResolver`, `fetchByVendor`) | Omits identifiers, forcing the planner to grep blindly |
| **Verification** | Describes how to test the change (commands, queries) | Describes what the code should do internally |
| **Data flow** | Maps boundaries (Resolver → Service → DB) | Details loops, filters, calculations |
| **Constraints** | Notes architectural rules (e.g., no business logic in resolvers) | Prescribes exact implementation approach |

**Why this matters:**
- Implementation Details feed directly into the planning agent
- Over-specification causes plan-phase over-coding (token waste, brittleness)
- Structural focus lets the planning agent make informed decisions without being over-constrained

**During refinement:**
- If the Implementation Details section reads like a step-by-step tutorial → revise to focus on contracts and boundaries
- If it includes conditionals, loops, or calculations → extract the architectural intent and omit the implementation details
- If it doesn't identify verification patterns → add them (verification commands, expected responses)
- If it doesn't name the key symbols (classes, methods, interfaces) → add a **Key symbols** line so the planning agent has precise grep targets

---

### Phase 5: Write (only when I say so)

1. **Overwrite the request shell** at `epics/<N-epic-name>/requests/<N-task.md>`
2. **Use the full template** from `agent-development/requests/_TEMPLATE-request.md`
3. **Fill frontmatter completely:**
   - `status: refined`
   - `complexity: <fibonacci>`
   - `api_checkpoint: <true/false>`
   - `last_updated: <today>`
4. **Include ALL sections with full content:**
   - **Goal** — clear end-state description
   - **Context** — current state, what changes, how it fits the epic
   - **Requirements** — numbered, concrete, verifiable (expanded from shell)
   - **Implementation Details** — files, patterns, signatures, algorithms
   - **Edge Cases** — specific scenarios with expected behavior
   - **Deliverables** — checklist of tangible outputs
   - **Acceptance Criteria** — the verified criteria from Phase 3
   - **Agent Checklist** — runnable verification steps
5. **Embed decisions** from our conversation into Implementation Details and Edge Cases
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
     - Context (epic link, dependencies, current state)
     - Goal from the request
     - Requirements from the request
     - Full acceptance criteria from the request
     - Dev notes (key files, patterns)
     - Design links (from epic references — propagate Figma URLs relevant to this task)
     - Product brief link (from epic references)
   - Set Epic Link to the parent epic's Jira ticket
   - Set "Blocks" / "Is Blocked By" dependency links based on `task-graph.md`
   - Record ticket ID back into:
     - The request file's `jira_ticket` frontmatter field
     - The `task-graph.md` frontmatter for this task
3. If no: leave `jira_ticket: null` for manual creation later.

---

## Output Quality Bar

The finished request must be detailed enough that:
- The planning agent (Prompt 1) produces a plan without asking clarifying questions
- The executing agent (Prompt 2) implements without making architectural decisions
- A human reviewer approves the plan quickly because all ambiguity was resolved here
- The Jira ticket (if created) is self-contained — any team member can understand the task without opening the repo

## Acceptance Criteria Quality Bar

Each acceptance criterion must be:
- **Specific** — not "it works correctly" but "returns 200 with `{ awards: [...] }` shape"
- **Testable** — someone can verify pass/fail without ambiguity
- **Independent** — each criterion can be verified separately
- **Complete** — together they cover the happy path, error cases, and edge cases identified during refinement
