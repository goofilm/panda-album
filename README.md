# 熊猫相册 Panda Album

一款基于 Flutter 的手机相册整理应用，用「左滑删除、右滑保留、下滑分类」的卡片式交互，帮你快速清理杂乱相册、归类珍贵照片。

## 功能特性

- **卡片式整理**：左右滑动快速决策，整理照片像玩游戏
- **照片/视频分离整理**：独立队列，支持分页加载海量媒体
- **自定义分类**：emoji 图标 + 自定义颜色，支持照片分类和视频分类
- **已保留照片管理**：未分类的保留媒体集中查看、批量分配分类
- **私密相册**：独立存储空间 + PIN 码保护
- **截图清理**：自动识别系统截图相册，批量清理释放空间
- **回收站**：30 天缓冲期，支持照片/视频分开浏览，防误删
- **AI 工具箱**：智能去重、相似照片检测等本地 AI 能力
- **照片搜索与地图**：按时间、地点浏览照片
- **多语言**：中文 / English
- **会员体系**：全功能免费 + 广告，会员免广告（激活码制）

## 技术栈

- Flutter（Android / iOS）
- Provider 状态管理
- SQLite 本地存储（sqflite）
- photo_manager 媒体访问
- ML Kit（本地 AI 识别）
- PHP（官网与统计/激活接口，见 `doc/website`）

## 项目结构

```
lib/
├── features/      # 各功能页面（整理、分类、回收站、私密相册、会员等）
├── providers/     # 状态管理
├── services/      # 会员服务、统计上报等
├── data/          # SQLite 数据层
├── widgets/       # 通用组件
└── l10n/          # 多语言资源
doc/website/       # 官网源码与 API 接口
```

## 构建运行

```bash
flutter pub get
flutter run          # 调试运行
flutter build apk --release   # 构建 Android 安装包
```

## 下载

官网：https://lightforever.net

## 许可证

本项目基于 [MIT License](LICENSE) 开源。
