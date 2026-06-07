---
name: weibo-skill
description: 微博内容搜索、热搜查看、用户动态及评论读取。使用 m.weibo.cn 移动端接口，无需账号和 API Key。触发场景：(1) 用户要求搜索微博内容或话题，(2) 查看实时微博热搜榜，(3) 获取指定用户的微博动态，(4) 查看某条微博的评论，(5) 用户粘贴了 weibo.com 或 m.weibo.cn 的链接。
version: 1.0.0
---

# 微博技能

直接调用 m.weibo.cn 移动端接口，实现微博内容搜索、热搜查看、用户动态及评论读取。无需账号，无需 API Key。

## 通用规则

### User-Agent

所有请求必须使用移动端 User-Agent：

```
Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Mobile/15E148 Safari/604.1
```

### Cookie 初始化

微博移动端接口需要访客 Cookie（SUB 和 SUBP）。通过 `visitor.passport.weibo.cn` 两步获取：

```bash
# Step 1: 获取 tid
TID=$(curl -s "https://visitor.passport.weibo.cn/visitor/genvisitor" \
  -d "cb=gen_callback&fp=%7B%22os%22%3A%221%22%7D" \
  -H "User-Agent: Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X)" \
  2>/dev/null | grep -oP '"tid":"[^"]*"' | cut -d'"' -f4)

# Step 2: 用 tid 换取 SUB/SUBP
SUB_RESP=$(curl -s "https://visitor.passport.weibo.cn/visitor/visitor?a=incarnate&t=${TID}&w=2&c=095&gc=&cb=cross_domain&from=sinawap&_rand=0.123" \
  -H "User-Agent: Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X)" \
  2>/dev/null)
SUB=$(echo "$SUB_RESP" | grep -oP '"sub":"[^"]*"' | cut -d'"' -f4)
SUBP=$(echo "$SUB_RESP" | grep -oP '"subp":"[^"]*"' | cut -d'"' -f4)

# Step 3: 后续请求带上 Cookie
curl -s "https://m.weibo.cn/api/..." \
  -H "User-Agent: Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Mobile/15E148 Safari/604.1" \
  -H "Cookie: SUB=$SUB; SUBP=$SUBP; WEIBOCN_FROM=1110003030"
```

如果请求被重定向到登录页（302 或返回 HTML 而非 JSON），说明访客 Cookie 已失效，需要重新获取。

### Cookie 缓存

Cookie 获取后在同一会话中复用，不必每次请求都重新获取。建议：
1. 首次调用时获取 Cookie
2. 如果后续请求失败（返回非 JSON），重新获取 Cookie 后重试

### 响应格式

- 所有 API 返回 JSON
- `ok` 字段为 1 表示成功，0 表示失败
- 实际数据在 `data` 字段中
- 微博正文文本可能包含 HTML 标签（如 `<br />`），展示时需转为纯文本

---

## API 接口

### 热搜榜

**接口：**

```
GET https://m.weibo.cn/api/container/getIndex?containerid=106003type%3D25%26t%3D3%26disable_hot%3D1%26filter_type%3Drealtimehot
```

**请求示例：**

```bash
curl -s "https://m.weibo.cn/api/container/getIndex?containerid=106003type%3D25%26t%3D3%26disable_hot%3D1%26filter_type%3Drealtimehot" \
  -H "User-Agent: Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Mobile/15E148 Safari/604.1" \
  -H "Cookie: SUB=$SUB; SUBP=$SUBP; WEIBOCN_FROM=1110003030"
```

**回包结构：**

```json
{
  "ok": 1,
  "data": {
    "cards": [
      {
        "card_group": [
          {
            "desc": "热搜词条名称",
            "desc_extr": "热度数值",
            "icon": "图标URL",
            "scheme": "点击跳转链接"
          }
        ]
      }
    ]
  }
}
```

**展示规则：**
- 提取 `cards[].card_group[]` 中的条目
- `desc` 为热搜词条名称
- `desc_extr` 为热度数值（可选展示）
- 带"热"、"沸"等图标标签的可特别标注
- 用编号列表展示，默认显示前 30 条

---

### 内容搜索

