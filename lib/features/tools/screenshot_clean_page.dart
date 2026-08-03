import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:share_plus/share_plus.dart';

import '../../l10n/app_localizations.dart';

class ScreenshotCleanPage extends StatefulWidget {
  const ScreenshotCleanPage({super.key});

  @override
  State<ScreenshotCleanPage> createState() => _ScreenshotCleanPageState();
}

class _ScreenshotCleanPageState extends State<ScreenshotCleanPage> {
  AssetPathEntity? _screenshotAlbum;
  List<AssetEntity> _screenshots = [];
  bool _loading = true;
  bool _multiSelectMode = false;
  final Set<String> _selectedIds = {};
  final Map<String, Uint8List> _thumbnailCache = {};

  @override
  void initState() {
    super.initState();
    _loadScreenshots();
  }

  Future<void> _loadScreenshots() async {
    setState(() => _loading = true);

    // 获取所有相册，查找截图相册
    final albums = await PhotoManager.getAssetPathList(
      type: RequestType.common,
      hasAll: true,
    );

    AssetPathEntity? screenshotAlbum;
    for (final album in albums) {
      final name = album.name.toLowerCase();
      if (name.contains('screenshot') ||
          name.contains('截屏') ||
          name.contains('截图') ||
          name.contains('screenshots')) {
        screenshotAlbum = album;
        break;
      }
    }

    if (screenshotAlbum == null) {
      setState(() {
        _loading = false;
      });
      return;
    }

    _screenshotAlbum = screenshotAlbum;

    // 获取截图列表
    final entities = await screenshotAlbum.getAssetListRange(
      start: 0,
      end: 200, // 最多加载200张
    );

    if (!mounted) return;

    setState(() {
      _screenshots = entities;
      _loading = false;
    });
  }

  Future<Uint8List?> _loadThumbnail(AssetEntity entity) async {
    if (_thumbnailCache.containsKey(entity.id)) {
      return _thumbnailCache[entity.id];
    }

    try {
      final data = await entity.thumbnailDataWithSize(
        const ThumbnailSize(300, 300),
      );
      if (data != null) {
        _thumbnailCache[entity.id] = data;
      }
      return data;
    } catch (e) {
      return null;
    }
  }

  Future<void> _deleteSelected() async {
    if (_selectedIds.isEmpty) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('确认删除'),
        content: Text('确定要删除选中的 ${_selectedIds.length} 张截图吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('删除', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    // 删除选中的截图
    final idsToDelete = _selectedIds.toList();
    await PhotoManager.editor.deleteWithIds(idsToDelete);

    setState(() {
      _selectedIds.clear();
      _multiSelectMode = false;
    });

    await _loadScreenshots();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('已删除 ${idsToDelete.length} 张截图'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _shareSelected() async {
    if (_selectedIds.isEmpty) return;

    final List<XFile> files = [];
    for (final entity in _screenshots) {
      if (_selectedIds.contains(entity.id)) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('截图清理'),
        actions: [
          if (_screenshots.isNotEmpty)
            TextButton(
              onPressed: () {
                setState(() {
                  _multiSelectMode = !_multiSelectMode;
                  _selectedIds.clear();
                });
              },
              child: Text(_multiSelectMode ? '取消' : '选择'),
            ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _screenshots.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.check_circle_outline,
                        size: 64,
                        color: Colors.green.shade300,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        '没有找到截图',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
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
                      color: Colors.orange.withValues(alpha: 0.06),
                      child: Text(
                        '共 ${_screenshots.length} 张截图',
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
                        itemCount: _screenshots.length,
                        itemBuilder: (context, index) {
                          final entity = _screenshots[index];
                          return _buildScreenshotGrid(entity);
                        },
                      ),
                    ),
                    // 多选模式底部工具栏
                    if (_multiSelectMode) _buildBottomToolbar(),
                  ],
                ),
    );
  }

  Widget _buildScreenshotGrid(AssetEntity entity) {
    final isSelected = _selectedIds.contains(entity.id);

    return FutureBuilder<Uint8List?>(
      future: _loadThumbnail(entity),
      builder: (context, snapshot) {
        return GestureDetector(
          onTap: () {
            if (_multiSelectMode) {
              setState(() {
                if (isSelected) {
                  _selectedIds.remove(entity.id);
                } else {
                  _selectedIds.add(entity.id);
                }
              });
            }
          },
          onLongPress: () {
            if (!_multiSelectMode) {
              setState(() {
                _multiSelectMode = true;
                _selectedIds.add(entity.id);
              });
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
                // 多选模式选中标记
                if (_multiSelectMode)
                  Positioned(
                    top: 4,
                    right: 4,
                    child: Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Colors.blue
                            : Colors.white.withValues(alpha: 0.7),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1.5),
                      ),
                      child: isSelected
                          ? const Icon(Icons.check,
                              size: 14, color: Colors.white)
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
                  '已选 ${_selectedIds.length} 项',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      if (_selectedIds.length == _screenshots.length) {
                        _selectedIds.clear();
                      } else {
                        _selectedIds.addAll(
                          _screenshots.map((e) => e.id),
                        );
                      }
                    });
                  },
                  child: Text(
                    _selectedIds.length == _screenshots.length
                        ? '取消全选'
                        : '全选',
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
                    onPressed:
                        _selectedIds.isEmpty ? null : _shareSelected,
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
                    onPressed:
                        _selectedIds.isEmpty ? null : _deleteSelected,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                    icon: const Icon(Icons.delete, size: 18),
                    label: const Text('删除'),
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
    _thumbnailCache.clear();
    super.dispose();
  }
}
