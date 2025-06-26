#!/bin/bash

# 项目根路径（自动检测脚本所在位置）
PROJECT_ROOT="$(cd "$(dirname "$0")" && pwd)"
BUILD_PATH="${PROJECT_ROOT}/binaries"

# 模块及其入口文件配置
declare -A MODULES
MODULES["Data/Extractor"]="main/ExtractorMain.go"
MODULES["LoginServer"]="main/LoginServer.go"
MODULES["GameServer"]="main/GameServer.go"

echo "📦 Go Modules 构建模式（输出 Windows 可执行文件）"
echo "📁 项目路径: $PROJECT_ROOT"
echo "📂 输出目录: $BUILD_PATH"
mkdir -p "$BUILD_PATH"

# 遍历构建
for PACKAGE in "${!MODULES[@]}"; do
    ENTRY_REL_PATH="${MODULES[$PACKAGE]}"
    MODULE_PATH="${PROJECT_ROOT}/${PACKAGE}/${ENTRY_REL_PATH}"

    MODULE_NAME=$(basename "$PACKAGE")
    OUTPUT_DIR="${BUILD_PATH}/${MODULE_NAME}"
    OUTPUT_FILE="${OUTPUT_DIR}/${MODULE_NAME}.exe"

    echo ""
    echo "🔨 编译模块: $PACKAGE"
    echo "📄 入口文件: $MODULE_PATH"
    echo "📁 输出到: $OUTPUT_FILE"

    mkdir -p "$OUTPUT_DIR"

    if [[ -f "$MODULE_PATH" ]]; then
        cd "$(dirname "$MODULE_PATH")" || exit 1
        GOOS=windows GOARCH=amd64 go build -o "$OUTPUT_FILE" "$(basename "$MODULE_PATH")" && {
            echo "✅ 编译成功: $OUTPUT_FILE"
        } || {
            echo "❌ 编译失败: $MODULE_NAME"
            exit 1
        }
    else
        echo "⚠️ 找不到入口文件，跳过：$MODULE_PATH"
    fi
done

echo ""
echo "🎉 所有模块编译完成，Windows 版可执行文件已生成。"