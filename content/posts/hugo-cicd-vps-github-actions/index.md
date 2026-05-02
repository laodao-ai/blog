---
title: "Hugo 博客自动部署：GitHub Actions + VPS 全流程踩坑实录"
date: 2026-05-01
draft: false
summary: "从零搭建 Hugo 博客的 CI/CD 流水线：push main 自动构建部署，原子回滚保护，附真实踩坑记录。每个步骤都经过实际验证，特别标注了容易翻车的细节。"
tags: ["Hugo", "GitHub Actions", "VPS", "CI/CD", "运维"]
categories: ["工程实践"]
---

> **适合人群**：已有 Hugo 博客 + 独立 VPS，想摆脱手动 `scp` 部署，实现 push 自动发布的开发者。  
> **最终效果**：push 到 `main` 分支 → GitHub Actions 自动构建 → rsync 传到 VPS → 20 秒内上线。

---

## 为什么要写这篇

我在搭这套流程时，前后踩了 4 个坑，每个单独看都不难，但文档里找不到，只能靠报错日志一点点排查。这篇把全流程梳理一遍，重点把**容易翻车的地方**标出来，省得你重蹈覆辙。

---

## 架构设计

```
push main
  └─ GitHub Actions
       ├─ checkout + submodules
       ├─ Hugo 0.161.1 extended 构建
       ├─ rsync → VPS /var/www/releases/<timestamp>/
       ├─ ln -snf 切换 symlink（原子操作）
       └─ curl healthcheck
```

**关键设计决策：symlink 原子切换**

不要用 `rsync --delete` 直接覆盖线上目录。Hugo 生成的静态文件之间有引用关系（JS 引 CSS hash），rsync 传输到一半如果中断，VPS 上会出现新旧文件混合的状态，导致 404。

正确做法：rsync 传到一个新的 timestamp 目录，成功后用 `ln -snf` 切换 symlink。`ln -snf` 是原子操作，nginx 读到的永远是完整的某一版，不存在中间态。

---

## 准备工作

- VPS：Ubuntu 22.04，已有 nginx 服务博客
- 博客仓库：`github.com/你的org/blog`，主分支 `main`
- 本地：macOS 或 Linux

---

## 第一步：VPS 准备（root 登录执行）

### 1.1 创建 deploy 专用用户

```bash
useradd -m -s /bin/bash deploy
```

> ⚠️ **常见错误：shell 设成 nologin**
>
> 很多教程建议用 `/usr/sbin/nologin` 作为 deploy 用户的 shell，看起来更安全。**但这行不通。**
>
> OpenSSH 在执行 `authorized_keys` 里的 `command=` 强制命令时，是通过 `shell -c command` 来调用的。如果 shell 是 `nologin`，它会打印 "This account is currently not available." 然后退出，rsync 客户端收到这段文字就报 "protocol version mismatch"。
>
> **正确做法**：shell 设为 `/bin/bash`，安全性通过 `forced command` + `no-pty` 限制来保证，效果是一样的。

### 1.2 创建 SSH 目录

```bash
mkdir -p /home/deploy/.ssh
chmod 700 /home/deploy/.ssh
chown deploy:deploy /home/deploy/.ssh
```

### 1.3 安装 rrsync

Ubuntu 22.04 不预装 rrsync，需要手动安装：

```bash
apt-get update && apt-get install -y rsync

# 验证
which rrsync
# 输出：/usr/bin/rrsync
```

> ⚠️ **不要跳过这步**。`rsync` 命令和 `rrsync` 是两个东西：
> - `rsync`：数据传输工具（两端都需要）
> - `rrsync`：restricted rsync，是服务端的"守门员"，限制 rsync 只能写入指定目录

### 1.4 编写部署脚本

