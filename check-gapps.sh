#!/bin/bash

# 检查 Waydroid GAPPS 安装状态脚本
# Script to check Waydroid GAPPS installation status

echo "========================================"
echo "Waydroid GAPPS 安装状态检查"
echo "Checking Waydroid GAPPS Installation"
echo "========================================"
echo ""

# 检查 waydroid 是否已安装
if ! command -v waydroid &> /dev/null; then
    echo "❌ Waydroid 未安装 / Waydroid is not installed"
    exit 1
fi

echo "✅ Waydroid 已安装 / Waydroid is installed"
echo ""

# 检查 waydroid 配置文件
echo "📋 检查配置文件 / Checking configuration files..."
echo ""

WAYDROID_CFG="/var/lib/waydroid/waydroid.cfg"
WAYDROID_PROP="/var/lib/waydroid/waydroid_base.prop"

if [ -f "$WAYDROID_CFG" ]; then
    echo "🔍 Waydroid 配置 / Waydroid Configuration:"
    echo "-------------------------------------------"
    cat "$WAYDROID_CFG"
    echo "-------------------------------------------"
    echo ""
else
    echo "⚠️  配置文件不存在 / Configuration file not found: $WAYDROID_CFG"
    echo ""
fi

# 检查已安装的镜像
echo "📦 检查已安装的镜像 / Checking installed images..."
echo ""

SYSTEM_IMG="/var/lib/waydroid/images/system.img"
VENDOR_IMG="/var/lib/waydroid/images/vendor.img"

if [ -f "$SYSTEM_IMG" ]; then
    echo "✅ System 镜像存在 / System image exists"
    echo "   大小 / Size: $(du -h "$SYSTEM_IMG" | cut -f1)"
else
    echo "❌ System 镜像不存在 / System image not found"
fi

if [ -f "$VENDOR_IMG" ]; then
    echo "✅ Vendor 镜像存在 / Vendor image exists"
    echo "   大小 / Size: $(du -h "$VENDOR_IMG" | cut -f1)"
else
    echo "❌ Vendor 镜像不存在 / Vendor image not found"
fi
echo ""

# 检查 GAPPS 相关文件
echo "🔍 检查 GAPPS 安装 / Checking GAPPS installation..."
echo ""

# 挂载 system.img 检查是否包含 GAPPS
TEMP_MOUNT=$(mktemp -d)

if [ -f "$SYSTEM_IMG" ]; then
    echo "尝试检查镜像内容... / Attempting to check image contents..."
    
    # 尝试使用 sudo 挂载镜像
    if sudo mount -o loop,ro "$SYSTEM_IMG" "$TEMP_MOUNT" 2>/dev/null; then
        echo ""
        echo "📱 检查 Google 应用 / Checking for Google apps..."
        
        GAPPS_FOUND=false
        
        # 检查常见的 Google 应用路径
        GAPPS_PATHS=(
            "$TEMP_MOUNT/system/priv-app/GmsCore"
            "$TEMP_MOUNT/system/priv-app/GoogleServicesFramework"
            "$TEMP_MOUNT/system/priv-app/Phonesky"
            "$TEMP_MOUNT/priv-app/GmsCore"
            "$TEMP_MOUNT/priv-app/GoogleServicesFramework"
            "$TEMP_MOUNT/priv-app/Phonesky"
        )
        
        for path in "${GAPPS_PATHS[@]}"; do
            if [ -d "$path" ]; then
                echo "✅ 找到 / Found: $(basename $path)"
                GAPPS_FOUND=true
            fi
        done
        
        if [ "$GAPPS_FOUND" = true ]; then
            echo ""
            echo "✅ ✅ ✅ 检测到 GAPPS / GAPPS detected! ✅ ✅ ✅"
        else
            echo ""
            echo "❌ ❌ ❌ 未检测到 GAPPS / GAPPS NOT detected! ❌ ❌ ❌"
            echo ""
            echo "可能的原因 / Possible reasons:"
            echo "1. 您选择了不带 GAPPS 的版本 / You selected the version without GAPPS"
            echo "2. 下载过程中出现问题 / Download was interrupted or corrupted"
            echo "3. 使用代理时环境变量未正确传递 / Proxy env vars not passed correctly"
        fi
        
        sudo umount "$TEMP_MOUNT"
    else
        echo "⚠️  无法挂载镜像进行检查 / Cannot mount image for inspection"
        echo "   可能需要 root 权限 / May require root privileges"
    fi
fi

# 清理临时挂载点
rm -rf "$TEMP_MOUNT"

echo ""
echo "========================================"
echo "检查完成 / Check completed"
echo "========================================"
echo ""
echo "💡 提示 / Tips:"
echo ""
echo "如果没有检测到 GAPPS，您可以："
echo "If GAPPS was not detected, you can:"
echo ""
echo "1. 重新安装并确保选择 A13_GAPPS 选项"
echo "   Reinstall and ensure you select A13_GAPPS option"
echo ""
echo "2. 检查网络连接和代理设置"
echo "   Check network connection and proxy settings"
echo ""
echo "3. 查看安装日志中的详细信息"
echo "   Check installation logs for details"
echo ""

