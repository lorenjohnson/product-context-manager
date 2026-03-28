#!/usr/bin/env bash
set -euo pipefail

clamp_int() {
  local v="$1"
  local lo="$2"
  local hi="$3"
  if [ "$v" -lt "$lo" ]; then
    echo "$lo"
  elif [ "$v" -gt "$hi" ]; then
    echo "$hi"
  else
    echo "$v"
  fi
}

has_re() {
  local file="$1"
  local pattern="$2"
  rg -qi -- "$pattern" "$file"
}

extract_doc_field_value() {
  local file="$1"
  local field="$2"

  sed -n '1,120p' "$file" \
    | rg -i -m1 "^[[:space:]>-]*(\\*{0,2})?${field}(\\*{0,2})?[[:space:]]*:\\*{0,2}[[:space:]]*.+$" \
    | sed -E 's/^[^:]*:[[:space:]]*//' \
    | sed -E 's/^[*_[:space:]]+//' \
    | sed -E 's/[[:space:]]+$//' \
    | tr -d '\r' \
    || true
}

extract_doc_date() {
  local file="$1"
  local field="$2"
  local line

  line="$(
    sed -n '1,120p' "$file" \
      | rg -i -m1 "^[[:space:]>-]*(\\*{0,2})?${field}(\\*{0,2})?[[:space:]]*:\\*{0,2}[[:space:]]*[0-9]{4}-[0-9]{2}-[0-9]{2}" \
      || true
  )"

  if [ -z "$line" ]; then
    echo ""
    return
  fi

  echo "$line" | sed -E 's/.*([0-9]{4}-[0-9]{2}-[0-9]{2}).*/\1/'
}

date_to_epoch() {
  local iso_date="$1"
  if [ -z "$iso_date" ]; then
    echo ""
    return
  fi

  if date -j -f "%Y-%m-%d" "$iso_date" "+%s" >/dev/null 2>&1; then
    date -j -f "%Y-%m-%d" "$iso_date" "+%s"
    return
  fi

  if date -d "$iso_date" "+%s" >/dev/null 2>&1; then
    date -d "$iso_date" "+%s"
    return
  fi

  echo ""
}

days_since_date() {
  local iso_date="$1"
  local then_epoch now_epoch

  then_epoch="$(date_to_epoch "$iso_date")"
  if [ -z "$then_epoch" ]; then
    echo ""
    return
  fi

  now_epoch="$(date +%s)"
  if [ "$then_epoch" -ge "$now_epoch" ]; then
    echo "0"
    return
  fi

  echo $(( (now_epoch - then_epoch) / 86400 ))
}

has_archived_slug_match() {
  local project_root="$1"
  local rel_path="$2"
  local archive_dir="$project_root/docs/archive"
  local stem archived name

  if [ ! -d "$archive_dir" ]; then
    return 1
  fi

  stem="$(basename "$rel_path" .md)"
  while IFS= read -r archived; do
    name="$(basename "$archived" .md)"
    name="$(printf '%s' "$name" | sed -E 's/^[0-9]{8}-//')"
    if [ "$name" = "$stem" ]; then
      return 0
    fi
  done < <(find "$archive_dir" -maxdepth 1 -type f -name '*.md' -print)

  return 1
}

queue_bonus_for_rel() {
  local project_root="$1"
  local rel_path="$2"
  local queue_file="$project_root/docs/queue.md"
  local section_rank=""
  local rank=""

  if [ ! -f "$queue_file" ]; then
    echo "0.0"
    return
  fi

  section_rank="$(
    awk -v rel="$rel_path" '
      BEGIN { section=""; rank=0 }
      /^##[[:space:]]+Active Projects/ { section="active"; rank=0; next }
      /^##[[:space:]]+Backlog Projects/ { section="backlog"; rank=0; next }
      /^##[[:space:]]+/ { section=""; rank=0; next }
      {
        if (section == "") next
        if (match($0, /\((active|backlog)\/[^)]+\)/)) {
          rank++
          item=substr($0, RSTART + 1, RLENGTH - 2)
          if (item == rel) {
            print section "\t" rank
            exit
          }
        }
      }
    ' "$queue_file"
  )"

  if [ -z "$section_rank" ]; then
    echo "0.0"
    return
  fi

  rank="$(printf '%s' "$section_rank" | cut -f2)"
  if [ -z "$rank" ]; then
    echo "0.0"
    return
  fi

  if [ "$rank" -le 1 ]; then
    echo "0.9"
  elif [ "$rank" -le 3 ]; then
    echo "0.7"
  elif [ "$rank" -le 6 ]; then
    echo "0.5"
  elif [ "$rank" -le 10 ]; then
    echo "0.3"
  else
    echo "0.1"
  fi
}

