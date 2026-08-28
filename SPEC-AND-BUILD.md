# SPEC-AND-BUILD.md — Living Project Documentation

**Owner:** Alan Strutz | **Last updated:** 2026-08-28 | **Load:** When the Change Gate (AGENT.md §3) applies, or when creating/updating project docs

Every project (app, pipeline, Azure configuration, integration) maintains exactly two living documents, plus optional modules and reference docs:

1. **SPEC** — *what* the system is and *why*: current requirements, scope, constraints. Written for the approver.
2. **BUILD** — *how* to construct the system from scratch: ordered, idempotent, parameterized steps. Written for a fresh session with no prior context.

Both are **as-built documents**: they always describe the system as it currently exists, written as if it was always designed this way. They contain no change history, no changelog sections, no "added in change X" annotations, and no execution evidence. Git history is the only record of how they evolved. A session loading them learns the current state and nothing else — that is the point.

**BUILD is an as-built configuration document, not a session execution plan.** Session plans are ephemeral (§2, stage 2). BUILD is executed in exactly one context: the rebuild test (§3).

**The rebuild standard (definition of correct docs):** a fresh session given only SPEC, BUILD, referenced modules/reference docs, and the required credentials could rebuild the entire system to its current state. Anything the rebuild would need that isn't in (or referenced by) these docs is a documentation defect.

---

## 1. Initial Creation

**SPEC first** (use `templates/SPEC-TEMPLATE.md`):

1. **Interrogate before writing.** Missing success criteria, sources/targets, environment, or constraints → ask first.
2. **Requirements are testable and numbered** (`R1, R2…`) so BUILD steps and verification can cite them. "Fast" is not a requirement; "full load completes in <15 min" is.
3. **Out-of-scope is mandatory and non-empty.**
4. **Open questions block approval.** The `## Open Questions` table must be resolved (or its recommendations explicitly accepted) before status moves to `Approved`. Resolve every row **one at a time** with the approver — present a single question (with options considered and the recommendation) and wait for a response before raising the next — never batch the table into one combined ask. Only once every row is resolved does the document go up for approval.
5. **One SPEC per system.** Independent systems get independent doc sets.

**BUILD is drafted after SPEC approval and kept current through implementation** (use `templates/BUILD-TEMPLATE.md`); it is approved at closeout certification (§2, stage 4):

1. **Traceability.** Every BUILD step cites the requirement(s) it realizes (`→ R3`); every requirement is realized by at least one step. Gaps in either direction are errors.
2. **Steps are desired-state and idempotent.** Each step converges the environment toward the target (create-or-update, `CREATE OR ALTER`, upsert, declarative config). Running BUILD against a half-built or fully-built environment must be safe. A step that cannot be made idempotent is marked `⚠ NON-IDEMPOTENT` with a guard check ("skip if X exists") preceding it.
3. **Parameterize the environment.** Resource names, tenant/company IDs, connection targets, and secret *names* live in the BUILD doc's Parameters table — steps reference parameters, never hardcode. This is what makes rebuild-into-dev and rebuild-into-prod the same document. **The Parameters table also pins tool and runtime versions** (runtime, CLI, key packages): two rebuilds must not diverge because "latest" changed between them.
4. **Each step carries a verification** with an expected value. Verification criteria are timeless ("row count matches source") — never session evidence ("matched on 2026-08-27").
5. **Modularize when complex.** BUILD.md may be an ordered index over `modules/BUILD-<component>.md` files (data layer, API layer, UI, deployment). Module boundaries follow rebuild-ordering seams, and each module states its dependencies on other modules. Sessions load only the modules the task touches. **Concrete trigger:** modularize when the system has two or more layers with a one-way rebuild dependency (a data layer that must exist before a UI layer can be built against it; a shared API layer other systems depend on) — one module per layer, each stating its dependencies. A single deployable layer stays single-file regardless of length. Growing hard to navigate in a single file (rule of thumb: ~150 lines of build steps) signals an undeclared seam to go find — not license to split a single-layer system for length alone.
6. **One execution per step.** A BUILD step admits exactly one execution. If a session must interpret, decide, or choose while executing a step, that is a documentation defect — stop and tighten the step (in a rebuild test, report it as a finding).

## 2. Change Workflow (the gate in practice)

Gated work — a new system or a change to an existing one — passes **four stages. Each stage is approved separately; never present two stages for one combined approval.** At every approval, the artifact is presumed **not** to satisfy the SPEC until an alignment section demonstrates it — conformance is shown, never assumed.

