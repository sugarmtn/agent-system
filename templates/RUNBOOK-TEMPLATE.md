# RB-<nn> — <Name>  *(or: <Project> — <Procedure>, for project runbooks)*

**Owner:** <name> | **Last updated:** <date> | **Frequency:** <Daily/Weekly/Monthly — omit this field entirely if the procedure is not scheduled>
**Applies to:** <the class of task this governs — precise enough that routing is unambiguous>
**Follows:** <RB-nn, for project runbooks — list only the DELTA steps below> *(delete line for agent-system runbooks)*
**Load with:** AGENT.md <+ project SPEC/BUILD docs if the Change Gate applies>

<!-- AUTHORING RULES (delete this block before committing):
1. Every step must be executable by a fresh session with no memory of this conversation.
2. Every step has a failure branch. A step with no "If it fails" hasn't been thought through.
3. Troubleshooting rows come from real incidents only — no speculative entries.
4. Project runbooks contain only steps that differ from the RB they follow. Never copy parent steps.
5. Update in place; refresh Last updated; git history is the change record (SPEC-AND-BUILD §4).
6. Escalation table lists only runbook-specific triggers — AGENT.md §6's global triggers apply to every runbook already and are never restated here.
-->

### Purpose
<One paragraph: what this standardizes and why it exists.>

### Prerequisites
- [ ] <access/permission, by name>
- [ ] <inputs that must exist, confirmed — not assumed>
- [ ] <environment explicitly confirmed if anything touches prod (AGENT.md §4.1)>

### Procedure

#### Step 1: <imperative name>
```
<exact command, query, or action — no "run the script"; name the script and flags>
```
**Expected result:** <observable outcome>
**If it fails:** <diagnosis path or escalation — never "retry">

#### Step 2: <name>
```
<action>
```
**Expected result:**
**If it fails:**

<⚠ prefix any non-idempotent or destructive step; state the required confirmation per AGENT.md §4.2.>

### Verification (definition of done)
- [ ] <specific check with expected value — data outcomes, not just successful execution>
- [ ] Closeout block produced (AGENT.md §5)

### Troubleshooting
| Symptom | Likely cause | Fix |
|---|---|---|
| | | |

### Rollback
<How to undo. If a step cannot be undone, say so explicitly.>

### Escalation
<Global triggers (two failed fix attempts, missing credentials/access, spec-contradicting results, scope drift) are already covered by AGENT.md §6 for every runbook — do not restate them here. List only triggers specific to this runbook's domain.>
| Situation | Action |
|---|---|
| | |
