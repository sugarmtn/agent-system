#!/usr/bin/env bash
# verify-adoption.sh — mechanical checks for RB-05's definition of done.
#
# Usage: scripts/verify-adoption.sh [repo-path]        (default: current directory)
#
# Checks the mechanical items only. It deliberately does NOT check that a fresh
# session actually loads AGENT.md: RB-05 requires that be verified by opening a
# session, and no amount of file inspection substitutes for it.
#
# Exit status: 0 = all checks passed, 1 = one or more failed, 2 = could not run.

set -uo pipefail

REPO="${1:-.}"
fail=0

pass() { printf 'PASS  %s\n' "$*"; }
bad()  { printf 'FAIL  %s\n' "$*"; fail=1; }
die()  { printf 'ERROR %s\n' "$*" >&2; exit 2; }

ROOT=$(git -C "$REPO" rev-parse --show-toplevel 2>/dev/null) \
  || die "not a git repository: $REPO  (RB-05 Step 0 establishes one)"

[ -f "$ROOT/.gitmodules" ] || die "no .gitmodules in $ROOT — agent-system is not a submodule here"

# Find the agent-system submodule by URL, not by assuming its path: a repo may
# mount it at .agent-system or elsewhere, and a hardcoded path would skip it.
SUB=""
while read -r key url; do
  case "$url" in
    *agent-system.git|*agent-system)
      name=${key#submodule.}; name=${name%.url}
      SUB=$(git -C "$ROOT" config --file "$ROOT/.gitmodules" --get "submodule.$name.path")
      break ;;
  esac
done < <(git -C "$ROOT" config --file "$ROOT/.gitmodules" --get-regexp '^submodule\..*\.url$' 2>/dev/null)

[ -n "$SUB" ] || die "no agent-system submodule declared in $ROOT/.gitmodules"
printf 'Repo: %s\nAgent-system submodule path: %s\n\n' "$ROOT" "$SUB"

# 1. Tracked as a gitlink, not copied files.
mode=$(git -C "$ROOT" ls-files -s -- "$SUB" | awk 'NR==1{print $1}')
if [ "$mode" = "160000" ]; then
  pass "agent-system is tracked as a gitlink (mode 160000), not copied files"
else
  bad "agent-system is tracked as mode '${mode:-<untracked>}', not 160000 — content may be copied in (README: never copy content into working repos)"
fi

# 2. Submodule initialized, not an empty directory (silent-failure case).
st=$(git -C "$ROOT" submodule status -- "$SUB" 2>/dev/null)
case "$st" in
  -*) bad "submodule not initialized — '$SUB/' is an empty directory, so the @$SUB/AGENT.md import resolves to nothing and sessions run UNGOVERNED with no error. Fix: git submodule update --init" ;;
  *)  if [ -f "$ROOT/$SUB/AGENT.md" ]; then
        pass "submodule initialized — $SUB/AGENT.md is present"
      else
        bad "$SUB/AGENT.md is missing although the submodule looks initialized — the import resolves to nothing, silently"
      fi ;;
esac

CM="$ROOT/CLAUDE.md"
if [ ! -f "$CM" ]; then
  bad "no CLAUDE.md at repo root — nothing imports AGENT.md (RB-05 Step 2)"
  printf '\nSkipping the four CLAUDE.md checks.\n'
else
  flat=$(tr '\n' ' ' < "$CM")

  # 3. The import is present as a bare line. Compared literally, line by line:
  #    a built regex has to escape the submodule path (.agent-system contains a
  #    dot) and getting that wrong silently mis-reports a correct repo.
  import_ok=0
  while IFS= read -r line || [ -n "$line" ]; do
    line=${line%$''}
    line="${line#"${line%%[![:space:]]*}"}"
    line="${line%"${line##*[![:space:]]}"}"
    [ "$line" = "@$SUB/AGENT.md" ] && { import_ok=1; break; }
  done < "$CM"
  if [ "$import_ok" -eq 1 ]; then
    pass "@$SUB/AGENT.md present as a bare line"
  else
    bad "@$SUB/AGENT.md is not present as a bare line — prose asking a session to read it is a request, not a load (RB-05 Step 2)"
  fi

  # 4. Recorded pin matches the gitlink exactly.
  pin_git=$(printf '%s' "$st" | sed -E 's/^[-+U ]//' | awk '{print $1}')
  pin_doc=$(grep -oiE '[0-9a-f]{40}' "$CM" | head -1)
  if [ -z "$pin_doc" ]; then
    bad "no 40-character SHA recorded in CLAUDE.md — 'main' is not a pin (README: pinning is mandatory)"
  elif [ "$(printf '%s' "$pin_doc" | tr 'A-Z' 'a-z')" = "$(printf '%s' "$pin_git" | tr 'A-Z' 'a-z')" ]; then
    pass "recorded pin matches the gitlink ($pin_git)"
  else
    bad "pin mismatch — CLAUDE.md says $pin_doc, gitlink is $pin_git. One was advanced without the other (RB-05 Step 3)"
  fi

  # 5. Pinned-on date recorded.
  if grep -iE 'pinned on' "$CM" | grep -qE '[0-9]{4}-[0-9]{2}-[0-9]{2}'; then
    pass "pinned-on date recorded"
  else
    bad "no pinned-on date recorded in CLAUDE.md (RB-05 Step 3)"
  fi

  # 6. RB-03 pin-advance rule recorded.
  if printf '%s' "$flat" | grep -qiE 'advanc(e|ing)[^.]{0,80}RB-03'; then
    pass "RB-03 pin-advance rule recorded"
  else
    bad "CLAUDE.md does not state that advancing the pin is a deliberate RB-03 change (RB-05 Step 3)"
  fi

  # 7. Adoption boundary section present.
  if grep -qiE '^#{1,6}[[:space:]]+adoption boundary' "$CM"; then
    pass "adoption boundary section present"
  else
    bad "no 'Adoption boundary' heading in CLAUDE.md — this looks for the heading the template standardizes; a boundary described only in prose does not satisfy RB-05 Step 4's folder-to-system table, so review by hand before treating this as clean"
  fi
fi

# 8. Machine-specific agent settings not tracked.
if git -C "$ROOT" check-ignore -q .claude/settings.local.json 2>/dev/null; then
  pass ".claude/settings.local.json is gitignored"
else
  bad ".claude/settings.local.json is not gitignored — it holds machine-specific paths (RB-05 Step 6)"
fi

printf '\nNOT CHECKED HERE (human verification, RB-05 definition of done):\n'
printf '  - A fresh session in this repo actually has AGENT.md loaded. Verify by opening\n'
printf '    a session, not by reading the file. This script cannot stand in for it.\n'
printf '  - Adopted docs match SPEC-AND-BUILD §4 naming (judgment, not mechanical).\n'
printf '  - Closeout block produced (AGENT.md §5).\n'

if [ "$fail" -ne 0 ]; then
  printf '\nRESULT: FAILED\n'; exit 1
fi
printf '\nRESULT: all mechanical checks passed\n'
