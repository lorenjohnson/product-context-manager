#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<USAGE
Usage: $0 <project-root-path> [--check] [--yes]

Set up one repository with Product Context Manager template contract files.

Modes:
  (default) apply changes in place
  --check   detect divergences only, no writes
  --yes     skip reconcile confirmation when existing setup fingerprint is detected
USAGE
}

PROJECT_ROOT_INPUT=""
MODE="apply"
ASSUME_YES=0

while [ "$#" -gt 0 ]; do
  case "$1" in
    --check)
      MODE="check"
      ;;
    --yes)
      ASSUME_YES=1
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

PP_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
TEMPLATE_ROOT="$PP_ROOT/template"
TEMPLATE_DOCS="$TEMPLATE_ROOT/docs"
TEMPLATE_AGENTS="$TEMPLATE_ROOT/AGENTS.md"
TARGET_DOCS="$PROJECT_ROOT/docs"
TASK_NAME="setup"

STRICT_ROOT_FILES=(
  "AGENTS.md"
)

SCAFFOLD_REL_FILES=(
  "queue.md"
  "product.md"
  "rules.md"
)

EXCLUDED_REL_FILES=(
  "archive/done.md"
)

CREATED_DIRS=()
CREATED_FILES=()
UPDATED_STRICT_FILES=()
UPDATED_SCAFFOLD_FILES=()
MISSING_DIRS=()
MISSING_FILES=()
CHANGED_FILES=()
NOTES=()
HEADING_GAPS=()

if [ ! -d "$TEMPLATE_DOCS" ]; then
  echo "Template docs directory not found: $TEMPLATE_DOCS" >&2
  exit 1
fi

if [ ! -f "$TEMPLATE_AGENTS" ]; then
  echo "Template AGENTS file not found: $TEMPLATE_AGENTS" >&2
  exit 1
fi

contains_item() {
  local seek="$1"
  shift
  local item
  for item in "$@"; do
    if [ "$item" = "$seek" ]; then
      return 0
    fi
  done
  return 1
}

add_unique() {
  local value="$1"
  shift
  local -n arr_ref="$1"
  if contains_item "$value" "${arr_ref[@]}"; then
    return 0
  fi
  arr_ref+=("$value")
}

is_excluded_rel_file() {
  local rel="$1"
  contains_item "$rel" "${EXCLUDED_REL_FILES[@]}"
}

is_scaffold_rel_file() {
  local rel="$1"
  contains_item "$rel" "${SCAFFOLD_REL_FILES[@]}"
}

detect_setup_fingerprint() {
  if [ -f "$PROJECT_ROOT/AGENTS.md" ]; then
    return 0
  fi
  if [ -d "$TARGET_DOCS" ]; then
    return 0
  fi
  return 1
}

FINGERPRINT_DETECTED=0
if detect_setup_fingerprint; then
  FINGERPRINT_DETECTED=1
fi

if [ "$MODE" = "apply" ] && [ "$FINGERPRINT_DETECTED" -eq 1 ] && [ "$ASSUME_YES" -eq 0 ]; then
  if [ -t 0 ]; then
    echo "Existing Product Context Manager setup fingerprint detected."
    printf "Proceed in reconcile mode and update files in place? [y/N]: "
    read -r reply
    case "$reply" in
      y|Y|yes|YES)
        ;;
      *)
        echo "setup: aborted by user"
        exit 0
        ;;
    esac
  else
    echo "fingerprint_detected: true"
    echo "note: non-interactive run; proceeding in reconcile mode"
  fi
fi

render_template_file() {
  local rel="$1"
  local out_path="$2"
  local src="$TEMPLATE_DOCS/$rel"
  cat "$src" > "$out_path"
}

write_strict_file_if_needed() {
  local rel="$1"
  local dst="$TARGET_DOCS/$rel"
  local rendered_tmp
  rendered_tmp="$(mktemp)"
  render_template_file "$rel" "$rendered_tmp"

  if [ ! -f "$dst" ]; then
    add_unique "$rel" MISSING_FILES
    add_unique "$rel" CHANGED_FILES
    if [ "$MODE" = "apply" ]; then
      mkdir -p "$(dirname "$dst")"
      cp "$rendered_tmp" "$dst"
      add_unique "$rel" CREATED_FILES
      add_unique "$rel" UPDATED_STRICT_FILES
    fi
  else
    if ! cmp -s "$rendered_tmp" "$dst"; then
      add_unique "$rel" CHANGED_FILES
      if [ "$MODE" = "apply" ]; then
        cp "$rendered_tmp" "$dst"
        add_unique "$rel" UPDATED_STRICT_FILES
      fi
    fi
  fi

  rm -f "$rendered_tmp"
}

check_or_apply_scaffold_headings() {
  local rel="$1"
  local template_file="$TEMPLATE_DOCS/$rel"
  local target_file="$TARGET_DOCS/$rel"
  local heading
  local missing_local=()

  if [ ! -f "$target_file" ]; then
    add_unique "$rel" MISSING_FILES
    add_unique "$rel" CHANGED_FILES
    if [ "$MODE" = "apply" ]; then
      mkdir -p "$(dirname "$target_file")"
      cp "$template_file" "$target_file"
      add_unique "$rel" CREATED_FILES
      add_unique "$rel" UPDATED_SCAFFOLD_FILES
    fi
    return
  fi

  while IFS= read -r heading; do
    [ -n "$heading" ] || continue
    if ! rg -Fxq "$heading" "$target_file"; then
      missing_local+=("$heading")
      add_unique "$rel :: missing heading '$heading'" HEADING_GAPS
    fi
  done < <(rg '^## ' "$template_file" || true)

  if [ "${#missing_local[@]}" -gt 0 ]; then
    add_unique "$rel" CHANGED_FILES
    if [ "$MODE" = "apply" ]; then
      {
        echo
        for heading in "${missing_local[@]}"; do
          echo "$heading"
          echo
        done
      } >> "$target_file"
      add_unique "$rel" UPDATED_SCAFFOLD_FILES
    fi
  fi
}

