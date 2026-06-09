---
name: sdd-slim-docs
description: Apply the "what can't code answer?" conciseness pass to any documentation folder — produces a human-approved cut plan then executes
---

## Input

Target documentation folder path (e.g., `documentation/TKMarketplace/`, `agent-development/agent-specs/`, `common-specs/`)

If not provided in the invocation message, ASK for it before proceeding.

---

## Cut Triggers — Remove When Approved

These are things code CAN answer. Remove when the human approves:

- **Tables tracking internal state** per hook/component (state read, state written, props) — agents read the source directly
- **Prose describing what a function/hook/component does** when the code is readable and follows a well-known pattern
- **Directory tree sections** that duplicate what `architecture-breakdown.md` already shows
- **Step-by-step "how X works" walkthroughs** for standard patterns (React Query data flow, Redux Toolkit slice anatomy, etc.)
- **Inline Table of Contents sections** — agents use the file outline feature, not TOC anchors

---

## Keep Triggers — Always Preserve

These are things code CANNOT answer. Always preserve:

- **Anti-patterns:** explicit "don't do X" guidance with a reason, especially when the wrong approach looks valid to an agent reading only the code
- **Placement guides:** "where to put new code" decision tables or rules (e.g., "put this in hooks not helpers because...")
- **Constraints not visible from code:** SSR import restrictions, module boundary rules, circular dependency prohibitions
- **Migration notes:** "this uses the old pattern; new code should use Z instead"
- **Architectural "why":** reasoning behind a choice not recoverable from reading the code
- **Auto-generation warnings:** any note that a file is auto-generated or must not be edited by hand

---

## Per-File Protocol

Follow these steps for the target folder:

1. **List all `.md` files** in the target folder (skip `README.md` and `overview.md` by default — see Edge Cases below)
2. **For each file:** retrieve the outline (sections + line counts)
3. **Build a cut plan:** for each file, list proposed cuts as `"Section X.Y — [cut reason] (~N lines saved)"` and note which sections are keep-trigger content
4. **Present the full cut plan** as a summary table (file | sections to cut | lines saved | sections preserved)
5. **STOP** — wait for explicit approval before writing anything. Accept per-file overrides (e.g., "do all except file X")
6. **Execute approved cuts** file by file
7. **Report total lines before/after** per file

---

## Edge Cases

- **Files ≤ 80 lines:** Skip and note "already concise — skipped"
- **Sections that are entirely keep-trigger content:** Say so explicitly rather than proposing cuts
- **`README.md` and `overview.md` files:** These are indices, not deep-dive docs — skip by default; include only if the user explicitly requests them
- **`writing-specs.md` in `common-specs/`:** Contains intentional examples (EARS patterns with Marketplace domain examples) — these are NOT redundant prose; flag them as keep-trigger content before any cut is proposed
- **Mixed doc/spec folders:** If the user points at a folder that mixes documentation with spec/ADR files (e.g., `common-specs/` contains both `writing-specs.md` and `coding-standards.md`), flag potential false positives in the cut plan

---

## Output

1. Present the cut plan as a summary table: file | sections to cut | lines saved | sections preserved
2. Wait for approval
3. Execute approved cuts file by file
4. Report total lines before/after per file
