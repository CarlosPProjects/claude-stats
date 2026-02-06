# ClaudeStats 📊

Minimal macOS menu bar app to monitor your Claude API usage.

## Features

- 🎯 Session usage percentage with visual progress bar
- ⏰ Time until reset countdown
- 🔄 One-click refresh
- 🔐 Reads token from Claude CLI keychain/credentials

## Requirements

- macOS 14+ (Sonoma)
- Xcode 15+
- Claude CLI authenticated (`claude` command)

## Build & Run

### Option 1: Xcode (Recommended)
```bash
cd ~/Developer/claude-stats
open Package.swift
# Press Cmd+R to run
```

### Option 2: Command Line
```bash
swift build -c release
.build/release/ClaudeStats
```

## How It Works

1. Reads your OAuth token from Claude CLI keychain
2. Fetches usage from `api.anthropic.com/v1/settings/usage`
3. Displays in a clean menu bar popover

## Token Sources (in order)

1. **Keychain:** `Claude Code-credentials` (set by `claude` CLI)
2. **File:** `~/.claude/credentials.json`
3. **File:** `~/.config/claude/credentials.json`

## License

MIT - Do whatever you want with it.
