# claude-code-status-line

[English README](README.md)

一個可自訂的 [Claude Code](https://docs.anthropic.com/en/docs/claude-code) 狀態列，在終端機底部即時顯示 session 資訊。

## 顯示內容

```
⎇ main | Claude Opus 4.6 | ~$1.23 | ctx: 40% | 5h: 12% | 7d: 3%
~/path/to/project
```

| 欄位 | 說明 |
|------|------|
| `⎇ main` | 目前 git 分支（綠色）|
| `Claude Opus 4.6` | 使用中的模型名稱 |
| `~$1.23` | 本次 session 估算費用（USD）|
| `ctx: 40%` | Context window 使用率（帶顏色）|
| `5h: 12%` | 5 小時速率限制使用率（僅 Pro/Max）|
| `7d: 3%` | 7 天速率限制使用率（僅 Pro/Max）|
| `~/path/to/project` | 目前工作目錄（暗灰色，`$HOME` 顯示為 `~`）|

### 顏色說明

**Context window：**
- 綠色：< 50%（安全）
- 黃色：50-70%（較早的對話可能被遺忘）
- 紅色 + 警告：>= 70%（建議壓縮對話）

**速率限制：**
- 綠色：< 50%
- 黃色：50-90%
- 紅色：>= 90%

## 安裝

### 一鍵安裝

```bash
git clone https://github.com/bolaslien/claude-code-status-line.git
cd claude-code-status-line
./install.sh
```

### 手動安裝

1. 複製 `statusline.sh` 到 `~/.claude/`：

```bash
cp statusline.sh ~/.claude/statusline.sh
chmod +x ~/.claude/statusline.sh
```

2. 在 `~/.claude/settings.json` 加入設定：

```json
{
  "statusLine": {
    "type": "command",
    "command": "~/.claude/statusline.sh"
  }
}
```

3. 重新啟動 Claude Code。

## 相依性

- [jq](https://jqlang.github.io/jq/) — JSON 處理工具

```bash
# macOS
brew install jq

# Ubuntu/Debian
sudo apt install jq

# Arch
sudo pacman -S jq
```

## 自訂

編輯 `~/.claude/statusline.sh` 即可自訂：

- **顏色門檻**：修改 `if/elif` 條件中的百分比數值
- **欄位**：在最後的 `printf` 增減區段

## 授權

[MIT](LICENSE)
