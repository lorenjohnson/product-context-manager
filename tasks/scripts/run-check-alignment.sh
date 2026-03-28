#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<USAGE
Usage: $0 <project-root-path> [--print-report]

Compares product intent docs with a populated, human-authored features file.

Options:
- --print-report   print full report after summary
USAGE
}

PROJECT_ROOT_INPUT=""
PRINT_REPORT=0

while [ "$#" -gt 0 ]; do
  case "$1" in
    --print-report)
      PRINT_REPORT=1
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

if [ ! -d "$PROJECT_ROOT_INPUT" ]; then
  echo "Project root path not found: $PROJECT_ROOT_INPUT" >&2
  exit 1
fi

PROJECT_ROOT="$(cd "$PROJECT_ROOT_INPUT" && pwd)"
PROJECT_NAME="$(basename "$PROJECT_ROOT")"
DOCS_DIR="$PROJECT_ROOT/docs"
FEATURE_FILE="$DOCS_DIR/features.md"
EVALS_DIR="$DOCS_DIR/evals"
REPORT_FILE="$EVALS_DIR/product-alignment.md"
NOW_UTC="$(date -u +%Y-%m-%dT%H:%M:%SZ)"

if [ ! -d "$DOCS_DIR" ]; then
  echo "Expected docs directory not found: $DOCS_DIR" >&2
  exit 1
fi

PRODUCT_DOC_FILES=()
if [ -f "$DOCS_DIR/product.md" ]; then
  PRODUCT_DOC_FILES+=("$DOCS_DIR/product.md")
elif [ -d "$DOCS_DIR/product" ]; then
  while IFS= read -r f; do
    PRODUCT_DOC_FILES+=("$f")
  done < <(find "$DOCS_DIR/product" -type f -name '*.md' | sort)
fi

if [ "${#PRODUCT_DOC_FILES[@]}" -eq 0 ]; then
  echo "No product definition source found. Expected docs/product.md or docs/product/*.md" >&2
  exit 1
fi

if [ ! -f "$FEATURE_FILE" ]; then
  echo "Features file is required before alignment." >&2
  echo "Create docs/features.md from template and populate it, then rerun alignment." >&2
  exit 2
fi

FEATURE_COUNT="$(rg -c '^## ' "$FEATURE_FILE" || true)"
if [ "${FEATURE_COUNT:-0}" -eq 0 ] || rg -q '<Feature Name>|<High-level summary' "$FEATURE_FILE"; then
  echo "Features file exists but is not populated yet." >&2
  echo "Populate docs/features.md through operator interview, then rerun alignment." >&2
  exit 2
fi

CLAIMS_TSV="$(mktemp)"
RESULTS_TSV="$(mktemp)"
trap 'rm -f "$CLAIMS_TSV" "$RESULTS_TSV"' EXIT

extract_claims() {
  local file="$1"
  awk '
    BEGIN { in_frontmatter=0; section="Overview" }
    NR == 1 && $0 ~ /^---[[:space:]]*$/ { in_frontmatter=1; next }
    in_frontmatter == 1 {
      if ($0 ~ /^---[[:space:]]*$/) in_frontmatter=0
      next
    }
    /^##[[:space:]]+/ {
      section = $0
      sub(/^##[[:space:]]+/, "", section)
      next
    }
    /^[*-][[:space:]]+/ || /^[0-9]+\.[[:space:]]+/ {
      claim = $0
      sub(/^[*-][[:space:]]+/, "", claim)
      sub(/^[0-9]+\.[[:space:]]+/, "", claim)
      gsub(/[[:space:]]+/, " ", claim)
      gsub(/^[[:space:]]+|[[:space:]]+$/, "", claim)
      if (length(claim) > 0) printf "%s\t%s\n", section, claim
    }
  ' "$file"
}

