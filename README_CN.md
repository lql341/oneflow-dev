# oneflow-dev

面向 [OneFLOW](https://github.com/eric2003/OneFLOW) 开发的智能体技能，聚焦
一维 Euler 的 CPU/DCU 移植与验证工作流。

它固化了以下几类规则和踩过的坑：

- **工作流**：fork/upstream 分支模型、按改动类型划分的回归门槛、PR 检查清单；
- **测试套件**：四个标准套件（资源配比、通过判据），以及保证性能数字可信的
  “同口径”比较规则；
- **构建矩阵**：主 CPU solver，以及 1D Euler port 的 CPU、HIP、HIP+MPI 三种配置；
- **报告规范**：命名、内容要求、公开发布边界与勘误处理；
- **坑位清单**：工具链（编译器版本下限、MPI C++ bindings、CMake 依赖传递）
  与测试框架（空测试假通过、后端前缀）两类陷阱。

集群连接信息有意不包含在本仓库：SSH、Slurm profile 与节点探测请使用配套的
[`scnet-hpc`](https://github.com/lql341/scnet-hpc) 技能。本仓库不含任何凭据、
账号或私有路径。

## 安装

```bash
mkdir -p ~/.claude/skills   # 或 ~/.codex/skills，取决于你的智能体
git clone https://github.com/lql341/oneflow-dev.git
cp -r oneflow-dev ~/.claude/skills/
```

本技能就是一个含 `SKILL.md` 的普通目录，凡是按目录扫描技能的智能体都可加载。

## 目录结构

```text
oneflow-dev/
├── SKILL.md                  入口（front matter + 任务路由表）
├── references/
│   ├── workflow.md           仓库工作流与 PR 规则
│   ├── kunshan-suites.md     四个标准套件与通过判据
│   ├── build-matrix.md       四类构建配置
│   ├── reports.md            报告规范与发布边界
│   └── pitfalls.md           已知陷阱
└── tests/validate.sh         结构自检
```

## 许可

MIT
