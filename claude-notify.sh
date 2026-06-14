#!/usr/bin/env bash
# 通知分发器：idle_prompt 触发时调用。
# 若模型只是在等后台任务（CI 监听等），则静默不发，避免“假完成”误报。
set -uo pipefail

INPUT="$(cat)"
JQ=/opt/homebrew/bin/jq
LOG="$HOME/.claude/hooks/notify.log"   # 临时调试日志，验证无误后可删

SID="$(printf '%s' "$INPUT" | "$JQ" -r '.session_id // empty' 2>/dev/null)"

# ---- 判定：本会话是否还有后台任务在跑 ----
# 思路：钩子自身的 stdout 也可能被写进某个 .output；先查出“自己的”那个文件并排除，
# 只要有“别的” .output 仍被活进程占用，就说明有后台任务在跑。
suppress=0
running=""
myout="$(/usr/sbin/lsof -p "$$" -a -d 1 -Fn 2>/dev/null | sed -n 's/^n//p' | head -1)"

if [ -n "$SID" ]; then
  for d in /private/tmp/claude-"$(id -u)"/*/"$SID"/tasks; do
    [ -d "$d" ] || continue
    for f in "$d"/*.output; do
      [ -e "$f" ] || continue
      [ "$f" = "$myout" ] && continue           # 跳过本钩子自己的输出文件
      if /usr/sbin/lsof -- "$f" >/dev/null 2>&1; then
        suppress=1
        running="$running ${f##*/}"
      fi
    done
  done
fi

printf '%s\t suppress=%s\t running=[%s]\t myout=%s\t sid=%s\n' \
  "$(date '+%F %T')" "$suppress" "${running# }" "${myout##*/}" "$SID" >> "$LOG" 2>/dev/null || true

if [ "$suppress" = 1 ]; then
  exit 0   # 模型在等后台任务，不是真的需要你接手 → 静默
fi

# ---- 真的停下了：手机 + mac 都通知 ----
printf '%s' "$INPUT" | "$HOME/.claude/hooks/claude-notify-ntfy.sh" || true
printf '%s' "$INPUT" | "$HOME/.claude/hooks/claude-mac-notify.sh"  || true
