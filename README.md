# Agent Instruction System

**Owner:** Alan Strutz | **Last updated:** 2026-09-07

A modular instruction set for AI sessions built on progressive disclosure: a small core is always loaded; everything else loads only when the task requires it.

## Structure

```
AGENT.md                      ← always loaded (mode, routing, safety, closeout, naming)
SPEC-AND-BUILD.md             ← loaded when the Change Gate applies or project docs are touched
templates/
  PROPOSAL-TEMPLATE.md        ← optional pre-stage; never auto-loaded (AGENT.md §1.1)
  SPEC-TEMPLATE.md
  BUILD-TEMPLATE.md
  RUNBOOK-TEMPLATE.md
runbooks/
  RB-01-data-ingestion.md     ← loaded per task routing (AGENT.md §2)
  RB-02-app-development.md
  RB-03-code-maintenance.md
  RB-04-common-tasks.md       ← four mini-procedures; load only the matching section
```

## Home & deployment

**Canonical home: `sugarmtn/agent-system`** (private). All changes to these documents go through PRs, approved by a human approver (AGENT.md §3). No direct pushes to main.

**Version pinning is mandatory.** Working repos consume a *pinned commit* of this repo, never a floating head:

- **Submodule at a pinned SHA** is the canonical consumption path.
- **Synced checkouts** record the synced SHA in the working repo's `CLAUDE.md`.
- **claude.ai Projects** record the SHA in the project instructions at each refresh.

Every session records the SHA (or tag) in force in its closeout (`Agent-system:` line, AGENT.md §5.2) — which ruleset governed a session must always be reconstructable. **Advancing a repo's pin is a deliberate RB-03 change** (smallest change, one concern): adoption of new rules is chosen, never passive.

Consumption:
- **Claude Code (primary):** each working repo's `CLAUDE.md` imports AGENT.md from this repo (pinned submodule, or synced checkout with recorded SHA) and adds only repo-specific context. Runbooks/templates are referenced by path and read on demand. Never copy content into working repos — copies drift.
- **claude.ai Projects (secondary):** AGENT.md as project instructions; runbooks + templates as project files, refreshed from the repo with the SHA recorded.

Whichever host: do NOT paste all runbooks into the always-loaded instructions — that defeats the design.

## Project layering

Agent-system runbooks are **operative, not templates** — they govern every project. Layering:

1. **AGENT.md** — how every session behaves (universal, always loaded)
2. **RB-nn** — how a class of work is done (universal, loaded per task routing)
3. **Project `CLAUDE.md`** — that project's resource names, conventions, and gotchas (instance context; never restates runbook procedure)

A project gets its own runbook **only** for a recurring procedure with genuinely project-unique steps. Project runbooks live in the project repo, open with `Follows RB-<nn>; project-specific steps below`, and contain only the delta — **extend, never fork.** A project runbook that copies steps from an agent-system runbook is a defect: the copy will drift. Use `templates/RUNBOOK-TEMPLATE.md` when authoring one.

**Where project-unique content lives — the routing test:**
| The content is… | It goes in… |
|---|---|
| What the system is and why (current requirements) | The project's living SPEC (`docs/SPEC.md`) |
| Steps to construct the system from scratch | The project's living BUILD doc (`docs/BUILD.md`, modularized when complex) — updated in place on every change so a rebuild always includes it |
| Operate-time procedures that don't change the system definition (backfill, watermark reset, failure recovery) | A project runbook (`Follows RB-<nn>`, delta only) |
| Facts about what exists (table inventories, mappings, transformation logic) | `docs/reference/`, cited by SPEC/BUILD and runbooks |

**Boundary rule:** if executing the steps changes what a from-scratch rebuild should produce, they belong in BUILD (and go through the Change Gate). If they restore or operate the system as already defined, they belong in a project runbook. Project runbooks are earned from real recurring operations, never written speculatively.

## Maintenance rules

1. All documents are living files updated in place — git history is the change record; there are no version suffixes or superseded copies. Changes refresh the last-updated date and go through PR review by a human approver with RB-03 discipline (smallest change, one concern per change).
2. When a session hits a failure mode no runbook covers, the closeout should propose the runbook addition — runbooks grow from real incidents (including break-glass incidents, AGENT.md §3b), not speculation.
3. Review cadence: quarterly, or after any escalation caused by an instruction gap. The quarterly review includes a sweep of consuming repos for stale agent-system pins.
