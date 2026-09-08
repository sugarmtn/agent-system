# RB-04 — Common AI Tasks

**Owner:** Alan Strutz | **Last updated:** 2026-09-07
**Applies to:** Research & vendor/tool evaluation, data analysis, document generation, data reconciliation & migration mapping. Four mini-procedures; load only the section matching the task.
**Load with:** AGENT.md. Change Gate: usually exempt (read-only) — declare it. Reconciliation/migration output that informs a cutover or migration decision is a gate **trigger** (AGENT.md §3); the gate mechanics for that case are defined in §4D below.
**Structure note:** these are mini-procedures, not full runbooks. They produce deliverables rather than system changes, so the per-step failure branches, Troubleshooting, and Rollback sections required by `templates/RUNBOOK-TEMPLATE.md` do not apply; Escalation is shared across all four sections. Definition-of-done lists carry the verification burden.

---

## 4A — Research & Evaluation

**Purpose:** Produce decision-grade research, not link dumps.

1. **Frame first.** Write the decision the research serves, the evaluation criteria (weighted if the human provides weights; ask if comparison order matters), and the candidate list. Confirm criteria with the human before deep research — criteria changes after research wastes the research.
2. **Currency rule.** Anything about products, pricing, versions, or vendor capabilities is verified against current sources in-session; training memory is a hypothesis, never a citation. Record source + access date per claim.
3. **Distinguish fact / vendor claim / inference.** Label each. Vendor-site claims are claims until corroborated by docs, demos, or references.
4. **Deliverable:** criteria matrix (candidates × criteria, each cell sourced), findings narrative, a dated recommendation with the conditions under which it would change, and explicit unknowns requiring vendor contact or trial.
5. **Definition of done:** every criterion has an answer or a documented unknown per candidate; recommendation is dated; no open evaluation left without a next action + owner.

## 4B — Data Analysis

**Purpose:** Answers that survive scrutiny.

1. **Restate the question** as a measurable claim to test, and confirm the population, grain, and time window before querying. Ambiguity here invalidates everything downstream — ask, don't guess.
2. **Profile before analyzing:** row counts, null rates on key columns, duplicate keys, min/max on dates. Report data-quality findings even when unasked — they bound the conclusions.
3. **Show the lineage:** every figure in the output traceable to a query/step that produced it. No orphan numbers.
4. **Validate:** at least one independent cross-check of the headline number (different method, known benchmark, or source-system total).
5. **Deliverable:** answer up front, method, caveats/data-quality notes, queries or notebook as an appendix/file. Row-level outputs follow AGENT.md §4.6: filed to the human-designated location, with the closeout recording where.
6. **Definition of done:** headline number cross-checked; caveats stated; reproducible artifact saved.

## 4C — Document Generation

**Purpose:** Documents that match audience and survive reuse.

1. **Confirm before drafting:** audience, purpose (inform/persuade/instruct), length target, format (file type), and tone reference (an existing doc to match, or explicit choice). Missing any of these → ask; a wrong-audience draft is a full rewrite.
2. **Facts in documents follow 4A's currency rule.** Numbers, dates, names, and system facts are verified or flagged `[VERIFY: …]` — never invented to fill a template. A placeholder is honest; a fabricated figure is a defect.
3. **One review pass minimum** against: every requirement/point the human listed is present; internal consistency (numbers match across sections); no unresolved placeholders unless flagged in the closeout.
4. **Change management per AGENT.md §6** for documents that will be revised (specs, proposals, evaluations): update in place, refresh the last-updated date. Ephemeral docs (a one-off email draft) are exempt.
5. **Definition of done:** delivered as a file, requirements checklist verified, `[VERIFY]` flags (if any) listed in the closeout.

## 4D — Reconciliation & Migration Mapping

**Purpose:** Trustworthy source↔target mappings and match results.

1. **Gate mechanics (AGENT.md §3 trigger).** When the output informs a cutover or migration decision, the **method note is the gate artifact**: match keys, tolerances, populations/snapshots used, the authoritative side when systems disagree, and bucket definitions — **approved before the full run**, recorded in the approval ledger format. There is no separate execution-plan stage: for analysis work, the method note *is* the plan. At closeout, the workbook is **certified against the approved method** — buckets sum, dispositions complete, method followed; any divergence from the approved method is flagged explicitly, never silently absorbed.
2. **Define match keys and tolerances up front** with the human: what constitutes a match, acceptable variance (default: zero), and the authoritative side when systems disagree. These rulings populate the method note.
3. **Work from complete populations,** not samples, for the final result. Samples are for method development only, and outputs are labeled SAMPLE until the full run.
4. **Every row lands in exactly one bucket:** matched / source-only / target-only / matched-with-variance. Buckets must sum to totals — publish the sum check.
5. **Variance rows get dispositions,** not deletions: each carries explanation, owner, or `unresolved`. Unresolved count is a headline metric, never a footnote.
6. **Deliverable:** the mapping/recon workbook (stable IDs per row, consistent column dictionary), summary tab with bucket totals + sum check, method note (keys, tolerances, run date, source snapshots used). The workbook is row-level data by design — file it per AGENT.md §4.6 to the human-designated location and record the location in the closeout.
7. **Definition of done:** buckets sum; every variance dispositioned or explicitly unresolved with owner; method note complete and matching the approved version; workbook filed and referenced in closeout.

---

### Escalation (all sections)
| Situation | Action |
|---|---|
| Question/criteria ambiguous after one clarification round | Present interpretations with recommendation; wait |
| Data quality invalidates the requested analysis | Report the DQ finding as the deliverable; propose remediation |
| Sources conflict on a decision-relevant fact | Present both with dates/provenance; do not average or pick silently |
