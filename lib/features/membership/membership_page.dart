import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';

import '../../providers/membership_provider.dart';
import '../../services/membership_service.dart';

class MembershipPage extends StatefulWidget {
  const MembershipPage({super.key});

  @override
  State<MembershipPage> createState() => _MembershipPageState();
}

class _MembershipPageState extends State<MembershipPage> {
  bool _purchasing = false;
  bool _activating = false;
  bool _isYearlySelected = true; // 默认选中年卡
  final _activationCodeController = TextEditingController();

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
        title: Text(isPremium ? AppLocalizations.of(context)!.membershipCenter : AppLocalizations.of(context)!.openMembership),
        actions: [
          if (!isPremium)
            TextButton(
              onPressed: _restorePurchases,
              child: Text(AppLocalizations.of(context)!.restorePurchase),
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
                title: AppLocalizations.of(context)!.yearlyPlan,
                price: AppLocalizations.of(context)!.yearlyPrice,
                period: AppLocalizations.of(context)!.perYear,
                badge: AppLocalizations.of(context)!.savePercent,
                badgeColor: Colors.orange,
                selected: _isYearlySelected,
                onTap: () => setState(() => _isYearlySelected = true),
              ),
              SizedBox(height: w * 0.03),
              _buildPlanCard(
                w,
                title: AppLocalizations.of(context)!.monthlyPlan,
                price: AppLocalizations.of(context)!.monthlyPrice,
                period: AppLocalizations.of(context)!.perMonth,
                badge: null,
                badgeColor: Colors.blue,
                selected: !_isYearlySelected,
                onTap: () => setState(() => _isYearlySelected = false),
              ),
              SizedBox(height: w * 0.06),

              // 购买按钮
              Padding(
                padding: EdgeInsets.symmetric(horizontal: w * 0.06),
                child: SizedBox(
                  width: double.infinity,
                  height: w * 0.13,
                  child: ElevatedButton(
                    onPressed: _purchasing ? null : _showPurchaseQRDialog,
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
                            AppLocalizations.of(context)!.subscribeNow,
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
                  AppLocalizations.of(context)!.restorePurchase,
                  style: TextStyle(fontSize: w * 0.035, color: Colors.grey.shade500),
                ),
              ),
            ],

            SizedBox(height: w * 0.04),

            // 订阅说明
            if (!isPremium) _buildSubscriptionNote(w),

            SizedBox(height: w * 0.06),

            // 扫码购买入口
            if (!isPremium) _buildPurchaseQRCodeEntry(w),

            SizedBox(height: w * 0.04),

            // 激活码入口
            if (!isPremium) _buildActivationCodeEntry(w),

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
          isPremium ? AppLocalizations.of(context)!.premiumMember : AppLocalizations.of(context)!.pandaVip,
          style: TextStyle(
            fontSize: w * 0.06,
            fontWeight: FontWeight.bold,
            color: isPremium ? Colors.amber.shade800 : Colors.blue.shade800,
          ),
        ),
        SizedBox(height: w * 0.02),
        Text(
          isPremium ? AppLocalizations.of(context)!.thankSupport : AppLocalizations.of(context)!.unlockAll,
          style: TextStyle(
            fontSize: w * 0.035,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildBenefits(double w) {
    final l10n = AppLocalizations.of(context)!;
    final benefits = [
      {'icon': Icons.block_outlined, 'title': l10n.adFreeBenefit, 'desc': l10n.adFreeBenefitDesc},
      {'icon': Icons.rocket_launch_outlined, 'title': l10n.splashAdBenefit, 'desc': l10n.splashAdBenefitDesc},
      {'icon': Icons.headset_outlined, 'title': l10n.prioritySupport, 'desc': l10n.prioritySupportDesc},
    ];

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: w * 0.06),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context)!.premiumBenefits,
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
                AppLocalizations.of(context)!.daysRemaining(membership.remainingDays.toString()),
                style: TextStyle(
                  fontSize: w * 0.04,
                  color: Colors.amber.shade800,
                  fontWeight: FontWeight.w500,
                ),
              ),
            if (membership.expireTime != null)
              Text(
                AppLocalizations.of(context)!.expireDate(membership.expireTime!.toString().substring(0, 10)),
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
                    AppLocalizations.of(context)!.autoRenew,
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
        AppLocalizations.of(context)!.subscriptionNote,
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
        final l10n = AppLocalizations.of(context)!;
        final levelName = level == MembershipLevel.premiumYearly ? l10n.yearly : l10n.monthly;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.purchaseSuccess(levelName)),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.purchaseFailed),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() { _purchasing = false; });
    }
  }

  Widget _buildPurchaseQRCodeEntry(double w) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: w * 0.08),
      child: Column(
        children: [
          Container(
            height: 1,
            color: Colors.grey.shade200,
          ),
          SizedBox(height: w * 0.04),
          TextButton.icon(
            onPressed: _showPurchaseQRDialog,
            icon: Icon(Icons.qr_code_2_outlined, size: w * 0.05, color: Colors.green.shade600),
            label: Text(
              AppLocalizations.of(context)!.scanToPurchase,
              style: TextStyle(
                fontSize: w * 0.038,
                color: Colors.green.shade600,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showPurchaseQRDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.scanToPurchase),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                AppLocalizations.of(context)!.purchaseQRHint,
                style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.asset(
                            'assets/images/alipay_qr.jpg',
                            width: 110,
                            height: 110,
                            fit: BoxFit.cover,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text('支付宝扫码', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                      ],
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.asset(
                            'assets/images/wechat_qr.jpg',
                            width: 110,
                            height: 110,
                            fit: BoxFit.cover,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text('微信扫码', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Text(
                AppLocalizations.of(context)!.purchaseQRNote,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              // 延迟一下再打开激活码对话框
              Future.delayed(const Duration(milliseconds: 300), () {
                _showActivationDialog();
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade600,
              foregroundColor: Colors.white,
            ),
            child: Text(AppLocalizations.of(context)!.activateWithCode),
          ),
        ],
      ),
    );
  }

  Widget _buildActivationCodeEntry(double w) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: w * 0.08),
      child: Column(
        children: [
          Container(
            height: 1,
            color: Colors.grey.shade200,
          ),
          SizedBox(height: w * 0.04),
          TextButton.icon(
            onPressed: _showActivationDialog,
            icon: Icon(Icons.key_outlined, size: w * 0.05, color: Colors.blue.shade600),
            label: Text(
              AppLocalizations.of(context)!.activateWithCode,
              style: TextStyle(
                fontSize: w * 0.038,
                color: Colors.blue.shade600,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showActivationDialog() {
    _activationCodeController.clear();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.activateWithCode),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              AppLocalizations.of(context)!.activateCodeHint,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _activationCodeController,
              decoration: InputDecoration(
                hintText: 'PANDA-XXXXXXXX-X',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
              textCapitalization: TextCapitalization.characters,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.5,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9\-]')),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          ElevatedButton(
            onPressed: _activating ? null : _activateCode,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade600,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: _activating
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Text(AppLocalizations.of(context)!.confirm),
          ),
        ],
      ),
    );
  }

  Future<void> _activateCode() async {
    final code = _activationCodeController.text.trim();
    if (code.isEmpty) return;

    setState(() { _activating = true; });

    try {
      final service = MembershipService();
      final result = await service.activateWithCode(code);

      if (!mounted) return;
      Navigator.pop(context); // 关闭对话框

      final l10n = AppLocalizations.of(context)!;
      String message;
      Color color;

      switch (result) {
        case 'success':
          message = l10n.activateSuccess;
          color = Colors.green;
          break;
        case 'already_used':
          message = l10n.activateAlreadyUsed;
          color = Colors.orange;
          break;
        default:
          message = l10n.activateInvalid;
          color = Colors.red;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: color,
          duration: const Duration(seconds: 2),
        ),
      );
    } finally {
      if (mounted) setState(() { _activating = false; });
    }
  }

  @override
  void dispose() {
    _activationCodeController.dispose();
    super.dispose();
  }

  Future<void> _restorePurchases() async {
    setState(() { _purchasing = true; });

    try {
      final provider = context.read<MembershipProvider>();
      final success = await provider.restorePurchases();

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.restoreSuccess),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.restoreFailed),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } finally {
      if (mounted) setState(() { _purchasing = false; });
    }
  }
}
