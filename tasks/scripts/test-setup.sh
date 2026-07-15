#!/usr/bin/env bash
set -euo pipefail

PCM_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
SETUP_SCRIPT="$PCM_ROOT/tasks/scripts/run-setup.sh"
TEMPLATE_ROOT="$PCM_ROOT/template"
TEST_ROOT="$(mktemp -d "${TMPDIR:-/tmp}/pcm-setup-tests.XXXXXX")"

cleanup() {
  rm -rf "$TEST_ROOT"
}
trap cleanup EXIT

fail() {
  echo "FAIL: $1" >&2
  exit 1
}

assert_exit() {
  local expected="$1"
  local actual="$2"
  local context="$3"
  if [ "$actual" -ne "$expected" ]; then
    fail "$context (expected exit $expected, got $actual)"
  fi
}

assert_contains() {
  local expected="$1"
  local file="$2"
  if ! grep -Fq -- "$expected" "$file"; then
    fail "expected '$expected' in $file"
  fi
}

assert_file_equals() {
  local expected="$1"
  local actual="$2"
  local context="$3"
  if ! cmp -s "$expected" "$actual"; then
    fail "$context"
  fi
}

run_captured() {
  local out="$1"
  local err="$2"
  shift 2
  set +e
  "$@" >"$out" 2>"$err"
  RUN_EXIT=$?
  set -e
}

test_fresh_setup_with_macos_bash() {
  local project="$TEST_ROOT/fresh"
  local out="$TEST_ROOT/fresh.out"
  local err="$TEST_ROOT/fresh.err"
  mkdir -p "$project/docs/unrelated"
  printf '%s\n' 'keep me' > "$project/docs/unrelated/note.md"

  run_captured "$out" "$err" env PATH=/usr/bin:/bin /bin/bash "$SETUP_SCRIPT" "$project"
  assert_exit 0 "$RUN_EXIT" "fresh setup under macOS Bash"
  assert_file_equals "$TEMPLATE_ROOT/.product-context-manager" "$project/.product-context-manager" "fresh setup marker differs"
  assert_file_equals "$TEMPLATE_ROOT/AGENTS.md" "$project/AGENTS.md" "fresh setup AGENTS differs"
  [ -f "$project/docs/unrelated/note.md" ] || fail "fresh setup removed unrelated docs content"
  assert_contains "status: initialized" "$out"
  assert_contains "installation_state: fresh" "$out"
}

test_known_reconciliation_requires_authorization() {
  local project="$TEST_ROOT/known"
  local original="$TEST_ROOT/known-original-agents.md"
  local out="$TEST_ROOT/known.out"
  local err="$TEST_ROOT/known.err"
  mkdir -p "$project"
  /bin/bash "$SETUP_SCRIPT" "$project" >/dev/null
  printf '%s\n' '# local divergence' > "$project/AGENTS.md"
  cp "$project/AGENTS.md" "$original"

  run_captured "$out" "$err" /bin/bash "$SETUP_SCRIPT" "$project"
  assert_exit 3 "$RUN_EXIT" "non-interactive known reconciliation"
  assert_file_equals "$original" "$project/AGENTS.md" "unauthorized known reconciliation changed AGENTS.md"
  assert_contains "non-interactive reconciliation requires --yes" "$err"

  run_captured "$out" "$err" /bin/bash "$SETUP_SCRIPT" "$project" --yes
  assert_exit 0 "$RUN_EXIT" "authorized known reconciliation"
  assert_file_equals "$TEMPLATE_ROOT/AGENTS.md" "$project/AGENTS.md" "authorized reconciliation did not restore AGENTS.md"
  assert_contains "status: reconciled" "$out"
  assert_contains "replace: AGENTS.md" "$out"
}

test_unknown_project_requires_adoption() {
  local project="$TEST_ROOT/unknown"
  local original="$TEST_ROOT/original-agents.md"
  local out="$TEST_ROOT/unknown.out"
  local err="$TEST_ROOT/unknown.err"
  mkdir -p "$project"
  printf '%s\n' '# unrelated agent policy' > "$original"
  cp "$original" "$project/AGENTS.md"

  run_captured "$out" "$err" /bin/bash "$SETUP_SCRIPT" "$project"
  assert_exit 3 "$RUN_EXIT" "unmarked project without adoption"
  assert_file_equals "$original" "$project/AGENTS.md" "unmarked project was changed without adoption"
  [ ! -e "$project/.product-context-manager" ] || fail "unmarked project received marker without adoption"
  assert_contains "conflicting_paths:" "$err"
  assert_contains "- AGENTS.md" "$err"

  run_captured "$out" "$err" /bin/bash "$SETUP_SCRIPT" "$project" --yes
  assert_exit 3 "$RUN_EXIT" "--yes must not authorize adoption"
  assert_file_equals "$original" "$project/AGENTS.md" "--yes changed an unmarked project"

  run_captured "$out" "$err" /bin/bash "$SETUP_SCRIPT" "$project" --adopt
  assert_exit 0 "$RUN_EXIT" "explicit adoption"
  assert_file_equals "$TEMPLATE_ROOT/.product-context-manager" "$project/.product-context-manager" "adoption marker differs"
  assert_file_equals "$TEMPLATE_ROOT/AGENTS.md" "$project/AGENTS.md" "adoption did not install AGENTS.md"
  assert_contains "status: adopted" "$out"
}

test_check_is_non_mutating_and_lists_paths() {
  local project="$TEST_ROOT/check"
  local original="$TEST_ROOT/check-original.md"
  local out="$TEST_ROOT/check.out"
  local err="$TEST_ROOT/check.err"
  mkdir -p "$project"
  printf '%s\n' '# unrelated agent policy' > "$original"
  cp "$original" "$project/AGENTS.md"

  run_captured "$out" "$err" /bin/bash "$SETUP_SCRIPT" "$project" --check
  assert_exit 2 "$RUN_EXIT" "check of divergent unmarked project"
  assert_file_equals "$original" "$project/AGENTS.md" "check changed AGENTS.md"
  [ ! -e "$project/.product-context-manager" ] || fail "check created an installation marker"
  assert_contains "installation_state: unknown" "$out"
  assert_contains "changed_paths:" "$out"
  assert_contains "- AGENTS.md" "$out"
  assert_contains "- .product-context-manager" "$out"
}

test_fresh_setup_with_macos_bash
test_known_reconciliation_requires_authorization
test_unknown_project_requires_adoption
test_check_is_non_mutating_and_lists_paths

echo "PASS: setup safety tests"
