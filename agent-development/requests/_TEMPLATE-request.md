---
# ─────────────────────────────────────────────────────────────────────────────
# Task Request Metadata
# ─────────────────────────────────────────────────────────────────────────────
id: null              # Sequential number within the epic (e.g., 1, 2, 3)
title: ""
status: draft         # draft | refined | activated | planned | done
complexity: null      # Fibonacci: 1 | 2 | 3 | 5 | 8 | 13

# Multirepo fields
target_repo: ""       # Which repo this task executes in (must match repos.yaml key)
hub_epic: ""          # Reference to parent epic folder (e.g., "1-feature-name")

created: null         # YYYY-MM-DD
last_updated: null    # YYYY-MM-DD
discovered_during: null  # Plan ID that surfaced this work (e.g., "3-add-notifications"), or null if planned from the start
---

# Task <N>: <Short Descriptive Title>

## Goal

_One sentence describing the end state when this task is done._

## Context

_Why this task is needed. How it fits into the broader epic. What has already been done (prior tasks), and what this enables (subsequent tasks)._

**Parent epic:** `epics/<hub_epic>/epic.md`
**Target repo:** `<target_repo>` (from `config/repos.yaml`)

## Requirements

_Verifiable requirements. Each should be testable._

- **R1.** ...
- **R2.** ...
- **R3.** ...

## Cross-Repo Context

_How does this task relate to work happening in other repos? What interfaces must be respected? What other PRs need to merge before or after this one?_

- Depends on: _task X in repo Y (describe what it provides)_
- Consumed by: _task Z in repo W (describe what it expects from us)_
- Contracts to honor: _reference relevant file in `contracts/`_

## Implementation Details

_Guidance for the planning agent — file paths, patterns to follow, edge cases, constraints. This is "what" not "how"._

- ...

## Deliverables

_Concrete outputs that should exist when this task is done._

- [ ] ...
- [ ] ...

## Acceptance Criteria

<!-- Verifiable criteria that define "done" for this task. Added during refinement (Prompt 7).    -->
<!-- See common-specs/writing-specs.md for the full EARS pattern reference.                        -->
<!--                                                                                               -->
<!-- System/API-level criteria → EARS notation (preferred):                                        -->
<!--   WHEN <trigger>, the system SHALL <response>                                                 -->
<!--   WHILE <state>, the system SHALL <behavior>                                                  -->
<!--   IF <unwanted condition>, the system SHALL <response>                                        -->
<!--   WHERE <feature flag>, the system SHALL <behavior>                                           -->
<!-- UI/behavioral flow criteria → Given/When/Then                                                 -->
<!--                                                                                               -->
<!-- Quality bar: each criterion must be Specific, Testable, Independent, and Complete.            -->

- [ ] [Criterion 1 — specific and testable]
- [ ] [Criterion 2 — specific and testable]
- [ ] [Criterion 3 — specific and testable]

## Agent Checklist

_Verification steps the executing agent must perform._

- [ ] All tests pass (`bin/dev test`)
- [ ] Lint passes (`bin/dev lint`)
- [ ] Type-check passes (`bin/dev typecheck`)
- [ ] Spec/doc updates included if interfaces changed
- [ ] Hub task-graph updated (status → done)
- [ ] Hub delivery.yaml updated (PR URL added)
