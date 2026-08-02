import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/membership_provider.dart';
import '../services/ad_service.dart';

/// 广告位组件 - 支持自投放广告
/// 
/// 功能：
/// - 会员用户自动隐藏
/// - 从服务器获取自投放广告
/// - 无广告时显示占位条
/// - 点击广告可跳转链接
class AdBanner extends StatefulWidget {
  /// 广告位标识
  final String position;
  
  /// 广告条高度
  final double height;
  
  /// 无广告时的占位文字
  final String placeholderText;

  const AdBanner({
    super.key,
    this.position = 'default',
    this.height = 60,
    this.placeholderText = '广告位',
  });

  @override
  State<AdBanner> createState() => _AdBannerState();
}

class _AdBannerState extends State<AdBanner> {
  AdData? _adData;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _loadAd();
  }

  Future<void> _loadAd() async {
    final ad = await AdService.getAd(position: widget.position);
    if (mounted) {
      setState(() {
        _adData = ad;
        _loaded = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MembershipProvider>(
      builder: (context, membership, _) {
        // 会员用户不显示广告
        if (membership.isPremium) {
          return const SizedBox.shrink();
        }

        // 有广告数据，显示真实广告
        if (_adData != null && _adData!.imageUrl.isNotEmpty) {
          return _buildRealAd();
        }

        // 加载中或无广告，显示占位条
        return _buildPlaceholder();
      },
    );
  }

  /// 显示真实广告
  Widget _buildRealAd() {
    return GestureDetector(
      onTap: () async {
        if (_adData!.linkUrl.isNotEmpty) {
          final uri = Uri.tryParse(_adData!.linkUrl);
          if (uri != null) {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
          }
        }
      },
      child: Container(
        width: double.infinity,
        height: widget.height,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            _adData!.imageUrl,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return _buildPlaceholder();
            },
            errorBuilder: (context, error, stackTrace) {
              return _buildPlaceholder();
            },
          ),
        ),
      ),
    );
  }

  /// 显示占位条
  Widget _buildPlaceholder() {
    return Container(
      width: double.infinity,
      height: widget.height,
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
              widget.placeholderText,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
