# 项目结构检查说明 (Structure Check)

## 1. 目的
本系统采用**前后端分离的双工程结构**,清晰的目录边界是项目的核心约束之一:

- 后端代码只能放在 `novel-backend/`,前端代码只能放在 `novel-frontend/`。
- 根目录只保留工程入口文件与文档索引,**不允许源码、构建文件散落到根目录**。

本文档说明如何运行结构检查、核对关键文件位置,并在目录缺失时给出修复提示。建议开发者在**克隆仓库后、提交代码前**各运行一次检查。

## 2. 标准目录结构
```text
novel-system/
├── novel-backend/            # 后端工程 (Spring Boot + Maven)
│   ├── pom.xml               # 后端构建文件,必须位于本目录
│   ├── src/main/java/com/novel/
│   └── Dockerfile
├── novel-frontend/           # 前端工程 (Vue 3 + Vite)
│   ├── package.json          # 前端依赖清单,必须位于本目录
│   ├── src/
│   └── Dockerfile
├── docs/                     # 项目文档
├── scripts/                  # 工程脚本(含结构检查脚本)
├── docker-compose.yml        # 容器编排入口
└── README.md                 # 项目说明,必须位于根目录
```

## 3. 运行检查
在项目根目录执行:
```bash
./scripts/check-structure.sh
```
- 输出 `✅` 表示该项通过;输出 `❌` 表示检查失败,并附带 💡 修复提示。
- 全部通过时退出码为 `0`;任一检查失败时退出码为 `1`,可直接接入 CI 或 pre-commit 钩子。

## 4. 检查项清单
| 分类 | 检查项 | 期望位置 |
| :--- | :--- | :--- |
| 后端工程 | 后端工程目录 | `novel-backend/` |
| 后端工程 | Maven 构建文件 | `novel-backend/pom.xml` |
| 后端工程 | 后端源码目录 | `novel-backend/src/main/java/` |
| 前端工程 | 前端工程目录 | `novel-frontend/` |
| 前端工程 | 前端依赖清单 | `novel-frontend/package.json` |
| 前端工程 | 前端源码目录 | `novel-frontend/src/` |
| 根目录 | 项目说明 | `README.md` |
| 根目录 | 容器编排入口 | `docker-compose.yml` |
| 根目录 | 文档目录 | `docs/` |
| 根目录 | 整洁性 | 无 `*.java` / `*.vue` / `pom.xml` / `package.json` / `src/` 等散落文件 |
| 容器化 | 后端镜像构建文件 | `novel-backend/Dockerfile` |
| 容器化 | 前端镜像构建文件 | `novel-frontend/Dockerfile` |

## 5. 常见问题与修复提示
| 异常现象 | 可能原因 | 修复方法 |
| :--- | :--- | :--- |
| 缺少 `novel-backend/` 目录 | 克隆不完整或误删 | 从版本库恢复;新环境则按 [开发指南](./development.md) 第 2 节重建 Maven 工程骨架 |
| 缺少 `novel-frontend/` 目录 | 克隆不完整或误删 | 从版本库恢复;新环境则在该目录内用 Vite 脚手架重新初始化 |
| `pom.xml` 出现在根目录 | 在错误位置初始化了 Maven 工程 | 将 `pom.xml` 及对应 `src/` 整体移入 `novel-backend/` |
| `package.json` 出现在根目录 | 在错误位置执行了 `npm init` | 将 `package.json`、`node_modules/` 等移入 `novel-frontend/`,并在该目录内重新 `npm install` |
| 根目录出现 `src/` 或 `*.java` / `*.vue` | 代码未归入前后端工程 | 后端代码移入 `novel-backend/src/`,前端代码移入 `novel-frontend/src/` |
| 缺少 `README.md` | 误删或未提交 | 在根目录恢复 README,内容应包含技术栈、启动指南与文档索引 |
| 缺少 `docker-compose.yml` | 误删或未提交 | 从版本库恢复;该文件引用 `./novel-backend` 与 `./novel-frontend`,必须位于根目录 |

## 6. 根目录守护规则 (防止代码散落)
为保证前后端结构长期清晰,根目录**只允许**保留以下内容:

- `novel-backend/`、`novel-frontend/` 两个工程目录
- `docs/`(文档)、`scripts/`(工程脚本)
- `README.md`、`docker-compose.yml`、`.gitignore`

新增内容时请遵循:

1. 后端代码 → `novel-backend/`,前端代码 → `novel-frontend/`,不得例外。
2. 新增文档 → `docs/`;新增脚本 → `scripts/`。
3. 提交代码前运行 `./scripts/check-structure.sh`,确认根目录整洁性检查通过。