claim_keywords() {
  local text="$1"
  echo "$text" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9 ]/ /g' | awk '
    BEGIN {
      stopwords = "the and for with from this that into onto over under while where what when then than those these they them their there being been are were was is as at by of to in on or an a if it its can could should would must may not no do does did done via across about around after before between through within without keep using use used product project feature software system user users maker makers intent context implementation current desired now this"
      nsw = split(stopwords, sw, " ")
      for (i = 1; i <= nsw; i++) stop[sw[i]] = 1
    }
    {
      for (i = 1; i <= NF; i++) {
        w = $i
        if (length(w) < 4) continue
        if (w ~ /^[0-9]+$/) continue
        if (stop[w]) continue
        if (!seen[w]++) order[++n] = w
      }
    }
    END {
      limit = n
      if (limit > 8) limit = 8
      for (i = 1; i <= limit; i++) printf "%s%s", order[i], (i < limit ? " " : "")
    }
  '
}

FEATURE_NAMES=()
while IFS= read -r f; do
  [ -n "$f" ] || continue
  FEATURE_NAMES+=("$f")
done < <(rg '^## ' "$FEATURE_FILE" | sed -E 's/^##[[:space:]]+//')

if [ "${#FEATURE_NAMES[@]}" -eq 0 ]; then
  echo "No feature entries found in docs/features.md" >&2
  exit 2
fi

for doc in "${PRODUCT_DOC_FILES[@]}"; do
  extract_claims "$doc" >> "$CLAIMS_TSV"
done

if [ ! -s "$CLAIMS_TSV" ]; then
  echo "No product claims found. Add bullet or numbered claims in product docs first." >&2
  exit 1
fi

feature_hints_for_claim() {
  local keywords="$1"
  local hints=()

  for name in "${FEATURE_NAMES[@]}"; do
    for kw in $keywords; do
      if printf '%s\n' "$name" | rg -qi -w -- "$kw"; then
        hints+=("$name")
        break
      fi
    done
    if [ "${#hints[@]}" -ge 2 ]; then
      break
    fi
  done

  if [ "${#hints[@]}" -eq 0 ]; then
    echo "n/a"
  elif [ "${#hints[@]}" -eq 1 ]; then
    echo "${hints[0]}"
  else
    echo "${hints[0]}, ${hints[1]}"
  fi
}

while IFS=$'\t' read -r section claim; do
  [ -n "$claim" ] || continue

  polarity="positive"
  if printf '%s %s\n' "$section" "$claim" | rg -qi '\b(no|not|without|must not|should not|never|do not|cannot|can.t|won.t|non-goal|out of scope)\b'; then
    polarity="negative"
  fi

  keywords="$(claim_keywords "$claim")"
  total_keywords="$(printf '%s\n' "$keywords" | wc -w | tr -d ' ')"
  matched=0
  for kw in $keywords; do
    if rg -qi -w -- "$kw" "$FEATURE_FILE"; then
      matched=$((matched + 1))
    fi
  done

  score="0.00"
  if [ "${total_keywords:-0}" -gt 0 ]; then
    score="$(awk -v m="$matched" -v t="$total_keywords" 'BEGIN{printf "%.2f", (t==0?0:m/t)}')"
  fi

  status="unclear"
  if [ "$polarity" = "negative" ]; then
    if awk -v s="$score" 'BEGIN{exit !(s >= 0.50)}'; then
      status="conflict"
    elif awk -v s="$score" 'BEGIN{exit !(s < 0.20)}'; then
      status="aligned"
    fi
  else
    if awk -v s="$score" 'BEGIN{exit !(s < 0.25)}'; then
      status="conflict"
    elif awk -v s="$score" 'BEGIN{exit !(s >= 0.60)}'; then
      status="aligned"
    fi
  fi

  hints="$(feature_hints_for_claim "$keywords")"
  printf '%s\t%s\t%s\t%s\t%s\n' "$section" "$status" "$score" "$hints" "$claim" >> "$RESULTS_TSV"
