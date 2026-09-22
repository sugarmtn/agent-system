# RB-05 — Agent-System Adoption

**Owner:** Alan Strutz | **Last updated:** 2026-09-22
**Applies to:** Bringing a repo under agent-system governance for the first time — submodule pin, `CLAUDE.md` wiring, and reconciling existing docs to the SPEC-AND-BUILD §4 naming scheme. **Not** advancing an existing pin (that is an RB-03 change, README "Home & deployment"), and not repos that host no system a SPEC/BUILD would describe.
**Load with:** AGENT.md + the agent-system README ("Home & deployment", "Project layering"). Change Gate per AGENT.md §3 — adoption is normally exempt (repo configuration, no production system touched); declare the exemption at the start.

### Purpose
Standardize first-time adoption so every governed repo loads AGENT.md the same way, pins deliberately, and states plainly which of its contents are governed and which are not. Repos that adopted before this runbook existed diverged on exactly these points — one wired the import so AGENT.md actually loads, two described it in prose and do not.

### Prerequisites
- [ ] Repo identified, working tree clean, and the human has confirmed this repo is an adoption target.
- [ ] The repo hosts at least one system a SPEC/BUILD would describe. A reference or context repo that hosts none is **out of scope** — say so and stop (Escalation).
- [ ] Adoption scope decided with the human: the whole repo, or named project folders only. Partial adoption is normal, not a defect.
- [ ] The exact agent-system commit SHA to pin, chosen deliberately. `main` is not an answer (README: pinning is mandatory).

### Procedure

#### Step 1: Add the submodule at the chosen SHA
```
git submodule add https://github.com/sugarmtn/agent-system.git agent-system
git -C agent-system checkout <sha>
git add .gitmodules agent-system
```
**Expected result:** `git submodule status` reports `<sha> agent-system`. The gitlink recorded in the parent repo is the chosen commit, not a branch tip.
**If it fails:** Clone/auth errors mean the private repo is not reachable by this session — hand to the human with the exact error; do not work around it by copying files in (README: "Never copy content into working repos"). If the repo already contains an `agent-system/` directory that is not a submodule, that is a prior copy-based adoption: stop and escalate, because removing it is destructive (§4.2).

#### Step 2: Wire `CLAUDE.md` so AGENT.md actually loads
```
Add as the first line of the governance section of the repo's CLAUDE.md:

@agent-system/AGENT.md
```
**Expected result:** A fresh session opened in the repo has AGENT.md's rules in context without being told to read anything. The `@` import is what loads the file.
**If it fails:** If the repo has no `CLAUDE.md`, create one with this as its first section. **If `CLAUDE.md` already instructs a session in prose to "load `agent-system/AGENT.md`", replace that prose with the import — prose is a request, not a load,** and a session that skips it is ungoverned without anyone noticing.

#### Step 3: Record the pin and its date in `CLAUDE.md`
```
| | |
|---|---|
| Agent-system pin | `<full 40-char sha>` |
| Pinned on | <date> |

Plus one sentence: advancing this pin is a deliberate RB-03 change, never
passive — `git -C agent-system fetch && git -C agent-system checkout <new-sha>`,
committed on its own.
```
**Expected result:** The SHA in `CLAUDE.md` matches `git submodule status` exactly. Sessions have the value they must record in the closeout `Agent-system:` line (AGENT.md §5.2) without inspecting git.
**If it fails:** A mismatch between the recorded SHA and the gitlink means one was advanced without the other. Correct both to the intended pin in the same change and state which was wrong.

#### Step 4: Declare the adoption boundary
```
In CLAUDE.md, state repo scope as a folder → system table, and name
explicitly any folder that predates adoption and is NOT yet governed.
```
**Expected result:** A fresh session can tell from `CLAUDE.md` alone which parts of the repo follow agent-system conventions. Unmigrated folders are named as unmigrated, with their migration identified as a separate future task.
**If it fails:** If the boundary cannot be stated because nobody knows which folders were built under which conventions, that is the finding — record it as an Open Item with a named owner rather than guessing. An unstated boundary lets a session assume conventions hold where they do not.

#### Step 5: Reconcile existing docs to the SPEC-AND-BUILD §4 naming scheme
```
Within the adopted scope only:
- SPEC/BUILD docs at a folder root → docs/SPEC.md, docs/BUILD.md
- README trimmed to entry-point scope (identity + links), per SPEC-AND-BUILD §4
- Any doc outside the scheme → flag it; do not silently rename or absorb it
```
**Expected result:** Adopted folders match SPEC-AND-BUILD §4. Out-of-scope folders are untouched and declared per Step 4.
**If it fails (a doc's correct home is genuinely unclear, or an existing instruction file conflicts with AGENT.md):** Do not subordinate it silently. Present the conflict and the options; a repo-level instruction file that contradicts AGENT.md is a §7 objection, raised as a `NEEDS YOU:` line before the reconciliation proceeds.

#### Step 6: Commit the adoption as one change
```
Commit together: .gitmodules, the agent-system gitlink, and CLAUDE.md.
Confirm .claude/settings.local.json is gitignored (machine-specific paths).
```
**Expected result:** One reviewable commit that a reader can see establishes governance, with the pin visible in the diff.
**If it fails:** If doc reconciliation from Step 5 is large enough to obscure the adoption itself, split it: adoption first, reconciliation second, per RB-03 discipline (one concern per change).

### Verification (definition of done)
- [ ] `git submodule status` reports the intended SHA, and it matches the SHA recorded in `CLAUDE.md`
- [ ] A fresh session in the repo has AGENT.md loaded via the `@` import — verified by opening one, not by reading the file
- [ ] `CLAUDE.md` records the pinned-on date and the RB-03 pin-advance rule
- [ ] Adoption boundary stated: every top-level folder is either governed or named as not-yet-governed
- [ ] Adopted docs match SPEC-AND-BUILD §4 naming; out-of-scope folders untouched
- [ ] No agent-system content copied into the repo — referenced by path only
- [ ] `.claude/settings.local.json` gitignored
- [ ] Closeout block produced (AGENT.md §5)

### Troubleshooting
| Symptom | Likely cause | Fix |
|---|---|---|
| | | |

*(Rows come from real incidents only — `templates/RUNBOOK-TEMPLATE.md`, authoring rule 3. Populate from adoption sessions as they happen, never speculatively.)*

### Rollback
Adoption is reversible up to the commit: `git submodule deinit -f agent-system`, `git rm -f agent-system`, and remove `.git/modules/agent-system`, then restore the prior `CLAUDE.md`. ⚠ These are destructive to the submodule working tree and require explicit confirmation per AGENT.md §4.2. Doc moves from Step 5 are reverted with `git revert` on that commit; if Step 6 was split as advised, reverting reconciliation does not undo governance.

### Escalation
| Situation | Action |
|---|---|
| Repo hosts no system a SPEC/BUILD would describe (reference or context repo) | Not an adoption target — say so and stop; do not adopt "for consistency" |
| An existing `agent-system/` directory is a copy, not a submodule | Stop; removal is destructive (§4.2) and the copy may have drifted — hand to the human with the diff against the intended pin |
| Repo-level instruction file contradicts AGENT.md | Present the conflict as a `NEEDS YOU:` line (§7); never resolve it by silently subordinating one to the other |
