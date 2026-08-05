import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../data/database_helper.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/category_provider.dart';
import '../../widgets/full_screen_media_viewer.dart';

/// 已保留但未分类的照片页面
class KeptPhotosPage extends StatefulWidget {
  final int mediaType; // 0=照片, 1=视频

  const KeptPhotosPage({super.key, this.mediaType = 0});

  @override
  State<KeptPhotosPage> createState() => _KeptPhotosPageState();
}

class _KeptPhotosPageState extends State<KeptPhotosPage> {
  final DatabaseHelper _db = DatabaseHelper.instance;

  final Map<String, Uint8List> _thumbnailCache = {};

  List<Map<String, dynamic>> _photos = [];

  final Set<int> _selectedIds = {};

  bool _multiSelectMode = false;

  bool _loading = true;

  @override
  void initState() {
    super.initState();

    _loadPhotos();
  }

  Future<void> _loadPhotos() async {
    final result = await _db.getKeptUncategorizedPhotos(mediaType: widget.mediaType);

    if (!mounted) return;

    setState(() {
      _photos = result;

      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.mediaType == 0 ? AppLocalizations.of(context)!.keptPhotosTitle : AppLocalizations.of(context)!.keptVideosTitle),
        actions: [
          if (_photos.isNotEmpty)
            TextButton(
              onPressed: () {
                setState(() {
                  _multiSelectMode = !_multiSelectMode;

                  _selectedIds.clear();
                });
              },
              child: Text(_multiSelectMode ? AppLocalizations.of(context)!.cancel : AppLocalizations.of(context)!.select),
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
                        size: 80,
                        color: Colors.grey.shade300,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        widget.mediaType == 0 ? AppLocalizations.of(context)!.keptEmptyPhotos : AppLocalizations.of(context)!.keptEmptyVideos,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        AppLocalizations.of(context)!.keptEmptyHint,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade400,
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
                      color: Colors.green.withValues(alpha: 0.06),
                      child: Text(
                        widget.mediaType == 0 ? AppLocalizations.of(context)!.keptStatsPhotos(_photos.length) : AppLocalizations.of(context)!.keptStatsVideos(_photos.length),
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),

                    Expanded(child: _buildGrid()),

                    if (_multiSelectMode) _buildBottomToolbar(),
                  ],
                ),
    );
  }

