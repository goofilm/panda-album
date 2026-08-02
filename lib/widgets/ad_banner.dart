import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/membership_provider.dart';

/// 广告位占位组件
/// 会员用户自动隐藏
class AdBanner extends StatelessWidget {
  final double height;
  final String adText;

  const AdBanner({
    super.key,
    this.height = 60,
    this.adText = '广告位',
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<MembershipProvider>(
      builder: (context, membership, _) {
        // 会员用户不显示广告
        if (membership.isPremium) {
          return const SizedBox.shrink();
        }

        return Container(
          width: double.infinity,
          height: height,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.campaign_outlined,
                  color: Colors.grey.shade400,
                  size: 20,
                ),
                const SizedBox(height: 4),
                Text(
                  adText,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade400,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
