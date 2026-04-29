---
title: "Hello, 老刀AI码场"
slug: "hello-laodao"
date: 2026-04-29
draft: false
summary: "这是老刀AI码场的第一篇博客文章，本文是阶段 1 的烟雾测试文，用来验证 Hugo + Blowfish 主题对代码块、Mermaid 流程图、表格和 TOC 的渲染能力，同时为系列后续内容做开篇预告。"
tags: ["系列开篇", "测试文"]
categories: ["公告"]
---

老刀AI码场的第一篇博客就这样上线了。这是一篇**阶段 1 的烟雾测试文**——它的主要目的不是讲清某个技术问题，而是把"博客基础设施"这条流水线跑通：archetype 写作模板、check-summary 摘要质量守门、JSON-LD 结构化数据注入、Hugo + Blowfish 渲染、scp 推送到 VPS——任何一环出问题都该在这一篇里暴露。等阶段 2 系列开篇文章上线后，本文将转为 archived 状态。

## 这个博客在讲什么

围绕 **AI 驱动后端开发的融合工作流** 做的系列内容。核心工具栈是 Claude Code + OpenSpec + Superpowers + GStack，场景以 Go 后端为主，辅以嵌入式变体。

后续将按以下三条主线推进：

| 主线 | 视角 | 起点文章 |
|------|------|---------|
| 层级视角 | 写代码 → 规格驱动 → 路线图 → 高阶评审 | ep01 系列开篇（W1） |
| 阶段视角 | 需求细化 / 代码生成 / 代码审查与归档 | ep02 S/M/L 操作手册（W5） |
| 工具对比 | 同类型 skill 怎么选、什么时候用哪个 | special-1 / 2 / 3（W2-W4） |

## 从一个 hello 函数说起

每条系列正式开始前，让我们先看一段 Go 代码——这也是老刀的语言主场：

```go
package main

import "fmt"

// Greet returns a greeting message tailored by language code.
// 仅支持 zh / en，其他默认 en。
func Greet(name, lang string) string {
    switch lang {
    case "zh":
        return fmt.Sprintf("你好，%s。这里是老刀AI码场。", name)
    default:
        return fmt.Sprintf("Hello %s, welcome to laodao-ai.", name)
    }
}

func main() {
    fmt.Println(Greet("读者", "zh"))
}
```

输出：

```
你好，读者。这里是老刀AI码场。
```

## 内容流水线

下图是这个博客背后的生产链路，每一步都有对应的工具支撑：

{{< mermaid >}}
graph LR
    A[读者带问题来] --> B[博客静态页]
    B --> C[AI 爬虫抓取]
    C --> D[结构化数据 JSON-LD]
    D --> E[反向引用 / 推荐]
    E --> A
{{< /mermaid >}}

四个节点分别对应博客需要解决的四件事：**让人能读到**（B）、**让 AI 能消化**（C）、**让结构能被识别**（D）、**让推荐流量回流**（E）。GEO（Generative Engine Optimization）这个词的核心，就是把这四件事一次做对——其中 robots.txt 允许爬虫、Article JSON-LD 标识文章、llms.txt 端点提供站点大纲，是阶段 1 已经落地的三件基础设施。

## front matter 里有什么

这个博客的每篇文章都用约束性 archetype 生成，强制约束 6 个必含字段：

```yaml
---
title: "文章标题"
date: 2026-04-29
draft: false
summary: "一段 80-200 字的摘要，会被用作 og:description 和 LLM 引用的主信息源"
tags: ["标签1", "标签2"]
categories: ["分类"]
---
```

`summary` 字段会被 `scripts/check-summary.sh` 强制校验——长度必须 ∈ [80, 200] 字符、不含字面量 TODO；正文首段也不能含 TODO。这是写作规范层的"质量守门"。

## 接下来

下一篇是 **ep01 系列开篇**：《AI 驱动后端开发的四层级工作流：从写对代码到治理演进》——会把"四层级"这个心智模型讲清楚，并带 ai-shorurl 真实工程案例。如果你对这套工作流感兴趣，可以现在就把 RSS 订阅好（[/index.xml](/index.xml)）或者 follow [github.com/laodao-ai](https://github.com/laodao-ai) 获取系列更新。

也欢迎通过 GitHub Issues 提问、反驳、或分享你自己跑这套工作流的踩坑——比起写文章，**听到你怎么用** 更让我有动力继续写下去。
