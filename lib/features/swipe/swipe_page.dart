import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

import '../../data/database_helper.dart';
import '../../providers/photo_provider.dart';
import '../../providers/category_provider.dart';
import '../categories/category_page.dart';

class SwipePage extends StatefulWidget {
  final bool isVideo;

  const SwipePage({super.key, this.isVideo = false});

  @override
  State<SwipePage> createState() => _SwipePageState();
}

class _SwipePageState extends State<SwipePage> {
  final Map<String, Uint8List> imageCache = {};

  final DatabaseHelper _db = DatabaseHelper.instance;

  double offsetX = 0;

  double offsetY = 0;

  double rotation = 0;

  Offset startOffset = Offset.zero;

  bool isFlying = false;

  /// 上一次移除的照片（用于撤销）

  AssetEntity? _lastRemovedPhoto;

  /// 上一次操作类型：keep / delete / category

  String? _lastAction;

  /// 获取当前列表

  List<AssetEntity> _getList(PhotoProvider provider) {
    return widget.isVideo ? provider.videos : provider.photos;
  }

  @override
  void initState() {
    super.initState();

    // 列表为空但还有更多照片时，自动加载更多

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<PhotoProvider>();

      final list = _getList(provider);

      if (list.isEmpty && provider.hasMore) {
        provider.loadMorePhotos();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PhotoProvider>();

    final list = _getList(provider);

    if (list.length > 1) {
      preloadImage(list[1]);
    }

    if (list.isEmpty) {
      // 还有更多照片未加载，显示加载中并自动加载更多

      if (provider.hasMore) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            context.read<PhotoProvider>().loadMorePhotos();
          }
        });

