import 'dart:math';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// 匿名活跃统计服务
///
/// App 每次启动时向服务器上报一个随机设备ID（不含任何个人信息），
/// 用于统计每日活跃人数和累计用户数。上报失败静默忽略，不影响使用。
class StatsService {
  static const String _statsUrl = 'https://lightforever.net/api/stats.php';
  static const String _deviceIdKey = 'stats_device_id';

  /// 启动上报（异步执行，不阻塞App启动）
  static Future<void> reportLaunch() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      String deviceId = prefs.getString(_deviceIdKey) ?? '';
      if (deviceId.isEmpty) {
        deviceId = _generateDeviceId();
        await prefs.setString(_deviceIdKey, deviceId);
      }

      await http
          .get(Uri.parse('$_statsUrl?action=report&device_id=$deviceId'))
          .timeout(const Duration(seconds: 5));
    } catch (_) {
      // 静默忽略上报失败，不影响App正常使用
    }
  }

  /// 生成16位随机匿名设备ID
  static String _generateDeviceId() {
    final random = Random.secure();
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    return List.generate(
      16,
      (_) => chars[random.nextInt(chars.length)],
    ).join();
  }
}
