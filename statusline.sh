#!/usr/bin/env bash
# Claude Code statusline script

input=$(cat)

# --- Colors ---
GREEN=$(printf '\x1b[32m')
YELLOW=$(printf '\x1b[33m')
RED=$(printf '\x1b[1;31m')
GRAY=$(printf '\x1b[90m')
RESET=$(printf '\x1b[0m')

# --- Current working directory (with ~ substitution) ---
cwd=$(echo "$input" | jq -r '.workspace.current_dir // .cwd // empty')
if [ -z "$cwd" ]; then
  cwd=$(pwd)
fi
case "$cwd" in
  "$HOME"*) cwd="~${cwd#$HOME}" ;;
esac

# --- Model ---
model=$(echo "$input" | jq -r '.model.display_name // "Unknown"')

# --- Git branch ---
branch=$(echo "$input" | jq -r '.git.branch // empty')
if [ -z "$branch" ]; then
  branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "")
fi
branch_str=""
if [ -n "$branch" ]; then
  branch_str="${GREEN}⎇ ${branch}${RESET} | "
fi

# --- Session cost ---
cost=$(echo "$input" | jq -r '.cost.total_cost_usd // empty')
if [ -n "$cost" ]; then
  cost_str=$(printf '~$%.2f' "$cost")
else
  total_in=$(echo "$input"  | jq -r '.context_window.total_input_tokens  // 0')
  total_out=$(echo "$input" | jq -r '.context_window.total_output_tokens // 0')
  cost_str=$(echo "$total_in $total_out" | awk '{
    cost = ($1/1000000)*15 + ($2/1000000)*75
    printf "~$%.2f", cost
  }')
fi

# --- Context window usage (color-coded) ---
# Green < 50% | Yellow 50-70% | Red >= 70%
used_pct=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
if [ -n "$used_pct" ]; then
  pct_int=$(printf '%.0f' "$used_pct")
  if [ "$pct_int" -ge 70 ]; then
    ctx_str="${RED}${pct_int}% ⚠ 建議壓縮${RESET}"
  elif [ "$pct_int" -ge 50 ]; then
    ctx_str="${YELLOW}${pct_int}%${RESET}"
  else
    ctx_str="${GREEN}${pct_int}%${RESET}"
  fi
else
  ctx_str="--%"
fi

# --- Rate limits (Pro/Max, color-coded) ---
# Green < 50% | Yellow 50-90% | Red >= 90%
rl5h=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')
rl7d=$(echo "$input" | jq -r '.rate_limits.seven_day.used_percentage // empty')
rl_str=""
if [ -n "$rl5h" ] || [ -n "$rl7d" ]; then
  rl_parts=""
  if [ -n "$rl5h" ]; then
    rl5h_int=$(printf '%.0f' "$rl5h")
    if [ "$rl5h_int" -ge 90 ]; then rl5c="$RED"
    elif [ "$rl5h_int" -ge 50 ]; then rl5c="$YELLOW"
    else rl5c="$GREEN"; fi
    rl_parts="5h: ${rl5c}${rl5h_int}%${RESET}"
  fi
  if [ -n "$rl7d" ]; then
    rl7d_int=$(printf '%.0f' "$rl7d")
    if [ "$rl7d_int" -ge 90 ]; then rl7c="$RED"
    elif [ "$rl7d_int" -ge 50 ]; then rl7c="$YELLOW"
    else rl7c="$GREEN"; fi
    rl_parts="${rl_parts:+$rl_parts | }7d: ${rl7c}${rl7d_int}%${RESET}"
  fi
  rl_str=" | ${rl_parts}"
fi

printf "%s%s | %s | ctx: %s%s\n%s%s%s" "$branch_str" "$model" "$cost_str" "$ctx_str" "$rl_str" "$GRAY" "$cwd" "$RESET"
