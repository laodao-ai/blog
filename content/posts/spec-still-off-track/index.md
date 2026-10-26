---
title: "Spec 怎么写，AI 才不会跑偏？"
slug: "spec-still-off-track"
date: 2026-10-23
draft: false
summary: "规格本身也是 AI 写的：它写规格时只问它想到的，同一个需求每次方案都不一样，问没问到、写得对不对一眼看不出来。想拿到靠得住的规格，要管住怎么问、怎么写、写成什么样三件事：AI 找问题、给推荐，决策由你拍板；先落纪要再成文；按通用规则和领域清单检查。"
tags: ["规格驱动开发", "SDFlow", "OpenSpec", "grill-me", "Claude Code", "AI 开发工作流"]
categories: ["AI 开发工作流"]
series: ["sdflow"]
series_order: 2
hero_image: "cover.jpg"
github_url: "https://github.com/laodao-ai/demo-temp-monitor"
github_label: "示例项目 demo-temp-monitor"
---

<!-- 由 /video-derive 生成；检查结果见 ../../review/derive-check.md -->

用了规格，AI 还是跑偏？

规格本身也是 AI 写的。它写规格时一样只问它想到的，同一个需求，每次出来的方案都不一样。

规格看着挺完整，问没问到、写得对不对，一眼看不出来。

视频里聊聊我的思路和做法：想拿到靠得住的规格，得一起管住怎么问、怎么写、写成什么样。

视频：[B站 · Spec 怎么写，AI 才不会跑偏？](https://www.bilibili.com/video/BV1JQnN6vEJ9/) · [YouTube](https://youtu.be/O09-pLXSD5c)

## 视频里聊了什么

### 1、旧流程与新流程（01:42）

- 有 B站网友问，为什么不用 grill-me 代替 OpenSpec。我的看法是不用二选一：OpenSpec 管规格怎么写、怎么归档，grill-me 管怎么问。
- 我一开始两个一起用，拷问完再回头改文档。
- 现在是我自己定制的 SDFlow：聊完先落一份临时的决策纪要，定一个填一个，最后一次写成规格。

### 2、怎么问（03:40）

- 探索只定两件事，问题的边界和方案的方向。聊到哪儿算够由你判断，AI 不能自己开工，你说开搞它才往下走。
- 拷问先分清问谁：代码里查得到的事实，AI 自己查；有几个方案的，带着推荐来；只有你自己知道的，才来问你。
- 例子：导入数据时有几条格式不对，AI 推荐整批拒绝，我选了格式对的先导入。

### 3、怎么写（08:01）

- 原来是拷问完再回头改四个文档，我跑示例项目那一轮，改完有两处说法对不上。
- 现在拷问一开始就建好分支和改动目录，放一份纪要草稿，每拍板一条当场写进去。
- 收住以后从纪要把四个文档一个一个写出来，写完再逐条对一遍纪要，这次没发现矛盾。

### 4、写成什么样（09:59）

- 通用规则每份规格都要过，比如写成功指标、事实先查再写。领域规则看这次需求涉及什么。
- 清单是分层的，写 Go 代码就是通用、后端、Go 三层一起过。哪块常踩坑，就往哪块加。
- 图也按需求画。示例项目这次画了八张，其中一张时序图是因为冷却表有并发读写。
- 这些要求写进 OpenSpec 的配置，每次生成都带上，不靠 AI 自己记。

### 5、解决了什么（13:25）

- 只问它想到的，就先分清问谁，一条条拷问，有证据了才停。
- 方案每次不一样，就把每一问的决定收回你手里，不让 AI 自己选。
- 心里没有预期，每一问都按推荐答，最后的方案就是 AI 的方案。
- 目标和方向清楚的小改动，探索可以缩短甚至跳过。范围和方案澄清、事实核对、决定确认不能省。

## 我的做法

1. 让 AI 把问题找出来，把推荐和后果摆清楚，决策还是你来拍板。
2. 决定先记进纪要，再从纪要一次写成规格，不回头改。
3. 每份规格先过通用规则，再按这次需求过领域清单、画图表。

## 链接

- 示例项目：[laodao-ai/demo-temp-monitor](https://github.com/laodao-ai/demo-temp-monitor)
- SDFlow：[laodao-ai/sdflow-skills](https://github.com/laodao-ai/sdflow-skills)
- OpenSpec：[Fission-AI/OpenSpec](https://github.com/Fission-AI/OpenSpec)
- grill-me：[mattpocock/skills](https://github.com/mattpocock/skills)
