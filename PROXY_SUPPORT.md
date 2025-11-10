# 代理支持说明 / Proxy Support Guide

## 概述 / Overview

本脚本现已支持通过代理服务器下载 Waydroid 镜像和依赖包。

This script now supports downloading Waydroid images and dependencies through a proxy server.

## 功能特性 / Features

### 支持的代理类型 / Supported Proxy Types
- HTTP 代理 / HTTP proxy
- HTTPS 代理 / HTTPS proxy  
- SOCKS5 代理 / SOCKS5 proxy

### 支持代理的组件 / Components with Proxy Support
1. **Git** - 克隆仓库 / Repository cloning
2. **curl** - 下载镜像文件 / Image file downloads
3. **waydroid init** - 初始化 Waydroid / Waydroid initialization
4. **pip** - Python 包安装 / Python package installation
5. **waydroid_script** - libndk/widevine 下载 / libndk/widevine downloads
6. **pacman** - 通过环境变量 / Via environment variables

## 使用方法 / Usage

### 启动脚本 / Running the Script

当你运行脚本时，会首先看到代理配置界面：

When you run the script, you'll first see the proxy configuration dialog:

```bash
./steamos-waydroid-installer.sh
```

### 配置选项 / Configuration Options

#### 选项 1: 不使用代理 / Option 1: No Proxy
- 选择 "不使用代理 (No proxy - direct connection)"
- 脚本将直接连接互联网下载

Choose "不使用代理 (No proxy - direct connection)" and the script will download directly.

#### 选项 2: 使用代理 / Option 2: Use Proxy
- 选择 "配置代理服务器 (Configure proxy server)"
- 输入代理服务器地址

Choose "配置代理服务器 (Configure proxy server)" and enter your proxy URL.

### 代理地址格式 / Proxy URL Format

#### HTTP 代理 / HTTP Proxy
```
http://proxy.example.com:8080
```

#### HTTPS 代理 / HTTPS Proxy
```
https://proxy.example.com:8080
```

#### SOCKS5 代理 / SOCKS5 Proxy
```
socks5://proxy.example.com:1080
```

#### 带认证的代理 / Proxy with Authentication
```
http://username:password@proxy.example.com:8080
https://username:password@proxy.example.com:8080
socks5://username:password@proxy.example.com:1080
```

## 技术实现 / Technical Implementation

### 环境变量 / Environment Variables
脚本会设置以下环境变量：
The script sets the following environment variables:

- `http_proxy` / `HTTP_PROXY`
- `https_proxy` / `HTTPS_PROXY`
- `all_proxy` / `ALL_PROXY`

### Git 配置 / Git Configuration
脚本会临时配置 Git 使用代理：
The script temporarily configures Git to use the proxy:

```bash
git config --global http.proxy "$PROXY_URL"
git config --global https.proxy "$PROXY_URL"
```

### 自动清理 / Automatic Cleanup
脚本结束时会自动清理代理配置，恢复原始设置。

The script automatically cleans up proxy configuration on exit.

## 示例 / Examples

### 示例 1: 使用公司 HTTP 代理 / Example 1: Using Corporate HTTP Proxy
```
代理地址 / Proxy URL: http://proxy.company.com:8080
```

### 示例 2: 使用认证代理 / Example 2: Using Authenticated Proxy
```
代理地址 / Proxy URL: http://myuser:mypass@proxy.company.com:8080
```

### 示例 3: 使用 SOCKS5 代理 / Example 3: Using SOCKS5 Proxy
```
代理地址 / Proxy URL: socks5://127.0.0.1:1080
```

## 故障排除 / Troubleshooting

### 连接超时 / Connection Timeout
- 检查代理地址是否正确 / Verify proxy URL is correct
- 确认代理服务器正在运行 / Ensure proxy server is running
- 检查防火墙设置 / Check firewall settings

### 认证失败 / Authentication Failed
- 检查用户名和密码是否正确 / Verify username and password
- 确保特殊字符正确编码 / Ensure special characters are properly encoded
- 例如 / Example: `@` 应该编码为 `%40` / `@` should be encoded as `%40`

### 代理不生效 / Proxy Not Working
- 重新运行脚本并检查代理配置 / Re-run script and check proxy configuration
- 查看终端输出中的代理信息 / Check terminal output for proxy messages
- 确认代理支持所需的协议 / Verify proxy supports required protocols

### waydroid_script 下载超时 / waydroid_script Download Timeout

**症状 / Symptoms:**
```
TimeoutError: [Errno 110] Connection timed out
```

**原因 / Cause:**
waydroid_script 下载 libndk/widevine 时需要代理支持
waydroid_script needs proxy to download libndk/widevine

**解决方案 / Solution:**
✅ **已修复** / **FIXED** - 脚本现在会传递代理环境变量给 waydroid_script
Script now passes proxy environment variables to waydroid_script

如果仍有问题，手动设置 / If still having issues, manually set:
```bash
export http_proxy="http://proxy:port"
export https_proxy="http://proxy:port"
sudo -E waydroid-script-command
```

## 注意事项 / Notes

1. 代理配置仅在脚本运行期间有效 / Proxy configuration is only active during script execution
2. 脚本会在退出时自动清理代理设置 / Script automatically cleans up proxy settings on exit
3. 如果脚本异常退出，可能需要手动清理 Git 配置 / If script exits abnormally, you may need to manually clean up Git config:
   ```bash
   git config --global --unset http.proxy
   git config --global --unset https.proxy
   ```

## 支持 / Support

如有问题，请在 GitHub 仓库提交 issue 或在 YT 频道留言。

For issues, please submit an issue on the GitHub repository or leave a comment on the YT channel.

- GitHub: https://github.com/ryanrudolfoba/SteamOS-Waydroid-Installer
- YouTube: 10MinuteSteamDeckGamer

