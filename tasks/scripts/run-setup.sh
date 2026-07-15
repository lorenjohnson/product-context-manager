#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<USAGE
Usage: $0 <project-root-path> [--check] [--yes] [--adopt]

Set up one repository with Product Context Manager template contract files.

Modes:
  (default) apply changes in place
  --check   detect divergences only, no writes
  --yes     authorize non-interactive reconciliation of a marked installation
  --adopt   explicitly authorize setup when unmarked managed files already exist
USAGE
}

PROJECT_ROOT_INPUT=""
MODE="apply"
ASSUME_YES=0
ADOPT=0

while [ "$#" -gt 0 ]; do
  case "$1" in
    --check)
      MODE="check"
      ;;
    --yes)
      ASSUME_YES=1
      ;;
    --adopt)
      ADOPT=1
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    -*)
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

PCM_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
TEMPLATE_ROOT="$PCM_ROOT/template"
TEMPLATE_DOCS="$TEMPLATE_ROOT/docs"
TEMPLATE_MARKER="$TEMPLATE_ROOT/.product-context-manager"
TARGET_DOCS="$PROJECT_ROOT/docs"
TARGET_MARKER="$PROJECT_ROOT/.product-context-manager"
TASK_NAME="setup"

STRICT_ROOT_FILES=(
  "AGENTS.md"
)

