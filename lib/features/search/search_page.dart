import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';

import '../../data/database_helper.dart';

/// 照片/视频搜索页面
class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final DatabaseHelper _db = DatabaseHelper.instance;

  final TextEditingController _controller = TextEditingController();

  final Map<String, Uint8List> _thumbnailCache = {};

  List<Map<String, dynamic>> _results = [];

  bool _searching = false;

  bool _hasSearched = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _doSearch(String keyword) async {
    if (keyword.trim().isEmpty) return;

    setState(() {
      _searching = true;
      _hasSearched = true;
    });

    final results = await _db.searchPhotosByName(keyword.trim());

    if (!mounted) return;

    setState(() {
      _results = results;
      _searching = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('搜索照片'),
      ),
      body: Column(
        children: [
          // 搜索栏
          Container(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _controller,
              autofocus: true,
              decoration: InputDecoration(
                hintText: '输入照片/视频名称搜索...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _controller.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _controller.clear();
                          setState(() {
                            _results = [];
                            _hasSearched = false;
                          });
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                filled: true,
                fillColor: Colors.grey.shade100,
              ),
              onChanged: (value) {
                setState(() {}); // 刷新清除按钮
              },
              onSubmitted: _doSearch,
            ),
          ),

          // 搜索结果
          Expanded(
            child: _searching
                ? const Center(child: CircularProgressIndicator())
                : _hasSearched
                    ? _results.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.search_off,
                                    size: 64, color: Colors.grey.shade300),
                                const SizedBox(height: 16),
                                Text(
                                  '没有找到匹配的结果',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey.shade500,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : _buildResultsGrid()
                    : _buildEmptyHint(),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyHint() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            '输入名称搜索已整理的照片和视频',
            style: TextStyle(fontSize: 15, color: Colors.grey.shade500),
          ),
          const SizedBox(height: 8),
          Text(
            '提示：在分类详情中长按照片可以重命名',
            style: TextStyle(fontSize: 13, color: Colors.grey.shade400),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 4,
        mainAxisSpacing: 4,
        childAspectRatio: 0.75,
      ),
      itemCount: _results.length,
      itemBuilder: (context, index) {
        return _buildResultCard(_results[index]);
      },
    );
  }

  Widget _buildResultCard(Map<String, dynamic> photo) {
    final assetId = photo['asset_id'] as String;
    final name = photo['name'] as String? ?? '';

    return GestureDetector(
      onTap: () => _showFullScreenViewer(photo),
      onLongPress: () => _showRenameDialog(photo),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.grey.shade200,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Column(
            children: [
              Expanded(
                child: _buildThumbnailImage(assetId),
              ),
              if (name.isNotEmpty)
                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                  color: Colors.black.withValues(alpha: 0.6),
                  child: Text(
                    name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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
            child: Icon(Icons.image, color: Colors.grey, size: 32),
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

  // 全屏查看
  void _showFullScreenViewer(Map<String, dynamic> photo) async {
    final assetId = photo['asset_id'] as String;
    final entity = await AssetEntity.fromId(assetId);
    if (entity == null || !mounted) return;

    final file = await entity.file;
    if (file == null || !mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _FullScreenViewer(
          file: file,
          name: photo['name'] as String? ?? '',
          isVideo: entity.type == AssetType.video,
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
          title: const Text('重命名'),
          content: TextField(
            controller: nameController,
            autofocus: true,
            decoration: const InputDecoration(
              hintText: '输入名称',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('取消'),
            ),
            ElevatedButton(
              onPressed: () async {
                final newName = nameController.text.trim();
                await _db.updatePhotoName(photoId, newName);
                if (!dialogContext.mounted) return;
                Navigator.pop(dialogContext);
                // 刷新搜索结果
                _doSearch(_controller.text);
              },
              child: const Text('保存'),
            ),
          ],
        );
      },
    );
  }
}

// 全屏查看器（支持缩放）
class _FullScreenViewer extends StatefulWidget {
  final File file;
  final String name;
  final bool isVideo;

  const _FullScreenViewer({
    required this.file,
    required this.name,
    this.isVideo = false,
  });

  @override
  State<_FullScreenViewer> createState() => _FullScreenViewerState();
}

class _FullScreenViewerState extends State<_FullScreenViewer> {
  final TransformationController _transformController =
      TransformationController();

  @override
  void dispose() {
    _transformController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          widget.name.isEmpty ? '预览' : widget.name,
          style: const TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: InteractiveViewer(
          transformationController: _transformController,
          minScale: 1.0,
          maxScale: 5.0,
          child: Image.file(
            widget.file,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
