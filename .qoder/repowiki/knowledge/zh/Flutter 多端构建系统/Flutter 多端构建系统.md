---
kind: build_system
name: Flutter 多端构建系统
category: build_system
scope:
    - '**'
source_files:
    - pubspec.yaml
    - android/build.gradle.kts
    - android/app/build.gradle.kts
    - android/gradle.properties
    - linux/CMakeLists.txt
    - windows/CMakeLists.txt
    - analysis_options.yaml
---

本项目采用 Flutter 框架作为统一的跨平台构建系统，通过单一 Dart 代码库同时编译为 Android、iOS、Linux、macOS、Windows 和 Web 六个目标平台。构建体系围绕 `pubspec.yaml` 依赖管理，结合各平台原生构建工具链（Gradle、Xcode、CMake）完成产物生成。

**核心构建流程**
- Dart 依赖与版本由根目录 `pubspec.yaml` 统一管理，使用 `flutter pub get` 解析依赖，`flutter analyze` 执行静态分析（基于 `analysis_options.yaml` 中的 flutter_lints 规则集）
- Android 平台通过 Gradle Kotlin DSL（`android/build.gradle.kts` 与 `android/app/build.gradle.kts`）构建，Java/Kotlin 编译目标为 JVM 17，NDK 版本由 Flutter 插件注入
- iOS/macOS 平台通过 Xcode 工程（`.xcodeproj`/`.xcworkspace`）构建，使用 `.xcconfig` 文件区分 Debug/Release 配置
- Linux/Windows 平台通过 CMake 构建，各平台 `CMakeLists.txt` 引入 Flutter 生成的插件注册代码
- Web 平台直接输出 HTML/CSS/JS，通过 `web/index.html` 和 `manifest.json` 配置 PWA 元数据

**版本与签名策略**
- 应用版本号在 `pubspec.yaml` 中统一声明为 `version: 1.0.0+1`，Android 的 versionName/versionCode 与 iOS 的 CFBundleShortVersionString/CFBundleVersion 均由 Flutter 插件自动映射
- Android Release 构建当前使用 debug 签名配置（`signingConfigs.getByName("debug")`），需替换为正式签名
- Android 构建目录被重定向到根 `build/` 目录下，避免与 Flutter 默认构建目录冲突

**构建环境与约束**
- Gradle JVM 参数配置为 `-Xmx8G -XX:MaxMetaspaceSize=4G`，支持大内存需求
- Android 启用 AndroidX 但禁用新 DSL 与内置 Kotlin（`android.newDsl=false`, `android.builtInKotlin=false`）
- 项目未包含 CI/CD 流水线、Dockerfile 或自定义构建脚本，构建主要依赖本地 Flutter SDK 与各平台原生工具链
- 无发布到 pub.dev 的配置（`publish_to: 'none'`），定位为私有包