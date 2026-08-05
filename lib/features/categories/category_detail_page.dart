import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:video_player/video_player.dart';

import '../../data/database_helper.dart';
import '../../widgets/full_screen_media_viewer.dart';
import '../../providers/photo_provider.dart';
import '../../providers/category_provider.dart';
import '../../l10n/app_localizations.dart';

class CategoryDetailPage extends StatefulWidget {
  final Map<String, dynamic> category;

  const CategoryDetailPage({super.key, required this.category});

  @override
  State<CategoryDetailPage> createState() => _CategoryDetailPageState();
}

class _CategoryDetailPageState extends State<CategoryDetailPage> {
  final DatabaseHelper _db = DatabaseHelper.instance;

  final Map<String, Uint8List> _thumbnailCache = {};

  List<Map<String, dynamic>> _photos = [];

  final Set<int> _selectedIds = {};

  bool _multiSelectMode = false;

  bool _loading = true;

  /// 当前分类的媒体类型

  int get _mediaType => (widget.category['media_type'] ?? 0) as int;

  @override
  void initState() {
    super.initState();

    _loadPhotos();
  }

  Future<void> _loadPhotos() async {
    final categoryId = widget.category['id'] as int;

    final result = await _db.getPhotosByCategory(categoryId);

    if (!mounted) return;

    setState(() {
      _photos = result;

      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final categoryName = DatabaseHelper.getCategoryName(widget.category, AppLocalizations.of(context)!);

    final icon = widget.category['icon'] as String;

    return Scaffold(
      appBar: AppBar(
        title: Text("$icon $categoryName"),

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
                      const Icon(Icons.photo_library_outlined, size: 80, color: Colors.grey),
              
                      const SizedBox(height: 16),
              
                      Text(AppLocalizations.of(context)!.noPhotos, style: const TextStyle(fontSize: 18, color: Colors.grey)),
                    ],
                  ),
                )
              : Column(
                  children: [
                    Expanded(child: _buildWaterfallGrid()),

                    // 操作提示
                    if (!_multiSelectMode)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        color: Colors.grey.shade50,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.touch_app, size: 14, color: Colors.grey.shade400),
                            const SizedBox(width: 4),
                            Text(
                              AppLocalizations.of(context)!.tapHint,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade400,
                              ),
                            ),
                          ],
                        ),
                      ),

                    if (_multiSelectMode) _buildBottomToolbar(),
                  ],
                ),
    );
  }

  Widget _buildWaterfallGrid() {
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
          // 长按显示操作菜单
          _showSingleActionSheet(photo);
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

              // 视频右下角小图标提示
              if ((photo['media_type'] ?? 0) == 1)
                Positioned(
                  right: 6,
                  bottom: 6,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.videocam, color: Colors.white, size: 14),
                      ],
                    ),
                  ),
                ),

              // 多选勾选标记

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
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,

              children: [
                const SizedBox(height: 16),

                // 缩略图预览

                SizedBox(
                  height: 120,

                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),

                    child: _buildThumbnailImage(photo['asset_id'] as String),
                  ),
                ),

                const SizedBox(height: 16),

                ListTile(
                  leading: const Icon(Icons.edit, color: Colors.green),

                  title: Text(AppLocalizations.of(context)!.rename),

                  subtitle: Text(
                    (photo['name'] as String?)?.isNotEmpty == true
                        ? AppLocalizations.of(context)!.currentName(photo['name'] as String)
                        : AppLocalizations.of(context)!.untitled,
                    style: const TextStyle(fontSize: 12),
                  ),

                  onTap: () {
                    Navigator.pop(sheetContext);

                    _showRenameDialog(photo);
                  },
                ),

                ListTile(
                  leading: const Icon(Icons.swap_horiz, color: Colors.blue),

                  title: Text(AppLocalizations.of(context)!.changeCategory),

                  onTap: () {
                    Navigator.pop(sheetContext);

                    _showCategoryPicker([photoId]);
                  },
                ),

                ListTile(
                  leading: const Icon(Icons.folder_off, color: Colors.orange),

                  title: Text(AppLocalizations.of(context)!.removeFromCategory),

                  onTap: () {
                    Navigator.pop(sheetContext);

                    _confirmRemoveFromCategory([photoId]);
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
            // 第一行：已选数量 + 全选

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,

              children: [
                Text(
                  AppLocalizations.of(context)!.selectedCount(_selectedIds.length.toString()),

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

            // 第二行：四个操作按钮

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

                    icon: const Icon(Icons.swap_horiz, size: 18),

                    label: Text(AppLocalizations.of(context)!.changeCategory),
                  ),
                ),

                const SizedBox(width: 8),

                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _selectedIds.isEmpty
                        ? null
                        : () => _confirmRemoveFromCategory(_selectedIds.toList()),

                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,

                      foregroundColor: Colors.white,
                    ),

                    icon: const Icon(Icons.folder_off, size: 18),

                    label: Text(AppLocalizations.of(context)!.remove),
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
          const SnackBar(content: Text('无法获取文件')),
        );
      }
      return;
    }

    await Share.shareXFiles(files);
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

  // 重命名对话框

  void _showRenameDialog(Map<String, dynamic> photo) {
    final photoId = photo['id'] as int;

    final currentName = photo['name'] as String? ?? '';

    final nameController = TextEditingController(text: currentName);

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.rename),
          content: TextField(
            controller: nameController,
            autofocus: true,
            decoration: InputDecoration(
              hintText: AppLocalizations.of(context)!.enterPhotoName,
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(AppLocalizations.of(context)!.cancel),
            ),
            ElevatedButton(
              onPressed: () async {
                final newName = nameController.text.trim();
                await _db.updatePhotoName(photoId, newName);
                if (!dialogContext.mounted) return;
                Navigator.pop(dialogContext);
                // 刷新列表
                await _loadPhotos();
              },
              child: Text(AppLocalizations.of(context)!.save),
            ),
          ],
        );
      },
    );
  }

  // 选择目标分类

  void _showCategoryPicker(List<int> photoIds) async {
    // 所有功能已对全部用户开放，无需会员检查
    final categoryProvider = context.read<CategoryProvider>();

    // 根据当前分类的媒体类型获取目标分类列表

    final categories = _mediaType == 1
        ? categoryProvider.videoCategories
        : categoryProvider.photoCategories;

    // 排除当前分类

    final currentId = widget.category['id'] as int;

    final otherCategories = categories
        .where((c) => c['id'] != currentId)
        .toList();

    if (otherCategories.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.noOtherCategories)),
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
                  AppLocalizations.of(context)!.moveToCategory,

                  style: TextStyle(
                    fontSize: 22,

                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  AppLocalizations.of(context)!.photoCount(photoIds.length.toString()),

                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),

                Expanded(
                  child: ListView.builder(
                    itemCount: otherCategories.length,

                    itemBuilder: (context, index) {
                      final item = otherCategories[index];

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

                        title: Text(DatabaseHelper.getCategoryName(item, AppLocalizations.of(context)!)),

                        trailing: const Icon(Icons.chevron_right, color: Colors.grey),

                        onTap: () async {
                          await _db.batchUpdateCategory(
                            photoIds,

                            item['id'] as int,
                          );

                          if (!sheetContext.mounted) return;

                          Navigator.pop(sheetContext);

                          // 退出多选模式

                          setState(() {
                            _multiSelectMode = false;

                            _selectedIds.clear();
                          });

                          await _loadPhotos();

                          if (!context.mounted) return;

                          context.read<PhotoProvider>().refreshStats();

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(AppLocalizations.of(context)!.movedTo(item['name'] as String)),

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

  // 确认移出分类

  void _confirmRemoveFromCategory(List<int> photoIds) {
    showDialog(
      context: context,

      builder: (dialogContext) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.removeFromCategory),

          content: Text(AppLocalizations.of(context)!.confirmRemoveFromCategory(photoIds.length.toString())),

          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),

              child: const Text("取消"),
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

                if (!mounted) return;

                context.read<PhotoProvider>().refreshStats();
              },

              style: TextButton.styleFrom(foregroundColor: Colors.orange),

              child: Text(AppLocalizations.of(context)!.remove),
            ),
          ],
        );
      },
    );
  }

  // 确认移到回收站

  void _confirmMoveToRecycleBin(List<int> photoIds) {
    showDialog(
      context: context,

      builder: (dialogContext) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.moveToRecycleBin),

          content: Text(AppLocalizations.of(context)!.confirmMoveToRecycleBinDetail(photoIds.length.toString())),

          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),

              child: const Text("取消"),
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

                if (!mounted) return;

                context.read<PhotoProvider>().refreshStats();
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
}