extract_first_goal_line() {
  local file="$1"

  awk '
    BEGIN { in_intent=0 }
    /^##[[:space:]]+Overview([[:space:]]|$)/ { in_intent=1; next }
    /^##[[:space:]]+Goal([[:space:]]|$)/ { in_intent=1; next }
    /^##[[:space:]]+Description([[:space:]]|$)/ { in_intent=1; next }
    /^##[[:space:]]+/ { if (in_intent) exit }
    {
      if (in_intent) {
        line=$0
        gsub(/^[[:space:]-]+/, "", line)
        if (length(line) > 0) {
          print line
          exit
        }
      }
    }
  ' "$file"
}

score_project_item() {
  local project_root="$1"
  local file="$2"
  local profile="$3"

  local rel bucket
  rel="${file#$project_root/docs/}"
  case "$rel" in
    active/*) bucket="active" ;;
    backlog/*) bucket="backlog" ;;
    *) bucket="other" ;;
  esac

  local filename title_line
  filename="$(basename "$file")"
  title_line="$(rg -n '^# ' "$file" | head -n1 | sed -E 's/^[0-9]+:#\s*//')"

  local front_status=""
  front_status="$(extract_doc_field_value "$file" "status" | tr '[:upper:]' '[:lower:]')"

  local created_date updated_date last_touch_date age_days
  created_date="$(extract_doc_date "$file" "created")"
  updated_date="$(extract_doc_date "$file" "updated")"
  last_touch_date="$updated_date"
  if [ -z "$last_touch_date" ]; then
    last_touch_date="$created_date"
  fi
  age_days="$(days_since_date "$last_touch_date")"

  local heading_count line_count
  heading_count="$(rg -c '^## ' "$file" 2>/dev/null || echo 0)"
  line_count="$(wc -l < "$file" | tr -d ' ')"
  if ! echo "$heading_count" | rg -q '^[0-9]+$'; then
    heading_count=0
  fi
  if ! echo "$line_count" | rg -q '^[0-9]+$'; then
    line_count=0
  fi

  local is_bug=0 is_spike=0 is_refactor=0 has_intent=0 has_scope_or_rules=0 has_plan_section=0 has_out_of_scope=0 is_completed=0 is_implemented=0 is_explicitly_misaligned=0 has_archived_match=0
  local intent_alias_count=0 scope_alias_count=0 has_intent_alias_dup=0 has_scope_alias_dup=0

  if has_re "$file" '\\b(bug|error|crash|failed|failure|regression|stall|cannot decode|cannot|bleed|broken|freeze)\\b'; then
    is_bug=1
  fi

  if echo "$filename $title_line" | rg -qi '(spike|pivot-spike)'; then
    is_spike=1
  fi

  if echo "$filename $title_line" | rg -qi '(refactor|architecture|rewrite|migration)'; then
    is_refactor=1
  fi

  intent_alias_count="$(rg -ci '^##[[:space:]]+(Overview|Goal|Description)\b' "$file" 2>/dev/null || echo 0)"
  scope_alias_count="$(rg -ci '^##[[:space:]]+(Scope|Rules)\b' "$file" 2>/dev/null || echo 0)"
  if ! echo "$intent_alias_count" | rg -q '^[0-9]+$'; then
    intent_alias_count=0
  fi
  if ! echo "$scope_alias_count" | rg -q '^[0-9]+$'; then
    scope_alias_count=0
  fi

  if [ "$intent_alias_count" -gt 0 ]; then
    has_intent=1
  fi

  if [ "$scope_alias_count" -gt 0 ]; then
    has_scope_or_rules=1
  fi

  if [ "$intent_alias_count" -gt 1 ]; then
    has_intent_alias_dup=1
  fi

  if [ "$scope_alias_count" -gt 1 ]; then
    has_scope_alias_dup=1
  fi

  if rg -qi '^##[[:space:]]+(Plan|Implementation Plan|Migration Plan|Work Plan|Proposed First Pass|Suggested Spike Method|First Implementation Slice)\b' "$file"; then
    has_plan_section=1
  fi

  if has_re "$file" '(Out of Scope|Boundaries)'; then
    has_out_of_scope=1
  fi

  if echo "$front_status" | rg -qi '^(done|complete|completed|obsolete|closed)$'; then
    is_completed=1
  fi

  if echo "$front_status" | rg -qi '^(implemented|shipped|released|production-ready)$'; then
    is_implemented=1
  fi

  if has_re "$file" '(\balready[[:space:]]+implemented\b|\balready[[:space:]]+shipped\b|\bimplementation[[:space:]]+complete\b|\bfeature[[:space:]]+is[[:space:]]+live\b|\bthis[[:space:]]+is[[:space:]]+shipped\b|\bshipped[[:space:]]+and[[:space:]]+live\b)'; then
    is_implemented=1
  fi

  if has_re "$file" '(superseded by|replaced by|no longer relevant|no longer aligned|not pursuing|abandoned direction|deprecated direction|wont fix|won.t fix)'; then
    is_explicitly_misaligned=1
  fi

  if has_archived_slug_match "$project_root" "$rel"; then
    is_implemented=1
    has_archived_match=1
  fi

  local core importance pull risk
  core=3
  importance=2
  pull=2
  risk=1

  if [ "$bucket" = "active" ]; then
    importance=3
    pull=3
  fi

  local reason=""
  if [ "$bucket" = "active" ]; then
    reason="active item"
  else
    reason="backlog item"
  fi

  if [ "$has_archived_match" -eq 1 ]; then
    reason="$reason; archived slug match"
  fi

  if [ -n "$age_days" ]; then
    if [ "$age_days" -le 21 ]; then
      importance=$((importance + 1))
      pull=$((pull + 1))
      reason="$reason; recently updated (${age_days}d)"
    elif [ "$age_days" -ge 180 ]; then
      importance=$((importance - 2))
      pull=$((pull - 1))
      risk=$((risk + 2))
      reason="$reason; stale (${age_days}d)"
    elif [ "$age_days" -ge 120 ]; then
      importance=$((importance - 1))
      pull=$((pull - 1))
      risk=$((risk + 1))
      reason="$reason; aging (${age_days}d)"
    elif [ "$age_days" -ge 60 ]; then
      pull=$((pull - 1))
      reason="$reason; touched ${age_days}d ago"
    fi
  else
    risk=$((risk + 1))
    reason="$reason; missing created/updated date"
  fi

  if [ "$is_bug" -eq 1 ]; then
    importance=$((importance + 2))
    core=$((core + 1))
    reason="$reason; reliability/bug signal"
  fi

  if [ "$is_spike" -eq 1 ]; then
    core=$((core - 1))
    importance=$((importance - 1))
    risk=$((risk + 2))
    reason="$reason; spike/exploration risk"
  fi

  if [ "$is_refactor" -eq 1 ]; then
    core=$((core - 1))
    risk=$((risk + 2))
    reason="$reason; architecture/refactor risk"
  fi

  if [ "$has_intent" -eq 1 ]; then
    pull=$((pull + 1))
  else
    risk=$((risk + 1))
    reason="$reason; intent section missing (Overview/Goal/Description)"
  fi

  if [ "$has_intent_alias_dup" -eq 1 ]; then
    risk=$((risk + 1))
    reason="$reason; intent alias duplication (Overview/Goal/Description)"
  fi

  if [ "$has_scope_alias_dup" -eq 1 ]; then
    risk=$((risk + 1))
    reason="$reason; scope alias duplication (Scope/Rules)"
  fi

  if [ "$heading_count" -lt 2 ]; then
    pull=$((pull - 1))
    risk=$((risk + 1))
    reason="$reason; sparse structure"
  fi

  if [ "$line_count" -gt 220 ]; then
    risk=$((risk + 1))
    reason="$reason; large scope surface"
  fi

  if [ "$has_out_of_scope" -eq 1 ]; then
    reason="$reason; boundaries explicitly documented"
  fi

  if [ "$is_explicitly_misaligned" -eq 1 ]; then
    core=$((core - 2))
    importance=$((importance - 2))
    risk=$((risk + 2))
    reason="$reason; explicit misalignment signal"
  fi

  local queue_bonus
  queue_bonus="$(queue_bonus_for_rel "$project_root" "$rel")"
  if awk -v q="$queue_bonus" 'BEGIN{exit !(q > 0)}'; then
    importance=$((importance + 1))
    reason="$reason; queue-prioritized"
  fi

  core="$(clamp_int "$core" 0 5)"
  importance="$(clamp_int "$importance" 0 5)"
  pull="$(clamp_int "$pull" 0 5)"
  risk="$(clamp_int "$risk" 0 5)"

  local grant adjusted final
  grant="$(awk -v c="$core" -v i="$importance" -v p="$pull" 'BEGIN{printf "%.2f", 0.5*c + 0.3*i + 0.2*p}')"
  adjusted="$(awk -v g="$grant" -v r="$risk" 'BEGIN{printf "%.2f", g - 0.25*r}')"
  final="$(awk -v a="$adjusted" -v q="$queue_bonus" 'BEGIN{printf "%.2f", a + q}')"

  local appetite decision action completion_state
  if awk -v a="$adjusted" 'BEGIN{exit !(a >= 3.5)}'; then
    appetite="L"
  elif awk -v a="$adjusted" 'BEGIN{exit !(a >= 2.5)}'; then
    appetite="M"
  elif awk -v a="$adjusted" 'BEGIN{exit !(a >= 1.8)}'; then
    appetite="S"
  else
    appetite="refuse-candidate"
  fi

  local stale_remove_gate=0
  if [ -n "$age_days" ]; then
    if [ "$bucket" = "backlog" ] && [ "$age_days" -ge 240 ]; then
      stale_remove_gate=1
    fi
    if [ "$bucket" = "active" ] && [ "$age_days" -ge 365 ]; then
      stale_remove_gate=1
    fi
  fi

  local low_value_remove_gate=0
  if [ -n "$age_days" ] && [ "$age_days" -ge 150 ]; then
    if awk -v a="$adjusted" -v q="$queue_bonus" 'BEGIN{exit !(a < 1.6 && q <= 0.0)}'; then
      low_value_remove_gate=1
    fi
  fi

  if [ "$is_completed" -eq 1 ] || [ "$is_implemented" -eq 1 ]; then
    decision="refuse"
    action="archive"
    completion_state="completed-or-obsolete"
    reason="$reason; implemented/completed gate (archive)"
  elif [ "$stale_remove_gate" -eq 1 ]; then
    decision="refuse"
    action="remove"
    completion_state="open"
    reason="$reason; staleness gate"
  elif [ "$is_explicitly_misaligned" -eq 1 ] || [ "$low_value_remove_gate" -eq 1 ]; then
    decision="refuse"
    action="remove"
    completion_state="open"
    reason="$reason; relevance gate"
  else
    completion_state="open"

    if [ "$has_intent_alias_dup" -eq 1 ] || [ "$has_scope_alias_dup" -eq 1 ]; then
      decision="reshape"
      action="refine"
      reason="$reason; alias-set cleanup required"
    else
      if [ "$profile" = "focus-cut" ]; then
        if awk -v a="$adjusted" 'BEGIN{exit !(a >= 3.6)}'; then
          decision="do-now"
          action="keep"
        elif awk -v a="$adjusted" 'BEGIN{exit !(a >= 1.9)}'; then
          decision="reshape"
          action="refine"
        else
          decision="reshape"
          action="refine"
        fi
      else
        if awk -v a="$adjusted" 'BEGIN{exit !(a >= 3.0)}'; then
          decision="do-now"
          action="keep"
        elif awk -v a="$adjusted" 'BEGIN{exit !(a >= 1.6)}'; then
          decision="reshape"
          action="refine"
        else
          decision="reshape"
          action="refine"
        fi
      fi
    fi
  fi

  local refine_effort="n/a"
  local refine_hint="n/a"
  if [ "$action" = "refine" ]; then
    refine_effort="easy"
    refine_hint="straight reshape to Overview/Goal/Description + optional Scope/Rules + Plan"

    if [ "$has_intent_alias_dup" -eq 1 ] || [ "$has_scope_alias_dup" -eq 1 ]; then
      refine_effort="needs-attention"
      refine_hint="multiple headings from a single alias set are present"
    elif [ "$heading_count" -eq 0 ]; then
      refine_effort="needs-attention"
      refine_hint="no section structure to map automatically"
    elif [ "$heading_count" -le 1 ]; then
      refine_effort="needs-attention"
      refine_hint="single-section document needs manual restructuring"
    elif [ "$has_intent" -eq 0 ]; then
      refine_effort="needs-attention"
      refine_hint="missing Overview/Goal/Description intent anchor"
    elif [ "$is_spike" -eq 1 ] && [ "$heading_count" -ge 8 ]; then
      refine_effort="needs-attention"
      refine_hint="spike-style doc with many custom sections"
    elif [ "$has_scope_or_rules" -eq 0 ] && [ "$has_plan_section" -eq 0 ] && [ "$heading_count" -ge 7 ]; then
      refine_effort="needs-attention"
      refine_hint="complex heading set lacks explicit Scope/Rules and Plan"
    elif [ "$line_count" -ge 260 ]; then
      refine_effort="needs-attention"
      refine_hint="large document size likely needs manual editorial pass"
    fi
  fi

  printf '%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n' \
    "$file" "$rel" "$bucket" "$decision" "$action" "$appetite" "$final" "$adjusted" "$core" "$importance" "$pull" "$risk" "$completion_state" "$reason" "$refine_effort" "$refine_hint"
}
