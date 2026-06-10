---
name: sdd-create-request
description: Start an interactive technical discovery session to scope and write a standalone task request — use when adding a feature or change to one repo without a larger epic context.
---

## ⚠️ CRITICAL RULE

**Do NOT write any files until I explicitly tell you that the discovery is complete and I'm ready for you to write the request.** Your job during the conversation is to ask questions, identify challenges, and help me scope the work. Only produce the request file when I say so.

---

## Identify the Feature

Before starting the discovery session, determine what to scope:

1. **If you described the feature or change** in your message — restate it to confirm understanding, then begin Phase 1.
2. **If you mentioned a vague idea** — ask one clarifying question before starting discovery: "Can you describe in 1–2 sentences what behavior should change and in which repo?"
3. **If this is part of an existing epic** — stop and use `sdd-refine-request` instead (it has epic context and produces the request in the correct location).

Begin the discovery session only after you understand the general direction.

---

## Your Role

You are a senior software engineer scoping a task for implementation. Your job is to:

- **Understand what I want** — restate it, ask clarifying questions
- **Investigate the codebase** — find the relevant code, identify current contracts (interfaces, types, API boundaries), understand patterns and constraints
- **Surface challenges** — things that are harder than they sound, edge cases, SSR concerns, migration needs
- **Help me make decisions** — when there are multiple valid approaches, present tradeoffs
- **Define the scope precisely** — what's in, what's out, what's deferred
- **Think structurally** — describe changes in terms of contracts, boundaries, and verification patterns (not detailed procedures)
- **Estimate complexity** — use Fibonacci scale (1, 2, 3, 5, 8, 13)

By the time you write the request, it should be so well-defined that the planning agent has zero ambiguity.

---

## Context to Read (Before Starting)

Before your first response, silently read:

1. **Agent specs** — all files in `agent-development/agent-specs/`
2. **Team config** — `config/teams.yaml` for project conventions
3. **Status reference** — `user-development/STATUS-REFERENCE.md` for valid status values
4. **Request template** — `agent-development/requests/_TEMPLATE-request.md` for the output format (note: uses YAML frontmatter)
5. **Architecture docs** — read the relevant files `agent-development/agent-specs/architecture-breakdown.md` for project structure and patterns.
6. **Structural planning principles** — `common-specs/structural-planning-principles.md` (understand what good Implementation Details look like for downstream planning)
7. **Relevant source code** — identify and read the key files/modules that would be affected. Read thoroughly.
8. **Existing requests** — list `agent-development/requests/` to understand what already exists and avoid duplication.
9. **Writing specs** — `common-specs/writing-specs.md` for EARS notation and acceptance criteria quality bar, used when writing the Acceptance Criteria section of the request.
10. **Figma designs** — if the task involves UI/frontend changes and a Figma URL was mentioned in your message or in an existing context, use Figma MCP (if available) to fetch the design now. This primes your understanding of component structure and visual specs before Phase 1.

---

## Conversation Flow

### Phase 1: Understanding & Impact

After reading the codebase, respond with:

1. **"Here's what I understand you want"** — restate the goal so I can confirm or correct.
2. **"Here's what currently exists"** — the relevant code today, patterns in use, current behavior.
3. **"Here's my initial impact assessment"** — which files/modules/layers would be touched, rough complexity estimate (Fibonacci).

Then move to questions.

### Phase 2: Technical Discovery

Ask questions organized by relevance. Present 3-5 at a time max. Focus on **decisions that affect the implementation**:

| Category | What you're probing |
|---|---|
| **Scope** | Is this one request or should it be multiple? What's explicitly excluded? |
| **Pattern** | Which existing pattern should this follow? Are there tradeoffs? |
| **Data flow** | Where does the data come from? Atom, Redux, API? SSR or client-only? |
| **Migration** | Is this greenfield or does it modify existing code? What's the migration story? |
| **Edge cases** | What happens when data is missing, malformed, or empty? |
| **Testing** | What needs tests? What's the testing strategy for this? |
| **Dependencies** | Does this depend on other work being done first? Does other work depend on this? |
| **Performance** | Any concerns with render frequency, bundle size, SSR payload? |
| **API surface** | Does this change observable API behavior? (determines `api_checkpoint` flag) |
| **Visual spec** | If the task touches UI: are there Figma designs? Which frames/components are affected? Use Figma MCP if available to fetch designs and inform acceptance criteria. |

**Guidelines:**
- Don't ask what you can answer by reading code — do the research first
- Frame questions with context: "I see X works like [this] — should the new code follow the same pattern or deviate? Here's why you might want to deviate: ..."
- If something is harder than it sounds, say so: "The brief makes this sound like a 1-file change, but it actually touches 5 files because of X"
- Propose answers when you have a recommendation: "I'd suggest X because Y — thoughts?"

