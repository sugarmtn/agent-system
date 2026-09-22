# RB-03 — Maintaining & Updating Code

**Owner:** Alan Strutz | **Last updated:** 2026-09-22
**Applies to:** Bug fixes, enhancements, refactors, dependency updates, config changes to existing code/pipelines/apps.
**Load with:** AGENT.md. Change Gate: AGENT.md §3 applies (its exemption/trigger precedence rule decides gate-or-exempt here) — declare which at the start. §3a applies regardless: if the fix alters what a rebuild should produce, update BUILD in the same session.

### Purpose
Ensure changes to existing systems are minimal, reversible, verified against a reproduced baseline, and never mix concerns.

### Evidence Minimization
Business data appears in commits, PR messages, closeouts, and committed docs only as keys, counts, aggregates, hashes, or masked values. Raw row contents may be displayed in-session for verification, but the durable record states which keys were checked and the result ("3 rows spot-checked field-by-field: match") — never the field values themselves. Deliverables whose *purpose* is row-level data (reconciliation workbooks, mapping files) are exempt in content but are filed to the location the human designates — not committed to code or agent-system repos by default — and the closeout records that location. A project's agent-context file (`CLAUDE.md` in Claude Code; the project instructions in a hosted project) may relax this rule explicitly for genuinely non-sensitive data.

### Prerequisites
- [ ] The change target identified precisely: repo/branch, or pipeline/object name + environment.
- [ ] For bugs: the failure is **reproduced** before any code is touched. A bug you cannot reproduce is investigated, not fixed.
- [ ] Version control state clean (no unrelated uncommitted changes mixed in). For non-git assets (e.g., pipeline definitions), capture the current definition (export/JSON) as the baseline before editing.
- [ ] Blast radius stated: what consumes the thing being changed (downstream pipelines, reports, callers).

### Procedure

#### Step 1: Reproduce and baseline
```
Bugs: run the failing case; capture exact error/wrong output.
Enhancements/refactors: run the current behavior; capture output as baseline.
Record both in the session.
```
**Expected result:** A concrete before-state to diff the after-state against.
**If it fails (cannot reproduce):** Stop. Gather environment/data-dependency details from the human. Never fix by pattern-matching a symptom you haven't seen.

#### Step 2: Locate root cause before editing
```
Trace the failure to a specific line/expression/config value. State the
root cause in one sentence. If the sentence contains "probably," keep digging.
```
**Expected result:** Named root cause, distinguishable from the symptom.
**If it fails:** Add targeted logging/inspection; do not shotgun-edit.

#### Step 3: Smallest correct change
```
Edit only what the root cause requires. No drive-by refactors, renames,
formatting, or dependency bumps in the same change. If adjacent problems
are found, list them in the closeout as follow-ups.
```
**Expected result:** A diff a reviewer can read in one pass, all of it about one thing. (A regression test for the fixed bug is part of the fix, not a drive-by — Step 4.)
**If it fails (fix genuinely requires broader restructuring): STOP — that is no longer a maintenance change; it is a separate task. Do not load RB-01/RB-02.** Log an Open Item — `route to Change Gate: <restructuring needed>, owner: <human>` — and close out this task with the bug's current state documented. The restructure enters the gate (SPEC diff → execution plan) in its own session.

#### Step 4: Verify fix + no regression
```
1. Re-run the Step-1 failing case → now passes.
2. Re-run the existing test suite if one exists.
3. Run at least one adjacent case that SHOULD be unaffected → unchanged
   vs. baseline (regression check).
4. Data-touching changes: verify the DATA outcome (counts/values), not
   just successful execution.
5. If a test harness exists for the affected code: the Step-1 failing
   case becomes a committed test in the same change — it must fail
   before the fix and pass after. If no harness exists, or the failure
   cannot practically be encoded (environment-, volume-, or
   external-system-dependent), declare that in the closeout as an open
   item — untestable fixes are a standing risk, same as unversioned assets.
```
**Expected result:** All of the above recorded with evidence (minimized per Evidence Minimization above where data is involved).
**If it fails:** Two attempts, then escalate. If the fix passes but the regression check changes, the fix is wrong even if the bug is gone.

#### Step 5: Commit with traceable history
```
One logical change per commit. Message: what + why (issue/task reference
if one exists), imperative mood, plus the approval ledger line where the
gate applied (AGENT.md §3). Never commit secrets, commented-out
"just in case" blocks, or debug output.
For non-git assets: store the new exported definition alongside the
baseline with a dated note.
```
**Expected result:** History that explains itself six months later.
**If it fails (no repo / no versioning exists for the asset):** Flag as an open item — unversioned production assets are a standing risk.

#### Step 6: Dependency updates (when that's the task)
```
Update one dependency (or one coherent group) at a time. Read its
changelog for breaking changes BEFORE updating. Run the full verification
from Step 4 after. Pin exact versions in the manifest/lockfile.
```
**Expected result:** Each bump independently verified and revertible.
**If it fails:** Revert that bump only; record the incompatibility.

### Verification (definition of done)
- [ ] Step 4's checks passed: failing case now passes, regression checked, regression test committed or its absence declared
- [ ] Diff contains only the intended change
- [ ] Committed/exported with baseline preserved
- [ ] Downstream consumers from Prerequisites checked or explicitly deferred with reason
- [ ] BUILD doc checked: updated if the change alters rebuild output, or "no doc impact" declared (§3a)
- [ ] Closeout block produced

### Troubleshooting
| Symptom | Likely cause | Fix |
|---|---|---|
| Fix works in dev, fails in prod | Config/env drift; data shape difference | Diff configs; test against prod-shaped data (sanitized) |
| Test suite fails on untouched areas | Pre-existing failures | Baseline the suite before your change; only new failures are yours — but report pre-existing ones |
| "Fixed" bug returns | Symptom patched, root cause live | Return to Step 2; the one-sentence root cause was wrong |
| Merge conflicts on long-running change | Change too big / branch too old | Split the change; rebase early and often |

### Rollback
Git: revert commit (never force-push shared branches without confirmation — AGENT.md §4.2). Non-git assets: restore the Step-1 baseline export. Data changes: reverse using audit columns/run ID, with confirmation.

### Escalation
| Situation | Action |
|---|---|
| Root cause sits in code/config the session can't access | Hand off with the trace evidence |
| Fix requires prod data correction | Change Gate + explicit human sign-off on the correction statement |
