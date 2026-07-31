---
kind: logging_system
name: 日志系统 — 基于 Flutter 内置 debugPrint 的简单输出
category: logging_system
scope:
    - '**'
source_files:
    - lib/services/photo_service.dart
    - lib/main.dart
    - pubspec.yaml
---

该仓库未实现专门的日志系统。代码中仅使用 Flutter 框架自带的 `debugPrint` 函数进行简单的控制台输出，没有引入任何第三方日志库（如 `logger`、`logging`、`loggy` 等），也没有统一的日志封装、级别管理或结构化字段。

具体表现：
- 所有日志调用集中在 `lib/services/photo_service.dart` 中，用于打印权限状态、相册扫描结果和照片数量等调试信息。
- 未定义任何日志级别（如 debug/info/warn/error），也未配置日志输出目标（文件、远程收集等）。
- `pubspec.yaml` 依赖中不包含任何日志相关包，`main.dart` 入口也未进行日志初始化。
- 各平台原生 Runner（Android/iOS/Linux/macOS/Windows）中未发现自定义日志桥接或增强。

因此，当前项目的“日志系统”实质上就是直接使用 `debugPrint` 进行开发期调试输出，不具备生产环境所需的结构化、分级、持久化能力。