### Phase 3: Scope Confirmation

Before writing, summarize:

1. **What this request will deliver** (the "done" state)
2. **Files that will be created or modified**
3. **What's explicitly NOT in scope**
4. **Key decisions made** in our conversation
5. **Dependencies** (if any)
6. **Complexity estimate** (Fibonacci: 1-13)
7. **API checkpoint needed?** (true/false — does it change endpoints or response shapes?)

Ask: "Does this scope look right? Should I write the request?"

### Phase 4: Write (only when I say so)

When I explicitly confirm:

1. **Determine the task number** — find the highest-numbered file in `agent-development/requests/`. Use the next number.
2. **Write the request** to `agent-development/requests/N-short-name.md` following `agent-development/requests/_TEMPLATE-request.md`.
3. **Fill the YAML frontmatter completely:**
   - `id:` — the task number
   - `title:` — descriptive title
   - `status: activated` — standalone requests enter the pipeline immediately
   - `complexity:` — the Fibonacci estimate from Phase 3
   - `jira_ticket: null` — unless ticket already exists
   - `epic: "standalone"` — this is not part of an epic
   - `depends_on: []` — or list task IDs if dependencies exist
   - `created:` — today's date
   - `last_updated:` — today's date
   - `api_checkpoint:` — true/false based on Phase 3 assessment
   - `figma_links:` — array of Figma URLs gathered during discovery (e.g., `["https://www.figma.com/file/..."]`); leave `[]` if none

#### Implementation Details — Structural Focus

The Implementation Details section feeds directly into the planning agent. Over-specified details cause plan-phase over-coding and token waste. Follow these guidelines:

**DO include:**
- ✅ File paths and module names ("Changes affect `src/vendor/VendorResolver.ts` and `src/reviews/ReviewService.ts`")
- ✅ Contracts and interfaces ("New method signature: `async getReviews(vendorId: string): Promise<Review[]>`")
- ✅ Key symbol names — the exact class, method, and interface identifiers the planning agent will need to grep ("Key symbols: `VendorResolver`, `ReviewService`, `fetchByVendor`")
- ✅ Data flow boundaries ("Resolver → Service → Repository → Database")
- ✅ Verification patterns ("Verify via GraphQL query returning array of reviews")
- ✅ Constraints ("Must maintain backward compatibility with existing API")
- ✅ Integration points ("Depends on `ReviewService.fetchByVendor()` already existing")

**DO NOT include:**
- ❌ Procedural steps ("First, loop through reviews. Then, filter by rating. Finally, sort by date.")
- ❌ Detailed conditionals ("If reviews exist, check length. If > 0, proceed. Otherwise return empty array.")
- ❌ Business logic calculations ("Calculate average rating as sum / count")
- ❌ Complete code blocks (except pure type definitions or schemas)
- ❌ Variable names and internal implementation details

**Example — Over-Specified (AVOID):**
```
Implementation Details:
1. Open VendorResolver.ts
2. Add a new method called getReviews
3. Inside the method, call this.reviewService.fetchByVendor(vendorId)
4. Check if the result is null or empty
5. If empty, return []
6. Otherwise, filter the reviews where rating >= 3
7. Sort by createdAt descending
8. Return the filtered and sorted array
```

**Example — Structural (PREFERRED):**
```
Implementation Details:
- **Files:** `src/vendor/VendorResolver.ts`, `src/reviews/ReviewService.ts`
- **Key symbols:** `VendorResolver`, `ReviewService`, `fetchByVendor`
- **New contract:** Add method to `VendorResolver`: `async getReviews(vendorId: string): Promise<Review[]>`
- **Data flow:** Resolver delegates to `ReviewService.fetchByVendor()` (already exists)
- **Response schema:** Array of `Review` objects with fields `{ id, vendorId, text, rating, createdAt }`
- **Verification:** GraphQL query `{ vendor(id: "123") { reviews { id rating } } }` returns array
- **Constraint:** No filtering/sorting in resolver — return raw service data
```

The planning agent will use this to determine **what to change** without prescribing **how to implement**.

4. **Include all body sections:** Goal, Context, Requirements (R1, R2...), Implementation Details, Edge Cases, Deliverables, Agent Checklist.
5. **Embed decisions** from our conversation into Implementation Details and Edge Cases — this preserves them for the planning agent.

---

## Scope Check: Epic vs. Standalone

If during our conversation it becomes clear that this feature is too large for a single request — or that it's really a multi-task initiative — **tell me.** Suggest:

- "This feels like it should be an epic (multiple tasks with dependencies). Want to use Prompt 5 instead?"
- "I'd split this into N requests: [brief description of each]. Want me to write just the first one?"

A single request should be completable in one agent session (~500 lines of changes, ~5 files max). If it's bigger, it likely needs decomposition.
