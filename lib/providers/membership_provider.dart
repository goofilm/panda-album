import 'package:flutter/material.dart';
import '../services/membership_service.dart';

/// 会员状态 Provider - 全局管理会员信息
class MembershipProvider extends ChangeNotifier {
  final MembershipService _service = MembershipService();

  MembershipLevel _level = MembershipLevel.free;
  DateTime? _expireTime;
  bool _loading = false;
  bool _initialized = false;

  /// 当前会员等级
  MembershipLevel get level => _level;

  /// 是否是会员
  bool get isPremium => _level != MembershipLevel.free;

  /// 会员等级名称
  String get levelName {
    switch (_level) {
      case MembershipLevel.free:
        return '免费版';
      case MembershipLevel.premiumMonthly:
        return '月度会员';
      case MembershipLevel.premiumYearly:
        return '年度会员';
    }
  }

  /// 过期时间
  DateTime? get expireTime => _expireTime;

  /// 是否正在加载
  bool get loading => _loading;

  /// 剩余天数
  int get remainingDays {
    if (_expireTime == null) return 0;
    final remaining = _expireTime!.difference(DateTime.now()).inDays;
    return remaining > 0 ? remaining : 0;
  }

  /// 初始化 - 加载会员状态
  Future<void> init() async {
    if (_initialized) return;
    
    _loading = true;
    notifyListeners();

    try {
      _level = await _service.getMembershipLevel();
      _expireTime = await _service.getExpireTime();
      _initialized = true;
    } catch (e) {
      debugPrint('加载会员状态失败: $e');
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  /// 刷新会员状态
  Future<void> refresh() async {
    _loading = true;
    notifyListeners();

    try {
      _level = await _service.getMembershipLevel();
      _expireTime = await _service.getExpireTime();
    } catch (e) {
      debugPrint('刷新会员状态失败: $e');
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  /// 购买月度会员
  Future<bool> purchaseMonthly() async {
    _loading = true;
    notifyListeners();

    try {
      final success = await _service.purchaseMonthly();
      if (success) {
        _level = MembershipLevel.premiumMonthly;
        _expireTime = await _service.getExpireTime();
      }
      return success;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  /// 购买年度会员
  Future<bool> purchaseYearly() async {
    _loading = true;
    notifyListeners();

    try {
      final success = await _service.purchaseYearly();
      if (success) {
        _level = MembershipLevel.premiumYearly;
        _expireTime = await _service.getExpireTime();
      }
      return success;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  /// 恢复购买
  Future<bool> restorePurchases() async {
    _loading = true;
    notifyListeners();

    try {
      final success = await _service.restorePurchases();
      if (success) {
        _level = await _service.getMembershipLevel();
        _expireTime = await _service.getExpireTime();
      }
      return success;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  /// 检查是否可以使用某功能
  Future<bool> canUseFeature(String feature, {int currentCount = 0}) async {
    return await _service.canUseFeature(feature, currentCount: currentCount);
  }
}
