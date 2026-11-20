---
title: "代码评审过了，怎么验收和归档？"
slug: "proof-before-merge"
date: 2026-11-20
draft: false
summary: "代码评审过了，怎么确认规格里的要求都实现了？我以温度监控服务的告警功能为例，对照规格、任务清单、代码和测试逐项验收，讲清修复后怎样核对回归结果，怎样记录还没做的真机测试。验收后，把当前行为同步进主规格，把验收依据和后续事项留在归档里，方便下次改功能时查到。"
tags: ["AI编程", "任务验收", "知识归档", "SDFlow", "OpenSpec", "软件测试"]
categories: ["AI 开发工作流"]
series: ["sdflow"]
series_order: 6
hero_image: "cover.jpg"
github_url: "https://github.com/laodao-ai/demo-temp-monitor"
github_label: "示例项目 demo-temp-monitor"
---

代码评审过了，规格里的要求都实现了吗？下次再改这个功能，又该到哪里查现在的规则和上次的验收依据？

视频里我用温度监控服务的告警功能演示收尾。先对照规格、任务清单和代码逐项验收，再把当前的要求、做过的检查和留给后续的事项记下来。

视频：[B站 · 代码评审过了，怎么验收和归档？](https://www.bilibili.com/video/BV15csh6gEbd/) · [YouTube](https://youtu.be/-elIrLETjTM)

## 视频里聊了什么

### 1、SDFlow 收尾流程（00:48）

- OpenSpec 的 verify 对照规格、设计和任务检查实现，archive 同步项目主规格并归档本次变更。
- 我在代码评审结束后开了一个新会话，运行 `/sdflow-done`。视频里展示了任务验收、决策记录同步、交接报告和规格归档的结果。

### 2、任务验收（03:06）

- 同一台设备同时上报多条超温读数时，系统只能推送一次。验收报告把这条要求对应到处理告警冷却的代码和并发测试，以后可以顺着报告回查。
- 评审修复之后，验收会核对回归测试的命令、退出码、用例数和提交号。报告分别记录了修复前后的结果，读报告时可以确认每组测试跑的是哪版代码。
- 这次验收结论是 PASS。真实钉钉群里的加签和关键词两种设置还需要人工测试，交接报告记录了验证步骤，并关联到问题池 T48。

### 3、知识归档（08:26）

- 告警冷却原来写在本次变更的规格里，归档后同步进了项目主规格。以后改推送时，可以先查现行的并发限制、冷却时间和失败处理规则。
- 带日期的归档目录保留本次变更记录。同步后还会检查规格条目有无缺失或重复，条目的描述则要对照代码核实。

### 4、验收与交接报告（11:56）

- 验收报告记每项要求的结论、对应实现和测试证据。交接报告记已经完成的工作、后续事项和执行步骤。
- 长期维护的决策也要跟着实现更新。这次把日志脱敏的处理器签名和密钥替换规则同步到了架构决策记录。

## 我的做法

1. 按规格和任务清单逐条核对实现，每项结论写明对应的代码或测试。
2. 评审修复后重跑受影响的测试，把结果、提交号和待补验证写进验收报告。
3. 把当前行为同步到主规格，随变更归档验收和交接报告，后面再改时先查这些记录。

## 链接

- [示例项目](https://github.com/laodao-ai/demo-temp-monitor)
- [本次验收报告](https://github.com/laodao-ai/demo-temp-monitor/blob/alarm-notify/done/openspec/changes/archive/2026-10-31-alarm-notify/verify-report.md)
- [本次交接报告](https://github.com/laodao-ai/demo-temp-monitor/blob/alarm-notify/done/openspec/changes/archive/2026-10-31-alarm-notify/hand-off.md)
- [SDFlow](https://github.com/laodao-ai/sdflow-skills)
- [OpenSpec](https://github.com/Fission-AI/OpenSpec)
