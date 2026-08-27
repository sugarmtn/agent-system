# RB-01 — Data Ingestion

**Owner:** Alan Strutz | **Last updated:** 2026-08-27 | **Frequency:** As needed
**Applies to:** New ingestion pipelines, new sources/endpoints/tables added to existing pipelines, changes to ingestion logic, control-table entries.
**Load with:** AGENT.md (always) + the project's SPEC/BUILD docs (approved diff for changes; new docs for new pipelines).

### Purpose
Standardize how an AI session builds or modifies data ingestion so that every pipeline is metadata-driven, idempotent, verified by counts, and documented — regardless of source (API/OData, database, file drop).

### Prerequisites
- [ ] Approved spec naming: source system + object(s), target (server/database/schema/table), load pattern (full/incremental), schedule, environment.
- [ ] Auth method confirmed and secret names identified (never secret values). If OAuth2 client credentials: app registration exists on BOTH sides where the source requires it.
- [ ] Target environment resolved per AGENT.md §4.1 (in-session statement, or the approved execution plan's stated target); state which path applied.
- [ ] For incremental loads: watermark column identified and its semantics confirmed with the human (modified vs. created; timezone; nullability).

### Procedure

#### Step 1: Profile the source before writing anything
```
Pull 1–5 sample records via the actual auth path the pipeline will use
(e.g., authenticated GET against the endpoint; SELECT TOP 5 against the source table).
```
**Expected result:** Real payload/rows in hand; field list, types, and pagination/continuation behavior observed — not assumed from docs.
**If it fails:** Auth and connectivity are the problem, not the pipeline. Resolve fully (401/403 → registration/consent/scopes; 400 → URL construction) before proceeding. Do not build pipeline logic around an endpoint you cannot call.
**Note:** Fields with special characters (e.g., `@odata.etag`) require bracket-notation JSONPath: `$['@odata.etag']`.

#### Step 2: Define the target schema explicitly
```
Write the DDL (or dataset definition) for the target table, including:
data types mapped from observed source types, PK or dedupe key,
load-audit columns (load_ts, source_system, pipeline_run_id).
```
**Expected result:** DDL reviewed against sample data; no implicit type inference left to the ingestion tool.
**If it fails:** Ambiguous types (e.g., numeric-as-string, mixed date formats) → ask the human for the ruling; record it in the spec's Open Questions resolution.

#### Step 3: Register in the control table (metadata-driven pattern)
```
Add one row per source object to the ingestion control table:
source identifier/endpoint, target schema.table, load type, watermark column,
enabled flag, schedule group. Pipelines read this table; per-object
hardcoding in pipeline definitions is prohibited.
```
**Expected result:** New object appears in control table; generic pipeline picks it up via its ForEach/lookup without pipeline-definition changes.
**If it fails (pipeline requires structural change to accommodate the object): STOP — that is a separate task. Do not load RB-03.** Log an Open Item — `route to RB-03: pipeline enhancement — <what the structure needs>, owner: <human>` — continue with any objects the existing pattern accommodates, and close out early only if nothing else can proceed. The enhancement gets its own session, spec, and gate.

#### Step 4: Build/modify in dev, run against a bounded slice
```
Execute the pipeline for the new object with a limiting filter
(e.g., top N, single day) in the dev/test environment.
```
**Expected result:** Rows land in target; datatypes intact; audit columns populated.
**If it fails:** Capture the exact error text. Two fix attempts, then escalate with the error, the request URL/query as executed, and the sample payload.

#### Step 5: Full load + reconciliation
```
Run the full initial load. Then reconcile:
- COUNT(*) target vs. source count (same filter window)
- Spot-check 3+ rows field-by-field against source
- For incremental: run twice consecutively; second run must produce
  0 duplicates (idempotency proof).
```
**Expected result:** Counts match exactly or the variance is explained in writing (e.g., source-side soft deletes). Double-run produces no dupes. **Evidence is recorded minimized per AGENT.md §4.6:** which keys were spot-checked and the result — never the field values themselves.
**If it fails:** Do not "close enough" a count mismatch. Diff keys between source and target to locate the missing/extra population; fix root cause.

#### Step 6: Schedule, alert, document
```
Attach to schedule/trigger per spec. Confirm failure alerting routes to a
monitored channel. Update the endpoint/table reconciliation workbook or
inventory doc with the new mapping row.
```
**Expected result:** Trigger enabled in the specified environment only; inventory updated.
**If it fails:** An unmonitored pipeline is incomplete work — list alerting as an Open Item in the closeout, never omit it silently.

### Verification (definition of done)
- [ ] Reconciliation results (counts; keys spot-checked + result, per AGENT.md §4.6) and idempotency double-run evidence recorded in the closeout and commit/PR message — never in SPEC/BUILD
- [ ] BUILD doc updated per AGENT.md §3a: control-table row, target DDL, and watermark config reflected as current design
- [ ] Rebuild trigger satisfied (SPEC-AND-BUILD §3): for a new or changed source, the updated BUILD steps were executed against a clean dev target and reconciled — not just the live change verified
- [ ] Control-table row(s) present and enabled per spec
- [ ] Secrets referenced by name only anywhere the session wrote
- [ ] Inventory/mapping doc updated
- [ ] Closeout block produced (AGENT.md §5)

### Troubleshooting
| Symptom | Likely cause | Fix |
|---|---|---|
| 401 from source API | Missing/incorrect app registration or consent on source side; wrong token scope | Verify registration exists in the source system, not only in Entra; re-check scope/resource in token request |
| 400 from source API | Malformed URL (encoding, company/tenant segment, $filter syntax) | Reconstruct URL manually in an HTTP client until 200, then port back |
| Nulls in fields that have data at source | JSONPath/mapping miss (special-char field names) | Use bracket notation `$['field']`; re-check mapping against raw payload |
| Duplicates after re-run | Load not keyed; watermark overlap without merge | Switch to MERGE/upsert on the dedupe key; never band-aid with post-hoc DELETE |
| Row counts drift over time | Source soft-deletes or updates outside watermark | Confirm delete-detection requirement with human; may need periodic full compare |

### Rollback
Disable the control-table row (enabled flag) and/or the trigger; drop or truncate the target table **only with explicit confirmation** (AGENT.md §4.2). Control-table pattern means rollback never requires pipeline-definition surgery. (These reversible interventions are also the permitted break-glass containment actions — AGENT.md §3b.)

### Escalation
| Situation | Action |
|---|---|
| Auth requires tenant-admin consent or new registration | Hand to human with exact registration/scope needed |
| Source data quality contradicts spec assumptions | Stop; update spec Open Questions; await ruling |
| Two failed fix attempts on the same error | AGENT.md §7 escalation with full evidence |
