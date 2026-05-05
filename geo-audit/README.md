# GEO Audit · CN 国际延迟监控

本目录承载 `roadmap blog-v2-rebuild` 阶段 4.G 的产物：每周采样 `laodao-ai.cn` 在国际访问视角下的首屏延迟，作为 Q6 架构决策（".com 走 CF 全球 CDN，.cn 走阿里云直连"）的权衡兜底数据源。

## 数据来源

- **GHA runner 视角**：GitHub Actions hosted runners 默认部署在美国/欧洲 → 天然代表"国际读者从 Google 搜到 .cn 链接"的访问路径
- **采样频率**：每周一 02:00 UTC（北京 10:00）由 `.github/workflows/intl-latency.yml` 触发
- **每页 5 次 curl `time_total`**，nearest-rank P95 = max（5 样本统计学上 P95 = max）
- **采样目标**：3 个稳定 URL（不会因文章重命名失效）
  - `/` 首页
  - `/posts/` 文章列表页
  - `/about/` 关于页

## 文件

| 文件 | 内容 |
|---|---|
| `cn-intl-latency.csv` | 周采样原始数据（date / page / p95_ms / samples_n / runner_region）|
| `README.md` | 本文件（阈值规则 + 评估流程）|

## 阈值规则

| 信号 | 触发动作 |
|---|---|
| 单周 P95 > **3000ms** | 立即评估 → 开新 OpenSpec 变更评估切换到 Q6 方案 C（独立 baseURL 双构建） |
| 连续 4 周 P95 > **1500ms** | 触发评估 → 同上 |
| 连续 4 周 P95 < 800ms | 维持当前方案 A，无需动作 |
| 单点抖动（单页面单周高），其他页面正常 | 大概率阿里云局部节点抖动，记录但不触发 |

**为什么 1500ms / 3000ms？**

- Google Web Vitals "Good" LCP 阈值 = 2500ms（移动端）
- 1500ms 是首屏延迟"良好"上限，留 1000ms 给 LCP 渲染余量
- 3000ms 已超 Web Vitals "Needs Improvement"，立即响应

## Q6 方案 C 切换流程（如果阈值触发）

1. **新开 OpenSpec 变更** `migrate-cn-baseurl-to-dual-build`（轻量）
2. 评估方案 C 实施成本（双构建、双部署 routing、SEO 影响）
3. **判断标准**：如果国际访问占 .cn 站总流量 > 5%（看 nginx access log），值得切换；< 1% 不切
4. 切换后 4 周内重新采样验证 P95 改善

## 手动触发

```bash
# 在 GitHub UI 上点 Actions → CN Intl Latency Monitor → Run workflow
# 或用 gh CLI:
gh workflow run intl-latency.yml
```

## 本地复测

```bash
bash scripts/measure-cn-latency.sh
# 注意：本地跑代表"作者自己的网络"视角，不等同于 GHA 国际 runner 视角，
# 但可用于脚本调试或对照参考。
```

## 历史归档

CSV 文件按 git 历史天然版本化，无需额外滚动。如长期数据量大（> 5 年），考虑按年拆 `cn-intl-latency-2026.csv` 等。

## 关联文档

- `openspec/roadmaps/blog-v2-rebuild/roadmap.md` § 阶段 4.G
- `openspec/roadmaps/blog-v2-rebuild/blog-v2-rebuild-memo.md` § Q6
- 已归档 `openspec/changes/archive/2026-05-05-implement-blog-phase-3-cn-vps/` —— 阶段 3 落地了 Q6 方案 A