**接口：**

```
GET https://m.weibo.cn/api/container/getIndex?containerid=100103type%3D1%26q%3D{keyword}
```

| 搜索类型 | containerid 格式 |
|---------|-----------------|
| 内容搜索 | `100103type=1&q={keyword}` |
| 用户搜索 | `100103type=3&q={keyword}` |
| 话题搜索 | `100103type=38&q={keyword}` |

**请求示例：**

```bash
curl -s "https://m.weibo.cn/api/container/getIndex?containerid=100103type%3D1%26q%3D{keyword}" \
  -H "User-Agent: Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Mobile/15E148 Safari/604.1" \
  -H "Cookie: SUB=$SUB; SUBP=$SUBP; WEIBOCN_FROM=1110003030"
```

**翻页：**

在 containerid 后追加 `&page={page}` 参数：

```
containerid=100103type%3D1%26q%3D{keyword}&page=2
```

**回包结构：**

```json
{
  "ok": 1,
  "data": {
    "cards": [
      {
        "card_type": 9,
        "mblog": {
          "id": "微博ID",
          "text": "微博正文（可能含HTML）",
          "created_at": "发布时间",
          "reposts_count": 0,
          "comments_count": 0,
          "attitudes_count": 0,
          "user": {
            "id": 123456,
            "screen_name": "用户昵称",
            "verified": true,
            "verified_reason": "认证信息",
            "profile_image_url": "头像URL"
          },
          "pics": [{"url": "图片URL"}],
          "page_info": {
            "page_title": "关联话题/视频标题"
          }
        }
      }
    ]
  }
}
```

**展示规则：**
- 只展示 `card_type=9` 的卡片（正文内容）
- `text` 字段包含 HTML，需转为纯文本展示
- 展示：用户昵称、正文摘要、发布时间、转发/评论/点赞数
- 如有图片，标注图片数量
- `created_at` 格式可能是 "刚刚"、"X分钟前"、"今天 HH:MM"、"MM-DD"、"YYYY-MM-DD" 等相对/绝对时间
- 用编号列表展示，默认显示前 10 条

---

### 用户搜索

**接口：**

```
GET https://m.weibo.cn/api/container/getIndex?containerid=100103type%3D3%26q%3D{keyword}
```

**回包结构：**

```json
{
  "ok": 1,
  "data": {
    "cards": [
      {
        "card_type": 11,
        "card_group": [
          {
            "user": {
              "id": 123456,
              "screen_name": "用户昵称",
              "description": "用户简介",
              "followers_count": 0,
              "follow_count": 0,
              "verified": true,
              "verified_reason": "认证信息",
              "profile_image_url": "头像URL",
              "gender": "m/f"
            }
          }
        ]
      }
    ]
  }
}
```

**展示规则：**
- 提取 `cards[].card_group[].user`
- 展示：用户昵称、认证信息、简介、粉丝数
- 用编号列表展示

---

### 用户动态

**步骤 1：获取用户的 containerid**

```
GET https://m.weibo.cn/api/container/getIndex?type=uid&value={uid}
```

```bash
curl -s "https://m.weibo.cn/api/container/getIndex?type=uid&value={uid}" \
  -H "User-Agent: Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Mobile/15E148 Safari/604.1" \
  -H "Cookie: SUB=$SUB; SUBP=$SUBP; WEIBOCN_FROM=1110003030"
```

**回包结构：**

```json
{
  "ok": 1,
  "data": {
    "userInfo": {
      "id": 123456,
      "screen_name": "用户昵称",
      "description": "简介",
      "followers_count": 0,
      "follow_count": 0,
      "statuses_count": 0,
      "verified": true,
      "verified_reason": "认证信息"
    },
    "tabsInfo": {
      "tabs": [
        {"tabKey": "weibo", "containerid": "107603123456"},
        {"tabKey": "album", "containerid": "..."}
      ]
    }
  }
}
```

从 `tabsInfo.tabs` 中找到 `tabKey` 为 `weibo` 的项，取其 `containerid`。

**步骤 2：获取用户微博列表**

```
GET https://m.weibo.cn/api/container/getIndex?type=uid&value={uid}&containerid={cid}
```

