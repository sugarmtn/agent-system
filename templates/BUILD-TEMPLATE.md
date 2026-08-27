# BUILD — <System Name>

| Field | Value |
|---|---|
| Status | Draft *(→ Approved at closeout certification, SPEC-AND-BUILD §2 stage 4; a material change returns it to Draft)* |
| Spec | docs/SPEC.md (Approved <date> by <n>) |
| Last updated | <date> |
| Owner | <person accountable for the system> |
| Runbook(s) | RB-<nn> <+ project runbook if any> |

> **As-built document.** Describes how to construct this system from scratch to its current state. No change history — git holds that. Every step is desired-state, safe to re-run against a partially or fully built environment, and admits exactly one execution (a step requiring interpretation is a doc defect — SPEC-AND-BUILD §1.6).

> A `WIP` block may appear at the top of this document **only mid-change** (SPEC-AND-BUILD §2, stage 3). Its presence means the doc does not currently meet the as-built standard: any session loading it stops and reconciles before new work. It is the sole permitted transient content here.

## Parameters
| Parameter | Dev | Prod | Notes |
|---|---|---|---|
| <resource/server/factory name> | | | |
| <tenant / company ID> | | | |
| <secret name (never value)> | | | Key Vault / secret store name |
| <tool/runtime version pin> | | | Runtime, CLI, key package versions — rebuilds must not diverge on "latest" |

Steps reference parameters as `{param}`. No environment values appear in steps.

> This table is the **environment catalog** — it names all environments and their values. It does not select a target. The target environment is chosen per session (AGENT.md §4.1): human statement, or the approved execution plan's stated target; otherwise the session must ask.

## Module Index *(delete section for single-file builds)*
| Order | Module | Depends on | Realizes |
|---|---|---|---|
| 1 | modules/BUILD-<component>.md | — | R1–R4 |
| 2 | modules/BUILD-<component>.md | 1 | R5–R8 |

## Prerequisites
- [ ] <access/permission, by name>
- [ ] <upstream systems that must exist — with pointer to their own BUILD docs if we own them>

## Build Steps

### Step 1 — <imperative name>  (→ R1)
- **Action:** <exact, desired-state: create-or-update / CREATE OR ALTER / declarative config, using {params}>
- **Expected state:** <what exists after this step>
- **Verify:** <timeless check + expected value — criteria, never dated evidence>
- **Idempotency:** <"re-run converges" or ⚠ NON-IDEMPOTENT + guard: "skip if <check>">

### Step 2 — <n>  (→ R2, R3)
- **Action:**
- **Expected state:**
- **Verify:**
- **Idempotency:**

## Requirement Coverage
| Req | Realized by step(s) |
|---|---|
| R1 | 1 |
| R2 | 2 |

<Every SPEC requirement appears here. Gaps in either direction = defect. **This table is presented at BUILD certification (SPEC-AND-BUILD §2, stage 4), alongside a statement of any divergence from the SPEC — approval is granted on the demonstrated mapping, never assumed.**>

## Acceptance (full-system verification)
<The end-to-end checks proving a completed build satisfies the SPEC's Success Criteria. Run after a full rebuild and after any change touching multiple steps.>
