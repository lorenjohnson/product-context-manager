#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<USAGE
Usage: $0 <project-root-path> [--profile default|focus-cut]

Scans docs/active and docs/backlog, classifies each project item as:
- refine-easy (low-risk reshape to canonical sections)
- refine-needs-attention (manual editorial pass recommended)
- archive (implemented/completed candidates)
- remove (stale / misaligned candidates)

Outputs a markdown summary directly to terminal/chat. No report files are written.
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
REFINE_COUNT="$(awk -F'\t' '$5=="refine"{c++} END{print c+0}' "$TMP_TSV")"
REFINE_EASY_COUNT="$(awk -F'\t' '$5=="refine" && $15=="easy"{c++} END{print c+0}' "$TMP_TSV")"
REFINE_HARD_COUNT="$(awk -F'\t' '$5=="refine" && $15=="needs-attention"{c++} END{print c+0}' "$TMP_TSV")"
ARCHIVE_COUNT="$(awk -F'\t' '$5=="archive"{c++} END{print c+0}' "$TMP_TSV")"
REMOVE_COUNT="$(awk -F'\t' '$5=="remove"{c++} END{print c+0}' "$TMP_TSV")"
ACTIVE_COUNT="$(awk -F'\t' '$3=="active"{c++} END{print c+0}' "$TMP_TSV")"
BACKLOG_COUNT="$(awk -F'\t' '$3=="backlog"{c++} END{print c+0}' "$TMP_TSV")"
IMPLEMENTED_GATE_COUNT="$(awk -F'\t' '$14 ~ /implemented\/completed gate/{c++} END{print c+0}' "$TMP_TSV")"
STALENESS_GATE_COUNT="$(awk -F'\t' '$14 ~ /staleness gate/{c++} END{print c+0}' "$TMP_TSV")"
RELEVANCE_GATE_COUNT="$(awk -F'\t' '$14 ~ /relevance gate/{c++} END{print c+0}' "$TMP_TSV")"

print_action_list() {
  local section_action="$1"
  local title="$2"
  local section_effort="${3:-}"
  local show_hint="${4:-0}"

  echo "### $title"
  echo
  local rows
  if [ -n "$section_effort" ]; then
    rows="$(awk -F'\t' -v a="$section_action" -v e="$section_effort" '$5==a && $15==e{print $2 "\t" $16}' "$TMP_TSV" | sort)"
  else
    rows="$(awk -F'\t' -v a="$section_action" '$5==a{print $2 "\t" $14}' "$TMP_TSV" | sort)"
  fi

  if [ -z "$rows" ]; then
    echo "- none"
    echo
    return
  fi

  while IFS=$'\t' read -r rel hint; do
    [ -n "$rel" ] || continue
    local abs_path="$PROJECT_ROOT/docs/$rel"
    if [ "$show_hint" = "1" ] && [ -n "$hint" ] && [ "$hint" != "n/a" ]; then
      echo "- [docs/$rel]($abs_path) - $hint"
    else
      echo "- [docs/$rel]($abs_path)"
    fi
  done <<< "$rows"
  echo
}

echo "# Projects Cleanup"
echo
echo "- project_root: $PROJECT_ROOT"
echo "- decision_profile: $PROFILE"
echo "- item_count: $TOTAL_ITEMS"
echo "- active_count: $ACTIVE_COUNT"
echo "- backlog_count: $BACKLOG_COUNT"
echo "- refine: $REFINE_COUNT"
echo "- refine_easy: $REFINE_EASY_COUNT"
echo "- refine_needs_attention: $REFINE_HARD_COUNT"
echo "- archive_candidates: $ARCHIVE_COUNT"
echo "- remove_candidates: $REMOVE_COUNT"
echo "- remove_gate_hits.implemented_or_completed: $IMPLEMENTED_GATE_COUNT"
echo "- remove_gate_hits.staleness: $STALENESS_GATE_COUNT"
echo "- remove_gate_hits.relevance: $RELEVANCE_GATE_COUNT"
echo

echo "## Cleanup Targets"
echo
echo "- refine_easy: good candidates for automated reshape"
echo "- refine_needs_attention: manual editorial pass recommended"
echo "- archive_candidates: implemented/completed candidates to move into docs/archive"
echo "- remove_candidates: stale/misaligned candidates to drop from active/backlog"
echo

echo "## Action Lists"
echo
print_action_list "refine" "Refine Easy" "easy"
print_action_list "refine" "Refine Needs Attention" "needs-attention" "1"
print_action_list "archive" "Archive Candidates"
print_action_list "remove" "Remove Candidates" "" "1"

echo "## Notes"
echo
echo "- This task does not edit files."
echo "- This task does not write a report file."
echo "- Decision order: implemented/completed signals -> staleness signals -> relevance/misalignment signals."
echo "- Projects already classified as keep are intentionally omitted from action lists."
