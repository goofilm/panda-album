---
kind: dependency_management
name: Flutter 依赖管理（pub + pubspec.lock）
category: dependency_management
scope:
    - '**'
source_files:
    - pubspec.yaml
    - pubspec.lock
    - analysis_options.yaml
---

本仓库使用 Flutter/Dart 生态的标准依赖管理系统，通过 `pubspec.yaml` 声明依赖、`pubspec.lock` 锁定版本，并借助国内镜像源加速下载。

**使用的系统与工具**
- 包管理器：`flutter pub`（Dart SDK 内置），用于解析、安装和更新依赖。
- 依赖声明文件：根目录 `pubspec.yaml`，按 `dependencies` / `dev_dependencies` 分类。
- 版本锁定文件：根目录 `pubspec.lock`，记录每个包的精确版本号与 sha256 校验值。
- 私有发布开关：`publish_to: 'none'` 禁止意外发布到 pub.dev。
- 代码质量分析：`analysis_options.yaml` 引入 `package:flutter_lints/flutter.yaml`，由 `flutter_lints` 提供 lint 规则。

**关键文件与位置**
- `pubspec.yaml`：声明 Dart SDK 版本约束 `^3.12.2`，直接依赖包括 `provider ^6.1.2`、`photo_manager ^3.7.0`、`sqflite ^2.4.3`、`cupertino_icons ^1.0.8`；开发依赖包含 `flutter_test`（SDK）与 `flutter_lints ^6.0.0`。
- `pubspec.lock`：锁定所有直接/间接依赖的精确版本与来源，所有第三方包均从 `https://pub.flutter-io.cn` 拉取，表明项目配置了国内镜像。
- `analysis_options.yaml`：启用 Flutter Lints 规则集，未做额外覆盖。

**架构与约定**
- 单工程多平台：Android、iOS、Linux、macOS、Windows 原生 Runner 子模块不单独声明依赖，统一由根 `pubspec.yaml` 管理，Flutter 插件通过各平台生成器自动集成。
- 版本策略：依赖使用语义化版本范围（`^x.y.z`），允许小版本升级；SDK 版本用 `^3.12.2` 约束。
- 依赖分类：运行时依赖放入 `dependencies`，测试与分析工具放入 `dev_dependencies`，保持构建产物最小化。
- 无 vendoring：未使用 `packages/` 或 `vendor/` 目录，依赖通过 pub 缓存机制管理。

**约束与规范**
- 禁止发布到公共仓库：`publish_to: 'none'` 明确禁用 `flutter pub publish`。
- 锁定文件必须提交：`pubspec.lock` 存在于仓库中，保证团队与 CI 环境获得一致的依赖树。
- 镜像源固定：`pubspec.lock` 中所有 hosted 包的 `url` 均为 `pub.flutter-io.cn`，说明全局已配置该镜像，且不应随意切换回官方源。
- 分析规则继承自 flutter_lints：如需关闭或新增规则，应在 `analysis_options.yaml` 的 `rules` 段显式覆盖。