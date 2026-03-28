#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<USAGE
Usage: $0 <project-root-path> [--profile default|focus-cut]

Ranks projects from docs/active and docs/backlog and returns:
- one top recommendation (next best thing)
- two alternates
- first concrete step for each

Outputs directly to terminal/chat. No files are written.
USAGE
}

PROJECT_ROOT_INPUT=""
PROFILE="focus-cut"

while [ "$#" -gt 0 ]; do
  case "$1" in
    --profile)
      shift
      if [ "$#" -eq 0 ]; then
        echo "Missing value for --profile" >&2
        exit 1
      fi
      PROFILE="$1"
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    -* )
      echo "Unknown option: $1" >&2
      usage >&2
      exit 1
      ;;
    *)
      if [ -n "$PROJECT_ROOT_INPUT" ]; then
        echo "Only one project root path is supported." >&2
        usage >&2
        exit 1
      fi
      PROJECT_ROOT_INPUT="$1"
      ;;
  esac
  shift
done

if [ -z "$PROJECT_ROOT_INPUT" ]; then
  usage >&2
  exit 1
fi

if [ "$PROFILE" != "default" ] && [ "$PROFILE" != "focus-cut" ]; then
  echo "Invalid profile: $PROFILE (expected default|focus-cut)" >&2
  exit 1
fi

if [ ! -d "$PROJECT_ROOT_INPUT" ]; then
  echo "Project root path not found: $PROJECT_ROOT_INPUT" >&2
  exit 1
fi

PROJECT_ROOT="$(cd "$PROJECT_ROOT_INPUT" && pwd)"
ACTIVE_DIR="$PROJECT_ROOT/docs/active"
BACKLOG_DIR="$PROJECT_ROOT/docs/backlog"

if [ ! -d "$ACTIVE_DIR" ] || [ ! -d "$BACKLOG_DIR" ]; then
  echo "Expected docs directories not found under: $PROJECT_ROOT/docs/{active,backlog}" >&2
  exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/lib-project-prioritization.sh"

TMP_TSV="$(mktemp)"
trap 'rm -f "$TMP_TSV"' EXIT

while IFS= read -r -d '' file; do
  score_project_item "$PROJECT_ROOT" "$file" "$PROFILE" >> "$TMP_TSV"
done < <(find "$ACTIVE_DIR" "$BACKLOG_DIR" -type f -name '*.md' -print0 | sort -z)

TOTAL_ITEMS="$(wc -l < "$TMP_TSV" | tr -d ' ')"
REFUSED_COUNT="$(awk -F'\t' '$4=="refuse"{c++} END{print c+0}' "$TMP_TSV")"

CANDIDATES="$(awk -F'\t' '$4=="do-now"{print}' "$TMP_TSV" | sort -t $'\t' -k7,7nr -k10,10nr -k12,12n)"
CANDIDATE_CLASS="do-now"
if [ -z "$CANDIDATES" ]; then
  CANDIDATES="$(awk -F'\t' '$4=="reshape"{print}' "$TMP_TSV" | sort -t $'\t' -k7,7nr -k10,10nr -k12,12n)"
  CANDIDATE_CLASS="reshape"
fi

if [ -z "$CANDIDATES" ]; then
  echo "# Next Best Thing"
  echo
  echo "- project_root: $PROJECT_ROOT"
  echo "- decision_profile: $PROFILE"
  echo "- item_count: $TOTAL_ITEMS"
  echo "- all items currently classify as refuse"
  echo
  echo "No actionable candidate was found."
  exit 0
fi

TOP_ONE="$(printf '%s\n' "$CANDIDATES" | sed -n '1p')"
ALT_ONE="$(printf '%s\n' "$CANDIDATES" | sed -n '2p')"
ALT_TWO="$(printf '%s\n' "$CANDIDATES" | sed -n '3p')"

print_candidate_block() {
  local row="$1"
  local label="$2"

  if [ -z "$row" ]; then
    echo "### $label"
    echo
    echo "- none"
    echo
    return
  fi

  local abs rel bucket decision action appetite final adjusted core importance pull risk completion reason refine_effort refine_hint
  IFS=$'\t' read -r abs rel bucket decision action appetite final adjusted core importance pull risk completion reason refine_effort refine_hint <<< "$row"

  local first_step
  first_step="$(extract_first_goal_line "$abs")"
  if [ -z "$first_step" ]; then
    first_step="Open \`docs/$rel\` and define or tighten the Overview/Goal/Description section before implementation."
  fi

  echo "### $label"
  echo
  echo "- item: \`docs/$rel\`"
  echo "- decision: $decision"
  echo "- appetite: $appetite"
  echo "- adjusted_score: $adjusted"
  echo "- ranking_score: $final"
  echo "- why: $reason"
  echo "- first_step: $first_step"
  echo
}

echo "# Next Best Thing"
echo
echo "- project_root: $PROJECT_ROOT"
echo "- decision_profile: $PROFILE"
echo "- item_count: $TOTAL_ITEMS"
echo "- candidate_pool: $CANDIDATE_CLASS"
echo "- refused_count: $REFUSED_COUNT"
echo

print_candidate_block "$TOP_ONE" "Recommendation"
print_candidate_block "$ALT_ONE" "Alternate 1"
print_candidate_block "$ALT_TWO" "Alternate 2"

echo "## Notes"
echo
echo "- This task does not edit files."
echo "- Ranking uses appetite-weighted scoring plus queue-order bonus from docs/queue.md when present."
