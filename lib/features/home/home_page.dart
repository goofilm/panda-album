import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/photo_provider.dart';
import '../../providers/category_provider.dart';
import '../swipe/swipe_page.dart';
import '../categories/category_page.dart';
import '../recycle/recycle_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  late AnimationController _breathController;

  late Animation<double> _breathAnimation;

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

    final w = MediaQuery.of(context).size.width;

    // 分别计算照片和视频统计

    final photoTotal = photoProvider.imageCount;

    final videoTotal = photoProvider.videoCount;

    final photoOrganized = photoProvider.organizedPhotoCount;

    final videoOrganized = photoProvider.organizedVideoCount;

    final totalAll = photoTotal + videoTotal;

    final organizedAll = photoOrganized + videoOrganized;

    final progress = totalAll == 0 ? 0.0 : organizedAll / totalAll;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "照片整理",

          style: TextStyle(fontSize: w * 0.048),
        ),

        actions: [
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
              "整理照片",

              style: TextStyle(
                fontSize: w * 0.065,

                fontWeight: FontWeight.bold,
              ),
            ),

            SizedBox(height: w * 0.04),

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

                      value: totalAll == 0 ? 0 : progress,
                    ),
                  ),

                  Text(
                    totalAll == 0
                        ? "0%"
                        : "${(progress * 100).round()}%",

                    style: TextStyle(
                      fontSize: w * 0.055,

                      fontWeight: FontWeight.bold,

                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: w * 0.03),

            // 照片和视频分别统计

            if (!photoProvider.loading) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,

                children: [
                  _statItem(Icons.photo, "照片", photoOrganized, photoTotal, w),

                  SizedBox(width: w * 0.08),

                  Container(
                    width: 1,

                    height: w * 0.08,

                    color: Colors.grey.shade300,
                  ),

                  SizedBox(width: w * 0.08),

                  _statItem(Icons.videocam, "视频", videoOrganized, videoTotal, w),
                ],
              ),

              SizedBox(height: w * 0.02),

              Text(
                "已整理 $organizedAll 张 / 共 $totalAll 张",

                style: TextStyle(
                  fontSize: w * 0.038,

                  color: Colors.grey.shade600,
                ),
              ),
            ] else
              const Text("正在扫描..."),

            SizedBox(height: w * 0.04),

            // 开始整理按钮（居中，在统计下方）

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

            // 底部毛玻璃导航按钮（3个：分类、整理视频、回收站）

            Container(
              padding: EdgeInsets.symmetric(
                horizontal: w * 0.06,

                vertical: w * 0.03,
              ),

              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,

                children: [
                  _glassButton(
                    Icons.category,

                    "我的分类",

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
                    Icons.videocam,

                    "整理视频",

                    videoTotal,

                    () {
                      Navigator.push(
                        context,

                        MaterialPageRoute(
                          builder: (_) => const SwipePage(isVideo: true),
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

  Widget _statItem(IconData icon, String label, int organized, int total, double w) {
    return Column(
      mainAxisSize: MainAxisSize.min,

      children: [
        Icon(icon, size: w * 0.055, color: Colors.blue),

        SizedBox(height: w * 0.01),

        Text(
          "$organized / $total",

          style: TextStyle(
            fontSize: w * 0.04,

            fontWeight: FontWeight.bold,
          ),
        ),

        Text(
          label,

          style: TextStyle(
            fontSize: w * 0.03,

            color: Colors.grey,
          ),
        ),
      ],
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

            MaterialPageRoute(builder: (_) => const SwipePage()),
          );
        },

        child: Container(
          width: w * 0.20,

          height: w * 0.20,

          decoration: BoxDecoration(
            color: Colors.blue,

            shape: BoxShape.circle,

            boxShadow: [
              BoxShadow(
                blurRadius: w * 0.05,

                spreadRadius: w * 0.01,

                color: Colors.blue.withValues(alpha: 0.4),
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
