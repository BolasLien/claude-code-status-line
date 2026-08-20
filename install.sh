#!/usr/bin/env bash
set -e

CLAUDE_DIR="$HOME/.claude"
AGY_DIR="$HOME/.gemini/antigravity-cli"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "=== Claude Code & Antigravity Status Bar Installer ==="
echo ""

# Check jq dependency
if ! command -v jq &>/dev/null; then
  echo "❌ jq is required but not installed."
  echo ""
  echo "Install it with:"
  echo "  macOS:  brew install jq"
  echo "  Ubuntu: sudo apt install jq"
  echo "  Arch:   sudo pacman -S jq"
  exit 1
fi

# Install for Claude Code
if [ -d "$CLAUDE_DIR" ] || [ "$1" == "--claude" ]; then
  mkdir -p "$CLAUDE_DIR"
  cp "$SCRIPT_DIR/statusline.sh" "$CLAUDE_DIR/statusline.sh"
  chmod +x "$CLAUDE_DIR/statusline.sh"
  echo "✅ Installed statusline.sh to $CLAUDE_DIR/statusline.sh"

  SETTINGS_FILE="$CLAUDE_DIR/settings.json"
  if [ -f "$SETTINGS_FILE" ]; then
    if echo "$(cat "$SETTINGS_FILE")" | jq -e '.statusLine' &>/dev/null; then
      echo "⚠️  statusLine already configured in $SETTINGS_FILE, updating..."
    fi
    tmp=$(mktemp)
    jq '.statusLine = {"type": "command", "command": "~/.claude/statusline.sh"}' "$SETTINGS_FILE" > "$tmp"
    mv "$tmp" "$SETTINGS_FILE"
  else
    echo '{"statusLine":{"type":"command","command":"~/.claude/statusline.sh"}}' | jq . > "$SETTINGS_FILE"
  fi
  echo "✅ Configured statusLine in $SETTINGS_FILE"
fi

# Install for Antigravity CLI (agy)
if [ -d "$AGY_DIR" ] || [ "$1" == "--agy" ]; then
  mkdir -p "$AGY_DIR"
  cp "$SCRIPT_DIR/statusline.sh" "$AGY_DIR/statusline.sh"
  chmod +x "$AGY_DIR/statusline.sh"
  echo "✅ Installed statusline.sh to $AGY_DIR/statusline.sh"

  AGY_SETTINGS="$AGY_DIR/settings.json"
  if [ -f "$AGY_SETTINGS" ]; then
    if echo "$(cat "$AGY_SETTINGS")" | jq -e '.statusLine' &>/dev/null; then
      echo "⚠️  statusLine already configured in $AGY_SETTINGS, updating..."
    fi
    tmp=$(mktemp)
    jq '.statusLine = {"type": "command", "command": "~/.gemini/antigravity-cli/statusline.sh"}' "$AGY_SETTINGS" > "$tmp"
    mv "$tmp" "$AGY_SETTINGS"
  else
    echo '{"statusLine":{"type":"command","command":"~/.gemini/antigravity-cli/statusline.sh"}}' | jq . > "$AGY_SETTINGS"
  fi
  echo "✅ Configured statusLine in $AGY_SETTINGS"
fi

echo ""
echo "🎉 Done! Restart Claude Code / Antigravity CLI to see the status bar."
