# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## [2026-08-20]

### Added
- Support for Google Antigravity CLI (`agy`) alongside Claude Code.
- Antigravity quota tracking for 5h (`gemini-5h` / `3p-5h`) and 7d (`gemini-weekly` / `3p-weekly`).
- Dynamic multi-model pricing fallback for Gemini Flash, Gemini Pro, Claude Opus, and Claude Sonnet.
- Context window token-based fallback calculation when `used_percentage` is omitted.
- Multi-target installation support in `install.sh` (`--claude` / `--agy`).

## [2026-04-14]

### Added
- Display the current working directory on the second line in gray, with `$HOME` substituted as `~`.

### Changed
- Split the status bar into two lines: branch, model, cost, context, and rate limits on the first line; working directory on the second line.
