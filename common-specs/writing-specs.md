# Writing Specs — EARS Notation, Failure Modes, and Methodology Positioning

> **Scope:** This document applies to all repos managed by this hub.
> It defines the standard syntax for acceptance criteria (EARS notation),
> the vocabulary for why the SDD pipeline rules exist (failure mode taxonomy),
> and a positioning reference for teams coming from other methodologies.
>
> **Rule:** EARS pattern definitions live only here. Other hub documents link
> to this file rather than restating syntax.

---

## SDD Failure Modes

The SDD pipeline rules — fresh sessions, blast radius, approval gates, spec cascade — exist to prevent three failure modes that occur in agent-assisted development. Understanding these makes the rules feel necessary rather than bureaucratic.

| Failure Mode | What it means | Which pipeline rule prevents it |
|---|---|---|
| **intent drift** | The requirement stated in the spec doesn't match what is built. Accumulated misinterpretation across sessions, rewrites, or handoffs causes the implementation to diverge from the original intent. | Approved plan before execution; humans define "what", agents define "how"; spec cascade provides anchoring context |
| **context decay** | A working session (human or AI) loses the architectural context built in earlier sessions. The agent makes decisions incompatible with established patterns because it can no longer "see" prior decisions. | Fresh-session discipline; mandatory spec reads at session start; plan stages as the session-to-session handoff artifact |
| **unverifiable output** | Acceptance criteria are too vague to prove pass/fail — "it works", "it looks right", "it performs well" are not criteria. There is no objective way to sign off on completion. | EARS notation + Given/When/Then syntax; quality bar checklist; explicit ACs in every request and Jira ticket |

These names are part of the hub's shared vocabulary. Use them in retrospectives, escalation discussions, and plan open questions.

---

## SDD vs Other Methodologies

For teams coming from TDD, BDD, or "vibe coding" backgrounds:

| Methodology | Primary artefact | Source of truth | AI-compatible at scale | Validation mechanism |
|---|---|---|---|---|
| **Spec-Driven Development (SDD)** | Approved plan + request document | Spec + code (code wins on conflict) | Yes — plan approval gates prevent unanchored generation; blast radius limits drift | Explicit verification commands per stage; AC checklist per request |
| **Vibe coding** | None / the AI output itself | AI output | No — no anchor; drifts on every session; unrecoverable after context window clears | Manual / ad hoc / "does it look right?" |
| **Test-Driven Development (TDD)** | Failing test | Test suite | Partial — tests constrain the AI, but tests can be incomplete or wrong | Red/green test runs |
| **Behavior-Driven Development (BDD)** | Gherkin scenarios | Feature files | Partial — scenarios constrain user-facing behavior but don't address architecture, session context, or cross-repo sequencing | Automated scenario execution (Cucumber, etc.) |

**SDD and TDD/BDD are complementary** — EARS/G/W/T acceptance criteria from SDD feed directly into BDD scenarios and TDD test cases. SDD adds the coordination and approval layer that TDD/BDD do not address.

---

## EARS Notation — Patterns and Syntax

EARS (Easy Approach to Requirements Syntax) provides five sentence patterns that eliminate the ambiguity common in freeform acceptance criteria. Each pattern has a keyword that signals what kind of requirement it is.

### Pattern 1: Ubiquitous

Use for requirements that are always active — no triggering event or precondition.

**Syntax:**
```
The system SHALL <behavior>
```

**Example:**
> The system SHALL validate all API request payloads against the documented JSON schema before processing.

---

### Pattern 2: Event-Driven

Use for requirements that are triggered by a specific event or stimulus.

**Syntax:**
```
WHEN <trigger event>, the system SHALL <response>
```

**Example:**
> WHEN a user submits a new order, the system SHALL enqueue a fulfillment job within 5 seconds and return a `202 Accepted` response.

---

### Pattern 3: State-Driven

Use for requirements that apply only while the system is in a particular state.

**Syntax:**
```
WHILE <system is in state>, the system SHALL <behavior>
```

**Example:**
> WHILE a product listing is in `draft` status, the system SHALL NOT include that listing in search results or public catalog pages.

---

### Pattern 4: Unwanted Behavior

Use for requirements that specify the system's response to an undesired condition (error handling, degraded mode, fallback behavior).

**Syntax:**
```
IF <unwanted condition>, the system SHALL <response>
```

**Example:**
> IF the upstream data provider returns a 5xx response, the system SHALL render the page without the affected section and emit a `WARN`-level log entry including the resource ID and the upstream status code.

---

### Pattern 5: Optional Feature

Use for requirements that apply only when a specific feature or configuration is present (feature flags, licensed modules, platform variants).

**Syntax:**
```
WHERE <feature is included>, the system SHALL <behavior>
```

**Example:**
> WHERE the `new-checkout-flow` feature flag is enabled for a user session, the system SHALL display the redesigned checkout form with inline address validation.

---

## Quality Bar for Acceptance Criteria

Each acceptance criterion — whether written in EARS notation or Given/When/Then — must meet this quality bar:

| Dimension | What it means | Failing example | Passing example |
|---|---|---|---|
| **Specific** | Names exact values, field names, endpoints, status codes, or user-visible text | "The API returns correct data" | "The API returns `200 OK` with a body matching the `OrdersResponse` schema" |
| **Testable** | Someone can determine pass or fail without ambiguity; no judgment calls required | "The page loads quickly" | "The page reaches Time-to-Interactive within 3 seconds on a 4G connection in Lighthouse" |
| **Independent** | Can be verified without checking other criteria in the same list | "Everything works end-to-end" | Single, bounded scenario that stands alone |
| **Complete** | Together the criteria cover: happy path, known error cases, and edge cases from the refinement session | Three happy-path-only criteria | Happy path + error fallback + boundary condition criteria |

---

## EARS vs Given/When/Then — When to Use Each

EARS and Given/When/Then are complementary. Choose based on the type of requirement:

| Context | Preferred syntax | Reason |
|---|---|---|
| API behavior, HTTP response contracts | EARS (Event-driven or Ubiquitous) | Precise, deterministic; maps directly to integration test assertions |
| System constraints, data invariants | EARS (Ubiquitous or State-driven) | Always-on rules without a triggering event |
| Error handling and fallback behavior | EARS (Unwanted behavior) | `IF` keyword signals defensive requirement cleanly |
| Feature flag or optional module behavior | EARS (Optional) | `WHERE` keyword documents conditional activation explicitly |
| UI flows, user interactions, end-to-end behavioral scenarios | Given/When/Then | Narrative form captures user intent and expected observation naturally |
| State machine or protocol transitions | EARS (State-driven) | `WHILE` keyword ties requirement to a defined system state |

**You can use both syntaxes in the same request document.** API-level criteria in EARS, UI flow criteria in G/W/T — each applied where it communicates most clearly.