  Widget _buildGrid() {
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.all(8),
          // 3列正方形网格，整齐排列
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 6,
              mainAxisSpacing: 6,
              childAspectRatio: 1.0,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                return _buildPhotoCard(_photos[index]);
              },
              childCount: _photos.length,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPhotoCard(Map<String, dynamic> photo) {
    final assetId = photo['asset_id'] as String;

    final photoId = photo['id'] as int;

    final isSelected = _selectedIds.contains(photoId);

    return GestureDetector(
      onTap: () {
        if (_multiSelectMode) {
          setState(() {
            if (isSelected) {
              _selectedIds.remove(photoId);
            } else {
              _selectedIds.add(photoId);
            }
          });
        } else {
          // 非多选模式，点击全屏放大查看
          _showFullScreenViewer(photo);
        }
      },
      onLongPress: () {
        if (!_multiSelectMode) {
          setState(() {
            _multiSelectMode = true;
            _selectedIds.add(photoId);
          });
        }
      },
      child: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.grey.shade300,
          border: isSelected
              ? Border.all(color: Colors.blue, width: 3)
              : null,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            fit: StackFit.expand,
            children: [
              _buildThumbnailImage(assetId),
              if (_multiSelectMode && isSelected)
                Positioned(
                  left: 8,
                  top: 8,
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: const BoxDecoration(
                      color: Colors.blue,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThumbnailImage(String assetId) {
    return FutureBuilder<Uint8List?>(
      future: _loadThumbnail(assetId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(
            child: Icon(Icons.image, color: Colors.grey, size: 40),
          );
        }

        return Image.memory(snapshot.data!, fit: BoxFit.cover);
      },
    );
  }

  Future<Uint8List?> _loadThumbnail(String assetId) async {
    if (_thumbnailCache.containsKey(assetId)) {
      return _thumbnailCache[assetId];
    }

    try {
      final asset = await AssetEntity.fromId(assetId);

      if (asset == null) return null;

      final data = await asset.thumbnailDataWithSize(
        const ThumbnailSize(300, 300),
      );

      if (data != null) {
        _thumbnailCache[assetId] = data;
      }

      return data;
    } catch (e) {
      return null;
    }
  }

  // 全屏查看（支持左右滑动）

  void _showFullScreenViewer(Map<String, dynamic> photo) {
    final initialIndex = _photos.indexWhere(
      (p) => p['id'] == photo['id'],
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FullScreenMediaViewer(
          mediaList: _photos,
          initialIndex: initialIndex >= 0 ? initialIndex : 0,
        ),
      ),
    );
  }

  // 单张操作菜单

  void _showSingleActionSheet(Map<String, dynamic> photo) {
    final photoId = photo['id'] as int;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 16),
              SizedBox(
                height: 120,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: _buildThumbnailImage(photo['asset_id'] as String),
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.category, color: Colors.blue),
                title: Text(AppLocalizations.of(context)!.assignToCategory),
                onTap: () {
                  Navigator.pop(sheetContext);

                  _showCategoryPicker([photoId]);
                },
              ),
              ListTile(
                leading: const Icon(Icons.undo, color: Colors.orange),
                title: Text(AppLocalizations.of(context)!.restoreToUnorganized),
                subtitle: Text(AppLocalizations.of(context)!.restoreToUnorganizedHint),
                onTap: () {
                  Navigator.pop(sheetContext);

                  _confirmRestore([photoId]);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete_forever, color: Colors.red),
                title: Text(AppLocalizations.of(context)!.moveToRecycleBin),
                onTap: () {
                  Navigator.pop(sheetContext);

                  _confirmMoveToRecycleBin([photoId]);
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  // 多选底部工具栏

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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppLocalizations.of(context)!.selectedCount(_selectedIds.length),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      final allIds = _photos.map((p) => p['id'] as int).toSet();

                      if (_selectedIds.length == allIds.length) {
                        _selectedIds.clear();
                      } else {
                        _selectedIds.addAll(allIds);
                      }
                    });
                  },
                  child: Text(
                    _selectedIds.length == _photos.length ? AppLocalizations.of(context)!.deselectAll : AppLocalizations.of(context)!.selectAllText,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _selectedIds.isEmpty
                        ? null
                        : () => _shareSelectedPhotos(_selectedIds.toList()),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                    icon: const Icon(Icons.share, size: 18),
                    label: Text(AppLocalizations.of(context)!.share),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _selectedIds.isEmpty
                        ? null
                        : () => _showCategoryPicker(_selectedIds.toList()),
                    icon: const Icon(Icons.category, size: 18),
                    label: Text(AppLocalizations.of(context)!.assignToCategory),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _selectedIds.isEmpty
                        ? null
                        : () => _confirmRestore(_selectedIds.toList()),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                    ),
                    icon: const Icon(Icons.undo, size: 18),
                    label: Text(AppLocalizations.of(context)!.restore),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _selectedIds.isEmpty
                        ? null
                        : () => _confirmMoveToRecycleBin(_selectedIds.toList()),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                    icon: const Icon(Icons.delete_forever, size: 18),
                    label: Text(AppLocalizations.of(context)!.delete),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // 分享选中的照片

  Future<void> _shareSelectedPhotos(List<int> ids) async {
    final photos = _photos.where((p) => ids.contains(p['id'] as int)).toList();
    final List<XFile> files = [];

    for (final photo in photos) {
      final assetId = photo['asset_id'] as String;
      final entity = await AssetEntity.fromId(assetId);
      if (entity != null) {
        final file = await entity.file;
        if (file != null) {
          files.add(XFile(file.path));
        }
      }
    }

    if (files.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.cannotGetFile)),
        );
      }
      return;
    }

    await Share.shareXFiles(files);
  }

  // 选择目标分类

  void _showCategoryPicker(List<int> photoIds) {
    final categoryProvider = context.read<CategoryProvider>();

    final categories = widget.mediaType == 1
        ? categoryProvider.videoCategories
        : categoryProvider.photoCategories;

    if (categories.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.createCategoryFirst)),
      );

      return;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: SizedBox(
            height: 450,
            child: Column(
              children: [
                const SizedBox(height: 20),
                Text(
                  AppLocalizations.of(context)!.assignToCategory,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  AppLocalizations.of(context)!.itemsCount(photoIds.length),
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      final item = categories[index];

                      return ListTile(
                        leading: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: _parseColor(item['color'] as String),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              item['icon'] as String,
                              style: const TextStyle(fontSize: 22),
                            ),
                          ),
                        ),
                        title: Text(item['name'] as String),
                        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                        onTap: () async {
                          await _db.batchUpdateCategory(
                            photoIds,
                            item['id'] as int,
                          );

                          if (!sheetContext.mounted) return;

                          Navigator.pop(sheetContext);

                          setState(() {
                            _multiSelectMode = false;

                            _selectedIds.clear();
                          });

                          await _loadPhotos();

                          if (!mounted) return;

                          // 刷新分类统计
                          await categoryProvider.loadCategories();

                          if (!mounted) return;

                          ScaffoldMessenger.of(this.context).showSnackBar(
                            SnackBar(
                              content: Text(AppLocalizations.of(this.context)!.assignedToCategory(item['name'])),
                              duration: const Duration(seconds: 1),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // 恢复为待整理

  void _confirmRestore(List<int> photoIds) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.restoreToUnorganized),
          content: Text(AppLocalizations.of(context)!.confirmRestoreKept(photoIds.length)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(AppLocalizations.of(context)!.cancel),
            ),
            TextButton(
              onPressed: () async {
                await _db.removeFromCategory(photoIds);

                if (!dialogContext.mounted) return;

                Navigator.pop(dialogContext);

                setState(() {
                  _multiSelectMode = false;

                  _selectedIds.clear();
                });

                await _loadPhotos();
              },
              style: TextButton.styleFrom(foregroundColor: Colors.orange),
              child: Text(AppLocalizations.of(context)!.restore),
            ),
          ],
        );
      },
    );
  }

  // 移到回收站

  void _confirmMoveToRecycleBin(List<int> photoIds) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.moveToRecycleBin),
          content: Text(AppLocalizations.of(context)!.confirmMoveToRecycleBinDetail(photoIds.length)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(AppLocalizations.of(context)!.cancel),
            ),
            TextButton(
              onPressed: () async {
                for (final id in photoIds) {
                  await _db.moveToRecycleBin(id);
                }

                if (!dialogContext.mounted) return;

                Navigator.pop(dialogContext);

                setState(() {
                  _multiSelectMode = false;

                  _selectedIds.clear();
                });

                await _loadPhotos();
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: Text(AppLocalizations.of(context)!.delete),
            ),
          ],
        );
      },
    );
  }

  Color _parseColor(String hex) {
    try {
      return Color(int.parse('FF$hex', radix: 16));
    } catch (e) {
      return Colors.blue;
    }
  }

  @override
  void dispose() {
    _thumbnailCache.clear();

    super.dispose();
  }
}
