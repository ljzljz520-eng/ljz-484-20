#!/usr/bin/env bash
#
# check-structure.sh —— 项目结构检查
#
# 本系统采用严格的前后端分离目录结构：
#   根目录只允许存放工程级文件（docker-compose、README、.gitignore 等），
#   所有后端代码必须位于 novel-backend/，所有前端代码必须位于 novel-frontend/。
#
# 用法：
#   bash scripts/check-structure.sh          # 从任意目录运行均可
#
# 退出码：
#   0  结构正确
#   1  发现缺失或散落的代码（必须修复后再提交 / 构建）

set -u

# 始终以仓库根目录（本脚本所在目录的上一级）为基准
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR" || exit 1

errors=0
pass()  { printf '  [\033[32m OK \033[0m] %s\n' "$1"; }
fail()  { printf '  [\033[31mFAIL\033[0m] %s\n' "$1"; errors=$((errors + 1)); }
note()  { printf '        -> %s\n' "$1"; }
header(){ printf '\n\033[1m%s\033[0m\n' "$1"; }

echo "项目结构检查（根目录: $ROOT_DIR）"

# ---------------------------------------------------------------
# 1. 必需的目录 / 文件
# ---------------------------------------------------------------
header "1. 必需的目录与文件"

check_path() {
  local path="$1" hint="$2"
  if [ -e "$path" ]; then
    pass "$path 存在"
  else
    fail "缺少: $path"
    note "修复提示: $hint"
  fi
}

check_path "novel-backend"                "后端工程目录被移动或未拉取？请恢复为根目录下的 novel-backend/（含 Maven 工程）。"
check_path "novel-frontend"               "前端工程目录被移动或未拉取？请恢复为根目录下的 novel-frontend/（含 Vite 工程）。"
check_path "docs"                         "项目文档应位于根目录 docs/，请从 git 恢复该目录。"
check_path "README.md"                    "根目录必须保留 README.md，请从 git 恢复: git checkout -- README.md"
check_path "novel-backend/pom.xml"        "后端 Maven 描述符缺失。请确认 pom.xml 位于 novel-backend/ 下，而非仓库根目录。"
check_path "novel-frontend/package.json"  "前端包描述符缺失。请确认 package.json 位于 novel-frontend/ 下，而非仓库根目录。"
check_path "novel-backend/src/main/java"  "后端源码目录缺失，标准 Maven 布局应为 novel-backend/src/main/java/。"
check_path "novel-frontend/src"           "前端源码目录缺失，Vite 工程的源码应位于 novel-frontend/src/。"
check_path "novel-frontend/vite.config.js" "前端缺少 vite.config.js，请检查前端工程是否完整。"

# ---------------------------------------------------------------
# 2. 禁止散落到根目录的文件
# ---------------------------------------------------------------
header "2. 根目录洁净度（代码不得散落到根目录）"

declare -a stray_hits=()

# 2.1 描述符 / 锁文件出现在根目录（除根目录自身允许的文件外）
root_descriptor_patterns='pom.xml|package.json|package-lock.json|mvnw|mvnw.cmd|vite.config.js|vite.config.ts'
while IFS= read -r f; do
  stray_hits+=("$f")
done < <(find . -maxdepth 1 -type f \
  \( -name 'pom.xml' -o -name 'package.json' -o -name 'package-lock.json' \
     -o -name 'mvnw' -o -name 'mvnw.cmd' \
     -o -name 'vite.config.js' -o -name 'vite.config.ts' \) \
  -printf '%P\n' 2>/dev/null)

# 2.2 散落在根目录的源码文件（.java/.vue/.js 等，深度 1）
while IFS= read -r f; do
  stray_hits+=("$f")
done < <(find . -maxdepth 1 -type f \
  \( -name '*.java' -o -name '*.vue' -o -name '*.js' -o -name '*.ts' \
     -o -name '*.jsx' -o -name '*.tsx' \) \
  -printf '%P\n' 2>/dev/null)

# 2.3 散落在根目录的源码目录（只报告常见的、明显属于前后端的目录）
while IFS= read -r d; do
  stray_hits+=("$d/")
done < <(find . -maxdepth 1 -mindepth 1 -type d \
  \( -name 'controller' -o -name 'model' -o -name 'repository' \
     -o -name 'views' -o -name 'components' -o -name 'router' \
     -o -name 'assets' -o -name 'src' \) \
  -printf '%P\n' 2>/dev/null)

if [ "${#stray_hits[@]}" -eq 0 ]; then
  pass "根目录没有散落的前后端代码或工程描述符"
else
  for hit in "${stray_hits[@]}"; do
    fail "根目录发现游离文件/目录: $hit"
  done
  note "修复提示:"
  note "  - 属于后端 (pom.xml、*.java、mvnw 等)，请移动到 novel-backend/，例如:"
  note "      mkdir -p novel-backend && mv pom.xml novel-backend/"
  note "  - 属于前端 (package.json、*.vue、vite.config.js、src/ 等)，请移动到 novel-frontend/，例如:"
  note "      mkdir -p novel-frontend && mv package.json vite.config.js src novel-frontend/"
  note "  - 移动后确认目录布局符合 docs/structure-check.md 中的标准结构，并重新运行本检查。"
fi

# ---------------------------------------------------------------
# 3. 总结
# ---------------------------------------------------------------
header "3. 结果"
if [ "$errors" -eq 0 ]; then
  printf '\033[32m结构检查通过 ✔\033[0m 后端与前端工程均在正确位置。\n'
  exit 0
else
  printf '\033[31m结构检查失败: 共 %d 个问题。\033[0m\n' "$errors"
  note "请按上面的修复提示处理，标准目录结构见 docs/structure-check.md。"
  note "不要把业务代码提交到仓库根目录；后端只进 novel-backend/，前端只进 novel-frontend/。"
  exit 1
fi
