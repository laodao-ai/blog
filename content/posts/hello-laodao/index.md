---
title: "Hello, 老刀AI工坊"
slug: "hello-laodao"
date: 2026-04-29
draft: false
summary: "这是老刀AI工坊的第一篇博客文章，本文是阶段 1 的烟雾测试文，用来验证 Hugo + Blowfish 主题对代码块、Mermaid 流程图、表格和 TOC 的渲染能力，同时介绍博客关注的 AI 开发工作流、系统架构、开发测试环境与数据库环境。"
tags: ["系列开篇", "测试文"]
categories: ["公告"]
---

老刀AI工坊的第一篇博客就这样上线了。这是一篇**阶段 1 的烟雾测试文**——它的主要目的不是讲清某个技术问题，而是把"博客基础设施"这条流水线跑通：archetype 写作模板、check-summary 摘要质量守门、JSON-LD 结构化数据注入、Hugo + Blowfish 渲染、scp 推送到 VPS——任何一环出问题都该在这一篇里暴露。本文保留为建站记录，名称与频道介绍已按当前定位更新。

## 这个博客在讲什么

**把 AI 做进生产**：面向用 AI 做产品的开发者，讲清从代码能跑到系统可靠运行之间的工程问题。

内容主要覆盖以下方向，用实际运行结果解释做法、取舍与边界：

| 方向 | 关注的问题 |
|------|------------|
| AI 开发工作流 | 从需求到实现、验证与交付，怎样协作 |
| 系统架构 | 系统怎样分工，如何选择与取舍 |
| 开发测试环境 | 怎样搭建可运行、可验证的开发与测试条件 |
| 数据库环境 | 怎样准备、管理与验证产品所需的数据环境 |

## 从一个 hello 函数说起

先用一段 Go 代码验证代码块的呈现：

```go
package main

import "fmt"

// Greet returns a greeting message tailored by language code.
// 仅支持 zh / en，其他默认 en。
func Greet(name, lang string) string {
    switch lang {
    case "zh":
        return fmt.Sprintf("你好，%s。这里是老刀AI工坊。", name)
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
你好，读者。这里是老刀AI工坊。
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

关于 AI 开发工作流，可以继续读[从失控到可控的五阶段 SDD 工作流](/posts/ep01-five-stage-workflow/)。更多工程实践可以通过 [RSS](/index.xml) 订阅，也可以在 [GitHub](https://github.com/laodao-ai) 找到相关仓库。

也欢迎通过 GitHub Issues 提问、反驳、或分享你自己跑这套工作流的踩坑——比起写文章，**听到你怎么用** 更让我有动力继续写下去。
