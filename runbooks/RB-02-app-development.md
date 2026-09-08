# RB-02 — Building Apps

**Owner:** Alan Strutz | **Last updated:** 2026-09-07
**Applies to:** New applications and new user-facing features: web apps, internal tools, custom-coded and low-code platform apps, dashboards with interactivity.
**Load with:** AGENT.md + the project's SPEC/BUILD docs. New apps always pass the Change Gate (SPEC → execution plan → implement → BUILD certification) — no exceptions.

### Purpose
Standardize how an AI session builds an app: contract-first (data and API shapes before UI), walking skeleton before features, platform constraints verified before code is written against them.

### Prerequisites
- [ ] Approved spec including: users/roles, the workflows the app must support (as numbered requirements), data sources with read/write directions, target platform, and explicit out-of-scope list.
- [ ] Platform capabilities verified, not remembered — check current docs for the target platform's constraints (auth model, storage APIs, deployment path, package/manifest requirements) before designing around them.
- [ ] Design inputs: existing app to match, style guide, or explicit "agent's choice." If none stated → ask; do not default silently.
- [ ] Write-back targets (if any) identified with their permission model.

### Procedure

#### Step 1: Define the data contract first
```
For every screen/feature: write the read queries/API calls and the
write payloads it needs, with field names and types, before any UI code.
Validate each against the real backend (execute the query / call the API once).
```
**Expected result:** A data-contract section in the BUILD doc listing every data interaction, each proven to return/accept real data.
**If it fails (backend gap found): STOP on that feature — the gap is a separate task. Do not load RB-01.** Log an Open Item — `route to RB-01: <object/endpoint needed>, owner: <human>` — pause only the blocked feature, and continue on features whose contracts validated. Close out early only if every feature is blocked. Finding the gap this early is cheap; the ingestion work gets its own session and gate.

#### Step 2: Walking skeleton
```
Build the thinnest end-to-end slice: app shell + one screen + one real
data read + deploy/run via the platform's actual deployment path.
```
**Expected result:** The app runs where it will live (not just locally), displaying real data. Deployment mechanics (manifests, package mappings, build steps) are proven now.
**If it fails:** Deployment/packaging issues (e.g., missing manifest entries, proxy config) are resolved before any feature work — they don't get easier with more code on top.

#### Step 3: Features in requirement order
```
Implement one numbered requirement at a time. After each:
run it, exercise the happy path AND one failure path (empty data,
bad input, permission denied), check the browser/platform console for errors.
```
**Expected result:** Each requirement demonstrably works before the next begins; evidence recorded in the closeout/commits, and affected BUILD steps kept current as the design settles.
**If it fails:** Fix within the feature; if the fix requires touching the contract from Step 1, update the contract section explicitly — silent contract drift is how apps rot.

#### Step 4: State, errors, and empty states
```
Sweep every screen for: loading state, empty state, error state
(user-readable message, no raw stack traces/JSON), and unsaved-changes
handling on any write surface.
```
**Expected result:** No screen renders blank or throws to console on empty/failed data.
**If it fails:** These are requirements, not polish. Treat gaps as defects.

#### Step 5: Write-path safety
```
For every write/save/send action: confirm destructive actions prompt,
writes are validated before send, failures surface to the user, and the
action is either idempotent or guarded against double-submit.
```
**Expected result:** Documented in the BUILD doc: each write action + its guard (it's part of the design, not session evidence).
**If it fails:** Block release of that feature.

#### Step 6: Handoff package
```
Confirm the BUILD doc passes the rebuild standard: a fresh session could
construct and deploy this app from docs/SPEC.md + docs/BUILD.md alone
(deployment path, manifests, config/secrets by name, platform gotchas as
design notes). Walk one named user (from the SPEC) through the primary workflow.
```
**Expected result:** A person (or session) that is not you can rebuild, deploy, and use it from the project docs alone.
**If it fails (user walkthrough surfaces mismatch):** Mismatch vs. spec = defect, fix. New desire beyond SPEC = Change Gate (SPEC diff, approval), not silent scope add.

### Verification (definition of done)
- [ ] Every SPEC requirement has recorded pass evidence (closeout/commits)
- [ ] Failure/empty states verified per screen
- [ ] Deployed via the real deployment path, not only local
- [ ] BUILD doc meets the rebuild standard and was sanity-checked once from scratch
- [ ] No secrets in code, config committed, or chat
- [ ] Closeout block produced

### Troubleshooting
| Symptom | Likely cause | Fix |
|---|---|---|
| Works locally, 404/proxy errors deployed | Platform manifest/routing entry missing (e.g., package mapping) | Compare manifest against platform docs field-by-field; fix manifest, redeploy |
| Auth works in tool, fails in app | Different auth context (user vs. service, missing scope) | Log the identity the app actually runs as; align permissions to it |
| UI shows stale data after writes | Client cache / no refetch on mutate | Refetch or update local state on successful write |
| Platform API rejects payload accepted in testing | Env config drift between dev and prod instances | Diff env configs; parameterize, don't fork |

### Rollback
Apps: previous deployed version restored via the platform's version/deployment history; if none exists, that is a Step-2 finding — establish one before feature work. Data written by the app: identify by audit columns/run ID and reverse with human confirmation.

### Escalation
| Situation | Action |
|---|---|
| Platform lacks a capability the spec assumes | Stop; document the gap with doc reference; spec revision |
| Design/UX decision with user-facing consequence and no guidance | Ask with 2–3 options described concretely (layout, behavior, and the tradeoff of each); build nothing until one is chosen. A rendered mock is produced only if the human asks for one to decide |
| Two failed attempts on same platform error | AGENT.md §7 |