done < "$CLAIMS_TSV"

TOTAL_CLAIMS="$(wc -l < "$RESULTS_TSV" | tr -d ' ')"
ALIGNED_COUNT="$(awk -F'\t' '$2=="aligned"{c++} END{print c+0}' "$RESULTS_TSV")"
CONFLICT_COUNT="$(awk -F'\t' '$2=="conflict"{c++} END{print c+0}' "$RESULTS_TSV")"
UNCLEAR_COUNT="$(awk -F'\t' '$2=="unclear"{c++} END{print c+0}' "$RESULTS_TSV")"

mkdir -p "$EVALS_DIR"

{
  echo "# Product Alignment Report"
  echo
  echo "## Metadata"
  echo
  echo "- generated_at_utc: $NOW_UTC"
  echo "- project: $PROJECT_NAME"
  echo "- project_root: \`$PROJECT_ROOT\`"
  echo "- product_intent_sources:"
  for doc in "${PRODUCT_DOC_FILES[@]}"; do
    printf '  - `%s`\n' "${doc#$PROJECT_ROOT/}"
  done
  echo "- features_source: \`docs/features.md\`"
  echo
  echo "## Alignment Summary"
  echo
  echo "- total_claims: $TOTAL_CLAIMS"
  echo "- aligned: $ALIGNED_COUNT"
  echo "- conflicts: $CONFLICT_COUNT"
  echo "- needs_clarification: $UNCLEAR_COUNT"
  echo
  echo "## Conflicts"
  echo
  echo "| Product Area | Claim | Score | Matching Features | Suggested Action |"
  echo "|---|---|---:|---|---|"
  rows=0
  while IFS=$'\t' read -r section status score hints claim; do
    [ "$status" = "conflict" ] || continue
    rows=1
    printf '| %s | %s | %s | %s | %s |\n' "$section" "$claim" "$score" "$hints" "Revise implementation or claim wording."
  done < "$RESULTS_TSV"
  if [ "$rows" -eq 0 ]; then
    echo "| n/a | none | n/a | n/a | none |"
  fi
  echo
  echo "## Needs Clarification"
  echo
  echo "| Product Area | Claim | Score | Matching Features | Suggested Action |"
  echo "|---|---|---:|---|---|"
  rows=0
  while IFS=$'\t' read -r section status score hints claim; do
    [ "$status" = "unclear" ] || continue
    rows=1
    printf '| %s | %s | %s | %s | %s |\n' "$section" "$claim" "$score" "$hints" "Split or clarify claim text for better testability."
  done < "$RESULTS_TSV"
  if [ "$rows" -eq 0 ]; then
    echo "| n/a | none | n/a | n/a | none |"
  fi
  echo
  echo "## Notes"
  echo
  echo "- This eval compares product intent claims to a human-authored features file."
  echo "- Scores are lightweight keyword-overlap heuristics for review only."
} > "$REPORT_FILE"

echo "# Product Alignment (Executive)"
echo
echo "- project_root: $PROJECT_ROOT"
echo "- aligned: $ALIGNED_COUNT"
echo "- conflicts: $CONFLICT_COUNT"
echo "- needs_clarification: $UNCLEAR_COUNT"
echo "- report_path: $REPORT_FILE"
echo

echo "Top Conflicts:"
conf=0
while IFS=$'\t' read -r section status score hints claim; do
  [ "$status" = "conflict" ] || continue
  conf=$((conf + 1))
  printf -- '- [%s] %s (score %s, features: %s)\n' "$section" "$claim" "$score" "$hints"
  if [ "$conf" -ge 5 ]; then
    break
  fi
done < "$RESULTS_TSV"

if [ "$conf" -eq 0 ]; then
  echo "- none"
fi

if [ "$PRINT_REPORT" -eq 1 ]; then
  echo
  cat "$REPORT_FILE"
fi
