# Weibo Skill for Claude Code

一个为 [Claude Code](https://docs.anthropic.com/en/docs/claude-code) 设计的微博技能，通过调用 `m.weibo.cn` 移动端接口实现微博内容搜索、热搜查看、用户动态及评论读取。

## 特性

- **无需账号**：自动获取访客 Cookie，无需登录
- **无需 API Key**：直接使用微博移动端公开接口
- **零依赖**：只需 `curl` 和 `python3`（macOS/Linux 自带）

## 支持的功能

| 功能 | 说明 | 示例 |
|------|------|------|
| 热搜榜 | 查看实时微博热搜 | "看看微博热搜" |
| 内容搜索 | 按关键词搜索微博 | "搜一下高考语文" |
| 用户搜索 | 搜索微博用户 | "搜一下罗永浩" |
| 用户动态 | 查看指定用户的微博 | "看看雷军最近发了什么" |
| 微博评论 | 查看评论列表 | "看看这条微博的评论" |
| URL 解析 | 自动识别微博链接 | 粘贴 weibo.com 链接 |

## 安装

### 方法一：直接复制

```bash
# 克隆仓库
git clone https://github.com/YOUR_USERNAME/weibo-skill.git

# 复制 Skill 文件到 Claude Code 技能目录
mkdir -p ~/.claude/skills/weibo-skill
cp weibo-skill/SKILL.md ~/.claude/skills/weibo-skill/

# 重启 Claude Code 即可生效
```

### 方法二：符号链接

```bash
# 克隆仓库后创建符号链接
git clone https://github.com/YOUR_USERNAME/weibo-skill.git
ln -s $(pwd)/weibo-skill ~/.claude/skills/weibo-skill
```

## 使用

安装后在 Claude Code 中直接用自然语言即可：

```
> 看看微博热搜

> 搜索 "置身钉内"

> 看看雷军最近的微博
```

## 技术原理

本 Skill 通过以下步骤实现免登录访问微博：

1. **获取访客凭证**：调用 `visitor.passport.weibo.cn` 接口获取 `tid`
2. **换取 Cookie**：用 `tid` 换取 `SUB` 和 `SUBP` 访客 Cookie
3. **请求数据**：使用 Cookie 访问 `m.weibo.cn` 移动端 API

详细接口文档见 [SKILL.md](./SKILL.md)。

## 文件说明

```
weibo-skill/
├── SKILL.md      # Claude Code 技能定义文件（核心）
└── README.md     # 本说明文档
```

## 注意事项

- 访客 Cookie 有有效期限制，过期后会自动重新获取
- 微博接口可能随时变更，如遇到问题请提 Issue
- 本 Skill 仅供学习研究，请遵守微博使用条款

## License

MIT
