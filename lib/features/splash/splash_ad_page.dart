import 'dart:async';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../l10n/app_localizations.dart';
import '../../services/membership_service.dart';
import '../../services/ad_service.dart';
import '../home/home_page.dart';

/// 开屏广告页
///
/// 规则：
/// - 仅冷启动显示一次（由 main.dart 控制）
/// - 会员完全跳过，直接进入首页
/// - 无广告数据时直接进入首页
/// - 3秒倒计时，可随时点击"跳过"
/// - 点击广告可跳转链接
class SplashAdPage extends StatefulWidget {
  const SplashAdPage({super.key});

  @override
  State<SplashAdPage> createState() => _SplashAdPageState();
}

class _SplashAdPageState extends State<SplashAdPage> {
  static const int _countdownSeconds = 3;

  AdData? _ad;
  int _remaining = _countdownSeconds;
  Timer? _timer;
  bool _navigated = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    // 会员直接进首页
    final isPremium = await MembershipService().isPremium();
    if (isPremium) {
      _goHome();
      return;
    }

    // 获取开屏广告（使用缓存数据，避免阻塞启动）
    final ad = await AdService.getAd(position: 'splash');
    if (!mounted) return;

    if (ad == null || ad.imageUrl.isEmpty) {
      _goHome();
      return;
    }

    setState(() => _ad = ad);
    _startCountdown();
  }

  void _startCountdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_remaining <= 1) {
        timer.cancel();
        _goHome();
      } else {
        setState(() => _remaining--);
      }
    });
  }

  void _goHome() {
    if (_navigated || !mounted) return;
    _navigated = true;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const HomePage()),
    );
  }

  Future<void> _openAdLink() async {
    final link = _ad?.linkUrl ?? '';
    if (link.isEmpty) return;
    try {
      final uri = Uri.parse(link);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      // 静默失败
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    // 广告未加载时显示品牌闪屏
    if (_ad == null) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/mascot_panda.png',
                width: 120,
                height: 120,
                errorBuilder: (_, __, ___) => Icon(
                  Icons.photo_album_outlined,
                  size: 100,
                  color: Colors.blue.shade300,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                l10n.appTitle,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade700,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // 开屏广告
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 广告图片（点击跳转）
          GestureDetector(
            onTap: _openAdLink,
            child: Image.network(
              _ad!.imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) {
                // 图片加载失败，直接进首页
                WidgetsBinding.instance.addPostFrameCallback((_) => _goHome());
                return const SizedBox.shrink();
              },
            ),
          ),

          // 跳过按钮
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            right: 16,
            child: GestureDetector(
              onTap: _goHome,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  l10n.skipAd(_remaining.toString()),
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                ),
              ),
            ),
          ),

          // 底部广告标识
          Positioned(
            bottom: MediaQuery.of(context).padding.bottom + 12,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.black38,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  '广告',
                  style: TextStyle(color: Colors.white70, fontSize: 11),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
