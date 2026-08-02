import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// 广告数据模型
class AdData {
  final String imageUrl;
  final String linkUrl;
  final String title;

  AdData({
    required this.imageUrl,
    required this.linkUrl,
    this.title = '',
  });

  factory AdData.fromJson(Map<String, dynamic> json) {
    return AdData(
      imageUrl: json['image'] ?? '',
      linkUrl: json['link'] ?? '',
      title: json['title'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'image': imageUrl,
      'link': linkUrl,
      'title': title,
    };
  }
}

/// 广告服务 - 从服务器获取自投放广告
///
/// 服务器接口格式：
/// GET {adServerUrl}/api/ads?position={position}
/// 返回：{"image": "https://...", "link": "https://...", "title": "..."}
/// 无广告时返回：{"image": ""} 或 404
class AdService {
  /// 广告服务器地址
  static const String adServerUrl = 'https://lightforever.net';

  /// 缓存键前缀
  static const String _cacheKeyPrefix = 'ad_cache_';

  /// 缓存过期时间（小时）
  static const int _cacheExpireHours = 24;

  /// 获取广告数据
  /// [position] 广告位标识：'home_banner', 'swipe_banner' 等
  static Future<AdData?> getAd({required String position}) async {
    // 先检查缓存
    final cached = await _getCachedAd(position);
    if (cached != null) return cached;

    // 从服务器获取
    try {
      final response = await http
          .get(Uri.parse('$adServerUrl/api/ads.php?position=$position'))
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final imageUrl = data['image'] as String? ?? '';

        if (imageUrl.isNotEmpty) {
          final ad = AdData.fromJson(data);
          // 缓存广告数据
          await _cacheAd(position, ad);
          return ad;
        }
      }
    } catch (e) {
      // 网络错误，静默失败
    }

    return null;
  }

  /// 从缓存获取广告
  static Future<AdData?> _getCachedAd(String position) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheKey = '$_cacheKeyPrefix$position';
      final cachedJson = prefs.getString(cacheKey);
      final cachedTime = prefs.getInt('${cacheKey}_time');

      if (cachedJson == null || cachedTime == null) return null;

      // 检查是否过期
      final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      final expireTime = _cacheExpireHours * 3600;
      if (now - cachedTime > expireTime) return null;

      final data = jsonDecode(cachedJson) as Map<String, dynamic>;
      return AdData.fromJson(data);
    } catch (e) {
      return null;
    }
  }

  /// 缓存广告数据
  static Future<void> _cacheAd(String position, AdData ad) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheKey = '$_cacheKeyPrefix$position';
      await prefs.setString(cacheKey, jsonEncode(ad.toJson()));
      await prefs.setInt(
        '${cacheKey}_time',
        DateTime.now().millisecondsSinceEpoch ~/ 1000,
      );
    } catch (e) {
      // 缓存失败，静默
    }
  }

  /// 清除广告缓存
  static Future<void> clearCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys().where((k) => k.startsWith(_cacheKeyPrefix));
      for (final key in keys) {
        await prefs.remove(key);
      }
    } catch (e) {
      // 静默
    }
  }
}
