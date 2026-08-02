import 'dart:io';

import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:share_plus/share_plus.dart';
import 'package:video_player/video_player.dart';

import '../../l10n/app_localizations.dart';

/// 全屏媒体查看器 - 支持照片放大和视频播放
class FullScreenMediaViewer extends StatefulWidget {
  final List<Map<String, dynamic>> mediaList;
  final int initialIndex;

  const FullScreenMediaViewer({
    super.key,
    required this.mediaList,
    required this.initialIndex,
  });

  @override
  State<FullScreenMediaViewer> createState() =>
      _FullScreenMediaViewerState();
}

class _FullScreenMediaViewerState extends State<FullScreenMediaViewer> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _shareCurrentMedia(Map<String, dynamic> media) async {
    final assetId = media['asset_id'] as String;
    final entity = await AssetEntity.fromId(assetId);
    if (entity == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('无法获取文件')),
        );
      }
      return;
    }
    final file = await entity.file;
    if (file != null && mounted) {
      await Share.shareXFiles([XFile(file.path)]);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentMedia = widget.mediaList[_currentIndex];
    final name = currentMedia['name'] as String? ?? '';

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Column(
          children: [
            Text(
              name.isEmpty ? AppLocalizations.of(context)!.preview : name,
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
            Text(
              '${_currentIndex + 1} / ${widget.mediaList.length}',
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ],
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => _shareCurrentMedia(currentMedia),
          ),
        ],
      ),
      body: PageView.builder(
        scrollDirection: Axis.vertical,
        controller: _pageController,
        itemCount: widget.mediaList.length,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        itemBuilder: (context, index) {
          final media = widget.mediaList[index];
          return MediaPage(media: media);
        },
      ),
    );
  }
}

/// 单个媒体页面（照片或视频）
class MediaPage extends StatefulWidget {
  final Map<String, dynamic> media;

  const MediaPage({super.key, required this.media});

  @override
  State<MediaPage> createState() => _MediaPageState();
}

class _MediaPageState extends State<MediaPage> {
  File? _file;
  bool _loading = true;
  bool _isVideo = false;

  @override
  void initState() {
    super.initState();
    _loadFile();
  }

  Future<void> _loadFile() async {
    final assetId = widget.media['asset_id'] as String;
    final entity = await AssetEntity.fromId(assetId);
    if (entity == null) {
      if (mounted) setState(() => _loading = false);
      return;
    }
    _isVideo = entity.type == AssetType.video;
    final file = await entity.file;
    if (mounted) {
      setState(() {
        _file = file;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    if (_file == null) {
      return const Center(
        child: Icon(Icons.broken_image, color: Colors.white54, size: 64),
      );
    }

    if (_isVideo) {
      return VideoPlayerPage(file: _file!);
    }

    // 照片：支持双指缩放
    return Center(
      child: InteractiveViewer(
        minScale: 1.0,
        maxScale: 5.0,
        child: Image.file(_file!, fit: BoxFit.contain),
      ),
    );
  }
}

/// 视频播放页面
class VideoPlayerPage extends StatefulWidget {
  final File file;

  const VideoPlayerPage({super.key, required this.file});

  @override
  State<VideoPlayerPage> createState() => _VideoPlayerPageState();
}

class _VideoPlayerPageState extends State<VideoPlayerPage> {
  late VideoPlayerController _controller;
  bool _initialized = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.file(widget.file);
    _controller.initialize().then((_) {
      if (mounted) {
        setState(() {
          _initialized = true;
        });
        _controller.play();
      }
    }).catchError((_) {
      if (mounted) setState(() => _hasError = true);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.white54, size: 64),
            const SizedBox(height: 16),
            Text(AppLocalizations.of(context)!.videoLoadFailed, style: const TextStyle(color: Colors.white54)),
          ],
        ),
      );
    }

    if (!_initialized) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    return GestureDetector(
      onTap: () {
        setState(() {
          if (_controller.value.isPlaying) {
            _controller.pause();
          } else {
            _controller.play();
          }
        });
      },
      child: Center(
        child: AspectRatio(
          aspectRatio: _controller.value.aspectRatio,
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              VideoPlayer(_controller),
              VideoProgressIndicator(
                _controller,
                allowScrubbing: true,
                colors: const VideoProgressColors(
                  playedColor: Colors.blue,
                  bufferedColor: Colors.white30,
                  backgroundColor: Colors.white12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
