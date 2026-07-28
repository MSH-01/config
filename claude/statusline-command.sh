#!/bin/bash

input=$(cat)

model=$(printf '%s' "$input" | jq -r '.model.display_name // empty' 2>/dev/null)
project_dir=$(printf '%s' "$input" | jq -r '.workspace.project_dir // .workspace.current_dir // .cwd // empty' 2>/dev/null)

dir_name=""
[ -n "$project_dir" ] && dir_name=$(basename "$project_dir")

branch=""
if [ -n "$project_dir" ] && git -C "$project_dir" --no-optional-locks rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  branch=$(git -C "$project_dir" --no-optional-locks symbolic-ref --short -q HEAD 2>/dev/null)
  [ -z "$branch" ] && branch=$(git -C "$project_dir" --no-optional-locks rev-parse --short HEAD 2>/dev/null)
  if [ -n "$branch" ] && [ -n "$(git -C "$project_dir" --no-optional-locks status --porcelain 2>/dev/null)" ]; then
    branch="${branch}*"
  fi
fi

USAGE_RESET_THRESHOLD="${STATUSLINE_USAGE_RESET_THRESHOLD:-50}"

usage_pct=$(printf '%s' "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty' 2>/dev/null)
usage_label=""
if [ -n "$usage_pct" ]; then
  usage_int=$(printf '%.0f' "$usage_pct" 2>/dev/null)
  [ -n "$usage_int" ] && usage_label="usage ${usage_int}%"
fi

if [ -n "$usage_int" ] && [ "$usage_int" -ge "$USAGE_RESET_THRESHOLD" ]; then
  resets_at=$(printf '%s' "$input" | jq -r '.rate_limits.five_hour.resets_at // empty' 2>/dev/null)
  case "$resets_at" in
    ''|*[!0-9]*) resets_at="" ;;
  esac
  if [ -n "$resets_at" ]; then
    remaining=$(( resets_at - $(date +%s) ))
    [ "$remaining" -lt 0 ] && remaining=0
    hours=$(( remaining / 3600 ))
    mins=$(( (remaining % 3600) / 60 ))
    if [ "$hours" -gt 0 ]; then
      usage_label="${usage_label} (${hours}h${mins}m)"
    else
      usage_label="${usage_label} (${mins}m)"
    fi
  fi
fi

ctx_pct=$(printf '%s' "$input" | jq -r '.context_window.used_percentage // empty' 2>/dev/null)
ctx_label=""
if [ -n "$ctx_pct" ]; then
  ctx_int=$(printf '%.0f' "$ctx_pct" 2>/dev/null)
  [ -n "$ctx_int" ] && ctx_label="ctx ${ctx_int}%"
fi

DIM=$'\033[2m'
RESET=$'\033[0m'
CYAN=$'\033[36m'
BLUE=$'\033[34m'
GREEN=$'\033[32m'
MAGENTA=$'\033[35m'
DOT="${DIM} · ${RESET}"
DOT_PLAIN=" · "
BAR="${DIM} │ ${RESET}"
BAR_PLAIN=" │ "

join() {
  local sep="$1"
  shift
  local out="" part
  for part in "$@"; do
    [ -z "$part" ] && continue
    if [ -z "$out" ]; then
      out="$part"
    else
      out="${out}${sep}${part}"
    fi
  done
  printf '%s' "$out"
}

group1_disp="${model:+${DIM}${CYAN}${model}${RESET}}"
group1_plain="$model"

group2_disp=$(join "$DOT" "${dir_name:+${DIM}${BLUE}${dir_name}${RESET}}" "${branch:+${DIM}${GREEN}${branch}${RESET}}")
group2_plain=$(join "$DOT_PLAIN" "$dir_name" "$branch")

group3_disp=$(join "$DOT" "${usage_label:+${DIM}${MAGENTA}${usage_label}${RESET}}" "${ctx_label:+${DIM}${MAGENTA}${ctx_label}${RESET}}")
group3_plain=$(join "$DOT_PLAIN" "$usage_label" "$ctx_label")

left_disp=$(join "$BAR" "$group1_disp" "$group2_disp")
left_plain=$(join "$BAR_PLAIN" "$group1_plain" "$group2_plain")

esc=$(printf '\033')
visible_len() {
  local stripped
  stripped=$(printf '%s' "$1" | sed "s/${esc}\[[0-9;]*m//g")
  printf '%s' "$stripped" | LC_ALL=en_US.UTF-8 wc -m 2>/dev/null | tr -d ' '
}

term_width=""
if [ -n "$COLUMNS" ]; then
  term_width="$COLUMNS"
elif command -v tput >/dev/null 2>&1; then
  tw=$(tput cols 2>/dev/null)
  [ -n "$tw" ] && term_width="$tw"
fi
case "$term_width" in
  ''|*[!0-9]*) term_width="" ;;
esac

# Claude Code appears to render the status line in an area narrower than the
# raw terminal width reported by tput/$COLUMNS (it likely reserves a column
# or two for its own UI chrome). Reserve a safety margin so the right-aligned
# group never gets clipped. If you still see truncation, raise this; if
# there's an unwanted large gap, lower it.
STATUSLINE_WIDTH_MARGIN="${STATUSLINE_WIDTH_MARGIN:-4}"

if [ -z "$group3_plain" ]; then
  printf "%s\n" "$left_disp"
elif [ -n "$term_width" ]; then
  left_len=$(visible_len "$left_plain")
  right_len=$(visible_len "$group3_plain")
  [ -z "$left_len" ] && left_len=0
  [ -z "$right_len" ] && right_len=0
  effective_width=$(( term_width - STATUSLINE_WIDTH_MARGIN ))
  [ "$effective_width" -lt 1 ] && effective_width=1
  pad=$(( effective_width - left_len - right_len ))
  if [ "$pad" -ge 1 ]; then
    printf "%s%*s%s\n" "$left_disp" "$pad" "" "$group3_disp"
  else
    printf "%s\n" "$(join "$BAR" "$left_disp" "$group3_disp")"
  fi
else
  printf "%s\n" "$(join "$BAR" "$left_disp" "$group3_disp")"
fi
