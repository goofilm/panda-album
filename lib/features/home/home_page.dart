import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/photo_provider.dart';
import '../../providers/category_provider.dart';
import '../../providers/private_album_provider.dart';
import '../swipe/swipe_page.dart';
import '../categories/category_page.dart';
import '../recycle/recycle_page.dart';
import '../private/private_lock_page.dart';
import '../search/search_page.dart';

import '../../features/categories/kept_photos_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  late AnimationController _breathController;

  late Animation<double> _breathAnimation;

  /// 0=照片整理, 1=视频整理
  int _mode = 0;

  @override
  void initState() {
    super.initState();

    _breathController = AnimationController(
      vsync: this,

      duration: const Duration(milliseconds: 2000),
    );

    _breathAnimation = Tween<double>(begin: 1.0, end: 1.12).animate(
      CurvedAnimation(parent: _breathController, curve: Curves.easeInOut),
    );

    _breathController.repeat(reverse: true);

    // 只在首次加载时初始化数据
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<PhotoProvider>();

      if (!provider.loading) {
        provider.loadPhotos();
      }
    });
  }

  @override
  void dispose() {
    _breathController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final photoProvider = context.watch<PhotoProvider>();

    final categoryProvider = context.watch<CategoryProvider>();

    final privateProvider = context.watch<PrivateAlbumProvider>();

    final w = MediaQuery.of(context).size.width;

    // 分别计算照片和视频统计

    final photoTotal = photoProvider.imageCount;

    final videoTotal = photoProvider.videoCount;

    final photoOrganized = photoProvider.organizedPhotoCount;

    final videoOrganized = photoProvider.organizedVideoCount;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "照片整理",

          style: TextStyle(fontSize: w * 0.048),
        ),

        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SearchPage()),
              );
            },
          ),

          IconButton(icon: const Icon(Icons.language), onPressed: () {}),

          IconButton(
            icon: const Icon(Icons.workspace_premium),

            onPressed: () {},
          ),
        ],
      ),

      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: w * 0.04),

            // 熊猫吸睛

            Image.asset(
              'assets/images/mascot_panda.png',

              width: w * 0.28,

              height: w * 0.28,

              fit: BoxFit.contain,
            ),

            SizedBox(height: w * 0.02),

            Text(
              "熊猫相册",

              style: TextStyle(
                fontSize: w * 0.065,

                fontWeight: FontWeight.bold,
              ),
            ),

            // 照片/视频切换标签

            _buildModeToggle(w, photoTotal, videoTotal),

            SizedBox(height: w * 0.03),

            // 进度环

            SizedBox(
              width: w * 0.32,

              height: w * 0.32,

              child: Stack(
                alignment: Alignment.center,

                children: [
                  SizedBox(
                    width: w * 0.32,

                    height: w * 0.32,

                    child: CircularProgressIndicator(
                      strokeWidth: w * 0.025,

                      value: _mode == 0
                          ? (photoTotal == 0 ? 0 : photoOrganized / photoTotal)
                          : (videoTotal == 0 ? 0 : videoOrganized / videoTotal),
                    ),
                  ),

                  Text(
                    _mode == 0
                        ? (photoTotal == 0 ? "0%" : "${((photoOrganized / photoTotal) * 100).round()}%")
                        : (videoTotal == 0 ? "0%" : "${((videoOrganized / videoTotal) * 100).round()}%"),

                    style: TextStyle(
                      fontSize: w * 0.055,

                      fontWeight: FontWeight.bold,

                      color: _mode == 0 ? Colors.blue : Colors.orange,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: w * 0.025),

            // 当前模式统计

            if (!photoProvider.loading)
              Text(
                _mode == 0
                    ? "已整理 $photoOrganized 张 / 共 $photoTotal 张"
                    : "已整理 $videoOrganized 个 / 共 $videoTotal 个",

                style: TextStyle(
                  fontSize: w * 0.035,

                  color: Colors.grey.shade600,
                ),
              )
            else
              const Text("正在扫描..."),

            SizedBox(height: w * 0.04),

            // 开始整理按钮

            _breathingButton(),

            SizedBox(height: w * 0.02),

            Text(
              "左滑保留 · 右滑删除 · 下滑分类",

              style: TextStyle(
                fontSize: w * 0.03,

                color: Colors.grey.shade500,
              ),
            ),

            const Spacer(),

            // 底部毛玻璃导航按钮

            Container(
              padding: EdgeInsets.symmetric(
                horizontal: w * 0.04,

                vertical: w * 0.03,
              ),

              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,

                children: [
                  _glassButton(
                    Icons.category,

                    "分类",

                    categoryProvider.categories.length,

                    () {
                      Navigator.push(
                        context,

                        MaterialPageRoute(
                          builder: (_) => const CategoryPage(),
                        ),
                      );
                    },
                  ),

                  _glassButton(
                    Icons.check_circle,

                    "已保留",

                    _mode == 0
                        ? categoryProvider.photoKeptCount
                        : categoryProvider.videoKeptCount,

                    () {
                      Navigator.push(
                        context,

                        MaterialPageRoute(
                          builder: (_) => KeptPhotosPage(mediaType: _mode),
                        ),
                      );
                    },
                  ),

                  _glassButton(
                    Icons.lock_outline,

                    "私密",

                    privateProvider.totalPrivateCount,

                    () {
                      Navigator.push(
                        context,

                        MaterialPageRoute(
                          builder: (_) => const PrivateLockPage(),
                        ),
                      );
                    },
                  ),

                  _glassButton(
                    Icons.delete,

                    "回收站",

                    photoProvider.recycleBinCount,

                    () {
                      Navigator.push(
                        context,

                        MaterialPageRoute(
                          builder: (_) => const RecyclePage(),
                        ),
                      );
                    },

                    isRecycle: true,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 照片/视频切换标签

  Widget _buildModeToggle(double w, int photoTotal, int videoTotal) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(25),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _modeTab(Icons.photo, "照片", photoTotal, 0, w),
          _modeTab(Icons.videocam, "视频", videoTotal, 1, w),
        ],
      ),
    );
  }

  Widget _modeTab(IconData icon, String label, int total, int mode, double w) {
    final isActive = _mode == mode;
    final activeColor = mode == 0 ? Colors.blue : Colors.orange;

    return GestureDetector(
      onTap: () => setState(() => _mode = mode),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          horizontal: w * 0.06,
          vertical: w * 0.02,
        ),
        decoration: BoxDecoration(
          color: isActive ? activeColor : Colors.transparent,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: w * 0.04, color: isActive ? Colors.white : Colors.grey),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: w * 0.035,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                color: isActive ? Colors.white : Colors.grey.shade600,
              ),
            ),
            if (total > 0) ...[
              const SizedBox(width: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                decoration: BoxDecoration(
                  color: isActive
                      ? Colors.white.withValues(alpha: 0.3)
                      : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$total',
                  style: TextStyle(
                    fontSize: w * 0.025,
                    fontWeight: FontWeight.bold,
                    color: isActive ? Colors.white : Colors.grey.shade600,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _glassButton(
    IconData icon,

    String label,

    int badgeCount,

    VoidCallback onTap, {
    bool isRecycle = false,
  }) {
    final w = MediaQuery.of(context).size.width;

    return GestureDetector(
      onTap: onTap,

      child: Column(
        mainAxisSize: MainAxisSize.min,

        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(w * 0.05),

            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),

              child: Container(
                width: w * 0.15,

                height: w * 0.15,

                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.25),

                  borderRadius: BorderRadius.circular(w * 0.05),

                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.4),

                    width: 1,
                  ),
                ),

                child: Stack(
                  alignment: Alignment.center,

                  children: [
                    Icon(icon, size: w * 0.065, color: Colors.grey.shade700),

                    if (badgeCount > 0 && !isRecycle)
                      Positioned(
                        right: 4,

                        top: 4,

                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 5,

                            vertical: 1,
                          ),

                          decoration: BoxDecoration(
                            color: Colors.blue,

                            borderRadius: BorderRadius.circular(10),
                          ),

                          child: Text(
                            "$badgeCount",

                            style: TextStyle(
                              color: Colors.white,

                              fontSize: w * 0.025,

                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),

                    if (badgeCount > 0 && isRecycle)
                      Positioned(
                        right: 6,

                        top: 6,

                        child: Container(
                          width: w * 0.025,

                          height: w * 0.025,

                          decoration: const BoxDecoration(
                            color: Colors.red,

                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),

          SizedBox(height: w * 0.015),

          Text(
            isRecycle && badgeCount > 0 ? "$label($badgeCount)" : label,

            style: TextStyle(fontSize: w * 0.03),
          ),
        ],
      ),
    );
  }

  Widget _breathingButton() {
    final w = MediaQuery.of(context).size.width;

    final color = _mode == 0 ? Colors.blue : Colors.orange;

    return AnimatedBuilder(
      animation: _breathAnimation,

      builder: (context, child) {
        return Transform.scale(
          scale: _breathAnimation.value,

          child: child,
        );
      },

      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,

            MaterialPageRoute(
              builder: (_) => SwipePage(isVideo: _mode == 1),
            ),
          );
        },

        child: Container(
          width: w * 0.20,

          height: w * 0.20,

          decoration: BoxDecoration(
            color: color,

            shape: BoxShape.circle,

            boxShadow: [
              BoxShadow(
                blurRadius: w * 0.05,

                spreadRadius: w * 0.01,

                color: color.withValues(alpha: 0.4),
              ),
            ],
          ),

          child: Icon(
            Icons.play_arrow,

            size: w * 0.10,

            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
