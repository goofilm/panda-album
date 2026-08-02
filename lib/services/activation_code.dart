import 'dart:convert';
import 'dart:math';

/// 激活码工具类 - 生成和校验会员激活码
///
/// 激活码格式: PANDA-XXXXXXXX-C
/// - PANDA: 固定前缀
/// - XXXXXXXX: 8位随机字母数字（大写）
/// - C: 1位校验码（0-9 或 A-F）
class ActivationCode {
  /// 应用密钥（用于校验）
  static const String _secret = 'PandaAlbum2025Secret';

  /// 生成激活码
  /// [type]: 'monthly' 或 'yearly'
  static String generate({required String type}) {
    final random = Random.secure();
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789'; // 去掉易混淆字符

    // 生成8位随机码
    final randomPart = String.fromCharCodes(
      Iterable.generate(8, (_) => chars.codeUnitAt(random.nextInt(chars.length))),
    );

    // 生成校验码
    final checkDigit = _generateCheckDigit(randomPart, type);

    return 'PANDA-$randomPart-$checkDigit';
  }

  /// 校验激活码
  /// 返回校验结果: 'valid_monthly', 'valid_yearly', 'invalid', 'expired'
  static String validate(String code) {
    final trimmed = code.trim().toUpperCase();

    // 格式检查
    if (!_isValidFormat(trimmed)) {
      return 'invalid';
    }

    final parts = trimmed.split('-');
    if (parts.length != 3) return 'invalid';

    final prefix = parts[0];
    final randomPart = parts[1];
    final checkDigit = parts[2];

    // 前缀检查
    if (prefix != 'PANDA') return 'invalid';

    // 随机部分长度检查
    if (randomPart.length != 8) return 'invalid';

    // 校验码检查
    final expectedMonthly = _generateCheckDigit(randomPart, 'monthly');
    final expectedYearly = _generateCheckDigit(randomPart, 'yearly');

    if (checkDigit == expectedMonthly) return 'valid_monthly';
    if (checkDigit == expectedYearly) return 'valid_yearly';

    return 'invalid';
  }

  /// 生成校验码
  static String _generateCheckDigit(String randomPart, String type) {
    // 将随机部分和类型组合，生成校验值
    final combined = '$randomPart$_secret$type';
    final bytes = utf8.encode(combined);

    // 简单哈希：累加所有字节
    int hash = 0;
    for (final byte in bytes) {
      hash = (hash * 31 + byte) & 0xFFFFFFFF;
    }

    // 取最后4位作为校验码（十六进制）
    return (hash & 0xF).toRadixString(16).toUpperCase();
  }

  /// 检查格式是否合法
  static bool _isValidFormat(String code) {
    // PANDA-XXXXXXXX-C
    final regex = RegExp(r'^PANDA-[A-Z2-9]{8}-[0-9A-F]$');
    return regex.hasMatch(code);
  }

  /// 批量生成激活码（用于预生成）
  static List<String> generateBatch({
    required String type,
    required int count,
  }) {
    final codes = <String>[];
    for (int i = 0; i < count; i++) {
      codes.add(generate(type: type));
    }
    return codes;
  }
}
