---
title: "Spec 写好了，为什么不一口气生成代码？"
slug: "split-and-verify"
date: 2026-11-05T20:00:00+08:00
draft: true
summary: "规格批准了，AI 一次改几十个文件，测试全绿，却说不清哪条需求做到了、哪些测试是后补的。我把开发任务拆成能单独验收的 ticket，带上需求编号和验收项，交给新的 agent 先写测试再写代码。视频对照三套做法，也看一次没有遵守 TDD 的真实记录：先查顺序，再改坏代码验测试，最后全量跑测试、留下证据。"
tags: ["AI编程", "TDD", "规格驱动开发", "SDFlow", "Superpowers", "Matt Pocock", "Claude Code"]
categories: ["AI 开发工作流"]
series: ["sdflow"]
series_order: 4
hero_image: "cover.jpg"
github_url: "https://github.com/laodao-ai/demo-temp-monitor"
github_label: "示例项目 demo-temp-monitor"
---

<!-- 由 /video-derive 生成；检查结果见 ../../review/derive-check.md -->

规格批准了，AI 一次改了几十个文件，测试全绿，最后说一句“做好了”。哪条需求做到了，哪些测试是代码写完才补的，却很难确认。

视频里我把“从规格到代码”拆成两部分：先把开发任务拆到能单独验收，再让新的 agent 按测试先行的顺序做完，每一步留审查和验证证据。

视频：[B站 · Spec 写好了，为什么不一口气生成代码？](TODO(video-url)) · [YouTube](TODO(video-url))

## 视频里聊了什么

### 1、怎么拆开发任务（01:19）

- 规格里的任务清单和开始实现前的 ticket，不是一一对应的。前者给设计门检查需求有没有漏，后者是一块能交给新的 agent 从头做到尾的行为。
- 我按做完能单独验收来切：一个 ticket 穿过相关的层，能演示或验证结果，不按数据库、接口、页面各切一块。每张带上需求编号、依赖和验收项，设计里的硬约束原样传下去。
- 拆完也会出错。我有一次把断言放进了第二个 ticket，用到的变量条件却要到第四个、第六个才有，检查发现后才重新分配；视频对照 Superpowers、Matt Pocock 和 SDFlow 的切法与检查方式。

### 2、怎么生成代码（07:52）

- 每个 ticket 交给一个新的 agent，从验收项写测试，先跑失败，再写刚好让测试通过的实现。能同时开工的任务各在独立目录里做，改动互不干扰。
- 规则写了 TDD，AI 仍可能先写实现、后补测试。示例项目有两个 ticket 跑偏，审查从报告和提交记录里发现，再故意改坏被测代码，找出没有被测试覆盖的地方，补测后才通过复审。
- 实现过程中只跑相关测试，收尾再把各层测试全量跑一遍。每层留下命令、退出码、用例数和提交号；所有层都用同一次提交的代码，避免旧代码上的单元测试和新代码上的集成测试拼成“全部通过”。
- 测不了的就写明未覆盖和原因，或者停下来交给人。自动化没有覆盖真机操作，就把这部分留下来，不把代码能跑当成全部验收过。

## 我的做法

1. ticket 从规格来，按能单独验收来拆，拆完再查一遍。
2. 先写测试再写代码，实现的时候只测相关的。
3. 最后全量跑测试，每一层留下证据，才算做完。

## 链接

- 示例项目：https://github.com/laodao-ai/demo-temp-monitor
- SDFlow：https://github.com/laodao-ai/sdflow-skills
- Superpowers：https://github.com/obra/superpowers
- Matt Pocock skills：https://github.com/mattpocock/skills
