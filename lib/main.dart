import 'package:flutter/material.dart';

import 'app.dart';
import 'services/stats_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // 匿名活跃统计上报（后台异步执行，不阻塞启动）
  StatsService.reportLaunch();

  runApp(const PhotoOrganizerApp());
}
