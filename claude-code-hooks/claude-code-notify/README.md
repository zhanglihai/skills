# Claude Code Notify

Claude Code hooks 配置，在需要人工确认时和完成工作时播放语音通知。

## 功能

通过配置 Claude Code hooks，在两个关键时刻播放语音提示：

| Hook 事件 | 触发时机 | 语音内容 |
|-----------|----------|----------|
| `Notification` | Claude 等待权限确认或提问时 | "需要确认" |
| `Stop` | Claude 完成当前工作时 | "已完成" |

语音文件由 macOS `say` 命令（TTS）生成，使用婷婷（Tingting）中文语音。

## 文件说明

```
claude-code-notify/
├── README.md           # 本文档
├── play-sound.sh       # macOS / Linux 播放脚本
├── play-sound.ps1      # Windows 播放脚本
└── sounds/
    ├── notify.wav      # "需要确认"（35KB）
    └── done.wav        # "已完成"（29KB）
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

## 自定义语音

### 使用 macOS `say` 命令生成语音文件

本项目自带的语音文件由 macOS `say` 命令（TTS 文字转语音）生成。你可以用同样的方式生成自己的语音文件。

#### 基本命令

```bash
# 生成语音文件
say -v Tingting -r 250 \
    --file-format=WAVE --data-format=LEI16@22050 \
    -o sounds/notify.wav "需要确认"

say -v Tingting -r 250 \
    --file-format=WAVE --data-format=LEI16@22050 \
    -o sounds/done.wav "已完成"
```

#### 查看可用语音

```bash
# 列出所有已安装语音
say -v '?'

# 只看中文语音
say -v '?' | grep -i zh
```

#### 调参示例

```bash
# 慢速（适合做提示音，听得更清楚）
say -v Tingting -r 150 --file-format=WAVE --data-format=LEI16@22050 \
    -o sounds/notify.wav "请注意"

# 快速
say -v Tingting -r 350 --file-format=WAVE --data-format=LEI16@22050 \
    -o sounds/done.wav "搞定了"

```

> **提示：** 如果系统没有安装某个语音，可以在"系统设置 → 辅助功能 → 语音内容 → 管理语音"中下载。

### 使用其他音频文件

直接将音频文件放到 `sounds/` 目录，保持文件名 `notify.wav` 和 `done.wav` 不变即可。支持的格式取决于平台音频引擎（macOS 支持 `.aiff`、`.wav`、`.mp3`、`.m4a` 等）。

## 禁用

删除 `~/.claude/settings.json` 中对应的 hooks 配置，或使用 Claude Code 内置的 `/hooks` 命令管理。
