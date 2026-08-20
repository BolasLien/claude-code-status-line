#!/usr/bin/env bash
# Claude Code & Antigravity statusline script
# Compatible with Claude Code and Antigravity (agy)

input=$(cat)

# --- Colors ---
GREEN=$(printf '\x1b[32m')
YELLOW=$(printf '\x1b[33m')
RED=$(printf '\x1b[1;31m')
GRAY=$(printf '\x1b[90m')
RESET=$(printf '\x1b[0m')

# --- Current working directory (with ~ substitution) ---
cwd=$(echo "$input" | jq -r '.workspace.current_dir // .workspace.path // .cwd // (if .workspaces | type == "array" then .workspaces[0] else empty end) // empty' 2>/dev/null)
if [ -z "$cwd" ]; then
  cwd=$(pwd)
fi
case "$cwd" in
  "$HOME"*) cwd="~${cwd#$HOME}" ;;
esac

# --- Model ---
model=$(echo "$input" | jq -r '.model.display_name // .model.name // (if .model | type == "string" then .model else empty end) // "Unknown"' 2>/dev/null)

# --- Git / VCS branch ---
branch=$(echo "$input" | jq -r '.vcs.branch // .git.branch // .branch // empty' 2>/dev/null)
if [ -z "$branch" ]; then
  branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "")
fi
branch_str=""
if [ -n "$branch" ]; then
  branch_str="${GREEN}⎇ ${branch}${RESET} | "
fi

# --- Session cost / tokens ---
cost=$(echo "$input" | jq -r '.cost.total_cost_usd // .cost.total_cost // empty' 2>/dev/null)
if [ -n "$cost" ]; then
  cost_str=$(printf '~$%.2f' "$cost")
else
  total_in=$(echo "$input"  | jq -r '.context_window.total_input_tokens  // .tokens.input // 0' 2>/dev/null)
  total_out=$(echo "$input" | jq -r '.context_window.total_output_tokens // .tokens.output // 0' 2>/dev/null)
  
  # Calculate fallback cost based on model family
  cost_str=$(echo "$model $total_in $total_out" | awk '{
    m = tolower($1);
    in_tok = $2;
    out_tok = $3;
    if (in_tok == 0 && out_tok == 0) {
      printf "~$0.00";
    } else if (index(m, "opus") > 0) {
      cost = (in_tok/1000000)*15 + (out_tok/1000000)*75;
      printf "~$%.2f", cost;
    } else if (index(m, "flash") > 0) {
      cost = (in_tok/1000000)*0.10 + (out_tok/1000000)*0.40;
      printf "~$%.2f", cost;
    } else if (index(m, "pro") > 0) {
      cost = (in_tok/1000000)*1.25 + (out_tok/1000000)*5.00;
      printf "~$%.2f", cost;
    } else {
      # Default Sonnet pricing fallback
      cost = (in_tok/1000000)*3 + (out_tok/1000000)*15;
      printf "~$%.2f", cost;
    }
  }')
fi

# --- Context window usage (color-coded) ---
# Green < 50% | Yellow 50-70% | Red >= 70%
used_pct=$(echo "$input" | jq -r '.context_window.used_percentage // .context_window.percent_used // .context.used_percentage // empty' 2>/dev/null)
if [ -z "$used_pct" ]; then
  tokens=$(echo "$input" | jq -r '.context_window.current_tokens // .context_window.total_input_tokens // empty' 2>/dev/null)
  limit=$(echo "$input" | jq -r '.context_window.context_window_size // .context_window.max_tokens // empty' 2>/dev/null)
  if [ -n "$tokens" ] && [ -n "$limit" ] && [ "$limit" -gt 0 ] 2>/dev/null; then
    used_pct=$(awk -v t="$tokens" -v l="$limit" 'BEGIN { printf "%.1f", (t/l)*100 }')
  fi
fi

if [ -n "$used_pct" ]; then
  pct_int=$(printf '%.0f' "$used_pct" 2>/dev/null || echo "0")
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

# --- Rate limits / Quota (Claude Code & Antigravity, color-coded) ---
# Green < 50% | Yellow 50-90% | Red >= 90%
rl5h=$(echo "$input" | jq -r '
  .rate_limits.five_hour.used_percentage //
  (if .quota then
    (if (.model.id // .model.display_name // "" | test("claude|gpt|3p"; "i")) then
      (.quota["3p-5h"].remaining_fraction // .quota["gemini-5h"].remaining_fraction)
    else
      (.quota["gemini-5h"].remaining_fraction // .quota["3p-5h"].remaining_fraction)
    end | if . != null then ((1 - .) * 100) else empty end)
  else empty end) // empty
' 2>/dev/null)

rl7d=$(echo "$input" | jq -r '
  .rate_limits.seven_day.used_percentage //
  (if .quota then
    (if (.model.id // .model.display_name // "" | test("claude|gpt|3p"; "i")) then
      (.quota["3p-weekly"].remaining_fraction // .quota["gemini-weekly"].remaining_fraction)
    else
      (.quota["gemini-weekly"].remaining_fraction // .quota["3p-weekly"].remaining_fraction)
    end | if . != null then ((1 - .) * 100) else empty end)
  else empty end) // empty
' 2>/dev/null)

rl_str=""
if [ -n "$rl5h" ] || [ -n "$rl7d" ]; then
  rl_parts=""
  if [ -n "$rl5h" ]; then
    rl5h_int=$(printf '%.0f' "$rl5h" 2>/dev/null || echo "0")
    if [ "$rl5h_int" -ge 90 ]; then rl5c="$RED"
    elif [ "$rl5h_int" -ge 50 ]; then rl5c="$YELLOW"
    else rl5c="$GREEN"; fi
    rl_parts="5h: ${rl5c}${rl5h_int}%${RESET}"
  fi
  if [ -n "$rl7d" ]; then
    rl7d_int=$(printf '%.0f' "$rl7d" 2>/dev/null || echo "0")
    if [ "$rl7d_int" -ge 90 ]; then rl7c="$RED"
    elif [ "$rl7d_int" -ge 50 ]; then rl7c="$YELLOW"
    else rl7c="$GREEN"; fi
    rl_parts="${rl_parts:+$rl_parts | }7d: ${rl7c}${rl7d_int}%${RESET}"
  fi
  rl_str=" | ${rl_parts}"
fi

printf "%s%s | %s | ctx: %s%s\n%s%s%s" "$branch_str" "$model" "$cost_str" "$ctx_str" "$rl_str" "$GRAY" "$cwd" "$RESET"
