#!/usr/bin/env bash
set -euo pipefail

INPUT="$(cat)"

MSG="$(echo "$INPUT" | /opt/homebrew/bin/jq -r '.message // "Claude Code 已完成，正在等待你的输入"')"
CWD="$(echo "$INPUT" | /opt/homebrew/bin/jq -r '.cwd // ""')"

TN="/opt/homebrew/bin/terminal-notifier"

if [ -x "$TN" ]; then
  "$TN" -title "Claude Code" -subtitle "$CWD" -message "$MSG" -sound Glass
else
  # 兜底：terminal-notifier 缺失时退回 osascript
  /usr/bin/osascript -e "display notification \"$MSG\" with title \"Claude Code\" subtitle \"$CWD\" sound name \"Glass\""
fi
