import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:provider/provider.dart';

import '../../data/database_helper.dart';
import '../../providers/photo_provider.dart';
import '../../providers/category_provider.dart';

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
    final categoryName = widget.category['name'] as String;

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

              child: Text(_multiSelectMode ? "取消" : "选择"),
            ),
        ],
      ),

      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _photos.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,

                    children: [
                      Icon(Icons.photo_library_outlined, size: 80, color: Colors.grey),

                      SizedBox(height: 16),

                      Text("暂无照片", style: TextStyle(fontSize: 18, color: Colors.grey)),
                    ],
                  ),
                )
              : Column(
                  children: [
                    Expanded(child: _buildWaterfallGrid()),

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

          sliver: SliverMasonryGrid.count(
            crossAxisCount: 2,

            mainAxisSpacing: 8,

            crossAxisSpacing: 8,

            childCount: _photos.length,

            itemBuilder: (context, index) {
              return _buildPhotoCard(_photos[index]);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPhotoCard(Map<String, dynamic> photo) {
    final assetId = photo['asset_id'] as String;

    final photoId = photo['id'] as int;

    final isSelected = _selectedIds.contains(photoId);

    // 使用随机高度模拟瀑布流效果

    final heights = [180.0, 220.0, 260.0, 200.0, 240.0];

    final height = heights[photoId % heights.length];

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
          // 非多选模式，点击弹出操作菜单

          _showSingleActionSheet(photo);
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
        height: height,

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
                leading: const Icon(Icons.swap_horiz, color: Colors.blue),

                title: const Text("修改分类"),

                onTap: () {
                  Navigator.pop(sheetContext);

                  _showCategoryPicker([photoId]);
                },
              ),

              ListTile(
                leading: const Icon(Icons.folder_off, color: Colors.orange),

                title: const Text("移出分类"),

                onTap: () {
                  Navigator.pop(sheetContext);

                  _confirmRemoveFromCategory([photoId]);
                },
              ),

              ListTile(
                leading: const Icon(Icons.delete_forever, color: Colors.red),

                title: const Text("移到回收站"),

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
            // 第一行：已选数量 + 全选

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,

              children: [
                Text(
                  "已选 ${_selectedIds.length} 项",

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
                    _selectedIds.length == _photos.length ? "取消全选" : "全选",
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // 第二行：三个操作按钮

            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _selectedIds.isEmpty
                        ? null
                        : () => _showCategoryPicker(_selectedIds.toList()),

                    icon: const Icon(Icons.swap_horiz, size: 18),

                    label: const Text("修改分类"),
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

                    label: const Text("移出"),
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

                    label: const Text("删除"),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // 选择目标分类

  void _showCategoryPicker(List<int> photoIds) {
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
        const SnackBar(content: Text("没有其他可用的分类，请先创建")),
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
                  "移动到分类",

                  style: TextStyle(
                    fontSize: 22,

                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  "${photoIds.length} 张",

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

                        title: Text(item['name'] as String),

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
                              content: Text("已移动到「${item['name']}」"),

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
          title: const Text("移出分类"),

          content: Text("确定将选中的 ${photoIds.length} 张移出当前分类？\n移出后需要重新整理。"),

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

              child: const Text("移出"),
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
          title: const Text("移到回收站"),

          content: Text("确定将选中的 ${photoIds.length} 张移到回收站？\n30天后将自动永久删除。"),

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

              child: const Text("删除"),
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
