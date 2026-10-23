# <repo name>

<One line: what this repo is.>

## Governance

@agent-system/AGENT.md

| | |
|---|---|
| Agent-system pin | `<full 40-char sha>` |
| Pinned on | <date> |

Advancing this pin is a deliberate RB-03 change, never passive —
`git -C agent-system fetch && git -C agent-system checkout <new-sha>`,
committed on its own.

## Adoption boundary

| Folder | System | Governed |
|---|---|---|
| `<folder>/` | <the system it hosts> | Yes |
| `<folder>/` | <what it is> | No — predates adoption; migration is a separate task |
| `agent-system/` | Submodule — not this repo's content | n/a |

<Where nothing predates adoption, say so in one sentence instead of listing
exceptions — e.g. "No folder predates adoption; the repo was empty when
agent-system was adopted on <date>.">

## <Repo-specific context>

<Resource names, conventions, and gotchas for this repo only — instance context,
never a restatement of runbook procedure (README, "Project layering"). This
section goes LAST: the governance import above is the stable prompt prefix, and
task-specific content placed ahead of it busts prompt caching (README, "Load
order matters for prompt caching").>

<!-- AUTHORING RULES (delete this block before committing):
1. The `@agent-system/AGENT.md` line stands alone, nothing else on it. Prose asking a
   session to "read agent-system/AGENT.md" is a request, not a load — a session that
   skips it is ungoverned and nothing reports the omission (RB-05 Step 2).
2. The import path must match the submodule path actually used. RB-05 Step 1 adds it at
   `agent-system`; a repo that added it elsewhere (e.g. `.agent-system`) must say so
   here — a wrong path resolves to nothing, silently (RB-05 Troubleshooting).
3. The pin is the full 40-character SHA and must equal `git submodule status` exactly
   (RB-05 Step 3). `main` is not a pin (README: pinning is mandatory).
4. Every top-level folder appears in the adoption boundary table, as governed or as
   not-yet-governed. An unstated boundary lets a session assume conventions hold where
   they do not (RB-05 Step 4).
5. Never copy agent-system content into this file — reference runbooks and templates by
   path (README, "Consumption": copies drift).
6. Update in place; git history is the change record (SPEC-AND-BUILD §4).
-->
