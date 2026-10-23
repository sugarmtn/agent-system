#!/usr/bin/env bash
# new-repo.sh — mechanical half of RB-05 adoption. Deliberately not the whole thing.
#
# Usage:
#   scripts/new-repo.sh --target <path> --scope <text> --pin <40-char-sha>
#
# All three are REQUIRED and the script refuses to run without them. Each is a
# human decision RB-05 makes deliberately, and a default would convert a
# governance choice into something nobody notices:
#   --target  which folder becomes the repo. This IS RB-05 Step 0's choice:
#             the project folder (standalone) or the workspace folder (parent).
#   --scope   whole repo, or named project folders only (RB-05 Prerequisites).
#   --pin     the exact agent-system commit. "main" is not an answer
#             (README: pinning is mandatory).
#
# WHAT IT DOES (the part automation cannot get wrong):
#   Step 0  git init, if the target is not already a repo
#   Step 1  git submodule add, checked out at --pin, staged
#   Step 6  .claude/settings.local.json added to .gitignore
#   places  templates/CLAUDE-TEMPLATE.md as CLAUDE.md.draft, with the pin and
#           date filled in and every judgment placeholder left intact
#
# WHAT IT DOES NOT DO, AND WHY:
#   It never writes CLAUDE.md and never commits. RB-05 Steps 4 and 5 — the
#   adoption boundary and doc reconciliation — are judgments no argument can
#   carry. A generated CLAUDE.md with <folder> placeholders would satisfy every
#   mechanical check in scripts/verify-adoption.sh (import present, pin matches,
#   date present, boundary heading present) while declaring nothing. The draft
#   is therefore NOT named CLAUDE.md: until a human fills it and renames it,
#   verify-adoption.sh correctly reports that this repo has no CLAUDE.md.
#
# EXIT STATUS: 1 = mechanical setup done, governance content still missing.
#              2 = refused or failed. This script never exits 0: its job is
#              finished only when a human finishes Steps 2-6.

set -uo pipefail

TARGET=""; SCOPE=""; PIN=""
SUBPATH="agent-system"            # RB-05 Step 1. A different path is a deliberate
URL="https://github.com/sugarmtn/agent-system.git"   # deviation, done by hand.

die() { printf 'REFUSED %s\n' "$*" >&2; exit 2; }

while [ $# -gt 0 ]; do
  case "$1" in
    --target) TARGET="${2:?--target needs a path}"; shift 2 ;;
    --scope)  SCOPE="${2:?--scope needs a description}"; shift 2 ;;
    --pin)    PIN="${2:?--pin needs a 40-character sha}"; shift 2 ;;
    -h|--help) sed -n '2,40p' "$0"; exit 2 ;;
    *) die "unknown argument: $1" ;;
  esac
done

[ -n "$TARGET" ] || die "--target is required. Which folder becomes the repo is RB-05 Step 0's decision; this script will not pick one."
[ -n "$SCOPE" ]  || die "--scope is required. Whole repo or named folders only is an RB-05 Prerequisite decision; partial adoption is normal, but it is stated, not assumed."
[ -n "$PIN" ]    || die "--pin is required. The agent-system commit is chosen deliberately; README: pinning is mandatory."