**翻页：**

使用 `since_id` 参数：

```
containerid={cid}&since_id={since_id}
```

`since_id` 从上一次响应的 `data.cardlistInfo.since_id` 获取。

**回包结构：**

```json
{
  "ok": 1,
  "data": {
    "cardlistInfo": {
      "since_id": 1234567890
    },
    "cards": [
      {
        "card_type": 9,
        "mblog": {
          "id": "微博ID",
          "text": "正文HTML",
          "created_at": "时间",
          "reposts_count": 0,
          "comments_count": 0,
          "attitudes_count": 0,
          "pics": [{"url": "图片URL"}],
          "retweeted_status": { ... }
        }
      }
    ]
  }
}
```

**展示规则：**
- 先展示用户基本信息（昵称、认证、简介、粉丝数、微博数）
- 微博列表只展示 `card_type=9` 的卡片
- 正文 HTML 转纯文本
- 如有转发微博（`retweeted_status`），标注原博主和原文
- 展示：正文摘要、时间、转发/评论/点赞数
- 用编号列表展示，默认显示前 10 条

---

### 微博评论

**接口：**

```
GET https://m.weibo.cn/api/comments/show?id={feed_id}&page={page}
```

**请求示例：**

```bash
curl -s "https://m.weibo.cn/api/comments/show?id={feed_id}&page=1" \
  -H "User-Agent: Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Mobile/15E148 Safari/604.1" \
  -H "Cookie: SUB=$SUB; SUBP=$SUBP; WEIBOCN_FROM=1110003030"
```

**回包结构：**

```json
{
  "ok": 1,
  "data": [
    {
      "id": 123456,
      "text": "评论内容（可能含HTML）",
      "created_at": "时间",
      "like_count": 0,
      "user": {
        "id": 123456,
        "screen_name": "用户昵称"
      },
      "comments": []
    }
  ]
}
```

**展示规则：**
- `data` 是评论数组
- 展示：用户昵称、评论内容、时间、点赞数
- 如有回复（`comments` 数组），缩进展示
- 用编号列表展示，默认显示前 20 条

---

### URL 解析

当用户粘贴微博链接时，从中提取关键信息：

| URL 格式 | 提取内容 |
|---------|---------|
| `m.weibo.cn/detail/{id}` | 微博 ID |
| `m.weibo.cn/status/{id}` | 微博 ID |
| `weibo.com/{uid}/{mid}` | 用户 ID 和微博 ID |
| `m.weibo.cn/u/{uid}` | 用户 ID |
| `weibo.com/u/{uid}` | 用户 ID |

提取到微博 ID 后，可调用评论接口查看评论。提取到用户 ID 后，可调用用户动态接口查看微博。

---

## 工作流

1. **用户问热搜**：调热搜榜接口，展示前 30 条热搜词条及热度
2. **用户搜索内容**：调内容搜索接口，展示搜索结果；如用户指定搜索用户或话题，使用对应 containerid
3. **用户查看某人动态**：先用用户搜索找到 uid，再调用户动态接口
4. **用户查看微博评论**：从链接或搜索结果中获取微博 ID，调评论接口
5. **用户粘贴微博链接**：解析 URL，根据包含的信息执行后续操作
6. **翻页**：搜索用 `page` 参数，用户动态用 `since_id` 参数

## 输出格式

- **热搜**：编号列表，显示词条名称和热度，标注"热"、"沸"等标签
- **微博内容**：编号列表，每条显示用户昵称、正文摘要（前 100 字）、时间、互动数据
- **用户信息**：昵称、认证、简介、粉丝数
- **评论**：编号列表，显示用户昵称、评论内容、点赞数

## 注意事项

- 所有文本字段可能包含 HTML 标签，展示前需转为纯文本（去掉 `<br />`、`<a>` 等标签）
- 如果 API 返回非 JSON（如 HTML），说明需要重新获取 Cookie
- 搜索结果可能包含广告卡片（非 `card_type=9`），应跳过
- 微博图片 URL 通常是缩略图，如需原图可去掉 URL 中的 `thumbnail` 或 `small` 替换为 `large`
