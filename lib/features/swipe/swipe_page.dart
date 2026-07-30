import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:provider/provider.dart';

import '../../providers/photo_provider.dart';
import '../../providers/category_provider.dart';

class SwipePage extends StatefulWidget {
  const SwipePage({super.key});

  @override
  State<SwipePage> createState() => _SwipePageState();
}

class _SwipePageState extends State<SwipePage> {
  final Map<String, Uint8List> imageCache = {};

  double offsetX = 0;

  double offsetY = 0;

  double rotation = 0;

  Offset startOffset = Offset.zero;

  bool isFlying = false;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PhotoProvider>();

    if (provider.photos.length > 1) {
      preloadImage(provider.photos[1]);
    }

    if (provider.photos.isEmpty) {
      return const Scaffold(body: Center(child: Text("整理完成")));
    }

    return Scaffold(
      appBar: AppBar(title: const Text("整理照片")),

      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Stack(
                alignment: Alignment.center,

                children: [
                  if (provider.photos.length > 1)
                    AnimatedScale(
                      duration: const Duration(milliseconds: 200),

                      scale: offsetX.abs() > 30 ? 1 : 0.93,

                      child: Transform.translate(
                        offset: const Offset(0, 25),

                        child: buildCard(provider.photos[1], opacity: 0.8),
                      ),
                    ),

                  GestureDetector(
                    onPanStart: (detail) {
                      if (isFlying) {
                        return;
                      }

                      startOffset = detail.globalPosition;
                    },

                    onPanUpdate: (detail) {
                      if (isFlying) {
                        return;
                      }

                      final current = detail.globalPosition;

                      setState(() {
                        offsetX = current.dx - startOffset.dx;

                        offsetY = current.dy - startOffset.dy;

                        rotation = offsetX / 850;
                      });
                    },

                    onPanEnd: (detail) {
                      if (isFlying) {
                        return;
                      }

                      final speedX = detail.velocity.pixelsPerSecond.dx;

                      final speedY = detail.velocity.pixelsPerSecond.dy;

                      if ((offsetX > 80 && offsetY.abs() < 50) ||
                          speedX > 800) {
                        deletePhoto(provider);
                      } else if ((offsetX < -80 && offsetY.abs() < 50) ||
                          speedX < -800) {
                        keepPhoto(provider);
                      } else if ((offsetY > 100 && offsetX.abs() < 50) ||
                          (speedY > 900 && offsetX.abs() < 50)) {
                        showCategory(provider);
                      } else {
                        resetCard();
                      }
                    },

                    child: Transform.translate(
                      offset: Offset(offsetX, offsetY),

                      child: Transform.rotate(
                        angle: rotation,

                        child: buildCard(provider.photos[0]),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            buildBottomButtons(),
          ],
        ),
      ),
    );
  }

  Widget buildCard(AssetEntity photo, {double opacity = 1}) {
    return FutureBuilder<Uint8List?>(
      future: loadThumbnail(photo),

      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Container(
            width: 330,

            height: 480,

            decoration: BoxDecoration(
              color: Colors.grey.shade300,

              borderRadius: BorderRadius.circular(30),
            ),
          );
        }

        return Opacity(
          opacity: opacity,

          child: Container(
            width: 330,

            height: 480,

            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),

              boxShadow: [
                const BoxShadow(
                  blurRadius: 25,

                  spreadRadius: 3,

                  color: Colors.black26,
                ),
              ],
            ),

            child: ClipRRect(
              borderRadius: BorderRadius.circular(30),

              child: Image.memory(snapshot.data!, fit: BoxFit.cover),
            ),
          ),
        );
      },
    );
  }

  Future<Uint8List?> loadThumbnail(AssetEntity photo) async {
    if (imageCache.containsKey(photo.id)) {
      return imageCache[photo.id];
    }

    final data = await photo.thumbnailDataWithSize(
      const ThumbnailSize(700, 700),
    );

    if (data != null) {
      imageCache[photo.id] = data;
    }

    return data;
  }

  void preloadImage(AssetEntity photo) async {
    if (imageCache.containsKey(photo.id)) {
      return;
    }

    final data = await photo.thumbnailDataWithSize(
      const ThumbnailSize(700, 700),
    );

    if (data != null) {
      imageCache[photo.id] = data;
    }
  }

  Widget buildBottomButtons() {
    final keepScale = (-offsetX / 120).clamp(0.0, 1.0);

    final deleteScale = (offsetX / 120).clamp(0.0, 1.0);

    return Padding(
      padding: const EdgeInsets.only(bottom: 25, top: 15),

      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,

        children: [
          AnimatedScale(
            scale: 1 + keepScale * 0.35,

            duration: const Duration(milliseconds: 150),

            child: Column(
              children: [
                const Icon(Icons.check_circle, size: 45, color: Colors.green),

                const Text(
                  "保留",

                  style: TextStyle(
                    color: Colors.green,

                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          AnimatedScale(
            scale: 1 + deleteScale * 0.35,

            duration: const Duration(milliseconds: 150),

            child: Column(
              children: [
                const Icon(Icons.delete_forever, size: 45, color: Colors.red),

                const Text(
                  "删除",

                  style: TextStyle(
                    color: Colors.red,

                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void keepPhoto(PhotoProvider provider) {
    flyOut(provider, -1);
  }

  void deletePhoto(PhotoProvider provider) {
    flyOut(provider, 1);
  }

  void flyOut(PhotoProvider provider, int direction) {
    setState(() {
      isFlying = true;

      offsetX = direction * MediaQuery.of(context).size.width * 1.3;

      rotation = direction * 0.6;
    });

    Future.delayed(const Duration(milliseconds: 350), () {
      if (!mounted) {
        return;
      }

      provider.removeCurrentPhoto();

      setState(() {
        offsetX = 0;

        offsetY = 0;

        rotation = 0;

        isFlying = false;
      });
    });
  }

  void resetCard() {
    setState(() {
      offsetX = 0;

      offsetY = 0;

      rotation = 0;
    });
  }

  void showCategory(PhotoProvider provider) {
    final categoryProvider = context.read<CategoryProvider>();

    final categories = categoryProvider.categories;

    showModalBottomSheet(
      context: context,

      backgroundColor: Colors.white,

      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),

      builder: (context) {
        return SizedBox(
          height: 450,

          child: Column(
            children: [
              const SizedBox(height: 20),

              const Text(
                "选择分类",

                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),

              Expanded(
                child: ListView.builder(
                  itemCount: categories.length,

                  itemBuilder: (context, index) {
                    final item = categories[index];

                    return ListTile(
                      leading: Text(
                        item['icon'],

                        style: const TextStyle(fontSize: 30),
                      ),

                      title: Text(item['name']),

                      onTap: () {
                        Navigator.pop(context);

                        setState(() {
                          offsetX = 0;

                          offsetY = 0;

                          rotation = 0;
                        });

                        provider.removeCurrentPhoto();
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
