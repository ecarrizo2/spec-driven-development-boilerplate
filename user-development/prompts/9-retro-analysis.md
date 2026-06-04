> **🎯 Preferred invocation:** In Zed or Claude Code, describe what you want —
> the `sdd-retro-analysis` skill activates automatically. In VS Code, use `/sdd-retro-analysis`.
>
> **📋 Fallback:** Copy-paste the content below into any agent conversation.

---

# Prompt: Retrospective Analysis

> **Usage:** Run this prompt after completing 1+ epics. The agent reads saved metrics and produces structured retro talking points with actionable recommendations.

---

## Input

**Metrics directory:** `metrics/thunders/cycles/`

Optionally specify a single epic: `metrics/thunders/cycles/<epic-name>.yaml`

---

## Context to Read

1. **All cycle files** in `metrics/thunders/cycles/` (or the one specified)
2. **The metrics schema** — `metrics/thunders/schema.yaml` (understand what each field means)
3. **Amendment details** — for each epic with amendments > 0, read the corresponding `epics/<epic>/delivery.yaml` → `amendments:` section
4. **Negotiation records** — `epics/<epic>/task-graph.md` → `negotiations:` section

---

## Your Task

Produce a structured retrospective analysis with these sections:

### 1. Summary Dashboard

For each epic in the metrics directory, produce a one-line summary:

```
| Epic | Focus Ratio | Amendments | Tasks (orig→final) | Incidents |
```

If multiple epics exist, add a row for averages.

### 2. What Went Well

Identify positives from the data:
- Epics with focus ratio ≥ 0.9 (accurate planning)
- Tasks that completed without blockers
- Repos that consistently had no amendments (good spec coverage)
- Velocity improvements between epics (if data allows)

Be specific — cite the epic name and metric.

### 3. What Needs Improvement

Identify patterns that indicate process gaps:
- Recurring amendment types across epics (e.g., `infra_need` appearing in 3/4 epics)
- Focus ratios below 0.7 (significant scope expansion)
- High negotiation counts (requirements unclear at start)
- Repos that consistently generate amendments (architecture docs may be stale)

For each finding, explain **why** it matters and **what it suggests** about the upstream process.

### 4. Actionable Recommendations

For each pattern identified in section 3, propose a concrete fix:

| Pattern | Root Cause Hypothesis | Recommended Action | Where to Implement |
|---------|----------------------|--------------------|--------------------|
| Recurring `infra_need` | Planning doesn't check infra | Add infra checklist to Prompt 6 | `user-development/prompts/6-break-down-epic.md` |
| Stale docs cause re-discovery | Docs not updated during execution | Enforce doc freshness check in Prompt 1 | Already done — verify compliance |

Limit to 3-5 highest-impact recommendations.

### 5. Estimation Calibration (if ≥5 tasks)

If enough data exists, correlate complexity estimates with actual outcomes:
- Do complexity-3 tasks consistently take longer than expected?
- Are there tasks estimated at 2 that spawned amendments (should have been 5)?
- Which repos are hardest to estimate for?

### 6. Questions for the Team

End with 2-3 open questions that the data raises but can't answer alone:
- "Tasks in TKMarketplace consistently spawn amendments — is the architecture overview outdated, or is the codebase inherently more unpredictable?"
- "Focus ratio has been declining — are we starting epics before requirements are firm, or is our codebase generating more surprises?"

---

## Output Format

Present as a markdown document suitable for pasting into a Confluence retro page or sharing in a team channel. Use headers, tables, and bullet points — no prose paragraphs.

**Do NOT** invent data. If there's only one epic, say so and note that trend analysis requires more data. If metrics files don't exist, say "No metrics found — run `bin/dev audit:delivery <epic-id> --save` on completed epics first."

---

## Rules

- Be specific: cite epic names, numbers, and amendment types
- Be actionable: every observation should connect to a process improvement
- Be honest: if the data is insufficient for conclusions, say so
- Don't speculate beyond what the data shows — frame hypotheses as questions
- Prioritize: the team's time is limited — surface the top 3-5 insights, not 20