case "$PIN" in
  main|master|HEAD|refs/*) die "--pin '$PIN' is a branch, not a pin. RB-05 Prerequisites: \"main is not an answer.\"" ;;
esac
printf '%s' "$PIN" | grep -qE '^[0-9a-f]{40}$' || die "--pin must be a full 40-character sha, got: $PIN"

HERE=$(cd "$(dirname "$0")" && pwd)
SELF_REPO=$(git -C "$HERE" rev-parse --show-toplevel 2>/dev/null || true)
TEMPLATE="$SELF_REPO/templates/CLAUDE-TEMPLATE.md"
[ -n "$SELF_REPO" ] && [ -f "$TEMPLATE" ] \
  || die "cannot find templates/CLAUDE-TEMPLATE.md next to this script — run it from a checkout of agent-system."

# The pin must actually exist. A typo'd sha would otherwise be pinned and
# recorded, and look entirely correct afterwards.
git -C "$SELF_REPO" cat-file -e "${PIN}^{commit}" 2>/dev/null \
  || die "commit $PIN is not in this agent-system clone. Fetch it first and confirm it is the commit you mean."

[ -d "$TARGET" ] || die "target folder does not exist: $TARGET"
TARGET=$(cd "$TARGET" && pwd)

# RB-05 Step 0's failure branch: adding a submodule inside someone else's repo
# would pin agent-system into a repo nobody intended to govern.
EXISTING=$(git -C "$TARGET" rev-parse --show-toplevel 2>/dev/null || true)
if [ -n "$EXISTING" ] && [ "$EXISTING" != "$TARGET" ]; then
  die "$TARGET sits inside the repo at $EXISTING. Adopting here would govern that repo, not this folder. Confirm the intended target with the human first (RB-05 Step 0)."
fi
[ -e "$TARGET/$SUBPATH" ] && die "$TARGET/$SUBPATH already exists — if it is a copy-based adoption, removal is destructive and must be confirmed (RB-05 Escalation, AGENT.md §4.2)."
[ -e "$TARGET/CLAUDE.md" ] && die "$TARGET/CLAUDE.md already exists — this repo may already be adopted. Run scripts/verify-adoption.sh against it instead."

printf 'Target: %s\nScope:  %s\nPin:    %s\n\n' "$TARGET" "$SCOPE" "$PIN"

# Step 0
if [ -z "$EXISTING" ]; then
  git -C "$TARGET" init -q || die "git init failed in $TARGET"
  printf 'Step 0  initialized a git repository at %s\n' "$TARGET"
else
  printf 'Step 0  already a git repository, left alone\n'
fi

# Step 1
git -C "$TARGET" submodule add -q "$URL" "$SUBPATH" || die "git submodule add failed"
git -C "$TARGET/$SUBPATH" checkout -q "$PIN" || die "could not check out $PIN in the submodule"
git -C "$TARGET" add .gitmodules "$SUBPATH" || die "could not stage the submodule"
printf 'Step 1  submodule added at %s and staged (not committed)\n' "$PIN"

# Step 6 mechanics
if ! grep -qF '.claude/settings.local.json' "$TARGET/.gitignore" 2>/dev/null; then
  printf '\n# Local agent tool settings — machine-specific paths, never shared\n.claude/settings.local.json\n' >> "$TARGET/.gitignore"
  printf 'Step 6  .claude/settings.local.json added to .gitignore\n'
else
  printf 'Step 6  .claude/settings.local.json already gitignored\n'
fi

# The draft — NOT CLAUDE.md, on purpose.
DRAFT="$TARGET/CLAUDE.md.draft"
sed -e "s|<full 40-char sha>|$PIN|" -e "s|<date>|$(date +%Y-%m-%d)|" "$TEMPLATE" > "$DRAFT" \
  || die "could not write $DRAFT"
printf '\n<!-- Scope declared at bootstrap (RB-05 Prerequisites): %s -->\n' "$SCOPE" >> "$DRAFT"
printf 'Draft   wrote %s with the pin and date filled in\n' "$DRAFT"

cat <<MSG

ADOPTION INCOMPLETE — by design. What remains is human work:

  Step 2  Confirm the @${SUBPATH}/AGENT.md import is a bare line in the draft.
  Step 4  Fill the adoption boundary table: every top-level folder named as
          governed or as not-yet-governed. Declared scope: ${SCOPE}
  Step 5  Reconcile existing docs to SPEC-AND-BUILD §4, within scope only.
  Then    Delete the authoring-rules comment, rename CLAUDE.md.draft to
          CLAUDE.md, and commit .gitmodules, the gitlink and CLAUDE.md
          together as one change (Step 6).

  Verify  scripts/verify-adoption.sh "$TARGET"
          It reports no CLAUDE.md until the rename, which is correct: an
          unfilled boundary table must not read as an adopted repo.
  Then    Open a fresh session in the repo and confirm AGENT.md is actually
          loaded. No script can check that for you (RB-05 definition of done).
MSG
exit 1