**Stage 1 — SPEC (intent).** Draft the SPEC (new system) or the SPEC diff (change; set the touched document's status to `Draft`). Requirements that arrived verbally are written down here (AGENT.md §3, requirement capture). Present what changes, what it affects, and what it deliberately does not touch. Approval per AGENT.md §3, recorded in the ledger format.

**Stage 2 — Execution plan (action).** Drafted only after SPEC approval. The plan is **ephemeral: chat-only, never committed** — but its *approval* is durable (ledger line in the implementing commit/PR message). The plan states: ordered steps for this implementation, target environment(s), named resources created or touched, blast radius, destructive operations flagged, and rollback points. **Alignment section required:** a requirement-by-requirement mapping (`Rn → plan step(s) x`); any requirement the plan does not address is flagged explicitly, never silently omitted; any plan content serving no requirement is flagged — that is scope creep surfacing. Approval covers the stated target environment(s) (AGENT.md §4.1b).

**Stage 3 — Implement.** Before the first implementing action, commit the **WIP marker**: a `WIP` block at the top of the affected BUILD doc (or `docs/WIP.md` when the change spans documents) carrying the plan-approval reference, target environment, the planned steps with a checkbox each, and the session date. Check steps off as they complete — the marker is the recovery map. **Deviation from the approved plan = stop and re-approve the delta** (the plan-level mirror of the material-change rule). Implement per the applicable runbook.

**Stage 4 — BUILD certification (record).** In the same session (AGENT.md §3a), update BUILD so a from-scratch rebuild now produces the changed system — rewrite affected steps as if the change had always been the design; do not append "modification" steps after original steps when the original step should simply read differently. (Genuine sequential steps — e.g., a migration that must run after a table exists — are fine; a step that merely edits an earlier step's output is not.) Verify both: the live change works (runbook verification), and the affected BUILD steps' verifications match current reality (doc↔reality reconciliation). Remove the WIP marker — **BUILD approval cannot be granted while a WIP block exists.** Present for approval: the Requirement Coverage table plus an explicit statement of any divergence between what was built and what the SPEC requires. On approval (ledger format), status returns to `Approved`. Evidence goes in the session closeout and the commit/PR message — never in the docs.

**WIP marker rules.** The WIP block is the **sole permitted transient content** in an as-built document; its presence means the document does not currently meet the as-built standard. **Any session loading a document containing a WIP block stops:** reconcile first — verify which checked/unchecked steps match reality, then either complete stage 4 or roll back per the plan's rollback points — before any new work on that system.

**Exempt work** (AGENT.md §3) skips the stage 1–2 approvals but declares the exemption, and §3a still applies in full: docs updated in the same session, declared in the closeout.

**As-built invariant (AGENT.md §3a):** a session that changes a system without completing stage 4 has not finished. "I'll update the docs later" is an open item that blocks closeout as complete.

## 3. Rebuild Discipline

- **Rebuild is the test of the docs.** Executing BUILD against a clean dev environment and comparing the result to the Acceptance section is the only proof the docs meet the rebuild standard. Divergence between docs and outcome is a defect in the docs, fixed before the triggering work closes.
- **Fixes discovered during a rebuild fold into BUILD before the rebuild counts as passed.** A rebuild that succeeded only because the session patched around a step is a *failed* test of the docs until the patch becomes the step.
- **Mandatory triggers:**
  1. **Ingestion-built databases:** any time a new source is added, or an existing source's definition changes (endpoint, schema, watermark, transformation) — execute BUILD for the affected scope against a clean dev target and reconcile counts before the change closes. For metadata-driven pipelines this is typically: apply the control-table and DDL steps to clean dev, run the load, reconcile per RB-01 Step 5.
  2. **All other systems — ruled at approval:** when the approver approves an execution plan (stage 2), the approval includes a rebuild ruling: `Rebuild test: required | not required`. Changes that span multiple BUILD modules or alter step ordering default to **required**; the approver may override with a stated reason. An approval missing the ruling is incomplete — ask.
- **Scope:** rebuild tests run at the affected-module scope by default; full-system rebuilds only when the change crosses module boundaries or the approver requires it.
- **Drift found in the live system** (someone changed reality without the docs): reconcile deliberately — either the docs adopt reality (retroactive change, approved) or reality is corrected to the docs. Never leave them disagreeing silently.

## Anti-patterns (reject on sight)

- A changelog, revision table, or "Change 7: …" section inside SPEC or BUILD → history lives in git only.
- BUILD steps that patch earlier steps' output ("Step 14: alter the table from Step 3") when Step 3 should simply define the final table.
- Hardcoded environment values in steps → belongs in the Parameters table.
- Committed execution plans or execution logs → plans are ephemeral, chat-only; only their outcome merges into BUILD.
- Any transient block in an as-built doc other than the WIP marker (§2, stage 3) — and a WIP block that outlives its change is itself a defect to reconcile.
- "Docs update deferred" in a closeout marked complete → the change isn't complete.
- A BUILD doc that assumes knowledge from prior sessions ("configure it the same way as the other pipeline") → fails the fresh-session rebuild standard.
- A BUILD step that requires interpretation to execute → tighten it (§1.6); two sessions must not be able to execute it differently.
