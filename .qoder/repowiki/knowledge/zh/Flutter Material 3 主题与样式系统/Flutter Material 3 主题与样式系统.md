---
kind: frontend_style
name: Flutter Material 3 主题与样式系统
category: frontend_style
scope:
    - '**'
source_files:
    - lib/app.dart
    - lib/main.dart
    - lib/features/home/home_page.dart
    - pubspec.yaml
    - analysis_options.yaml
---

该 Flutter 应用采用原生 Flutter Material Design 3 作为前端样式体系，未引入第三方 UI 组件库或 CSS-in-Dart 方案。

**样式系统与主题配置**
- 通过 `MaterialApp` 的 `theme: ThemeData(useMaterial3: true, colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue))` 统一全局主题，使用蓝色种子色生成 Material 3 色彩方案。
- 所有页面基于 `Scaffold` + `AppBar` + `SafeArea` 的标准 Material 布局结构构建。
- 图标统一使用 `Icons.*`（如 `Icons.inventory_2`、`Icons.category`、`Icons.delete`），字体样式直接内联定义（如 `TextStyle(fontSize: 28, fontWeight: FontWeight.bold)`）。

**状态管理与样式解耦**
- 使用 `provider` 包进行状态管理，UI 通过 `context.watch<T>()` 和 `context.read<T>()` 订阅数据变化，实现样式与业务逻辑分离。
- 应用级 Provider 在 `app.dart` 中通过 `MultiProvider` 集中注册（`PhotoProvider`、`CategoryProvider`）。

**代码风格约束**
- 遵循 `flutter_lints` 推荐的 Dart/Flutter 代码规范（见 `analysis_options.yaml` 继承 `package:flutter_lints/flutter.yaml`）。
- 组件按功能域组织：`lib/features/` 下按业务模块划分页面（如 `home`、`swipe`），`lib/providers/` 存放状态提供者，`lib/services/` 存放服务层。
- 无自定义 CSS/SCSS/Tailwind 等样式文件，所有视觉样式均通过 Flutter Widget 属性声明式构建。

**平台适配**
- 通过 `uses-material-design: true` 启用 Material Icons 字体资源。
- 各平台（Android/iOS/Linux/macOS/Windows）共享同一套 Dart UI 代码，由 Flutter 引擎负责平台渲染差异。