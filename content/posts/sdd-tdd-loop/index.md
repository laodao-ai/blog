---
title: "AI 写代码总跑偏？用 OpenSpec 和 Superpowers 搭一个最小的开发循环"
slug: "sdd-tdd-loop"
date: 2026-10-09
draft: false
summary: "用 AI 写代码常碰到两件事：做出来的不是你要的，说做完了其实不对。前一件把要猜的地方写成带具体场景的规格，后一件先写测试、看它失败再写实现。OpenSpec 管做什么，Superpowers 管怎么做对，用一个超温告警的小需求在 Claude Code 里走一遍。"
tags: ["OpenSpec", "Superpowers", "Claude Code", "规格驱动开发", "测试驱动开发", "SDD", "TDD", "AI 开发工作流"]
categories: ["AI 开发工作流"]
series: ["sdflow"]
series_order: 1
hero_image: "cover.jpg"
github_url: "https://github.com/laodao-ai/sdd-tdd-loop-demo"
github_label: "演示仓 sdd-tdd-loop-demo"
---

<!-- 由 /video-derive 生成；检查结果见 ../../review/derive-check.md -->

用 AI 写代码，碰到过两种情况：做出来的不是你要的；它说做完了，你一跑还是不对。

前一种，需求在你脑子里，AI 只拿到一句话，剩下的只能猜。

后一种，「做完了」是它自己判断的，测试也是它自己写的。

视频里我用 OpenSpec 和 Superpowers 搭了个最小的开发循环，各管一件事。

视频：[B站 · AI 写代码总跑偏？用 OpenSpec 和 Superpowers 搭一个最小的开发循环](https://www.bilibili.com/video/BV1hPH96dE3V/) · [YouTube](https://youtu.be/AoCEBAJ53Uo)

## 视频里聊了什么

### 1、规格驱动开发（01:45）

- 告警发到哪、阈值怎么定、正好 80 度报不报，我没说，AI 只能猜。
- 我的做法是写代码前先写规格：为什么做、做什么、做到什么样才算对。
- 「做到什么样」用具体场景写，比如输入 81.2 报警，输入 80 不报警。

### 2、OpenSpec（04:10）

- `/opsx:propose` 生成提案、规格、设计、任务四个文档，然后停下等你看，不写代码。
- 演示先用 `/opsx:explore` 聊，AI 问了：告警发到哪、阈值写死还是参数、80 度算不算。
- 我的回答进了规格，成了四个场景：81.2 报，80.1 报，80.0 不报，23.5 不报。

### 3、测试驱动开发（08:18）

- 先写代码再补测试，代码错了测试跟着错，全过说明不了什么。
- 所以倒过来：先写测试，看它失败，再写刚好让它通过的代码。
- 测试先失败，才说明它真在测东西。做没做完看测试，不听 AI 怎么说。

### 4、Superpowers（09:53）

- Superpowers 是一组 skill，到该用时自己触发。
- 它先写计划：把 OpenSpec 的任务清单拆细，每个任务先写测试、看失败，再写代码、看通过。
- 再按计划做：每个任务派一个子代理做、一个审，最后整体审一遍。

### 5、两个怎么接（14:35）

- 两边官方文档都没写怎么一起用，这是我自己的接法。
- 先用 OpenSpec 规划，再让 Superpowers 写计划、做实现，最后回 OpenSpec 核对、归档。
- 实现只交给一边，我选了 Superpowers。两份清单不自动同步，演示里核对就报出六项任务一项没勾。

### 6、解决了什么（16:45）

- 要猜的地方，比如 80 度算不算超温，写进规格、写成场景。
- 做没做完，看测试，先失败再通过。
- 这只是最小的循环，放进项目还要补，我后来整理成了流程 SDFlow。

## 我的做法

1. 写代码前，先把 AI 要猜的地方写成带具体场景的规格。
2. 做没做完看测试，先让测试失败，再让它通过。
3. 做什么交给 OpenSpec，怎么做对交给 Superpowers。

## 链接

- 演示仓：[laodao-ai/sdd-tdd-loop-demo](https://github.com/laodao-ai/sdd-tdd-loop-demo)
- OpenSpec：[Fission-AI/OpenSpec](https://github.com/Fission-AI/OpenSpec)
- Superpowers：[obra/superpowers](https://github.com/obra/superpowers)
