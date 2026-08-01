import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

import '../../data/database_helper.dart';
import '../../providers/photo_provider.dart';
import '../../providers/category_provider.dart';
import '../../providers/private_album_provider.dart';
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
                  leading: const Icon(Icons.lock_outline, color: Colors.purple),

                  title: Text(AppLocalizations.of(context)!.moveToPrivate),

                  onTap: () {
                    Navigator.pop(sheetContext);

                    _showPrivateAlbumPicker(photo);
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

            // 第二行：三个操作按钮

            Row(
              children: [
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

  // 全屏查看（支持左右滑动）

  void _showFullScreenViewer(Map<String, dynamic> photo) {
    final initialIndex = _photos.indexWhere(
      (p) => p['id'] == photo['id'],
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _FullScreenMediaViewer(
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

  // 移入私密相册选择器

  void _showPrivateAlbumPicker(Map<String, dynamic> photo) async {
    final privateProvider = context.read<PrivateAlbumProvider>();

    // 先加载相册数据（确保重启后也能获取到）
    await privateProvider.loadAlbums();

    if (!mounted) return;

    // 根据当前媒体的类型获取对应的私密相册
    final mediaType = _mediaType;

    final albums = mediaType == 1
        ? privateProvider.videoAlbums
        : privateProvider.photoAlbums;

    if (albums.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            mediaType == 1 ? AppLocalizations.of(context)!.createPrivateVideoAlbumFirst : AppLocalizations.of(context)!.createPrivatePhotoAlbumFirst,
          ),
        ),
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
            height: 400,
            child: Column(
              children: [
                const SizedBox(height: 20),
                Text(
                  '🔒 ${AppLocalizations.of(context)!.selectPrivateAlbum}',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView.builder(
                    itemCount: albums.length,
                    itemBuilder: (context, index) {
                      final album = albums[index];
                      final count =
                          privateProvider.albumCounts[album['id']] ?? 0;
                      return ListTile(
                        leading: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: _parseColor(album['color'] as String)
                                .withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              album['icon'] as String,
                              style: const TextStyle(fontSize: 22),
                            ),
                          ),
                        ),
                        title: Text(album['name'] as String),
                        subtitle: Text(AppLocalizations.of(context)!.albumProtected(count.toString())),
                        trailing:
                            const Icon(Icons.lock, color: Colors.purple, size: 20),
                        onTap: () async {
                          final assetId = photo['asset_id'] as String;
                          final albumId = album['id'] as int;

                          // 添加到私密相册
                          await privateProvider.addPhotoToAlbum(
                            assetId: assetId,
                            albumId: albumId,
                            mediaType: mediaType,
                          );

                          // 从当前分类移除
                          final photoId = photo['id'] as int;
                          await _db.moveToPrivate(photoId);

                          if (!sheetContext.mounted) return;
                          Navigator.pop(sheetContext);

                          await _loadPhotos();

                          if (!mounted) return;
                          this.context.read<PhotoProvider>().refreshStats();

                          ScaffoldMessenger.of(this.context).showSnackBar(
                            SnackBar(
                              content: Text(
                                AppLocalizations.of(context)!.movedToPrivateAlbum(album['name'] as String),
                              ),
                              duration: const Duration(seconds: 2),
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

// 全屏查看器（PageView 左右滑动，支持照片缩放和视频播放）
class _FullScreenMediaViewer extends StatefulWidget {
  final List<Map<String, dynamic>> mediaList;
  final int initialIndex;

  const _FullScreenMediaViewer({
    required this.mediaList,
    required this.initialIndex,
  });

  @override
  State<_FullScreenMediaViewer> createState() =>
      _FullScreenMediaViewerState();
}

class _FullScreenMediaViewerState extends State<_FullScreenMediaViewer> {
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
          return _MediaPage(media: media);
        },
      ),
    );
  }
}

// 单个媒体页面（照片或视频）
class _MediaPage extends StatefulWidget {
  final Map<String, dynamic> media;

  const _MediaPage({required this.media});

  @override
  State<_MediaPage> createState() => _MediaPageState();
}

class _MediaPageState extends State<_MediaPage> {
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
      return _VideoPlayerPage(file: _file!);
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

// 视频播放页面
class _VideoPlayerPage extends StatefulWidget {
  final File file;

  const _VideoPlayerPage({required this.file});

  @override
  State<_VideoPlayerPage> createState() => _VideoPlayerPageState();
}

class _VideoPlayerPageState extends State<_VideoPlayerPage> {
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
              // 底部进度条
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
