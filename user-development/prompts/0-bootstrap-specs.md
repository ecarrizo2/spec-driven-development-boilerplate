# Prompt: Bootstrap Project Specs

> **Usage:** Copy this prompt into a new agent conversation when you are adopting the SDD boilerplate for a new project. Replace `<PROJECT_DESCRIPTION>` with a plain-language description of your project — what it does, who it's for, what tech stack you're using (or planning to use), and any key architectural decisions you've already made. If you have an existing codebase, also point the agent at the source tree so it can read the code directly.

---

You are helping a developer bootstrap the **Spec-Driven Development (SDD)** workflow for a new project. Your job is to generate the five `agent-specs/` files that provide foundational context for every future agent conversation in this project.

## Before Starting

1. **Read the SDD boilerplate structure** to understand what each spec file is for:
   - `user-development/DEVELOPMENT-GUIDE.md` — the full workflow documentation
   - `agent-development/agent-specs/` — read ALL existing files to understand the expected structure, heading hierarchy, and level of detail. These contain **example content** for a fictional NestJS project. You will **replace** the example content but **preserve the same structural patterns** (headings, tables, comment banners, etc.).
   - `agent-development/plans/_templates/` — skim these to understand how plans reference the spec files

2. **Read the project's existing source code** (if any). If the developer pointed you at a codebase, explore the directory tree, read key files (`package.json`, `go.mod`, `Cargo.toml`, `pyproject.toml`, config files, entry points, etc.), and understand the current state. The source code is the source of truth — your generated specs must accurately reflect what exists, not what the developer wishes existed.

3. **Read the project description below** for intent, goals, and any decisions the developer has already made.

**→ `<PROJECT_DESCRIPTION>`**

## What You Will Generate

You will create or overwrite the following five files in `agent-development/agent-specs/`:

### 1. `application-overview.md`

**Purpose:** What the app does, who it's for, core workflows, key UX/DX goals, and what's out of scope.

- Replace the example content entirely.
- Keep the same heading structure: Purpose, Core Workflows, Key UX Goals (or Key DX Goals), Out of Scope.
- Replace the `THIS IS AN EXAMPLE` banner with a banner that says the file was generated during project bootstrap and should be kept up to date.
- Be specific — vague overviews produce vague agent output.

### 2. `architecture-breakdown.md`

**Purpose:** Directory tree, folder descriptions, module dependency graph, design patterns, technology stack, key architectural decisions, and conventions.

- If an existing codebase was provided, generate the directory tree from the **actual** file structure.
- If this is a greenfield project, generate a **proposed** directory tree. Mark it clearly as proposed.
- Keep the same heading structure as the example.
- Include the `agent-development/` and `user-development/` directories in the tree.

### 3. `agent-instructions.md`

**Purpose:** Coding standards, dos/don'ts, error handling, testing, naming conventions, and any stack-specific rules.

- This file is a **starting point** that the developer will tweak over time.
- Replace content sections with rules appropriate to the project's language and framework.
- Keep sensible defaults and add framework-specific rules.

### 4. `agent-workflow.md`

**Purpose:** Execution rules — how agents interact with plans, stages, blast radius, commits, spec/doc update handling, etc.

- This file is **system-level** and typically does NOT need customization per project.
- **Copy the existing file as-is** unless the developer explicitly calls for workflow changes.
- If the existing file already has the correct content, confirm it is unchanged and skip this file.

### 5. `git-workflow.md`

**Purpose:** Branching strategy, commit conventions, ticket ID pattern, versioning expectations.

- This file is a **starting point** that the developer tweaks.
- Update the ticket ID regex pattern if specified.
- Update branch naming examples to match the project.
- If no git preferences specified, keep the defaults.

## Rules

1. **Generate all five files** (or confirm `agent-workflow.md` is unchanged). Do not skip any.
2. **Match the level of detail** shown in the example files.
3. **Be accurate** — specs must reflect actual state of the code.
4. **Preserve heading structure** — other files reference these by heading.
5. **Do NOT generate plans, requests, or any code.** This prompt is only for bootstrapping spec files.
6. **Do NOT delete** the example files in `agent-development/done/`.
7. **Do NOT modify** any files outside of `agent-development/agent-specs/`.

## After Generation

Once all files are generated, provide a summary:

- 📄 Files created or updated (list each with a one-line description)
- ⚠️ Anything you were unsure about or had to guess
- 🔜 Recommended next steps (typically: review the generated specs, then create your first task request using `user-development/prompts/3-create-request.md`)

## Notes

- The developer may run this prompt multiple times. Each run overwrites the previous specs.
- If both a project description AND existing codebase are provided, the codebase takes precedence where they conflict. Flag the conflicts.
- The example pending requests in `agent-development/pending/` are NestJS-specific. Remind the developer to delete or replace them if they don't apply.