```bash
cat > /usr/local/bin/blog-deploy.sh << 'SCRIPT'
#!/bin/bash
# 以 forced command 方式运行：rrsync 接收文件 + symlink 原子切换
set -euo pipefail
umask 022

RELEASES_DIR="/var/www/releases"
SYMLINK="/var/www/laodao-ai"   # 改成你的实际路径
KEEP=5
TIMESTAMP=$(date +%Y%m%d%H%M%S)
DEST="${RELEASES_DIR}/${TIMESTAMP}"

mkdir -p "${DEST}"

# ⚠️ 关键：set +e 包裹 rrsync，否则清理逻辑不可达（见下方说明）
set +e
/usr/bin/rrsync -wo "${DEST}"
RSYNC_EXIT=$?
set -e

if [ "${RSYNC_EXIT}" -eq 0 ]; then
    ln -snf "${DEST}" "${SYMLINK}"
    ls -dt "${RELEASES_DIR}"/[0-9]*/ 2>/dev/null | tail -n +"$((KEEP + 1))" | xargs -r rm -rf
else
    rm -rf "${DEST}"
fi

exit "${RSYNC_EXIT}"
SCRIPT
```

> ⚠️ **`set -e` 陷阱**
>
> 脚本顶部的 `set -euo pipefail` 很好，但会带来一个副作用：任何命令以非零退出码结束，脚本立即退出，后面的代码不执行。
>
> 如果你这样写：
> ```bash
> /usr/bin/rrsync -wo "${DEST}"
> RSYNC_EXIT=$?   # ← 永远不会到达这里（rrsync 失败时）
> ```
>
> rrsync 失败 → set -e 触发脚本退出 → `$?` 捕获失败 → `else` 分支的 `rm -rf "${DEST}"` 永远不执行 → 目录垃圾堆积。
>
> **正确做法**：用 `set +e` / `set -e` 临时关闭，手动捕获退出码。

### 1.5 设置脚本权限

```bash
chown root:deploy /usr/local/bin/blog-deploy.sh
chmod 750 /usr/local/bin/blog-deploy.sh
```

> ⚠️ **属组必须是 deploy，不能是 root:root**
>
> `chmod 750` 的权限分布：
> - `7`（rwx）：属主 root 可读写执行
> - `5`（r-x）：属组可读执行
> - `0`（---）：其他人无权限
>
> deploy 用户不在 root 组，如果属主是 `root:root`，deploy 落入"其他人"，没有执行权限，CI 会报 `Permission denied`。
>
> 属组设为 `deploy` → deploy 用户进入"属组"一栏 → 有读+执行权限 → 脚本可以运行。

### 1.6 创建 releases 目录并设置权限

```bash
mkdir -p /var/www/releases
chown -R deploy:deploy /var/www/releases/

# 关键：/var/www/ 本身需要 deploy 组可写（用于创建/替换 symlink）
chown root:deploy /var/www
chmod 775 /var/www

# 验证
ls -la /var | grep www
# 应该显示：drwxrwxr-x root deploy
```

> ⚠️ **symlink 需要父目录写权限**
>
> `ln -snf /var/www/releases/xxx /var/www/laodao-ai` 这个操作，实际上是在 `/var/www/` 目录里创建/替换一个条目。
>
> 要在目录里创建文件（包括 symlink），需要对**该目录本身**有写权限，不是对 symlink 本身。
>
> deploy 用户默认对 `/var/www/` 没有写权限 → `ln` 报 `Permission denied` → symlink 不更新 → 旧版还在上面，但 CI 显示成功（rsync 其实成功了）。
>
> 解决：给 `/var/www/` 开放 deploy 组的写权限。

---

## 第二步：本地生成 deploy key（macOS 执行）

```bash
# 生成专用 deploy key，无密码（CI 自动使用）
ssh-keygen -t ed25519 -f ~/.ssh/deploy_key -N ""

# 查看公钥（后面要用）
cat ~/.ssh/deploy_key.pub

# 获取 VPS 主机指纹（后面要填入 GitHub Secrets）
ssh-keyscan -H 你的VPS_IP
```

---

## 第三步：配置 GitHub Secrets

在 `github.com/你的org/blog` → **Settings** → **Secrets and variables** → **Actions** → 停留在 **Secrets** tab（不是 Variables）。

