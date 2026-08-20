# claude-code-status-line

[繁體中文版 README](README.zh-TW.md)

A customizable status bar for [Claude Code](https://docs.anthropic.com/en/docs/claude-code) and [Google Antigravity CLI (`agy`)](https://antigravity.google) that displays real-time session info at the bottom of your terminal.

## What it shows

![Status line preview](docs/preview.png)

```
⎇ main | Claude Opus 4.6 | ~$1.23 | ctx: 40% | 5h: 12% | 7d: 3%
~/path/to/project
```

| Field | Description |
|-------|-------------|
| `⎇ main` | Current git branch (green) |
| `Claude Opus 4.6` / `Gemini 3.7 Flash` | Active model name |
| `~$1.23` | Estimated session cost (USD, dynamic multi-model pricing) |
| `ctx: 40%` | Context window usage (color-coded) |
| `5h: 12%` | 5-hour rate limit / quota usage (Claude Pro/Max or Antigravity) |
| `7d: 3%` | 7-day rate limit / weekly quota usage (Claude Pro/Max or Antigravity) |
| `~/path/to/project` | Current working directory (gray, `$HOME` shown as `~`) |

### Color coding

**Context window:**
- Green: < 50% (safe)
- Yellow: 50-70% (early content may be forgotten)
- Red + warning: >= 70% (recommend compacting)

**Rate limits / Quota:**
- Green: < 50%
- Yellow: 50-90%
- Red: >= 90%

## Installation

### One-line install

```bash
git clone https://github.com/bolaslien/claude-code-status-line.git
cd claude-code-status-line
./install.sh
```

### Manual install

#### For Claude Code
1. Copy `statusline.sh` to `~/.claude/`:

```bash
cp statusline.sh ~/.claude/statusline.sh
chmod +x ~/.claude/statusline.sh
```

2. Add to `~/.claude/settings.json`:

```json
{
  "statusLine": {
    "type": "command",
    "command": "~/.claude/statusline.sh"
  }
}
```

3. Restart Claude Code.

#### For Antigravity CLI (`agy`)
1. Copy `statusline.sh` to `~/.gemini/antigravity-cli/`:

```bash
cp statusline.sh ~/.gemini/antigravity-cli/statusline.sh
chmod +x ~/.gemini/antigravity-cli/statusline.sh
```

2. Add to `~/.gemini/antigravity-cli/settings.json`:

```json
{
  "statusLine": {
    "type": "command",
    "command": "~/.gemini/antigravity-cli/statusline.sh"
  }
}
```

3. Restart Antigravity CLI (`agy`).

## Requirements

- [jq](https://jqlang.github.io/jq/) - JSON processor

```bash
# macOS
brew install jq

# Ubuntu/Debian
sudo apt install jq

# Arch
sudo pacman -S jq
```

## Customization

Edit `statusline.sh` to customize:

- **Color thresholds**: Change the percentage values in the `if/elif` conditions
- **Fields**: Add or remove sections in the final `printf`

## License

[MIT](LICENSE)

