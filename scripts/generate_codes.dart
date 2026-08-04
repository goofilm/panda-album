import 'dart:convert';
import 'dart:math';
import 'dart:io';

/// 激活码生成脚本
/// 运行: dart scripts/generate_codes.dart
class ActivationCode {
  static const String _secret = 'PandaAlbum2025Secret';

  static String generate({required String type}) {
    final random = Random.secure();
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';

    final randomPart = String.fromCharCodes(
      Iterable.generate(8, (_) => chars.codeUnitAt(random.nextInt(chars.length))),
    );

    final checkDigit = _generateCheckDigit(randomPart, type);
    return 'PANDA-$randomPart-$checkDigit';
  }

  static String _generateCheckDigit(String randomPart, String type) {
    final combined = '$randomPart$_secret$type';
    final bytes = utf8.encode(combined);

    int hash = 0;
    for (final byte in bytes) {
      hash = (hash * 31 + byte) & 0xFFFFFFFF;
    }

    return (hash & 0xF).toRadixString(16).toUpperCase();
  }
}

void main() {
  final now = DateTime.now();
  final dateStr = '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}';
  
  // 生成月卡激活码 100个
  final monthlyCodes = <String>[];
  for (int i = 0; i < 100; i++) {
    monthlyCodes.add(ActivationCode.generate(type: 'monthly'));
  }
  
  // 生成年卡激活码 100个
  final yearlyCodes = <String>[];
  for (int i = 0; i < 100; i++) {
    yearlyCodes.add(ActivationCode.generate(type: 'yearly'));
  }
  
  // 保存到文件
  final monthlyFile = File('activation_codes_monthly_$dateStr.txt');
  monthlyFile.writeAsStringSync(monthlyCodes.join('\n'));
  print('月卡激活码已保存: ${monthlyFile.path}');
  print('共 ${monthlyCodes.length} 个\n');
  
  final yearlyFile = File('activation_codes_yearly_$dateStr.txt');
  yearlyFile.writeAsStringSync(yearlyCodes.join('\n'));
  print('年卡激活码已保存: ${yearlyFile.path}');
  print('共 ${yearlyCodes.length} 个\n');
  
  // 显示前5个示例
  print('=== 月卡示例 ===');
  for (int i = 0; i < 5; i++) {
    print(monthlyCodes[i]);
  }
  
  print('\n=== 年卡示例 ===');
  for (int i = 0; i < 5; i++) {
    print(yearlyCodes[i]);
  }
}