> ⚠️ **Secrets vs Variables 的区别**
>
> - **Secrets**：加密存储，在 Actions 日志中自动脱敏显示为 `***`
> - **Variables**：明文存储，日志里可见
>
> SSH 私钥和 IP 都是敏感信息，必须用 **Secrets**。

点击 **New repository secret**，依次添加三个：

**`DEPLOY_SSH_KEY`**

```bash
cat ~/.ssh/deploy_key
```

把完整输出粘贴进去，包括首尾的 `-----BEGIN OPENSSH PRIVATE KEY-----` 和 `-----END OPENSSH PRIVATE KEY-----` 两行。

**`VPS_HOST`**

直接填 VPS IP，例如 `1.2.3.4`。

**`KNOWN_HOSTS`**

```bash
ssh-keyscan -H 你的VPS_IP
```

把完整输出（通常是 3 行，分别是 ecdsa、rsa、ed25519 三种算法）全部粘贴进去。

---

## 第四步：VPS 配置 authorized_keys

先把公钥传到 VPS：

```bash
scp ~/.ssh/deploy_key.pub root@你的VPS_IP:/tmp/deploy_key.pub
```

SSH 进 VPS，写入 authorized_keys：

```bash
# ⚠️ 分两步写，避免引号地狱
echo -n 'command="/usr/local/bin/blog-deploy.sh",no-pty,no-agent-forwarding,no-X11-forwarding,no-port-forwarding ' \
    > /home/deploy/.ssh/authorized_keys

cat /tmp/deploy_key.pub >> /home/deploy/.ssh/authorized_keys

# 验证：应该是一整行
cat /home/deploy/.ssh/authorized_keys
```

> ⚠️ **公钥内容有空格，不能直接拼在单引号字符串里**
>
> `deploy_key.pub` 的内容是 `ssh-ed25519 AAAA... user@host`，中间有空格。如果你试图把它直接拼在 `echo '...前缀... <公钥>'` 里，shell 的引号规则会让你头大。
>
> **最简单的方法**：用两步拼接。先用 `echo -n`（`-n` 去掉换行）写入前缀，再用 `cat >>` 追加公钥内容，这样两部分在同一行，不需要处理任何引号。

设置权限：

```bash
chmod 600 /home/deploy/.ssh/authorized_keys
chown deploy:deploy /home/deploy/.ssh/authorized_keys
```

验证 certbot 不受影响（如果你用 Let's Encrypt）：

```bash
certbot renew --dry-run
```

---

## 第五步：创建 GitHub Actions Workflow

在博客仓库本地创建文件：

```bash
mkdir -p .github/workflows
```

写入 `.github/workflows/deploy.yml`：

```yaml
name: Deploy Blog

on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    env:
      FORCE_JAVASCRIPT_ACTIONS_TO_NODE24: "true"  # 提前兼容 Node.js 24
    steps:
      - name: Checkout
        uses: actions/checkout@v4
        with:
          submodules: recursive
          fetch-depth: 0

      - name: Setup Hugo
        uses: peaceiris/actions-hugo@v3
        with:
          hugo-version: "0.161.1"   # 固定版本，与本地一致
          extended: true

      - name: Build
        run: hugo --minify --gc

      - name: Configure SSH
        env:
          DEPLOY_SSH_KEY: ${{ secrets.DEPLOY_SSH_KEY }}
          KNOWN_HOSTS: ${{ secrets.KNOWN_HOSTS }}
        run: |
          mkdir -p ~/.ssh
          echo "$DEPLOY_SSH_KEY" > ~/.ssh/deploy_key
          chmod 600 ~/.ssh/deploy_key
          echo "$KNOWN_HOSTS" > ~/.ssh/known_hosts
          chmod 644 ~/.ssh/known_hosts

      - name: Deploy via rsync
        env:
          VPS_HOST: ${{ secrets.VPS_HOST }}
        run: |
          rsync -avz --delete \
            -e "ssh -i ~/.ssh/deploy_key -o StrictHostKeyChecking=yes" \
            ./public/ deploy@$VPS_HOST:

      - name: Health check
        run: |
          curl -f --retry 3 --retry-delay 2 https://你的域名.com
```

