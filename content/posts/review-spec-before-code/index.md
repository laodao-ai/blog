---
title: "AI 写的 Spec，能直接生成代码吗？"
slug: "review-spec-before-code"
date: 2026-10-30
draft: true
summary: "规格写完直接生成代码，规格错了开发也照做；错得一致，测试全绿也发现不了。写代码前先审一道：派独立的 agent 分角度审，先核引用再逐条裁决，人只答三问、拍要拍的板，批准后锁住规格。再算一笔账：多花的时间和 token 值不值，评审漏掉的怎么补。"
tags: ["规格评审", "规格驱动开发", "SDFlow", "gstack", "OpenSpec", "Claude Code", "AI 开发工作流"]
categories: ["AI 开发工作流"]
series: ["sdflow"]
series_order: 3
hero_image: "cover.jpg"
github_url: "https://github.com/laodao-ai/demo-temp-monitor"
github_label: "示例项目 demo-temp-monitor"
---

<!-- 由 /video-derive 生成；检查结果见 ../../review/derive-check.md -->

AI 把规格写好了，能直接拿去生成代码吗？

我之前的最小开发循环 demo 这么干过，规格里有一条测试写错了，开发也照做。

那次是规格前后对不上，子代理跑测试时才撞出来。要是从头到尾错得一致，测试全绿，谁也发现不了。

视频里聊聊写完规格、写代码之前的这一道评审：AI 先分角度审，人只拍要拍的板。

视频：[B站 · AI 写的 Spec，能直接生成代码吗？](https://www.bilibili.com/video/BV1k6nZ6XEvY/) · [YouTube](https://youtu.be/EsiFc6yBd4Q)

## 视频里聊了什么

### 1、AI 怎么审（01:51）

- 我不在写规格的会话里审，派独立的 agent 从几个角度同时审，再请另一个模型给第二意见。
- 对抗审先假设推送代码会崩，查出 goroutine 里的 panic 会拖垮整个服务，规格补上了 recover。
- 报上来的先合并重复、核引用，再逐条裁决。50 条合并成 28 条。

### 2、人怎么拍板（10:06）

- 评审中途不打断我，AI 能定的自己定，采纳的直接改规格。这次 18 条采纳，留给我拍板的只有 1 条。
- 报告有网页版，固定列三个问题，要拍板的写清选项、推荐和后果。
- 批准后规格就锁住，之后再改，开工时会被拦下来重审。

### 3、值不值得（13:37）

- 这一套跑下来要十七分钟，一千五百多万 token。
- 同一份规格我开三个全新会话各审一次：实质问题 7 条，三次都查到的只有 2 条。
- 请另一个模型，是因为它看到的不一样。放在写代码之前审，是因为问题越早发现越便宜。

### 4、局限与改进（17:34）

- 这次有个问题没人问过我：值班的人看到的时间，用 UTC 还是北京时间。规格直接写死了 UTC。
- 评审只对着写下来的东西查，大家都默认的事，没人会回头问。
- 办法是写成新规则加进领域清单，自己项目踩过的坑也可以一条条加。

### 5、一句话「魔法咒语」（18:36）

- 这句话是：按第一性原理，从这次需求的目标出发，重新调研，有没有更简洁、更合适、更便宜的方案？
- 给 Go 项目补测试时问了这句，AI 回头查代码，最后生产代码一处没改，规范也放宽了。
- 我试过把它写进 SDFlow，效果不如单独问，原因我没有深究。

### 6、总结（20:17）

- 规格先审一轮再说：AI 分几路审，我看报告、提意见、批准。
- 评审替代不了人，需求最后做成什么样，要自己定。

## 我的做法

1. 规格写完先审一轮再开工。让独立的 agent 分角度审，先核引用，再逐条裁决。
2. 过程不用盯，只看评审报告、提意见、批准。批准后规格就锁住。
3. 审不出来的，发现了就写成规则加进清单。对推荐有疑虑，就问一句有没有更简洁、更便宜的方案。

## 链接

- 示例项目：[laodao-ai/demo-temp-monitor](https://github.com/laodao-ai/demo-temp-monitor)
- SDFlow：[laodao-ai/sdflow-skills](https://github.com/laodao-ai/sdflow-skills)
- OpenSpec：[Fission-AI/OpenSpec](https://github.com/Fission-AI/OpenSpec)
- gstack（Garry Tan）：[garrytan/gstack](https://github.com/garrytan/gstack)
- Böckeler《Understanding Spec-Driven-Development》：[martinfowler.com](https://martinfowler.com/articles/exploring-gen-ai/sdd-3-tools.html)
- Thariq《The Unreasonable Effectiveness of HTML》：[Claude 博客](https://claude.com/blog/using-claude-code-the-unreasonable-effectiveness-of-html)
- Thinking Machines《Defeating Nondeterminism in LLM Inference》：[thinkingmachines.ai](https://thinkingmachines.ai/blog/defeating-nondeterminism-in-llm-inference/)
- Anthropic《Building effective agents》：[anthropic.com](https://www.anthropic.com/engineering/building-effective-agents)
- 需求评审基准（arXiv 2609.03230）：[arxiv.org](https://arxiv.org/abs/2609.03230)
- 另一个模型什么时候有用（arXiv 2610.01471）：[arxiv.org](https://arxiv.org/abs/2610.01471)
- Boehm & Basili《Software Defect Reduction Top 10 List》（2001）：[cs.umd.edu](https://www.cs.umd.edu/projects/SoftEng/ESEG/papers/82.78.pdf)
