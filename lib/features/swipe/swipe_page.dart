import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:provider/provider.dart';

import '../../providers/photo_provider.dart';

class SwipePage extends StatefulWidget {
  const SwipePage({super.key});

  @override
  State<SwipePage> createState() => _SwipePageState();
}

class _SwipePageState extends State<SwipePage>
    with SingleTickerProviderStateMixin {
  double x = 0;

  double y = 0;

  double angle = 0;

  bool flying = false;

  Offset start = Offset.zero;

  late AnimationController controller;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      vsync: this,

      duration: const Duration(milliseconds: 350),
    );
  }

  @override
  void dispose() {
    controller.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PhotoProvider>();

    if (provider.photos.isEmpty) {
      return const Scaffold(body: Center(child: Text("整理完成")));
    }

    final photo = provider.photos.first;

    return Scaffold(
      appBar: AppBar(title: const Text("整理照片")),

      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Stack(
                alignment: Alignment.center,

                children: [
                  /// 后面的提示
                  Positioned(
                    left: 40,

                    child: Opacity(
                      opacity: (-x / 200).clamp(0, 1),

                      child: Column(
                        children: [
                          const Icon(
                            Icons.check_circle,

                            size: 80,

                            color: Colors.green,
                          ),

                          Text(
                            "保留",

                            style: TextStyle(
                              fontSize: 25,

                              color: Colors.green,

                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  Positioned(
                    right: 40,

                    child: Opacity(
                      opacity: (x / 200).clamp(0, 1),

                      child: Column(
                        children: [
                          const Icon(
                            Icons.delete_forever,

                            size: 80,

                            color: Colors.red,
                          ),

                          Text(
                            "删除",

                            style: TextStyle(
                              fontSize: 25,

                              color: Colors.red,

                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  GestureDetector(
                    onPanStart: (d) {
                      if (flying) return;

                      start = d.globalPosition;
                    },

                    onPanUpdate: (d) {
                      if (flying) return;

                      setState(() {
                        x = d.globalPosition.dx - start.dx;

                        y = d.globalPosition.dy - start.dy;

                        angle = x / 900;
                      });
                    },

                    onPanEnd: (d) {
                      if (flying) return;

                      if (x > 100 && y.abs() < 120) {
                        delete(provider);
                      } else if (x < -100 && y.abs() < 120) {
                        keep(provider);
                      } else if (y > 120 && x.abs() < 80) {
                        category(provider);
                      } else {
                        reset();
                      }
                    },

                    child: Transform.translate(
                      offset: Offset(x, y),

                      child: Transform.rotate(
                        angle: angle,

                        child: photoWidget(photo),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,

              children: [
                const Icon(Icons.arrow_back, color: Colors.green),

                const Text("左滑保留"),

                const SizedBox(width: 40),

                const Text("右滑删除"),

                const Icon(Icons.arrow_forward, color: Colors.red),
              ],
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget photoWidget(AssetEntity photo) {
    return FutureBuilder<Uint8List?>(
      future: photo.thumbnailDataWithSize(const ThumbnailSize(800, 800)),

      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Container(width: 330, height: 480, color: Colors.grey);
        }

        return ClipRRect(
          borderRadius: BorderRadius.circular(30),

          child: Image.memory(
            snapshot.data!,

            width: 330,

            height: 480,

            fit: BoxFit.cover,
          ),
        );
      },
    );
  }

  void keep(PhotoProvider provider) {
    flying = true;

    setState(() {
      x = -600;

      angle = -0.6;
    });

    Future.delayed(const Duration(milliseconds: 350), () {
      next(provider);
    });
  }

  void delete(PhotoProvider provider) {
    flying = true;

    setState(() {
      x = 600;

      angle = 0.6;
    });

    Future.delayed(const Duration(milliseconds: 350), () {
      next(provider);
    });
  }

  void next(PhotoProvider provider) {
    provider.photos.removeAt(0);

    provider.notifyListeners();

    setState(() {
      x = 0;

      y = 0;

      angle = 0;

      flying = false;
    });
  }

  void reset() {
    setState(() {
      x = 0;

      y = 0;

      angle = 0;
    });
  }

  void category(PhotoProvider provider) {
    showModalBottomSheet(
      context: context,

      builder: (context) {
        return SizedBox(
          height: 250,

          child: Column(
            children: [
              const SizedBox(height: 20),

              const Text(
                "选择分类",

                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),

              ListTile(
                title: const Text("💼 工作"),

                onTap: () {
                  Navigator.pop(context);

                  next(provider);
                },
              ),

              ListTile(
                title: const Text("🏠 生活"),

                onTap: () {
                  Navigator.pop(context);

                  next(provider);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
