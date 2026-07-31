---
kind: configuration_system
name: 配置系统：Flutter 工程默认模板，无运行时配置框架
category: configuration_system
scope:
    - '**'
source_files:
    - pubspec.yaml
    - android/gradle.properties
    - ios/Runner/Info.plist
    - lib/main.dart
    - lib/app.dart
---

该仓库是一个 Flutter 多端应用根工程，当前**未实现专门的运行时配置系统**。代码库中不存在 `config/`、`.env`、`application.properties`、`*.toml` 等常见配置文件，Dart 层也未引入 `dotenv`、`flutter_config`、`easy_localization` 等配置管理依赖。所有构建与平台相关配置均通过 Flutter 模板提供的标准文件完成：

1. **Dart 层依赖与版本**：集中在 `pubspec.yaml`，使用 `version: 1.0.0+1` 定义应用版本，SDK 约束为 `^3.12.2`。
2. **Android 构建参数**：`android/gradle.properties` 仅包含 Gradle JVM 内存、AndroidX 开关等构建期属性，无运行时配置。
3. **iOS 元数据**：`ios/Runner/Info.plist` 声明权限（如 `NSPhotoLibraryUsageDescription`）、Bundle 标识、启动界面等，均为静态清单而非运行时可加载的配置。
4. **macOS / Windows / Linux Runner**：各平台原生入口仅负责引擎初始化与插件注册，未暴露配置加载逻辑。
5. **应用入口**：`lib/main.dart` 直接调用 `runApp(PhotoOrganizerApp())`，无任何配置初始化步骤；`lib/app.dart` 通过 Provider 注入业务状态，同样不涉及配置读取。

因此，本项目目前处于**最小可用模板阶段**，尚未集成任何运行时配置加载机制（环境变量、远程配置、Feature Flag 等）。若需扩展配置能力，可在 `main.dart` 启动前引入 `dotenv` 或 `flutter_config` 等包进行集中管理。