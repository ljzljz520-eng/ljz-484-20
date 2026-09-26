#!/usr/bin/env bash
#
# check-structure.sh — 小说系统项目结构检查
#
# 用法:
#   ./scripts/check-structure.sh
#
# 退出码:
#   0  所有检查通过
#   1  存在缺失目录/文件,或根目录出现散落的代码文件
#
set -u

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

pass_count=0
fail_count=0

ok() {
  printf '✅ %s\n' "$1"
  pass_count=$((pass_count + 1))
}

bad() {
  printf '❌ %s\n' "$1"
  printf '   💡 修复提示: %s\n' "$2"
  fail_count=$((fail_count + 1))
}

check_dir() { # $1=路径 $2=检查项描述 $3=修复提示
  if [ -d "$1" ]; then ok "$2"; else bad "$2" "$3"; fi
}

check_file() { # $1=路径 $2=检查项描述 $3=修复提示
  if [ -f "$1" ]; then ok "$2"; else bad "$2" "$3"; fi
}

echo "======================================"
echo "  小说系统 · 项目结构检查"
echo "  根目录: $ROOT_DIR"
echo "======================================"

echo
echo "[1/5] 后端工程 (novel-backend/)"
check_dir  "novel-backend"                 "后端工程目录 novel-backend/ 存在" \
  "从版本库恢复该目录;若为新环境,请按 docs/development.md 第 2 节的结构重建 Maven 工程"
check_file "novel-backend/pom.xml"         "后端构建文件 novel-backend/pom.xml 就位" \
  "pom.xml 必须位于 novel-backend/ 根下;若发现它在仓库根目录,请移回 novel-backend/"
check_dir  "novel-backend/src/main/java"   "后端源码目录 novel-backend/src/main/java/ 存在" \
  "按 Maven 标准目录重建: mkdir -p novel-backend/src/main/java/com/novel"

echo
echo "[2/5] 前端工程 (novel-frontend/)"
check_dir  "novel-frontend"                "前端工程目录 novel-frontend/ 存在" \
  "从版本库恢复该目录;若为新环境,请在 novel-frontend/ 内使用 Vite 脚手架初始化工程"
check_file "novel-frontend/package.json"   "前端依赖清单 novel-frontend/package.json 就位" \
  "package.json 必须位于 novel-frontend/ 根下;若发现它在仓库根目录,请移回 novel-frontend/"
check_dir  "novel-frontend/src"            "前端源码目录 novel-frontend/src/ 存在" \
  "从版本库恢复 src/,其中应包含 views/、router/、assets/ 等目录"

echo
echo "[3/5] 根目录关键文件"
check_file "README.md"                     "项目说明 README.md 位于根目录" \
  "在仓库根目录新建 README.md 或从版本库恢复,内容应包含技术栈、启动指南与文档索引"
check_file "docker-compose.yml"            "编排文件 docker-compose.yml 位于根目录" \
  "从版本库恢复 docker-compose.yml;它引用 ./novel-backend 与 ./novel-frontend,必须放在根目录"
check_dir  "docs"                          "文档目录 docs/ 存在" \
  "新建 docs/ 目录并将项目文档迁入,文档不得散落在根目录"

echo
echo "[4/5] 根目录整洁性 (防止代码散落)"
stray=""
for f in *.java *.vue *.ts *.tsx *.jsx; do
  [ -e "$f" ] && stray="$stray $f"
done
[ -f pom.xml ]      && stray="$stray pom.xml"
[ -f package.json ] && stray="$stray package.json"
[ -d src ]          && stray="$stray src/"
if [ -z "$stray" ]; then
  ok "根目录无散落的源码/构建文件"
else
  bad "根目录发现散落的文件:$stray" \
    "后端代码移入 novel-backend/,前端代码移入 novel-frontend/,脚本移入 scripts/,文档移入 docs/"
fi

echo
echo "[5/5] 容器化配置"
check_file "novel-backend/Dockerfile"      "后端 Dockerfile 就位" \
  "从版本库恢复 novel-backend/Dockerfile"
check_file "novel-frontend/Dockerfile"     "前端 Dockerfile 就位" \
  "从版本库恢复 novel-frontend/Dockerfile"

echo
echo "======================================"
printf '检查完成: %d 项通过, %d 项失败\n' "$pass_count" "$fail_count"
echo "======================================"

if [ "$fail_count" -gt 0 ]; then
  echo "请先按上述 💡 修复提示处理,再重新运行本脚本。"
  exit 1
fi
echo "项目结构完整,可以开始开发。"
exit 0
