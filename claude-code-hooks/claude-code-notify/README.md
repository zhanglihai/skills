# Claude Code Notify

Claude Code hooks 配置，在需要人工确认时和完成工作时播放声音通知。

## 功能

通过配置 Claude Code hooks，在两个关键时刻播放声音：

| Hook 事件 | 触发时机 | 声音 |
|-----------|----------|------|
| `Notification` | Claude 等待权限确认或提问时 | Hero（响亮，引起注意） |
| `Stop` | Claude 完成当前工作时 | Sosumi（清脆，标识完成） |

## 文件说明

```
claude-code-notify/
├── README.md           # 本文档
├── play-sound.sh       # macOS / Linux 播放脚本
├── play-sound.ps1      # Windows 播放脚本
└── sounds/
    ├── Hero.aiff       # 确认提示音
    └── Sosumi.aiff     # 完成提示音
```

## 安装配置

### 1. 复制文件到 Claude Code 目录

```bash
cp -r claude-code-notify ~/.claude/claude-code-notify
```

### 2. 配置 Hooks

编辑 `~/.claude/settings.json`，添加 `hooks` 配置。

**macOS / Linux：**

```json
{
  "hooks": {
    "Notification": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "~/.claude/claude-code-notify/play-sound.sh prompt",
            "shell": "bash",
            "async": true
          }
        ]
      }
    ],
    "Stop": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "~/.claude/claude-code-notify/play-sound.sh done",
            "shell": "bash",
            "async": true
          }
        ]
      }
    ]
  }
}
```

**Windows：**

```json
{
  "hooks": {
    "Notification": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "$HOME\\.claude\\claude-code-notify\\play-sound.ps1 prompt",
            "shell": "powershell",
            "async": true
          }
        ]
      }
    ],
    "Stop": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "$HOME\\.claude\\claude-code-notify\\play-sound.ps1 done",
            "shell": "powershell",
            "async": true
          }
        ]
      }
    ]
  }
}
```

> **注意：** 如果 `~/.claude/settings.json` 已有 `hooks` 配置，请将上面的内容合并到现有 hooks 中，而不是替换。

### 3. 测试

```bash
# macOS / Linux
~/.claude/claude-code-notify/play-sound.sh prompt
~/.claude/claude-code-notify/play-sound.sh done

# Windows (PowerShell)
& "$HOME\.claude\claude-code-notify\play-sound.ps1" prompt
& "$HOME\.claude\claude-code-notify\play-sound.ps1" done
```

## 平台支持

| 平台 | 脚本 | 音频引擎 | 回退方案 |
|------|------|----------|----------|
| macOS | `play-sound.sh` | `afplay`（系统自带） | 终端响铃 |
| Linux | `play-sound.sh` | `paplay` → `aplay` → `ffplay` → `mpv` | 终端响铃 |
| Windows | `play-sound.ps1` | `System.Media.SoundPlayer` | `Console.Beep` |

Linux 需确保已安装至少一个音频播放器（大多数桌面发行版已预装 PulseAudio 或 PipeWire）。

## 自定义

替换 `sounds/` 目录中的音频文件即可自定义声音。macOS 系统自带声音位于 `/System/Library/Sounds/`，可选：Hero、Sosumi、Funk、Bottle、Ping、Glass、Pop 等。

## 禁用

删除 `~/.claude/settings.json` 中对应的 hooks 配置，或使用 Claude Code 内置的 `/hooks` 命令管理。
