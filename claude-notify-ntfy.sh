#!/usr/bin/env bash
set -euo pipefail

INPUT="$(cat)"
EVENT="$(echo "$INPUT" | jq -r '.hook_event_name // ""')"
TYPE="$(echo "$INPUT" | jq -r '.notification_type // ""')"
MSG="$(echo "$INPUT" | jq -r '.message // ""')"
CWD="$(echo "$INPUT" | jq -r '.cwd // ""')"

# Derive a friendly title/message depending on which hook fired.
if [ "$EVENT" = "Stop" ]; then
  TITLE="Claude Code: 任务完成"
  [ -z "$MSG" ] && MSG="Claude Code 已完成本轮任务"
else
  TITLE="Claude Code: ${TYPE:-notification}"
  [ -z "$MSG" ] && MSG="Claude Code finished or needs attention"
fi

curl -fsS \
  -H "Title: ${TITLE}" \
  -H "Priority: default" \
  -d "${MSG}

${CWD}" \
  "此处填你的订阅号（因为是发布订阅模式，所以注意重复导致被监听）" >/dev/null
