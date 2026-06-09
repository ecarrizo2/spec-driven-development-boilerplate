# ADR-010: Structural Planning as Mandatory Plan Format (v2.0)

**Status:** Accepted
**Date:** 2026-06-04

## Conclusion

Plan artifacts (stage instruction files, `specification.md`, `manifest.yaml`) MUST follow Structural Planning principles: instructions use AST-targeted verbs (Inject, Wrap, Delete, Rename, Append, Extract) and signature-only contracts; implementation logic, complete function bodies, and procedural narratives are forbidden. This is Plan Format Version 2.0. The canonical reference is `common-specs/structural-planning-principles.md`.

## Why

- Plans that contained complete function bodies, full code blocks, and step-by-step procedural narratives wasted 500–1000+ tokens per stage on content the executing agent should derive from source code
- Over-specified plans were brittle — they broke when the codebase changed because they were coupled to implementation details rather than structural contracts
- Agents had no clear standard for what belonged in a plan versus what belonged in the code; the absence of a syntax standard led to inconsistent plan quality across epics

## What Changed

- `common-specs/structural-planning-principles.md` — new canonical document defining three pillars: Signature-Driven Planning, AST-Targeted Instructions, Strict Format Constraints
- `common-specs/writing-specs.md` — new section clarifying the scope boundary between EARS/G/W/T (requirements) and structural instructions (implementation guidance)
- `agent-development/plans/_templates/manifest.yaml` — version marker "Format Version 2.0", new `dependency_mapping` section for file-grouped contracts
- `agent-development/plans/_templates/specification.md` — version marker, new "Contracts:" line in stage summaries, note referencing structural principles
- `agent-development/plans/_templates/stage.md` — version marker, steps now use Mutation/Target/Signature fields instead of Action field
- `agent-development/plans/_templates/EXAMPLES.md` — new before/after transformation from real plan showing 58% token reduction
- `.agents/skills/sdd-plan-task/SKILL.md` — mandatory reads for principles doc and EXAMPLES.md, Structural Planning Enforcement section with negative constraints and self-check
- `.agents/skills/sdd-create-request/SKILL.md` — structural thinking guidance in "Your Role" and "Implementation Details — Structural Focus" in Phase 4
- `.agents/skills/sdd-refine-request/SKILL.md` — Implementation Details Quality Bar table with 5 dimensions

## Consequences

- New plans must use Mutation/Target/Signature/Contract fields in stage steps; the old "Action: create | modify | delete" field is deprecated
- `dependency_mapping` is optional but available for plans that introduce cross-file contracts; structure is file-grouped (Option C): `file:` + `signatures:` / `types:` arrays
- Existing plans (pre-v2.0) remain valid and do not need migration; version markers are for new plans only
- The six AST verbs are the standard vocabulary: Inject, Wrap, Delete, Rename, Append, Extract; natural variations ("add method to class") are acceptable when structural intent is clear
- Skills and prompts remain synchronized: any update to a skill requires the identical update to the corresponding prompt file
