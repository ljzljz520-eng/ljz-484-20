# 开发指南 (Development)

## 1. 环境依赖
- Java 17+
- Node.js 20+
- Maven 3.9+
- Docker & Docker Compose

## 2. 目录结构
```text
novel-system/
├── novel-backend/          # 后端项目 (Maven)
│   ├── src/main/java/com/novel/
│   │   ├── controller/    # 接口定义
│   │   ├── model/         # 数据实体
│   │   └── repository/    # 数据存储逻辑
│   └── Dockerfile
├── novel-frontend/         # 前端项目 (Vite + Vue)
│   ├── src/
│   │   ├── views/         # 页面组件
│   │   ├── assets/        # 全局样式与资源
│   │   └── router/        # 路由配置
│   └── Dockerfile
└── docker-compose.yml
```

## 3. 本地开发启动

### 后端启动:
```bash
cd novel-backend
mvn spring-boot:run
```
访问 Swagger 调试: `http://localhost:8080/swagger-ui/index.html`

### 前端启动:
```bash
cd novel-frontend
npm install
npm run dev
```
访问地址: `http://localhost:3000`

## 4. 关键配置
- **前端代理**: 在 `vite.config.js` 中配置了对 `/api` 的本地转发。
- **Docker 镜像**: 后端使用 `eclipse-temurin:17-jre` 基础镜像，前端基于 `nginx:alpine`。

## 5. 项目结构检查
本系统要求严格的前后端目录边界：后端代码只允许进入 `novel-backend/`，前端代码只允许进入
`novel-frontend/`，根目录仅保留工程级文件，禁止把业务代码散落到根目录。

克隆代码、调整目录或提交前，运行结构检查：
```bash
bash scripts/check-structure.sh
```
脚本会确认 `novel-backend/`、`novel-frontend/`、`novel-backend/pom.xml`、
`novel-frontend/package.json`、`README.md` 等均在正确位置，并扫描根目录是否有游离的
源码 / 描述符；发现问题时会以非零退出码退出并打印逐项修复提示。完整说明（含常见问题
修复步骤与新增代码放置约定）见 [structure-check.md](./structure-check.md)。

## 6. 发布流程
1. 提交代码至仓库。
2. 运行 `bash scripts/check-structure.sh` 确认结构正确。
3. 确保 `package-lock.json` 已更新。
4. 运行 `docker compose up --build` 进行全量构建。
