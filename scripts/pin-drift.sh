#!/usr/bin/env bash
# pin-drift.sh — report each consuming repo's agent-system pin against main.
#
# Usage: scripts/pin-drift.sh <search-root> [<search-root>...]
#        scripts/pin-drift.sh --depth 4 /c/GitHubRepoClone
#
# Makes README maintenance rule 3 executable: "The quarterly review includes a
# sweep of consuming repos for stale agent-system pins."
#
# Drift is NOT reported as failure. Advancing a pin is a deliberate RB-03 change
# (README, "Home & deployment": "adoption of new rules is chosen, never passive"),
# so a repo sitting behind main is a standing choice, not a defect. This script
# reports; a human decides. Exit: 0 = report produced, 2 = could not run.
#
# No registry of consuming repos is committed: their paths are machine-specific.
# Roots are passed in.

set -uo pipefail

DEPTH=3
REF=""
ROOTS=()
while [ $# -gt 0 ]; do
  case "$1" in
    --depth) DEPTH="${2:?--depth needs a number}"; shift 2 ;;
    --ref)   REF="${2:?--ref needs a path to an agent-system clone}"; shift 2 ;;
    -h|--help) sed -n '2,20p' "$0"; exit 0 ;;
    -*) printf 'ERROR unknown option: %s\n' "$1" >&2; exit 2 ;;
    *) ROOTS+=("$1"); shift ;;
  esac
done
[ "${#ROOTS[@]}" -gt 0 ] || { printf 'ERROR no search root given.\nUsage: %s <search-root> [...]\n' "$0" >&2; exit 2; }

UPSTREAM="https://github.com/sugarmtn/agent-system.git"

MAIN=$(git ls-remote "$UPSTREAM" refs/heads/main 2>/dev/null | awk 'NR==1{print $1}')
[ -n "$MAIN" ] || { printf 'ERROR could not read main from %s — no network, or the repo is not readable with these credentials.\n' "$UPSTREAM" >&2; exit 2; }

# Distance is measured against an agent-system clone. By default that is this
# script's own repo, since it ships inside agent-system; --ref overrides it when
# the script is run from a copy. The clone is never fetched here: a reporting
# script does not mutate a repo to produce a report. Where the clone lacks the
# commits, the status says so instead of guessing a number.
if [ -n "$REF" ]; then
  REF=$(git -C "$REF" rev-parse --show-toplevel 2>/dev/null)     || { printf 'ERROR --ref is not a git repository: %s
' "$REF" >&2; exit 2; }
else
  REF=$(git -C "$(dirname "$0")" rev-parse --show-toplevel 2>/dev/null || true)
fi

printf 'agent-system main: %s\n\n' "$MAIN"
printf '%-42s %-12s %-12s %s\n' "REPO" "PIN" "PINNED ON" "STATUS"
printf '%-42s %-12s %-12s %s\n' "------------------------------------------" "------------" "------------" "------"

found=0
while IFS= read -r gm; do
  dir=$(dirname "$gm")
  prefix=$(git -C "$dir" rev-parse --show-prefix 2>/dev/null) || continue
  [ -z "$prefix" ] || continue        # not a repo root (nested path inside one)

  sub=""
  while read -r key url; do
    case "$url" in
      *agent-system.git|*agent-system)
        name=${key#submodule.}; name=${name%.url}
        sub=$(git -C "$dir" config --file "$dir/.gitmodules" --get "submodule.$name.path")
        break ;;
    esac
  done < <(git -C "$dir" config --file "$dir/.gitmodules" --get-regexp '^submodule\..*\.url$' 2>/dev/null)
  [ -n "$sub" ] || continue

  found=$((found + 1))

  # The committed gitlink is the pin of record, whatever the working tree holds.
  pin=$(git -C "$dir" rev-parse "HEAD:$sub" 2>/dev/null || echo "")
  date=$(grep -iE 'pinned on' "$dir/CLAUDE.md" 2>/dev/null | grep -oE '[0-9]{4}-[0-9]{2}-[0-9]{2}' | head -1)

  if [ -z "$pin" ]; then
    status="no gitlink committed"
  elif [ "$pin" = "$MAIN" ]; then
    status="current"
  elif [ -n "$REF" ] && git -C "$REF" cat-file -e "$pin^{commit}" 2>/dev/null \
       && git -C "$REF" cat-file -e "$MAIN^{commit}" 2>/dev/null; then
    behind=$(git -C "$REF" rev-list --count "$pin..$MAIN" 2>/dev/null)
    ahead=$(git -C "$REF" rev-list --count "$MAIN..$pin" 2>/dev/null)
    if [ "${ahead:-0}" -gt 0 ]; then
      status="behind ${behind:-?}, ahead ${ahead} (off main)"
    else
      status="behind ${behind:-?}"
    fi
  else
    status="differs from main (no clone with both commits; pass --ref)"
  fi

  printf '%-42s %-12s %-12s %s\n' \
    "$(basename "$dir")" "$(printf '%.10s' "${pin:-none}")" "${date:-none}" "$status"
done < <(for r in "${ROOTS[@]}"; do find "$r" -maxdepth "$DEPTH" -name .gitmodules -type f 2>/dev/null; done | sort -u)

printf '\n%s consuming repo(s) found under: %s\n' "$found" "${ROOTS[*]}"
printf 'Pins behind main are deliberate choices, not defects — advancing one is its own RB-03 change (README, "Home & deployment").\n'