SCAFFOLD_REL_FILES=(
  "current.md"
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
CONFLICTING_FILES=()

if [ ! -d "$TEMPLATE_DOCS" ]; then
  echo "Template docs directory not found: $TEMPLATE_DOCS" >&2
  exit 1
fi

if [ ! -f "$TEMPLATE_ROOT/AGENTS.md" ]; then
  echo "Template AGENTS file not found: $TEMPLATE_ROOT/AGENTS.md" >&2
  exit 1
fi

if [ ! -f "$TEMPLATE_MARKER" ]; then
  echo "Template installation marker not found: $TEMPLATE_MARKER" >&2
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

is_excluded_rel_file() {
  local rel="$1"
  contains_item "$rel" "${EXCLUDED_REL_FILES[@]}"
}

is_scaffold_rel_file() {
  local rel="$1"
  contains_item "$rel" "${SCAFFOLD_REL_FILES[@]}"
}

is_ignored_template_file() {
  local rel="$1"
  [[ "$rel" == *.gitkeep || "$rel" == ".DS_Store" || "$rel" == */.DS_Store ]]
}

print_list() {
  local label="$1"
  shift
  local item
  echo "$label:"
  for item in "$@"; do
    echo "- $item"
  done
}

detect_unmarked_conflicts() {
  local rel
  local src

  if [ -e "$PROJECT_ROOT/AGENTS.md" ]; then
    CONFLICTING_FILES+=("AGENTS.md")
  fi

  while IFS= read -r src; do
    rel="${src#$TEMPLATE_DOCS/}"
    if is_ignored_template_file "$rel" || is_excluded_rel_file "$rel"; then
      continue
    fi
    if [ -e "$TARGET_DOCS/$rel" ]; then
      CONFLICTING_FILES+=("docs/$rel")
    fi
  done < <(find "$TEMPLATE_DOCS" -type f | sort)
}

MARKER_DETECTED=0
INSTALLATION_STATE="fresh"

if [ -e "$TARGET_MARKER" ]; then
  if [ ! -f "$TARGET_MARKER" ]; then
    echo "Invalid Product Context Manager marker path: $TARGET_MARKER" >&2
    exit 3
  fi
  MARKER_DETECTED=1
  INSTALLATION_STATE="known"
  if ! cmp -s "$TEMPLATE_MARKER" "$TARGET_MARKER"; then
    echo "Unsupported Product Context Manager marker: $TARGET_MARKER" >&2
    echo "Run a compatible migration before reconciliation." >&2
    exit 3
  fi
else
  detect_unmarked_conflicts
  if [ "${#CONFLICTING_FILES[@]}" -gt 0 ]; then
    INSTALLATION_STATE="unknown"
  fi
fi

if [ "$MODE" = "apply" ] && [ "$INSTALLATION_STATE" = "unknown" ] && [ "$ADOPT" -eq 0 ]; then
  echo "setup: aborted; unmarked managed files already exist" >&2
  print_list "conflicting_paths" "${CONFLICTING_FILES[@]}" >&2
  echo "Review with --check, then rerun with --adopt to authorize replacement or modification." >&2
  exit 3
fi

if [ "$MODE" = "apply" ] && [ "$INSTALLATION_STATE" = "known" ] && [ "$ASSUME_YES" -eq 0 ]; then
  if [ -t 0 ]; then
    echo "Known Product Context Manager installation detected."
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
    echo "setup: aborted; non-interactive reconciliation requires --yes" >&2
    exit 3
  fi
fi

write_marker_if_needed() {
  local display_path=".product-context-manager"

  if [ ! -f "$TARGET_MARKER" ]; then
    MISSING_FILES+=("$display_path")
    CHANGED_FILES+=("$display_path")
    if [ "$MODE" = "apply" ]; then
      echo "create: $display_path"
      cp "$TEMPLATE_MARKER" "$TARGET_MARKER"
      CREATED_FILES+=("$display_path")
      UPDATED_STRICT_FILES+=("$display_path")
    fi
  fi
}

write_root_strict_file_if_needed() {
  local rel="$1"
  local src="$TEMPLATE_ROOT/$rel"
  local dst="$PROJECT_ROOT/$rel"

  if [ ! -f "$dst" ]; then
    MISSING_FILES+=("$rel")
    CHANGED_FILES+=("$rel")
    if [ "$MODE" = "apply" ]; then
      echo "create: $rel"
      cp "$src" "$dst"
      CREATED_FILES+=("$rel")
      UPDATED_STRICT_FILES+=("$rel")
    fi
  elif ! cmp -s "$src" "$dst"; then
    CHANGED_FILES+=("$rel")
    if [ "$MODE" = "apply" ]; then
      echo "replace: $rel"
      cp "$src" "$dst"
      UPDATED_STRICT_FILES+=("$rel")
    fi
  fi
}

write_docs_strict_file_if_needed() {
  local rel="$1"
  local src="$TEMPLATE_DOCS/$rel"
  local dst="$TARGET_DOCS/$rel"
  local display_path="docs/$rel"

  if [ ! -f "$dst" ]; then
    MISSING_FILES+=("$display_path")
    CHANGED_FILES+=("$display_path")
    if [ "$MODE" = "apply" ]; then
      echo "create: $display_path"
      mkdir -p "$(dirname "$dst")"
      cp "$src" "$dst"
      CREATED_FILES+=("$display_path")
      UPDATED_STRICT_FILES+=("$display_path")
    fi
  elif ! cmp -s "$src" "$dst"; then
    CHANGED_FILES+=("$display_path")
    if [ "$MODE" = "apply" ]; then
      echo "replace: $display_path"
      cp "$src" "$dst"
      UPDATED_STRICT_FILES+=("$display_path")
    fi
  fi
}

check_or_apply_scaffold_headings() {
  local rel="$1"
  local template_file="$TEMPLATE_DOCS/$rel"
  local target_file="$TARGET_DOCS/$rel"
  local display_path="docs/$rel"
  local heading
  local missing_local=()

  if [ ! -f "$target_file" ]; then
    MISSING_FILES+=("$display_path")
    CHANGED_FILES+=("$display_path")
    if [ "$MODE" = "apply" ]; then
      echo "create: $display_path"
      mkdir -p "$(dirname "$target_file")"
      cp "$template_file" "$target_file"
      CREATED_FILES+=("$display_path")
      UPDATED_SCAFFOLD_FILES+=("$display_path")
    fi
    return
  fi

  while IFS= read -r heading; do
    [ -n "$heading" ] || continue
    if ! grep -Fqx -- "$heading" "$target_file"; then
      missing_local+=("$heading")
      HEADING_GAPS+=("$display_path :: missing heading '$heading'")
    fi
  done < <(grep '^## ' "$template_file" || true)

  if [ "${#missing_local[@]}" -gt 0 ]; then
    CHANGED_FILES+=("$display_path")
    if [ "$MODE" = "apply" ]; then
      echo "append headings: $display_path"
      {
        echo
        for heading in "${missing_local[@]}"; do
          echo "$heading"
          echo
        done
      } >> "$target_file"
      UPDATED_SCAFFOLD_FILES+=("$display_path")
    fi
  fi
}

for rel in "${STRICT_ROOT_FILES[@]}"; do
  write_root_strict_file_if_needed "$rel"
done

while IFS= read -r dir; do
  rel="${dir#$TEMPLATE_DOCS/}"
  if [ ! -d "$TARGET_DOCS/$rel" ]; then
    MISSING_DIRS+=("docs/$rel")
    if [ "$MODE" = "apply" ]; then
      echo "create directory: docs/$rel"
      mkdir -p "$TARGET_DOCS/$rel"
      CREATED_DIRS+=("docs/$rel")
    fi
  fi
done < <(find "$TEMPLATE_DOCS" -mindepth 1 -type d | sort)

while IFS= read -r src; do
  rel="${src#$TEMPLATE_DOCS/}"

  if is_ignored_template_file "$rel" || is_excluded_rel_file "$rel"; then
    continue
  fi

  if is_scaffold_rel_file "$rel"; then
    check_or_apply_scaffold_headings "$rel"
  else
    write_docs_strict_file_if_needed "$rel"
  fi
done < <(find "$TEMPLATE_DOCS" -type f | sort)

# Write the marker last so a failed partial setup is not recognized as complete.
write_marker_if_needed

if [ -f "$TARGET_DOCS/README.md" ]; then
  if grep -Eq 'docs/index\.md|docs/roadmap\.md' "$TARGET_DOCS/README.md"; then
    NOTES+=("Found legacy docs contract references in docs/README.md (index/roadmap naming)")
  fi
fi

TOTAL_MISSING_DIRS=${#MISSING_DIRS[@]}
TOTAL_MISSING_FILES=${#MISSING_FILES[@]}
TOTAL_CHANGED_FILES=${#CHANGED_FILES[@]}
TOTAL_NOTES=${#NOTES[@]}
TOTAL_HEADING_GAPS=${#HEADING_GAPS[@]}
TOTAL_DIVERGENCES=$((TOTAL_MISSING_DIRS + TOTAL_CHANGED_FILES + TOTAL_NOTES))
TOTAL_CREATED_DIRS=${#CREATED_DIRS[@]}
TOTAL_CREATED_FILES=${#CREATED_FILES[@]}
TOTAL_UPDATED_STRICT=${#UPDATED_STRICT_FILES[@]}
TOTAL_UPDATED_SCAFFOLD=${#UPDATED_SCAFFOLD_FILES[@]}

STATUS="aligned"
if [ "$TOTAL_DIVERGENCES" -gt 0 ]; then
  if [ "$MODE" = "check" ]; then
    STATUS="diverged"
  elif [ "$INSTALLATION_STATE" = "known" ]; then
    STATUS="reconciled"
  elif [ "$INSTALLATION_STATE" = "unknown" ]; then
    STATUS="adopted"
  else
    STATUS="initialized"
  fi
fi

echo "task: $TASK_NAME"
echo "mode: $MODE"
echo "status: $STATUS"
echo "installation_state: $INSTALLATION_STATE"
echo "marker_detected: $MARKER_DETECTED"
echo "project_root: $PROJECT_ROOT"
echo "project_name: $PROJECT_NAME"
echo "missing_directories: $TOTAL_MISSING_DIRS"
echo "missing_files: $TOTAL_MISSING_FILES"
echo "changed_template_managed_files: $TOTAL_CHANGED_FILES"
echo "scaffold_heading_gaps: $TOTAL_HEADING_GAPS"
echo "notes: $TOTAL_NOTES"

if [ "$TOTAL_CHANGED_FILES" -gt 0 ]; then
  print_list "changed_paths" "${CHANGED_FILES[@]}"
fi

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
