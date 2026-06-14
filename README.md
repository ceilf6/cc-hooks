## iphone

[ntfy](https://github.com/binwiederhier/ntfy)

记得填你的订阅号：因为是发布-订阅模式，所以小心重复导致被监听

## macbook

用 terminal-notifier + osascript 兜底

## goal 模式

idle_prompt 的触发条件就是「输入框闲置 ≥60 秒」——它分不清「闲置是因为你真的该接手了」还是「闲置是因为模型在等后台 CI 任务、马上会自己继续」。所以监听 CI 会误报。

解决方案: [claude-notify.sh](claude-notify.sh)

1. 把「手机 + mac」两个钩子合并成一个分发脚本（避免两个钩子并发时互相把对方误判成后台任务）。
2. 脚本先做判定：用 session_id 定位本会话的 tasks/ 目录，lsof 看有没有别的活进程占着 .output（排除自身进程链）。有 → 模型在等后台任务，静默不发；没有 → 真的停下了，手机 + mac 都发。

## 权限

别忘记去 `系统设置 → 通知` 配置权限

1. 手机端允许 ntfy 即可
2. macbook 允许 terminal-notifier、iTerm2、Script Editor
3. 如果开了勿扰模式，记得去 `系统设置 → 专注模式 → 勿扰模式 → 允许的 App` 为上述应用打开权限