几个关键点：

- `submodules: recursive`：Hugo 主题通常是 git submodule，必须加
- `hugo-version`：**固定版本**，不要用 `latest`，本地和 CI 版本不一致会导致构建结果差异
- `StrictHostKeyChecking=yes`：不要图省事用 `StrictHostKeyChecking=no`，那等于在 CI runner 上关掉 MITM 检测
- `FORCE_JAVASCRIPT_ACTIONS_TO_NODE24`：GitHub Actions 在 2026 年 6 月强制切换 Node.js 24，提前加这个 env var 现在就能测试兼容性

commit 并 push：

```bash
git add .github/workflows/deploy.yml
git commit -m "ci: add GitHub Actions deploy workflow"
git push origin main
```

---

## 第六步：验证

### 6.1 查看 CI 运行结果

push 后约 30 秒，在 GitHub → Actions 页面看到运行记录。全绿代表成功：

```
✓ Checkout
✓ Setup Hugo
✓ Build
✓ Configure SSH
✓ Deploy via rsync
✓ Health check
```

### 6.2 验证 VPS 目录结构

SSH 进 VPS：

```bash
ls -la /var/www/releases/
# 应该有 20260501XXXXXX 格式的 timestamp 目录

ls -la /var/www/laodao-ai
# 应该显示：lrwxrwxrwx ... /var/www/laodao-ai -> /var/www/releases/20260501XXXXXX
```

### 6.3 回滚安全验证（必做）

在任意文章里加一个不存在的 shortcode，触发 Hugo 构建失败：

```markdown
{{</* this_shortcode_does_not_exist */>}}
```

push 后观察：
1. CI 在 **Build 步骤失败**，rsync 步骤不执行
2. `curl https://你的域名.com` 仍返回 200，线上内容完好
3. VPS 的 symlink 指向没有变化

验证通过后删掉这行，再 push，CI 恢复全绿。

---

## 踩坑汇总

| 错误现象 | 根因 | 修复 |
|---|---|---|
| `protocol version mismatch` | deploy shell 是 nologin，forced command 无法执行 | `usermod -s /bin/bash deploy` |
| `Permission denied` 执行 blog-deploy.sh | 脚本属组是 root，deploy 用户无执行权限 | `chown root:deploy` + `chmod 750` |
| `ln: failed to create symbolic link: Permission denied` | deploy 对 `/var/www/` 目录无写权限 | `chown root:deploy /var/www && chmod 775 /var/www` |
| `No such file or directory: /usr/bin/rrsync` | Ubuntu 22.04 未预装 rrsync | `apt install rsync` |
| rsync 失败后 releases/ 留有空目录 | `set -e` 使清理逻辑不可达 | `set +e` / `set -e` 包裹 rrsync 调用 |

---

## 安全性说明

搭完之后，deploy 用户的权限边界是这样的：

- **forced command**：authorized_keys 里写死 `command=blog-deploy.sh`，SSH 连接建立后只能执行这一个脚本，不能执行任何其他命令
- **no-pty**：不能获得交互式终端
- **no-agent-forwarding / no-X11-forwarding / no-port-forwarding**：关掉所有转发能力
- **rrsync -wo**：限制 rsync 只能写入指定目录，不能读取其他文件

即使 deploy key 泄露，攻击者能做的只有：往 `/var/www/releases/` rsync 静态文件。无法获得 shell，无法读取系统文件，无法横向移动。

---

## 下一步

- 如果你有多个环境（staging/production），可以再加一个 deploy user 和对应的 authorized_keys 条目
- 阶段 2 可以把 `check-summary.sh` 等质量检查接入 CI，在构建前就拦截不合规的文章
- 想手动回滚到某个历史版本，在 VPS 上执行：

```bash
ln -snf /var/www/releases/20260501XXXXXX /var/www/laodao-ai
```

秒级生效，无需重新部署。
