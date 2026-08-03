import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:video_player/video_player.dart';

import '../../providers/private_album_provider.dart';
import '../../widgets/full_screen_media_viewer.dart';

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

  final Set<String> _selectedAssetIds = {};

  bool _multiSelectMode = false;

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
        actions: [
          if (_photos.isNotEmpty)
            TextButton(
              onPressed: () {
                setState(() {
                  _multiSelectMode = !_multiSelectMode;
                  _selectedAssetIds.clear();
                });
              },
              child: Text(_multiSelectMode ? '取消' : '选择'),
            ),
        ],
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

                    // 多选模式底部工具栏
                    if (_multiSelectMode) _buildBottomToolbar(),
                  ],
                ),
    );
  }

  Widget _buildPhotoGrid(String assetId, int mediaType) {
    final isSelected = _selectedAssetIds.contains(assetId);

    return FutureBuilder<Uint8List?>(
      future: _loadThumbnail(assetId),
      builder: (context, snapshot) {
        return GestureDetector(
          onTap: () {
            if (_multiSelectMode) {
              setState(() {
                if (isSelected) {
                  _selectedAssetIds.remove(assetId);
                } else {
                  _selectedAssetIds.add(assetId);
                }
              });
            } else {
              _showPhotoPreview(assetId, mediaType);
            }
          },
          onLongPress: () {
            if (!_multiSelectMode) {
              _showPhotoOptions(assetId, mediaType);
            }
          },
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
                // 多选模式选中标记
                if (_multiSelectMode)
                  Positioned(
                    top: 4,
                    right: 4,
                    child: Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.blue : Colors.white.withValues(alpha: 0.7),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1.5),
                      ),
                      child: isSelected
                          ? const Icon(Icons.check, size: 14, color: Colors.white)
                          : null,
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showPhotoPreview(String assetId, int mediaType) {
    // 找到当前照片在列表中的索引
    final index = _photos.indexWhere((p) => p['asset_id'] == assetId);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FullScreenMediaViewer(
          mediaList: _photos,
          initialIndex: index >= 0 ? index : 0,
        ),
      ),
    );
  }

  void _showPhotoOptions(String assetId, int mediaType) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.share, color: Colors.blue),
                title: const Text('分享'),
                onTap: () async {
                  Navigator.pop(ctx);
                  await _shareSinglePhoto(assetId);
                },
              ),
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

  Future<void> _shareSinglePhoto(String assetId) async {
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

  Future<void> _shareSelectedPhotos() async {
    final List<XFile> files = [];
    for (final assetId in _selectedAssetIds) {
      final entity = await AssetEntity.fromId(assetId);
      if (entity != null) {
        final file = await entity.file;
        if (file != null) {
          files.add(XFile(file.path));
        }
      }
    }
    if (files.isNotEmpty) {
      await Share.shareXFiles(files);
    }
  }

  Future<void> _removeSelectedPhotos() async {
    final provider = context.read<PrivateAlbumProvider>();
    for (final assetId in _selectedAssetIds.toList()) {
      await provider.removePhotoFromAlbum(assetId);
    }
    setState(() {
      _selectedAssetIds.clear();
      _multiSelectMode = false;
    });
    await _loadPhotos();
  }

  Widget _buildBottomToolbar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            blurRadius: 10,
            color: Colors.black.withValues(alpha: 0.05),
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 已选数量 + 全选
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '已选 ${_selectedAssetIds.length} 项',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      final allIds = _photos.map((p) => p['asset_id'] as String).toSet();
                      if (_selectedAssetIds.length == allIds.length) {
                        _selectedAssetIds.clear();
                      } else {
                        _selectedAssetIds.addAll(allIds);
                      }
                    });
                  },
                  child: Text(
                    _selectedAssetIds.length == _photos.length ? '取消全选' : '全选',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // 操作按钮
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _selectedAssetIds.isEmpty ? null : _shareSelectedPhotos,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                    icon: const Icon(Icons.share, size: 18),
                    label: const Text('分享'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _selectedAssetIds.isEmpty ? null : _removeSelectedPhotos,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                    ),
                    icon: const Icon(Icons.logout, size: 18),
                    label: const Text('移出私密'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _imageCache.clear();

    super.dispose();
  }
}
