#!/usr/bin/env bash
# Claude Code status line
# Sections separated by " | ", colored via ANSI

input=$(cat)

# ── 1. Model ────────────────────────────────────────────────────────────────
model=$(echo "$input" | jq -r '.model.display_name // .model.id // "unknown"')

# ── 2. Context window progress bar ──────────────────────────────────────────
used_pct=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
if [ -n "$used_pct" ]; then
  used_int=$(printf '%.0f' "$used_pct")
  bar_total=10
  bar_filled=$(( used_int * bar_total / 100 ))
  bar_empty=$(( bar_total - bar_filled ))
  bar=""
  for ((i=0; i<bar_filled; i++)); do bar="${bar}█"; done
  for ((i=0; i<bar_empty; i++));  do bar="${bar}░"; done
  # color: green < 60%, yellow < 85%, red >= 85%
  if   [ "$used_int" -ge 85 ]; then bar_color="\033[0;31m"
  elif [ "$used_int" -ge 60 ]; then bar_color="\033[0;33m"
  else                               bar_color="\033[0;32m"
  fi
  ctx_section="${bar_color}${bar}\033[0m ${used_int}%"
else
  ctx_section="ctx: --"
fi

# ── 3. Git branch ────────────────────────────────────────────────────────────
cwd=$(echo "$input" | jq -r '.workspace.current_dir // .cwd // ""')
if [ -n "$cwd" ]; then
  branch=$(git -C "$cwd" --no-optional-locks symbolic-ref --short HEAD 2>/dev/null)
fi
if [ -n "$branch" ]; then
  git_section="\033[0;36m${branch}\033[0m"
else
  git_section="\033[2mno git\033[0m"
fi

# ── 4. 5-hour usage limit ────────────────────────────────────────────────────
five_pct=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')
five_resets=$(echo "$input" | jq -r '.rate_limits.five_hour.resets_at // empty')
if [ -n "$five_pct" ]; then
  five_int=$(printf '%.0f' "$five_pct")
  if [ -n "$five_resets" ]; then
    now=$(date +%s)
    diff=$(( five_resets - now ))
    if [ "$diff" -gt 0 ]; then
      mins=$(( diff / 60 ))
      hrs=$(( mins / 60 ))
      mins=$(( mins % 60 ))
      reset_str=" (resets ${hrs}h${mins}m)"
    else
      reset_str=""
    fi
  fi
  if   [ "$five_int" -ge 85 ]; then lim_color="\033[0;31m"
  elif [ "$five_int" -ge 60 ]; then lim_color="\033[0;33m"
  else                               lim_color="\033[0;32m"
  fi
  five_section="${lim_color}5h: ${five_int}%${reset_str}\033[0m"
else
  five_section=""
fi

# ── 5. 7-day quota ───────────────────────────────────────────────────────────
week_pct=$(echo "$input" | jq -r '.rate_limits.seven_day.used_percentage // empty')
if [ -n "$week_pct" ]; then
  week_int=$(printf '%.0f' "$week_pct")
  if   [ "$week_int" -ge 85 ]; then wk_color="\033[0;31m"
  elif [ "$week_int" -ge 60 ]; then wk_color="\033[0;33m"
  else                               wk_color="\033[0;32m"
  fi
  week_section="${wk_color}7d: ${week_int}%\033[0m"
else
  week_section=""
fi

# ── Assemble ─────────────────────────────────────────────────────────────────
sep="\033[2m | \033[0m"
line="\033[0;35m${model}\033[0m${sep}${ctx_section}${sep}${git_section}"
[ -n "$five_section" ] && line="${line}${sep}${five_section}"
[ -n "$week_section" ] && line="${line}${sep}${week_section}"

printf "%b\n" "${line}"
