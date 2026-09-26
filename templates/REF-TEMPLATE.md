# REF — <Component / Topic Name>

| Field | Value |
|---|---|
| Owner | <person accountable for the system> |
| Last updated | <date> |
| Cited by | <the one BUILD module (docs/modules/BUILD-<component>.md), or "SPEC only" \| an approved-exception module list — SPEC-AND-BUILD §1c.3> |

> **As-built document, facts only.** No procedure (that's BUILD), no rationale (that's
> SPEC's Design Rationale), no changelog or dated entries — git holds the history. This
> doc has no `Draft | Approved` status of its own: it is certified alongside whichever
> BUILD module(s) cite it, at that module's stage 4 (SPEC-AND-BUILD §2).

> A `WIP` block may appear at the top of this document **only mid-change**
> (SPEC-AND-BUILD §2, stage 3), matching the citing module's own WIP marker. It is the
> sole permitted transient content here.

<!-- AUTHORING RULES (delete this block before committing):
1. One reference doc, one citing BUILD module, by default (SPEC-AND-BUILD §1c.3).
   Citing it from a second module needs an approved SPEC Design Rationale entry first —
   without one, split this doc along module lines instead.
2. Split when the facts serve more than one module's rebuild-ordering seam, or when a
   reader is scrolling past unrelated content to find what they need — not at a line
   count (SPEC-AND-BUILD §1c.5, §1b.5).
3. Content is current-state facts only: inventories, mappings, transformation logic,
   data contracts (field names, types, read/write payloads). If you're describing how
   to build something or why a choice was made, that content belongs in BUILD or SPEC
   instead — move it, don't duplicate it here.
-->

## <Inventory | Mapping | Data Contract | Transformation Logic — name the fact set>

<Fact tables/lists only, current state. Examples of shape, pick what fits:>

| <Object> | <Field> | <Type> | <Notes> |
|---|---|---|---|

<or, for a data contract:>

### <Screen / endpoint name>
| Direction | Field | Type | Source/target | Notes |
|---|---|---|---|---|
