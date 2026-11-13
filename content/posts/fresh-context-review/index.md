---
title: "测试全过了，为什么还要代码评审？"
slug: "fresh-context-review"
date: 2026-11-13
draft: false
summary: "每个开发任务都审过，测试也全绿，合起来运行仍可能漏掉调用路径。我会再换一批新的 agent，从不同角度检查全部改动，逐条核实发现，再修复、复审或留下待办。视频用锁被入口绕过、密钥转义后脱敏失效的真实记录，说明单个任务审查与整体评审的区别，也对照 Claude Code 团队的做法，交代测试和自动修复的边界。"
tags: ["AI编程", "代码评审", "Code Review", "SDFlow", "Claude Code", "Codex", "AI开发工作流", "测试"]
categories: ["AI 开发工作流"]
series: ["sdflow"]
series_order: 5
hero_image: "cover.jpg"
github_url: "https://github.com/laodao-ai/demo-temp-monitor"
github_label: "示例项目 demo-temp-monitor"
---

每个开发任务都审过，测试也全绿，合起来运行还是出了问题。我遇到过一把锁：锁本身没写错，却只接进了“打开”，“新建”和“删除”都绕过去了。

视频里我聊聊为什么还要整体评审：换几个新的 agent，从不同角度，检查全部改动和受影响的调用路径，再把发现逐条核实、处理。

视频：[B站 · 测试全过了，为什么还要代码评审？](https://www.bilibili.com/video/BV1VWW262ELt/) · [YouTube](https://youtu.be/WmwSxW9bdnI)

## 视频里聊了什么

### 1、审什么（01:11）

- 一个 ticket 做完时，对照规格、项目规范和清单查这块改动；全部 ticket 完成后，还要把整体调用关系连起来查，两遍范围不同。
- 我把整体评审分成五路：对照规格、领域视角、对抗视角、换模型和历史视角。每一路回答不同的问题，历史视角只在文件改名或旧文件大幅修改时派出。
- 领域清单按技术栈选择，先看通用问题，再加后端、Go等检查项。开头的锁就是逐任务审查漏掉了入口，整体评审才把遗漏查出来。

### 2、怎么审（04:37）

- 明确的规则交给工具查，代码交给新的 agent 分角度读，能跑的再跑出来验证。审查 agent 不带开发对话，各看各的；发现汇总后先核对引用，再判断问题成不成立。
- 示例项目里，密钥带引号，先转义再按原文脱敏，字符串变了就匹配不到。修复后先脱敏，再交给日志处理器转义；补同一个测试，在旧代码上失败，在修复后的代码上通过。
- 测试本身也要审。工具扫描、读代码、运行验证各有用处；视频也对照 Claude Code 团队怎样核验发现、决定审查深度，不把多派几个 agent 当成结果保证。

### 3、审出问题以后怎么改（09:01）

- 影响目标的问题马上修；不重要的、无关的旧问题单独记录。发现被裁掉也要写理由，避免一条问题在汇总时消失。
- 示例项目自动修了密钥脱敏和响应处理两项，补了测试；真机冒烟还没做，就记进问题池交给人，不把自动流程结束说成全部验证完成。
- 修完只复审改过的部分，最多两轮。你定目标，把踩过的坑写进清单；看报告时重点看发现依据、修复怎样验证，以及还剩什么没完成。

## 我的做法

1. 每个任务单独审，做完再换新的 agent，整体查改动和调用路径。
2. 每条发现先核实，能跑的跑出来验证，测试本身也要审。
3. 该修的修，修完再审；留下的问题写清原因、验证缺口和后续动作。

## 链接

- 示例项目：https://github.com/laodao-ai/demo-temp-monitor
- SDFlow：https://github.com/laodao-ai/sdflow-skills
- 本次代码评审报告：https://github.com/laodao-ai/demo-temp-monitor/blob/alarm-notify/review-done/openspec/changes/alarm-notify/code-review-report.md
- Google · What to look for in a code review：https://google.github.io/eng-practices/review/reviewer/looking-for.html
- Anthropic · How the Claude Code team does code review：https://claude.dev/blog/solving-code-review-at-anthropic/
