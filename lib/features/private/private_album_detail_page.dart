import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

import '../../providers/private_album_provider.dart';

class PrivateAlbumDetailPage extends StatefulWidget {
  final int albumId;
  final String albumName;
  final String albumIcon;
  final Color albumColor;
  final int mediaType;

  const PrivateAlbumDetailPage({
    super.key,
    required this.albumId,
    required this.albumName,
    required this.albumIcon,
    required this.albumColor,
    required this.mediaType,
  });

  @override
  State<PrivateAlbumDetailPage> createState() =>
      _PrivateAlbumDetailPageState();
}

class _PrivateAlbumDetailPageState extends State<PrivateAlbumDetailPage> {
  List<Map<String, dynamic>> _photos = [];

  bool _loading = true;

  final Map<String, Uint8List> _imageCache = {};

  @override
  void initState() {
    super.initState();

    _loadPhotos();
  }

  Future<void> _loadPhotos() async {
    final provider = context.read<PrivateAlbumProvider>();

    _photos = await provider.getPrivatePhotos(widget.albumId);

    setState(() {
      _loading = false;
    });
  }

  Future<Uint8List?> _loadThumbnail(String assetId) async {
    if (_imageCache.containsKey(assetId)) {
      return _imageCache[assetId];
    }

    try {
      final entity = await AssetEntity.fromId(assetId);

      if (entity == null) return null;

      final data = await entity.thumbnailDataWithSize(
        const ThumbnailSize(400, 400),
      );

      if (data != null) {
        _imageCache[assetId] = data;
      }

      return data;
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PrivateAlbumProvider>();

    final count = provider.albumCounts[widget.albumId] ?? _photos.length;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(widget.albumIcon, style: const TextStyle(fontSize: 22)),
            const SizedBox(width: 8),
            Text(widget.albumName),
          ],
        ),
        centerTitle: true,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _photos.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.photo_library_outlined,
                        size: 64,
                        color: Colors.grey.shade300,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        widget.mediaType == 0
                            ? '相册中暂无私密照片'
                            : '相册中暂无私密视频',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    // 顶部统计
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      color: widget.albumColor.withValues(alpha: 0.06),
                      child: Text(
                        '共 $count 个${widget.mediaType == 0 ? "照片" : "视频"}',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),

                    // 网格列表
                    Expanded(
                      child: GridView.builder(
                        padding: const EdgeInsets.all(4),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          mainAxisSpacing: 4,
                          crossAxisSpacing: 4,
                        ),
                        itemCount: _photos.length,
                        itemBuilder: (context, index) {
                          final photo = _photos[index];
                          final assetId = photo['asset_id'] as String;
                          final mediaType = photo['media_type'] as int? ?? 0;

                          return _buildPhotoGrid(assetId, mediaType);
                        },
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildPhotoGrid(String assetId, int mediaType) {
    return FutureBuilder<Uint8List?>(
      future: _loadThumbnail(assetId),
      builder: (context, snapshot) {
        return GestureDetector(
          onLongPress: () => _showPhotoOptions(assetId),
          onTap: () => _showPhotoPreview(assetId, mediaType),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Container(
                  color: Colors.grey.shade200,
                  child: snapshot.hasData
                      ? Image.memory(
                          snapshot.data!,
                          fit: BoxFit.cover,
                        )
                      : const Center(
                          child: Icon(
                            Icons.image,
                            color: Colors.grey,
                            size: 32,
                          ),
                        ),
                ),
                // 视频右下角图标
                if (mediaType == 1)
                  Positioned(
                    right: 4,
                    bottom: 4,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Icon(
                        Icons.videocam,
                        color: Colors.white,
                        size: 14,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showPhotoPreview(String assetId, int mediaType) async {
    final entity = await AssetEntity.fromId(assetId);

    if (entity == null || !mounted) return;

    final file = await entity.file;

    if (file == null || !mounted) return;

    if (mediaType == 1) {
      // 视频播放
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => _VideoPlayerPage(file: file, title: widget.albumName),
        ),
      );
    } else {
      // 照片预览
      showDialog(
        context: context,
        builder: (ctx) {
          return Dialog(
            backgroundColor: Colors.black,
            child: Stack(
              alignment: Alignment.topRight,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(file, fit: BoxFit.contain),
                ),
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ),
              ],
            ),
          );
        },
      );
    }
  }

  void _showPhotoOptions(String assetId) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 16),
              ListTile(
                leading:
                    const Icon(Icons.logout, color: Colors.orange),
                title: const Text('移出私密相册'),
                subtitle: const Text('照片将回到待整理状态'),
                onTap: () async {
                  Navigator.pop(ctx);

                  await context
                      .read<PrivateAlbumProvider>()
                      .removePhotoFromAlbum(assetId);

                  await _loadPhotos();
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _imageCache.clear();

    super.dispose();
  }
}

// 视频播放页面

class _VideoPlayerPage extends StatefulWidget {
  final File file;
  final String title;

  const _VideoPlayerPage({required this.file, required this.title});

  @override
  State<_VideoPlayerPage> createState() => _VideoPlayerPageState();
}

class _VideoPlayerPageState extends State<_VideoPlayerPage> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();

    _controller = VideoPlayerController.file(widget.file);

    _controller.initialize().then((_) {
      _controller.play();

      setState(() {});
    });
  }

  @override
  void dispose() {
    _controller.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(widget.title, style: const TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: _controller.value.isInitialized
            ? AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: VideoPlayer(_controller),
              )
            : const CircularProgressIndicator(color: Colors.white),
      ),
    );
  }
}