        return Scaffold(
          appBar: AppBar(
            title: Text(widget.isVideo ? "整理视频" : "整理照片"),
          ),

          body: const Center(child: CircularProgressIndicator()),
        );
      }

      return Scaffold(
        appBar: AppBar(
          title: Text(widget.isVideo ? "整理视频" : "整理照片"),
        ),

        body: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),

            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,

              children: [
                // 熊猫插画

                Image.asset(
                  'assets/images/mascot_panda.png',

                  width: 160,

                  height: 160,

                  fit: BoxFit.contain,
                ),

                const SizedBox(height: 24),

                Text(
                  widget.isVideo ? "视频全部整理完成 🎉" : "照片全部整理完成 🎉",

                  style: const TextStyle(
                    fontSize: 22,

                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 12),

                Text(
                  widget.isVideo
                      ? "所有视频已处理，可下方去视频分类查看"
                      : "所有照片已处理，可下方去分类查看",

                  style: TextStyle(
                    fontSize: 15,

                    color: Colors.grey.shade500,
                  ),

                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 36),

                // 去分类管理

                SizedBox(
                  width: double.infinity,

                  child: FilledButton.icon(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,

                        MaterialPageRoute(
                          builder: (_) => const CategoryPage(),
                        ),
                      );
                    },

                    icon: const Icon(Icons.category),

                    label: Text(
                      widget.isVideo ? "查看视频分类" : "查看分类",

                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // 返回首页

                SizedBox(
                  width: double.infinity,

                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.pop(context),

                    icon: const Icon(Icons.home_outlined),

                    label: const Text(
                      "返回首页",

                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(widget.isVideo ? "整理视频" : "整理照片")),

      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Stack(
                alignment: Alignment.center,

                children: [
                  if (list.length > 1)
                    AnimatedScale(
                      duration: const Duration(milliseconds: 200),

                      scale: offsetX.abs() > 30 ? 1 : 0.93,

                      child: Transform.translate(
                        offset: const Offset(0, 25),

                        child: buildCard(list[1], opacity: 0.8),
                      ),
                    ),

                  GestureDetector(
                    onPanStart: (detail) {
                      if (isFlying) return;

                      startOffset = detail.globalPosition;
                    },

                    onPanUpdate: (detail) {
                      if (isFlying) return;

                      final current = detail.globalPosition;

                      setState(() {
                        offsetX = current.dx - startOffset.dx;

                        offsetY = current.dy - startOffset.dy;

                        rotation = offsetX / 850;
                      });
                    },

                    onPanEnd: (detail) {
                      if (isFlying) return;

                      final speedX = detail.velocity.pixelsPerSecond.dx;

                      final speedY = detail.velocity.pixelsPerSecond.dy;

                      if ((offsetX < -80 && offsetY.abs() < 50) ||
                          speedX < -800) {
                        keepPhoto(provider);
                      } else if ((offsetX > 80 && offsetY.abs() < 50) ||
                          speedX > 800) {
                        deletePhoto(provider);
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

                        child: buildCard(list[0]),
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

        final isVideoAsset = photo.type == AssetType.video;

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

              child: Stack(
                fit: StackFit.expand,

                children: [
                  Image.memory(snapshot.data!, fit: BoxFit.cover),

                  // 视频播放按钮（居中，可点击播放）

                  if (isVideoAsset)
                    Center(
                      child: GestureDetector(
                        onTap: () => _playVideo(photo),

                        child: Container(
                          width: 70,

                          height: 70,

                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.5),

                            shape: BoxShape.circle,
                          ),

                          child: const Icon(
                            Icons.play_arrow,

                            color: Colors.white,

                            size: 42,
                          ),
                        ),
                      ),
                    ),

                  // 左下角小播放图标

                  if (isVideoAsset)
                    Positioned(
                      left: 16,

                      bottom: 16,

                      child: Container(
                        padding: const EdgeInsets.all(6),

                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.6),

                          shape: BoxShape.circle,
                        ),

                        child: const Icon(
                          Icons.videocam,

                          color: Colors.white,

                          size: 20,
                        ),
                      ),
                    ),

                  // 视频时长标签

                  if (isVideoAsset && photo.duration > 0)
                    Positioned(
                      right: 16,

                      bottom: 16,

                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,

                          vertical: 4,
                        ),

                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.6),

                          borderRadius: BorderRadius.circular(6),
                        ),

                        child: Text(
                          _formatDuration(photo.duration),

                          style: const TextStyle(
                            color: Colors.white,

                            fontSize: 13,

                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // 播放视频

  void _playVideo(AssetEntity asset) async {
    // 获取视频原始文件

    final file = await asset.file;

    if (file == null || !mounted) return;

    // 弹出全屏视频播放对话框

    if (!mounted) return;

    showDialog(
      context: context,

      builder: (dialogContext) {
        return _VideoPlayerDialog(file: file);
      },
    );
  }

  String _formatDuration(int seconds) {
    final m = seconds ~/ 60;

    final s = seconds % 60;

    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
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
    if (imageCache.containsKey(photo.id)) return;

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

  void keepPhoto(PhotoProvider provider) async {
    final list = _getList(provider);

    if (list.isEmpty) return;

    final photo = list.first;

    _lastRemovedPhoto = photo;

    _lastAction = 'keep';

    final mediaType = widget.isVideo ? 1 : 0;

    await _db.addPhoto(assetId: photo.id, status: 1, mediaType: mediaType);

    flyOut(provider, -1);
  }

  void deletePhoto(PhotoProvider provider) async {
    final list = _getList(provider);

    if (list.isEmpty) return;

    final photo = list.first;

    _lastRemovedPhoto = photo;

    _lastAction = 'delete';

    final mediaType = widget.isVideo ? 1 : 0;

    final photoId = await _db.addPhoto(
      assetId: photo.id,

      status: 0,

      mediaType: mediaType,
    );

    await _db.moveToRecycleBin(photoId);

    flyOut(provider, 1);
  }

  void flyOut(PhotoProvider provider, int direction) {
    setState(() {
      isFlying = true;

      offsetX = direction * MediaQuery.of(context).size.width * 1.3;

      rotation = direction * 0.6;
    });

    Future.delayed(const Duration(milliseconds: 350), () async {
      if (!mounted) return;

      await provider.removeCurrentPhoto(isVideo: widget.isVideo);

      if (!mounted) return;

      await provider.refreshStats();

      if (!mounted) return;

      setState(() {
        offsetX = 0;

        offsetY = 0;

        rotation = 0;

        isFlying = false;
      });

      // 显示撤销 SnackBar

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("已操作"),

          duration: const Duration(seconds: 3),

          action: SnackBarAction(
            label: "撤销",

            onPressed: _undoLastAction,
          ),
        ),
      );
    });
  }

  void resetCard() {
    setState(() {
      offsetX = 0;

      offsetY = 0;

      rotation = 0;
    });
  }

  /// 撤销上一次操作

  Future<void> _undoLastAction() async {
    if (_lastRemovedPhoto == null || _lastAction == null) return;

    final photo = _lastRemovedPhoto!;

    final action = _lastAction!;

    _lastRemovedPhoto = null;

    _lastAction = null;

    final provider = context.read<PhotoProvider>();

    // 撤销数据库操作

    if (action == 'delete') {
      // 删除→回收站：恢复为待整理状态

      await _db.addPhoto(
        assetId: photo.id,

        status: 0,

        mediaType: widget.isVideo ? 1 : 0,
      );
    } else {
      // 保留或分类：重置为待整理状态

      await _db.addPhoto(
        assetId: photo.id,

        status: 0,

        mediaType: widget.isVideo ? 1 : 0,
      );
    }

    // 重新插入列表头部

    provider.reinsertPhoto(photo, isVideo: widget.isVideo);

    await provider.refreshStats();
  }

  void showCategory(PhotoProvider provider) {
    final categoryProvider = context.read<CategoryProvider>();

    final categories = widget.isVideo
        ? categoryProvider.videoCategories
        : categoryProvider.photoCategories;

    final mediaType = widget.isVideo ? 1 : 0;

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

              Text(
                widget.isVideo ? "选择视频分类" : "选择分类",

                style: const TextStyle(
                  fontSize: 22,

                  fontWeight: FontWeight.bold,
                ),
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

                      onTap: () async {
                        final list = _getList(provider);

                        if (list.isEmpty) return;

                        final photo = list.first;

                        _lastRemovedPhoto = photo;

                        _lastAction = 'category';

                        await _db.addPhoto(
                          assetId: photo.id,

                          categoryId: item['id'],

                          status: 1,

                          mediaType: mediaType,
                        );

                        if (!context.mounted) return;

                        Navigator.pop(context);

                        setState(() {
                          offsetX = 0;

                          offsetY = 0;

                          rotation = 0;
                        });

                        await provider.removeCurrentPhoto(
                          isVideo: widget.isVideo,
                        );

                        await provider.refreshStats();
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

/// 全屏视频播放对话框

class _VideoPlayerDialog extends StatefulWidget {
  final File file;

  const _VideoPlayerDialog({required this.file});

  @override
  State<_VideoPlayerDialog> createState() => _VideoPlayerDialogState();
}

class _VideoPlayerDialogState extends State<_VideoPlayerDialog> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();

    _controller = VideoPlayerController.file(widget.file);

    _controller.initialize().then((_) {
      setState(() {});

      _controller.play();
    });
  }

  @override
  void dispose() {
    _controller.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    final maxVideoHeight = screenHeight * 0.6;

    return Dialog(
      backgroundColor: Colors.black,

      insetPadding: const EdgeInsets.all(16),

      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),

        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: screenHeight * 0.8,
          ),

          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,

              children: [
                // 关闭按钮

                Row(
                  mainAxisAlignment: MainAxisAlignment.end,

                  children: [
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),

                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),

                // 视频播放器

                if (_controller.value.isInitialized)
                  ConstrainedBox(
                    constraints: BoxConstraints(maxHeight: maxVideoHeight),

                    child: AspectRatio(
                      aspectRatio: _controller.value.aspectRatio,

                      child: VideoPlayer(_controller),
                    ),
                  )
                else
                  const AspectRatio(
                    aspectRatio: 16 / 9,

                    child: Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    ),
                  ),

                // 控制条

                if (_controller.value.isInitialized)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,

                      vertical: 8,
                    ),

                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _controller.value.isPlaying
                                  ? _controller.pause()
                                  : _controller.play();
                            });
                          },

                          child: Icon(
                            _controller.value.isPlaying
                                ? Icons.pause
                                : Icons.play_arrow,

                            color: Colors.white,

                            size: 36,
                          ),
                        ),

                        const SizedBox(width: 12),

                        Expanded(
                          child: VideoProgressIndicator(
                            _controller,

                            allowScrubbing: true,

                            colors: const VideoProgressColors(
                              playedColor: Colors.blue,

                              bufferedColor: Colors.grey,

                              backgroundColor: Colors.white24,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
