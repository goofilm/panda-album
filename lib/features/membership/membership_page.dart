import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/membership_provider.dart';
import '../../services/membership_service.dart';

class MembershipPage extends StatefulWidget {
  const MembershipPage({super.key});

  @override
  State<MembershipPage> createState() => _MembershipPageState();
}

class _MembershipPageState extends State<MembershipPage> {
  bool _purchasing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MembershipProvider>().refresh();
    });
  }

  @override
  Widget build(BuildContext context) {
    final membership = context.watch<MembershipProvider>();
    final w = MediaQuery.of(context).size.width;
    final isPremium = membership.isPremium;

    return Scaffold(
      appBar: AppBar(
        title: Text(isPremium ? '会员中心' : '开通会员'),
        actions: [
          if (!isPremium)
            TextButton(
              onPressed: _restorePurchases,
              child: const Text('恢复购买'),
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: w * 0.06),

            // 顶部图标 + 品牌
            _buildHeader(w, isPremium),

            SizedBox(height: w * 0.06),

            // 会员权益
            _buildBenefits(w),

            SizedBox(height: w * 0.06),

            // 已开通会员 - 状态显示
            if (isPremium) _buildPremiumStatus(w, membership),

            // 未开通 - 套餐选择
            if (!isPremium) ...[
              _buildPlanCard(
                w,
                title: '年度会员',
                price: '¥98',
                period: '/年',
                badge: '省 38%',
                badgeColor: Colors.orange,
                selected: true,
                onTap: () => _purchase(MembershipLevel.premiumYearly),
              ),
              SizedBox(height: w * 0.03),
              _buildPlanCard(
                w,
                title: '月度会员',
                price: '¥12',
                period: '/月',
                badge: null,
                badgeColor: Colors.blue,
                selected: false,
                onTap: () => _purchase(MembershipLevel.premiumMonthly),
              ),
              SizedBox(height: w * 0.06),

              // 购买按钮
              Padding(
                padding: EdgeInsets.symmetric(horizontal: w * 0.06),
                child: SizedBox(
                  width: double.infinity,
                  height: w * 0.13,
                  child: ElevatedButton(
                    onPressed: _purchasing ? null : () => _purchase(MembershipLevel.premiumYearly),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber.shade700,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(w * 0.065),
                      ),
                      elevation: 4,
                    ),
                    child: _purchasing
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            '立即开通',
                            style: TextStyle(
                              fontSize: w * 0.045,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ),
              SizedBox(height: w * 0.03),

              // 恢复购买
              TextButton(
                onPressed: _restorePurchases,
                child: Text(
                  '恢复购买',
                  style: TextStyle(fontSize: w * 0.035, color: Colors.grey.shade500),
                ),
              ),
            ],

            SizedBox(height: w * 0.04),

            // 订阅说明
            if (!isPremium) _buildSubscriptionNote(w),

            SizedBox(height: w * 0.06),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(double w, bool isPremium) {
    return Column(
      children: [
        Container(
          width: w * 0.22,
          height: w * 0.22,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isPremium
                  ? [Colors.amber.shade400, Colors.orange.shade600]
                  : [Colors.blue.shade300, Colors.blue.shade600],
            ),
            boxShadow: [
              BoxShadow(
                blurRadius: w * 0.04,
                spreadRadius: w * 0.005,
                color: (isPremium ? Colors.amber : Colors.blue).withValues(alpha: 0.3),
              ),
            ],
          ),
          child: Icon(
            isPremium ? Icons.workspace_premium : Icons.star_outline,
            size: w * 0.12,
            color: Colors.white,
          ),
        ),
        SizedBox(height: w * 0.04),
        Text(
          isPremium ? '尊贵的会员' : '熊猫相册 VIP',
          style: TextStyle(
            fontSize: w * 0.06,
            fontWeight: FontWeight.bold,
            color: isPremium ? Colors.amber.shade800 : Colors.blue.shade800,
          ),
        ),
        SizedBox(height: w * 0.02),
        Text(
          isPremium ? '感谢您的支持' : '解锁全部功能，畅享完整体验',
          style: TextStyle(
            fontSize: w * 0.035,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildBenefits(double w) {
    final benefits = [
      {'icon': Icons.category_outlined, 'title': '无限分类', 'desc': '自由创建任意数量分类'},
      {'icon': Icons.lock_outline, 'title': '无限私密', 'desc': '私密相册不再受限'},
      {'icon': Icons.delete_sweep_outlined, 'title': '永久回收站', 'desc': '回收站照片不会被自动清理'},
      {'icon': Icons.select_all_outlined, 'title': '批量操作', 'desc': '高效整理大量照片'},
      {'icon': Icons.headset_outlined, 'title': '优先客服', 'desc': '专属客服快速响应'},
    ];

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: w * 0.06),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '会员专享权益',
            style: TextStyle(
              fontSize: w * 0.045,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: w * 0.04),
          ...benefits.map((b) => Padding(
            padding: EdgeInsets.only(bottom: w * 0.03),
            child: Row(
              children: [
                Container(
                  width: w * 0.10,
                  height: w * 0.10,
                  decoration: BoxDecoration(
                    color: Colors.amber.shade50,
                    borderRadius: BorderRadius.circular(w * 0.025),
                  ),
                  child: Icon(b['icon'] as IconData, size: w * 0.055, color: Colors.amber.shade700),
                ),
                SizedBox(width: w * 0.03),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        b['title'] as String,
                        style: TextStyle(
                          fontSize: w * 0.038,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        b['desc'] as String,
                        style: TextStyle(
                          fontSize: w * 0.03,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.check_circle, color: Colors.amber.shade600, size: w * 0.05),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildPremiumStatus(double w, MembershipProvider membership) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: w * 0.06),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(w * 0.05),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.amber.shade50, Colors.orange.shade50],
          ),
          borderRadius: BorderRadius.circular(w * 0.04),
          border: Border.all(color: Colors.amber.shade200),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.workspace_premium, color: Colors.amber.shade700, size: w * 0.07),
                SizedBox(width: w * 0.02),
                Text(
                  membership.levelName,
                  style: TextStyle(
                    fontSize: w * 0.05,
                    fontWeight: FontWeight.bold,
                    color: Colors.amber.shade900,
                  ),
                ),
              ],
            ),
            SizedBox(height: w * 0.03),
            if (membership.remainingDays > 0)
              Text(
                '剩余 ${membership.remainingDays} 天',
                style: TextStyle(
                  fontSize: w * 0.04,
                  color: Colors.amber.shade800,
                  fontWeight: FontWeight.w500,
                ),
              ),
            if (membership.expireTime != null)
              Text(
                '到期时间: ${membership.expireTime!.toString().substring(0, 10)}',
                style: TextStyle(
                  fontSize: w * 0.03,
                  color: Colors.grey.shade600,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanCard(
    double w, {
    required String title,
    required String price,
    required String period,
    required String? badge,
    required Color badgeColor,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: w * 0.06),
        padding: EdgeInsets.all(w * 0.04),
        decoration: BoxDecoration(
          color: selected ? Colors.amber.shade50 : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(w * 0.04),
          border: Border.all(
            color: selected ? Colors.amber.shade400 : Colors.grey.shade300,
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: w * 0.04,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (badge != null) ...[
                        SizedBox(width: w * 0.02),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: w * 0.02, vertical: 2),
                          decoration: BoxDecoration(
                            color: badgeColor,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            badge,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: w * 0.025,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  SizedBox(height: w * 0.01),
                  Text(
                    '自动续费，随时取消',
                    style: TextStyle(
                      fontSize: w * 0.028,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: price,
                    style: TextStyle(
                      fontSize: w * 0.055,
                      fontWeight: FontWeight.bold,
                      color: selected ? Colors.amber.shade800 : Colors.grey.shade700,
                    ),
                  ),
                  TextSpan(
                    text: period,
                    style: TextStyle(
                      fontSize: w * 0.03,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubscriptionNote(double w) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: w * 0.08),
      child: Text(
        '订阅说明：\n'
        '• 订阅到期后自动续费，可在应用商店随时取消\n'
        '• 取消后当前周期内仍可使用会员功能\n'
        '• 到期后未续费将恢复免费版\n'
        '• 所有价格均含税',
        style: TextStyle(
          fontSize: w * 0.028,
          color: Colors.grey.shade400,
          height: 1.6,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Future<void> _purchase(MembershipLevel level) async {
    setState(() { _purchasing = true; });

    try {
      final provider = context.read<MembershipProvider>();
      bool success;

      if (level == MembershipLevel.premiumYearly) {
        success = await provider.purchaseYearly();
      } else {
        success = await provider.purchaseMonthly();
      }

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('恭喜！${level == MembershipLevel.premiumYearly ? "年度" : "月度"}会员开通成功'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('购买失败，请稍后重试'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() { _purchasing = false; });
    }
  }

  Future<void> _restorePurchases() async {
    setState(() { _purchasing = true; });

    try {
      final provider = context.read<MembershipProvider>();
      final success = await provider.restorePurchases();

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('恢复购买成功'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('未找到可恢复的购买记录'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } finally {
      if (mounted) setState(() { _purchasing = false; });
    }
  }
}
