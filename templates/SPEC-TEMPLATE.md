# SPEC — <System Name>

| Field | Value |
|---|---|
| Status | Draft *(→ Approved per the gate; a material change returns it to Draft)* |
| Last updated | <date> |
| Owner | <person accountable for the system> |
| Approver | <name> |
| Approved date | — |
| Build doc | docs/BUILD.md (drafted after approval; certified at closeout) |

<The sections below are required. Domain sections may be added after them — but content
with a designated home goes there: construction steps in BUILD, inventories, mappings and
transformation logic in docs/reference/. SPEC states what the system is and why, never how
it is built.>

## Problem / Objective
<2–4 sentences: what this system does and why it exists. Present tense, current state — as-built, no history. Business language, no implementation detail.>

## Success Criteria
<How the approver will know this worked. Measurable. e.g., "Table X refreshes daily by 06:00 in the target timezone with row counts matching source ±0."
Where a criterion could be read as proving more than it does, state what it does not
establish — e.g. "matching counts do not establish field-level correctness.">

## Requirements
| ID | Requirement (testable) | Priority (Must/Should) |
|---|---|---|
| R1 | | Must |
| R2 | | |

<Requirements may be stated negatively. A behavior the system must never exhibit
("never deletes target rows", "never writes to the source") is a requirement with its
own Rn — it needs a BUILD step and a verification the same way a positive one does.>

## Constraints
<Hard boundaries: environments, platforms, auth methods, budget/credits, deadlines, standards that must be followed. e.g., "Managed compute only — no self-hosted runtimes." "No new datasets in the BI platform." "OAuth2 client credentials only — no interactive auth.">

## In Scope / Out of Scope
**In:** <bullet list>
**Out:** <bullet list — mandatory, must be non-empty>

## Inputs & Dependencies
<Source systems, credentials (by secret name only), upstream work that must exist first, people who must provide something.>

## Risks
| Risk | Impact | Mitigation |
|---|---|---|

## Design Rationale
<Why the system is shaped this way — the decisions a competent fresh session
might otherwise reverse. Written timelessly: state what is true and why it
holds, never how it came to be. Omit choices with no live alternative.
An abstraction that exists to admit future work is rationale — say why it exists.
A plan for that future work is not: roadmaps are not as-built content.>

### <The decision, as a present-tense statement of what is true>
<Why it holds. The alternative rejected, and what it would have cost.>

## Open Questions
| # | Question | Options considered | Recommended | Owner | Resolved? |
|---|---|---|---|---|---|

> Spec cannot be Approved while any row is unresolved, unless approver explicitly accepts the recommendations.
