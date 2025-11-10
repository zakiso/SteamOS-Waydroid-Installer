# 代理问题修复总结 / Proxy Issues Fix Summary

## 问题 1: GAPPS 下载问题 / Issue 1: GAPPS Download Problem

### 症状 / Symptom
选择了带 GAPPS 的镜像，但下载的是不带 GAPPS 的镜像
Selected GAPPS image but got non-GAPPS image

### 原因 / Cause
使用 `sudo` 时环境变量未正确传递
Environment variables not passed correctly with `sudo`

```bash
# ❌ 错误的方式 / Wrong way
sudo -S http_proxy="..." waydroid init -s GAPPS
```

### 解决方案 / Solution
✅ 使用 `env` 命令显式传递环境变量
Use `env` command to explicitly pass environment variables

```bash
# ✅ 正确的方式 / Correct way
sudo -S env http_proxy="..." https_proxy="..." HTTP_PROXY="..." HTTPS_PROXY="..." waydroid init -s GAPPS
```

### 影响的文件 / Affected Files
- `steamos-waydroid-installer.sh` (lines 276, 287, 304)

---

## 问题 2: waydroid_script 超时 / Issue 2: waydroid_script Timeout

### 症状 / Symptom
```
INFO: Downloading libndktranslation.zip now ...
TimeoutError: [Errno 110] Connection timed out
```

### 原因 / Cause
`waydroid_script` 的 Python 脚本执行时没有代理环境变量
Python script execution of `waydroid_script` without proxy environment variables

```bash
# ❌ 错误的方式 / Wrong way
sudo -S python3 main.py -a13 install {libndk,widevine}
```

### 解决方案 / Solution
✅ 传递代理环境变量给 Python 脚本
Pass proxy environment variables to Python script

```bash
# ✅ 正确的方式 / Correct way
sudo -S env http_proxy="..." https_proxy="..." HTTP_PROXY="..." HTTPS_PROXY="..." python3 main.py -a13 install {libndk,widevine}
```

### 影响的文件 / Affected Files
- `functions.sh` (lines 111-117)

---

## 问题 3: curl 下载问题 / Issue 3: curl Download Problem

### 症状 / Symptom
自定义镜像下载超时
Custom image download timeout

### 原因 / Cause
curl 使用 `sudo` 时代理设置丢失
Proxy settings lost when curl runs with `sudo`

### 解决方案 / Solution
✅ 使用 `env` 命令传递代理设置
Use `env` command to pass proxy settings

```bash
# ✅ 正确的方式 / Correct way
sudo -S env http_proxy="..." https_proxy="..." curl -o file.zip url -L
```

### 影响的文件 / Affected Files
- `functions.sh` (line 79)

---

## 完整的代理传递模式 / Complete Proxy Passing Pattern

### 标准模式 / Standard Pattern

```bash
if [ "$USE_PROXY" == "true" ] && [ -n "$PROXY_URL" ]; then
    echo "使用代理 / Using proxy"
    sudo -S env \
        http_proxy="$PROXY_URL" \
        https_proxy="$PROXY_URL" \
        HTTP_PROXY="$PROXY_URL" \
        HTTPS_PROXY="$PROXY_URL" \
        command_to_run
else
    sudo -S command_to_run
fi
```

### 为什么需要大小写都设置？ / Why Both Cases?
不同的工具查找不同的环境变量：
Different tools look for different environment variables:

- **小写** `http_proxy`, `https_proxy` - curl, wget, Python requests/urllib3
- **大小写** `HTTP_PROXY`, `HTTPS_PROXY` - 某些 Java 应用, Go 应用
- **Both** ensure maximum compatibility

---

## 验证修复 / Verify Fixes

### 1. 检查脚本语法 / Check Script Syntax
```bash
bash -n steamos-waydroid-installer.sh
bash -n functions.sh
```

### 2. 测试代理连接 / Test Proxy Connection
```bash
# 测试 HTTP 代理
curl --proxy "http://proxy:port" https://www.google.com

# 测试环境变量
export http_proxy="http://proxy:port"
export https_proxy="http://proxy:port"
curl https://www.google.com
```

### 3. 查看脚本输出 / Check Script Output
运行脚本时应该看到：
When running the script, you should see:

```
使用代理初始化 Waydroid Initializing Waydroid via proxy
使用代理下载 Downloading via proxy: http://...
使用代理运行 waydroid_script Running waydroid_script via proxy
```

---

## 常见问题 / Common Issues

### Q: 为什么不能只设置环境变量？
### Q: Why not just export environment variables?

A: `sudo` 默认会重置环境变量（安全机制）
`sudo` resets environment variables by default (security feature)

```bash
# ❌ 不工作 / Doesn't work
export http_proxy="http://proxy:port"
sudo command  # 环境变量丢失 / env vars lost

# ✅ 工作 / Works
export http_proxy="http://proxy:port"
sudo -E command  # 保留环境 / preserve env

# ✅ 最佳 / Best
sudo env http_proxy="..." command  # 显式传递 / explicit pass
```

### Q: 为什么使用 `env` 而不是 `sudo -E`?

A: 
- `sudo -E` 保留所有环境变量（可能有安全风险）
- `env VAR=value` 只传递特定变量（更安全）
- `sudo -E` preserves ALL env vars (security risk)
- `env VAR=value` passes only specific vars (safer)

### Q: SOCKS5 代理支持吗？

A: 部分支持
Partial support:
- ✅ curl - 支持 SOCKS5 / supports SOCKS5
- ✅ Git - 支持 SOCKS5 / supports SOCKS5
- ⚠️ Python urllib3 - 可能需要额外配置 / may need extra config
- ❌ 某些工具不支持 SOCKS5 / some tools don't support SOCKS5

如果 SOCKS5 有问题，建议使用 HTTP 代理：
If SOCKS5 has issues, use HTTP proxy instead:
```bash
# 如果你有 SOCKS5 代理，可以用本地 HTTP 代理转换
# If you have SOCKS5, use local HTTP proxy converter
# 例如使用 privoxy 或 polipo
# For example: privoxy or polipo
```

---

## 修复时间线 / Fix Timeline

### 2025-01-XX 第一版代理支持 / Initial Proxy Support
- ✅ 添加代理配置界面
- ✅ 基本的环境变量设置
- ❌ sudo 环境变量传递不正确

### 2025-01-XX 修复 GAPPS 问题 / GAPPS Fix
- ✅ 使用 `env` 命令修复 waydroid init
- ✅ 添加选项确认输出
- ✅ 修复 curl 下载

### 2025-01-XX 修复 waydroid_script / waydroid_script Fix
- ✅ 传递代理到 Python 脚本
- ✅ 支持 libndk/widevine 下载
- ✅ 更新文档

---

## 测试清单 / Testing Checklist

使用代理测试以下场景：
Test following scenarios with proxy:

- [ ] Git clone (binder 和 waydroid_script)
- [ ] pacman 包安装
- [ ] waydroid init (GAPPS 版本)
- [ ] waydroid init (非 GAPPS 版本)
- [ ] 自定义镜像下载 (TV 版本)
- [ ] pip 安装 Python 包
- [ ] waydroid_script 下载 libndk
- [ ] waydroid_script 下载 widevine

不使用代理测试：
Test without proxy:

- [ ] 所有功能应该正常工作
- [ ] 不应该有代理相关错误

---

## 相关文件 / Related Files

### 主要修改 / Main Changes
- ✏️ `steamos-waydroid-installer.sh` - 主脚本
- ✏️ `functions.sh` - 函数库

### 文档 / Documentation
- 📄 `PROXY_SUPPORT.md` - 代理使用指南
- 📄 `GAPPS_TROUBLESHOOTING.md` - GAPPS 故障排除
- 📄 `PROXY_FIX_SUMMARY.md` - 本文件

### 工具 / Tools
- 🔧 `check-gapps.sh` - GAPPS 检查脚本

---

## 获取帮助 / Get Help

如果还有代理相关问题：
If you still have proxy-related issues:

1. 运行检查脚本 / Run check script:
   ```bash
   ./check-gapps.sh
   ```

2. 保存完整日志 / Save full log:
   ```bash
   ./steamos-waydroid-installer.sh 2>&1 | tee install.log
   ```

3. 提供以下信息 / Provide this info:
   - 代理类型 (HTTP/HTTPS/SOCKS5)
   - 错误信息完整输出
   - 使用的 SteamOS 版本
   - 网络环境描述

提交 Issue: https://github.com/ryanrudolfoba/SteamOS-Waydroid-Installer/issues

