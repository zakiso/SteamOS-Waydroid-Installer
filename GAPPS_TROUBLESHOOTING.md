# GAPPS 安装问题诊断 / GAPPS Installation Troubleshooting

## 问题描述 / Problem Description

**问题**: 选择了带 GAPPS 的镜像，但实际下载的是不带 GAPPS 的镜像。

**Problem**: Selected GAPPS image but ended up with non-GAPPS image.

---

## 可能的原因 / Possible Causes

### 1. 代理环境变量传递问题 / Proxy Environment Variable Issues

**症状 / Symptoms:**
- 使用代理时，`waydroid init -s GAPPS` 命令可能没有正确接收到代理设置
- When using proxy, `waydroid init -s GAPPS` may not receive proxy settings correctly

**原因 / Cause:**
- `sudo` 默认不传递环境变量 / `sudo` doesn't pass environment variables by default
- 之前的代码使用 `sudo -S http_proxy=... waydroid init` 可能无效
- Previous code using `sudo -S http_proxy=... waydroid init` may not work

**解决方案 / Solution:**
✅ **已修复** / **FIXED** - 现在使用 `sudo -S env http_proxy=... waydroid init`

---

### 2. Waydroid 下载源问题 / Waydroid Download Source Issues

**症状 / Symptoms:**
- 即使命令正确，仍下载错误的镜像
- Downloads wrong image even with correct command

**可能原因 / Possible Causes:**
- 官方镜像源可能临时不可用 / Official image source may be temporarily unavailable
- 代理服务器缓存了旧的响应 / Proxy server cached old response
- 网络连接中断导致下载不完整 / Network interruption caused incomplete download

**解决方案 / Solutions:**

1. **清理并重新安装 / Clean and Reinstall:**
```bash
# 删除现有安装
sudo rm -rf ~/waydroid /var/lib/waydroid

# 重新运行安装脚本
./steamos-waydroid-installer.sh
```

2. **检查 waydroid 日志 / Check waydroid logs:**
```bash
journalctl -u waydroid-container.service -n 100
```

---

### 3. 选项传递问题 / Option Passing Issues

**症状 / Symptoms:**
- 界面显示选择了 A13_GAPPS，但实际执行的是 A13_NO_GAPPS
- UI shows A13_GAPPS selected but A13_NO_GAPPS is executed

**诊断方法 / Diagnostic Method:**
- 现在脚本会显示你选择的选项
- Script now displays the option you selected:
```
======================================
用户选择 / User selected: A13_GAPPS
带 Google Play 服务 / With Google Play Services
======================================
```

---

## 诊断步骤 / Diagnostic Steps

### 步骤 1: 运行检查脚本 / Step 1: Run Check Script

```bash
./check-gapps.sh
```

这个脚本会:
This script will:
- 检查 Waydroid 是否已安装 / Check if Waydroid is installed
- 检查镜像文件 / Check image files
- 尝试检测是否包含 GAPPS / Attempt to detect if GAPPS is included

### 步骤 2: 查看安装日志 / Step 2: Check Installation Logs

在安装过程中，注意以下输出:
During installation, look for these outputs:

```bash
====================================== 
用户选择 / User selected: A13_GAPPS
带 Google Play 服务 / With Google Play Services
======================================
Initializing Waydroid.
```

如果使用代理，应该看到:
If using proxy, you should see:
```bash
使用代理初始化 Waydroid Initializing Waydroid via proxy
```

### 步骤 3: 验证命令执行 / Step 3: Verify Command Execution

理论上执行的命令应该是:
The command that should be executed:

**不使用代理 / Without proxy:**
```bash
sudo waydroid init -s GAPPS
```

**使用代理 / With proxy:**
```bash
sudo env http_proxy="..." https_proxy="..." waydroid init -s GAPPS
```

### 步骤 4: 检查镜像来源 / Step 4: Check Image Source

```bash
# 查看 waydroid 配置
cat /var/lib/waydroid/waydroid.cfg

# 应该包含类似这样的内容:
# [waydroid]
# images_path=/var/lib/waydroid/images
```

---

## 解决方案 / Solutions

### 方案 1: 完全重新安装 / Solution 1: Complete Reinstallation

```bash
# 1. 停止 waydroid
sudo waydroid container stop

# 2. 清理所有 waydroid 文件
sudo rm -rf ~/waydroid /var/lib/waydroid

# 3. 重新运行安装脚本
./steamos-waydroid-installer.sh

# 4. 仔细观察输出，确认选择正确
```

### 方案 2: 手动初始化 GAPPS / Solution 2: Manual GAPPS Initialization

如果脚本安装失败，可以尝试手动初始化:
If script installation fails, try manual initialization:

```bash
# 不使用代理
sudo waydroid init -s GAPPS -f

# 使用代理
sudo env http_proxy="http://proxy:port" https_proxy="http://proxy:port" waydroid init -s GAPPS -f
```

`-f` 参数会强制重新下载 / `-f` flag forces re-download

### 方案 3: 使用离线镜像 / Solution 3: Use Offline Image

如果网络问题持续存在:
If network issues persist:

1. 从其他地方下载 GAPPS 镜像
2. 将镜像放到 `/var/lib/waydroid/images/`
3. 手动初始化

---

## 验证 GAPPS 安装 / Verify GAPPS Installation

### 方法 1: 使用检查脚本 / Method 1: Use Check Script
```bash
./check-gapps.sh
```

### 方法 2: 手动检查 / Method 2: Manual Check

启动 Waydroid 后检查以下应用:
After starting Waydroid, check for these apps:
- Google Play Store
- Google Services Framework
- Google Play Services

```bash
# 启动 waydroid
waydroid show-full-ui

# 在 Android 中查看已安装应用
# 应该能看到 Play Store 图标
```

### 方法 3: 使用 ADB / Method 3: Use ADB

```bash
# 连接到 waydroid
adb connect 192.168.250.2:5555

# 列出系统应用
adb shell pm list packages | grep google

# 应该看到类似这样的输出:
# com.google.android.gms
# com.google.android.gsf
# com.android.vending
```

---

## 预防措施 / Prevention

### 1. 确保稳定的网络连接 / Ensure Stable Network
- 使用有线网络而不是 WiFi / Use wired network instead of WiFi
- 避免在网络高峰期安装 / Avoid installation during peak hours

### 2. 正确配置代理 / Configure Proxy Correctly
- 测试代理连接 / Test proxy connection:
```bash
curl --proxy "http://proxy:port" https://www.google.com
```

### 3. 保存安装日志 / Save Installation Logs
```bash
./steamos-waydroid-installer.sh 2>&1 | tee install.log
```

---

## 获取帮助 / Get Help

如果问题仍然存在，请提供以下信息:
If the problem persists, please provide:

1. 安装日志 / Installation log
2. `check-gapps.sh` 的输出 / Output of `check-gapps.sh`
3. 是否使用代理 / Whether using proxy
4. 网络环境描述 / Network environment description

提交 Issue: https://github.com/ryanrudolfoba/SteamOS-Waydroid-Installer/issues

---

## 更新日志 / Changelog

### 2025-01-XX
- ✅ 修复代理环境变量传递问题 / Fixed proxy environment variable passing
- ✅ 添加选项确认输出 / Added option confirmation output
- ✅ 使用 `env` 命令确保环境变量传递 / Use `env` command to ensure variable passing
- ✅ 创建 GAPPS 检查脚本 / Created GAPPS check script