# Apply root-level strict file(s).
for rel in "${STRICT_ROOT_FILES[@]}"; do
  src="$TEMPLATE_ROOT/$rel"
  dst="$PROJECT_ROOT/$rel"
  if [ ! -f "$dst" ]; then
    add_unique "$rel" MISSING_FILES
    add_unique "$rel" CHANGED_FILES
    if [ "$MODE" = "apply" ]; then
      cp "$src" "$dst"
      add_unique "$rel" CREATED_FILES
      add_unique "$rel" UPDATED_STRICT_FILES
    fi
  else
    if ! cmp -s "$src" "$dst"; then
      add_unique "$rel" CHANGED_FILES
      if [ "$MODE" = "apply" ]; then
        cp "$src" "$dst"
        add_unique "$rel" UPDATED_STRICT_FILES
      fi
    fi
  fi
done

# Create missing directories from template docs.
while IFS= read -r dir; do
  rel="${dir#$TEMPLATE_DOCS/}"
  if [ ! -d "$TARGET_DOCS/$rel" ]; then
    add_unique "$rel" MISSING_DIRS
    if [ "$MODE" = "apply" ]; then
      mkdir -p "$TARGET_DOCS/$rel"
      add_unique "$rel" CREATED_DIRS
    fi
  fi
done < <(find "$TEMPLATE_DOCS" -mindepth 1 -type d | sort)

# Apply template-managed docs files.
while IFS= read -r src; do
  rel="${src#$TEMPLATE_DOCS/}"

  if [[ "$rel" == *.gitkeep ]]; then
    continue
  fi
  if [[ "$rel" == ".DS_Store" || "$rel" == */.DS_Store ]]; then
    continue
  fi
  if is_excluded_rel_file "$rel"; then
    continue
  fi

  if is_scaffold_rel_file "$rel"; then
    check_or_apply_scaffold_headings "$rel"
  else
    write_strict_file_if_needed "$rel"
  fi
done < <(find "$TEMPLATE_DOCS" -type f | sort)

if [ -f "$TARGET_DOCS/README.md" ]; then
  if rg -q "docs/index\.md|docs/roadmap\.md" "$TARGET_DOCS/README.md"; then
    add_unique "Found legacy docs contract references in docs/README.md (index/roadmap naming)" NOTES
  fi
fi

TOTAL_MISSING_DIRS=${#MISSING_DIRS[@]}
TOTAL_MISSING_FILES=${#MISSING_FILES[@]}
TOTAL_CHANGED_FILES=${#CHANGED_FILES[@]}
TOTAL_NOTES=${#NOTES[@]}
TOTAL_HEADING_GAPS=${#HEADING_GAPS[@]}
TOTAL_DIVERGENCES=$((TOTAL_MISSING_DIRS + TOTAL_MISSING_FILES + TOTAL_CHANGED_FILES + TOTAL_NOTES))
TOTAL_CREATED_DIRS=${#CREATED_DIRS[@]}
TOTAL_CREATED_FILES=${#CREATED_FILES[@]}
TOTAL_UPDATED_STRICT=${#UPDATED_STRICT_FILES[@]}
TOTAL_UPDATED_SCAFFOLD=${#UPDATED_SCAFFOLD_FILES[@]}

STATUS="aligned"
if [ "$TOTAL_DIVERGENCES" -gt 0 ]; then
  if [ "$MODE" = "apply" ]; then
    if [ "$FINGERPRINT_DETECTED" -eq 1 ]; then
      STATUS="reconciled"
    else
      STATUS="initialized"
    fi
  else
    STATUS="diverged"
  fi
fi

echo "task: $TASK_NAME"
echo "mode: $MODE"
echo "status: $STATUS"
echo "fingerprint_detected: $FINGERPRINT_DETECTED"
echo "project_root: $PROJECT_ROOT"
echo "project_name: $PROJECT_NAME"
echo "missing_directories: $TOTAL_MISSING_DIRS"
echo "missing_files: $TOTAL_MISSING_FILES"
echo "changed_template_managed_files: $TOTAL_CHANGED_FILES"
echo "scaffold_heading_gaps: $TOTAL_HEADING_GAPS"
echo "notes: $TOTAL_NOTES"

if [ "$MODE" = "apply" ]; then
  echo "created_directories: $TOTAL_CREATED_DIRS"
  echo "created_files: $TOTAL_CREATED_FILES"
  echo "updated_strict_files: $TOTAL_UPDATED_STRICT"
  echo "updated_scaffold_files: $TOTAL_UPDATED_SCAFFOLD"
fi

if [ "$MODE" = "check" ] && [ "$TOTAL_DIVERGENCES" -gt 0 ]; then
  exit 2
fi

exit 0
