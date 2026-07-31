import 'package:flutter/material.dart';

extension MorandiColor on Color {
  /// 降低饱和度30%，呈现莫兰迪色调
  Color toMorandi() {
    final hsv = HSVColor.fromColor(this);

    final newSaturation = (hsv.saturation * 0.7).clamp(0.0, 1.0);

    return hsv.withSaturation(newSaturation).toColor();
  }
}

/// 从hex字符串解析颜色并自动应用莫兰迪色调
Color morandiFromHex(String hex) {
  final color = Color(int.parse("FF$hex", radix: 16));

  return color.toMorandi();
}
