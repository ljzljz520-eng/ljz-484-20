# 项目结构检查说明

本系统采用**严格的前后端分离目录结构**。清晰的目录边界是本项目的核心约定之一：
后端代码只允许出现在 `novel-backend/`，前端代码只允许出现在 `novel-frontend/`，
仓库根目录仅保留工程级文件（`docker-compose.yml`、`README.md`、`.gitignore` 等），
**不允许把后续业务代码散落到根目录**。

## 1. 标准目录结构

```text
novel-system/                    # 仓库根目录
├── README.md                   # 项目总说明（必须位于根目录）
├── docker-compose.yml          # 容器编排（工程级配置）
├── .gitignore
├── docs/                       # 项目文档
│   ├── architecture.md
│   ├── design.md
│   ├── development.md
│   ├── structure-check.md      # 本文件
│   └── ...
├── scripts/
│   └── check-structure.sh      # 结构检查脚本
├── novel-backend/              # 后端工程（Maven + Spring Boot）
│   ├── pom.xml                 # 后端 Maven 描述符，必须在此处
│   ├── src/main/java/com/novel/
│   │   ├── controller/
│   │   ├── model/
│   │   └── repository/
│   └── Dockerfile
└── novel-frontend/             # 前端工程（Vite + Vue 3）
    ├── package.json            # 前端包描述符，必须在此处
    ├── vite.config.js
    ├── src/
    │   ├── views/
    │   ├── assets/
    │   └── router/
    └── Dockerfile
```

根目录的判断原则：**一个文件如果只服务于前端或只服务于后端，它就不该出现在根目录。**

## 2. 运行检查

在仓库内任意位置执行均可（脚本会自动定位到仓库根目录）：

```bash
bash scripts/check-structure.sh
```

- 退出码 `0`：结构正确，终端输出「结构检查通过」。
- 退出码 `1`：发现缺失或散落的代码，输出中逐条列出问题与修复提示，修复后需重新运行。

建议在以下时机运行：

1. 克隆仓库或切换分支之后，确认工程完整；
2. 新增 / 移动模块、调整构建文件之后；
3. 提交 Pull Request 之前；
4. `docker compose up --build` 构建失败、怀疑工程结构被动过时。

## 3. 检查项清单

脚本会依次检查两类内容。

### 3.1 必需的目录与文件（缺失即报错）

| 路径 | 含义 |
| --- | --- |
| `novel-backend/` | 后端工程根目录 |
| `novel-frontend/` | 前端工程根目录 |
| `docs/` | 项目文档目录 |
| `README.md` | 根目录项目说明 |
| `novel-backend/pom.xml` | 后端 Maven 描述符 |
| `novel-backend/src/main/java/` | 后端标准 Maven 源码目录 |
| `novel-frontend/package.json` | 前端包描述符 |
| `novel-frontend/vite.config.js` | 前端 Vite 配置 |
| `novel-frontend/src/` | 前端源码目录 |

### 3.2 根目录洁净度（出现即报错）

以下内容一旦出现在仓库根目录（深度 1）即视为「游离代码」：

- 工程描述符与锁文件：`pom.xml`、`package.json`、`package-lock.json`、
  `mvnw` / `mvnw.cmd`、`vite.config.js` / `vite.config.ts`；
- 源码文件：`*.java`、`*.vue`、`*.js`、`*.ts`、`*.jsx`、`*.tsx`；
- 明显属于前后端工程的源码目录：`src/`、`controller/`、`model/`、
  `repository/`、`views/`、`components/`、`router/`、`assets/`。

## 4. 常见问题与修复方法

### 问题 A：提示「缺少: novel-backend/pom.xml」

说明后端工程不完整，或 `pom.xml` 被放到了错误的位置。

1. 先在仓库中查找它的实际位置：
   ```bash
   find . -name pom.xml -not -path '*/target/*'
   ```
2. 若文件在根目录，移回后端工程：
   ```bash
   mv pom.xml novel-backend/
   ```
3. 若整个 `novel-backend/` 目录都不存在，从 git 恢复：
   ```bash
   git checkout HEAD -- novel-backend
   ```
4. 重新运行检查确认通过。

### 问题 B：提示「缺少: novel-frontend/package.json」

处理方式与问题 A 对称：

```bash
find . -name package.json -not -path '*/node_modules/*'
# 若在根目录找到：
mv package.json novel-frontend/
# 若目录整体缺失：
git checkout HEAD -- novel-frontend
```

### 问题 C：根目录发现游离文件 / 目录

按归属移动到对应工程，而不是删除：

- 属于后端（`pom.xml`、`*.java`、`mvnw`、`controller/` 等）→ `novel-backend/`
  （源码放入 `novel-backend/src/main/java/com/novel/` 下对应包）；
- 属于前端（`package.json`、`*.vue`、`vite.config.js`、`src/`、`views/` 等）→ `novel-frontend/`
  （页面组件放入 `novel-frontend/src/views/`，静态资源放入 `src/assets/`）。

示例：

```bash
# 后端文件散落根目录
mkdir -p novel-backend
mv pom.xml novel-backend/

# 前端文件散落根目录
mkdir -p novel-frontend
mv package.json vite.config.js src novel-frontend/
```

移动后重新运行 `bash scripts/check-structure.sh`，直到退出码为 0。

### 问题 D：`novel-backend/` 或 `novel-frontend/` 整个目录缺失

通常是稀疏检出、误删或拷贝不全导致：

```bash
git status
git checkout HEAD -- novel-backend novel-frontend
```

## 5. 新增代码时的放置约定

为避免检查失败、也为保持结构清晰，新增代码请遵循：

| 新增内容 | 放置位置 |
| --- | --- |
| REST 接口 / Controller | `novel-backend/src/main/java/com/novel/controller/` |
| 数据实体 / Model | `novel-backend/src/main/java/com/novel/model/` |
| 存储与数据访问逻辑 | `novel-backend/src/main/java/com/novel/repository/` |
| Maven 依赖变更 | 只修改 `novel-backend/pom.xml` |
| 页面（.vue） | `novel-frontend/src/views/` |
| 全局样式与图片 | `novel-frontend/src/assets/` |
| 路由配置 | `novel-frontend/src/router/` |
| npm 依赖变更 | 只修改 `novel-frontend/package.json` |
| 跨工程的通用脚本 | `scripts/` |
| 设计与说明文档 | `docs/` |

> 规则一句话：**后端只进 `novel-backend/`，前端只进 `novel-frontend/`，
> 根目录只放工程级文件。**
