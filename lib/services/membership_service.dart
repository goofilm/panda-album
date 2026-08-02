import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'activation_code.dart';

/// 会员等级
enum MembershipLevel {
  free,           // 免费版
  premiumMonthly, // 月度会员
  premiumYearly,  // 年度会员
}

/// 会员功能权限
class MembershipBenefits {
  /// 免费版分类数量限制
  static const int freeCategoryLimit = 3;
  
  /// 免费版私密相册数量限制
  static const int freePrivateAlbumLimit = 1;
  
  /// 免费版回收站保留天数
  static const int freeRecycleBinDays = 7;
  
  /// 会员回收站保留天数（永久）
  static const int premiumRecycleBinDays = 9999;
}

/// 会员服务 - 管理会员状态和购买逻辑
class MembershipService {
  static const String _keyLevel = 'membership_level';
  static const String _keyExpireTime = 'membership_expire_time';
  static const String _keyPurchaseTime = 'membership_purchase_time';

  /// 获取当前会员等级
  Future<MembershipLevel> getMembershipLevel() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final levelStr = prefs.getString(_keyLevel) ?? 'free';
      
      // 检查是否过期
      final expireTime = prefs.getInt(_keyExpireTime);
      if (expireTime != null && DateTime.now().millisecondsSinceEpoch > expireTime) {
        // 已过期，重置为免费版
        await setMembershipLevel(MembershipLevel.free);
        return MembershipLevel.free;
      }
      
      return MembershipLevel.values.firstWhere(
        (e) => e.name == levelStr,
        orElse: () => MembershipLevel.free,
      );
    } catch (e) {
      debugPrint('获取会员状态失败: $e');
      return MembershipLevel.free;
    }
  }

  /// 设置会员等级
  Future<void> setMembershipLevel(MembershipLevel level) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyLevel, level.name);
      
      if (level != MembershipLevel.free) {
        await prefs.setInt(_keyPurchaseTime, DateTime.now().millisecondsSinceEpoch);
        
        // 设置过期时间
        final expireTime = level == MembershipLevel.premiumMonthly
            ? DateTime.now().add(const Duration(days: 30)).millisecondsSinceEpoch
            : DateTime.now().add(const Duration(days: 365)).millisecondsSinceEpoch;
        await prefs.setInt(_keyExpireTime, expireTime);
      } else {
        await prefs.remove(_keyExpireTime);
        await prefs.remove(_keyPurchaseTime);
      }
    } catch (e) {
      debugPrint('设置会员状态失败: $e');
    }
  }

  /// 获取过期时间
  Future<DateTime?> getExpireTime() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final expireTime = prefs.getInt(_keyExpireTime);
      if (expireTime != null) {
        return DateTime.fromMillisecondsSinceEpoch(expireTime);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 模拟购买月度会员（实际发布时替换为真实支付）
  Future<bool> purchaseMonthly() async {
    try {
      // TODO: 接入真实支付 (Google Play Billing / StoreKit)
      // 这里模拟购买成功
      await Future.delayed(const Duration(seconds: 1));
      
      await setMembershipLevel(MembershipLevel.premiumMonthly);
      debugPrint('月度会员购买成功');
      return true;
    } catch (e) {
      debugPrint('购买失败: $e');
      return false;
    }
  }

  /// 模拟购买年度会员（实际发布时替换为真实支付）
  Future<bool> purchaseYearly() async {
    try {
      // TODO: 接入真实支付 (Google Play Billing / StoreKit)
      // 这里模拟购买成功
      await Future.delayed(const Duration(seconds: 1));
      
      await setMembershipLevel(MembershipLevel.premiumYearly);
      debugPrint('年度会员购买成功');
      return true;
    } catch (e) {
      debugPrint('购买失败: $e');
      return false;
    }
  }

  /// 恢复购买（App Store 审核要求）
  Future<bool> restorePurchases() async {
    try {
      // TODO: 接入真实恢复购买逻辑
      // 这里检查本地是否有有效的会员状态
      final level = await getMembershipLevel();
      return level != MembershipLevel.free;
    } catch (e) {
      debugPrint('恢复购买失败: $e');
      return false;
    }
  }

  /// 使用激活码激活会员
  /// 返回结果: 'success', 'invalid_code', 'already_used'
  Future<String> activateWithCode(String code) async {
    try {
      final result = ActivationCode.validate(code);

      if (result == 'invalid') {
        return 'invalid_code';
      }

      // 检查是否已使用过该激活码
      final prefs = await SharedPreferences.getInstance();
      final usedCodes = prefs.getStringList('used_activation_codes') ?? [];
      if (usedCodes.contains(code.trim().toUpperCase())) {
        return 'already_used';
      }

      // 激活会员
      final level = result == 'valid_yearly'
          ? MembershipLevel.premiumYearly
          : MembershipLevel.premiumMonthly;

      await setMembershipLevel(level);

      // 记录已使用的激活码
      usedCodes.add(code.trim().toUpperCase());
      await prefs.setStringList('used_activation_codes', usedCodes);

      debugPrint('激活码激活成功: $code -> $level');
      return 'success';
    } catch (e) {
      debugPrint('激活码激活失败: $e');
      return 'invalid_code';
    }
  }

  /// 检查是否是会员
  Future<bool> isPremium() async {
    final level = await getMembershipLevel();
    return level != MembershipLevel.free;
  }

  /// 检查是否可以使用某功能（免费版限制检查）
  Future<bool> canUseFeature(String feature, {int currentCount = 0}) async {
    final isPremiumUser = await isPremium();
    
    switch (feature) {
      case 'category':
        return isPremiumUser || currentCount < MembershipBenefits.freeCategoryLimit;
      case 'private_album':
        return isPremiumUser || currentCount < MembershipBenefits.freePrivateAlbumLimit;
      default:
        return true;
    }
  }
}
