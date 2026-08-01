import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:provider/provider.dart';

import '../../providers/photo_provider.dart';
import '../../providers/membership_provider.dart';

class RecyclePage extends StatefulWidget {
  const RecyclePage({super.key});

  @override
  State<RecyclePage> createState() => _RecyclePageState();
}

class _RecyclePageState extends State<RecyclePage> {
  final Map<String, Uint8List> _thumbnailCache = {};

  final Set<int> _selectedIds = {};

  bool _multiSelectMode = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PhotoProvider>().loadRecyclePhotos();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PhotoProvider>();

    final photos = provider.recyclePhotos;

    final groups = _groupByDate(photos);

    return Scaffold(
      appBar: AppBar(
        title: const Text("回收站"),

        actions: [
          if (photos.isNotEmpty)
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

      body: photos.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,

                children: [
                  Icon(Icons.delete_outline, size: 80, color: Colors.grey),

                  SizedBox(height: 16),

                  Text("回收站是空的", style: TextStyle(fontSize: 18, color: Colors.grey)),
                ],
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(12),

                    itemCount: groups.length,

                    itemBuilder: (context, index) {
                      final entry = groups.entries.elementAt(index);

                      return _buildGroup(entry.key, entry.value);
                    },
                  ),
                ),

                _buildBottomToolbar(provider),
              ],
            ),
    );
  }

  // 按日期分组

  Map<String, List<Map<String, dynamic>>> _groupByDate(
    List<Map<String, dynamic>> photos,
  ) {
    final Map<String, List<Map<String, dynamic>>> groups = {};

    final now = DateTime.now();

    final today = DateTime(now.year, now.month, now.day);

    final yesterday = today.subtract(const Duration(days: 1));

    for (final photo in photos) {
      final deleteTime = photo['delete_time'] as int?;

      if (deleteTime == null) continue;

      final date = DateTime.fromMillisecondsSinceEpoch(deleteTime);

      final day = DateTime(date.year, date.month, date.day);

      String label;

      if (day == today) {
        label = "今天";
      } else if (day == yesterday) {
        label = "昨天";
      } else {
        label = "${date.month}月${date.day}日";
      }

      groups.putIfAbsent(label, () => []);

      groups[label]!.add(photo);
    }

    return groups;
  }

  Widget _buildGroup(String label, List<Map<String, dynamic>> photos) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),

          child: Text(
            "$label · ${photos.length} 张",

            style: const TextStyle(
              fontSize: 16,

              fontWeight: FontWeight.bold,

              color: Colors.grey,
            ),
          ),
        ),

        SizedBox(
          height: 120,

          child: ListView.separated(
            scrollDirection: Axis.horizontal,

            itemCount: photos.length,

            separatorBuilder: (_, _) => const SizedBox(width: 10),

            itemBuilder: (context, index) {
              return _buildThumbnail(photos[index]);
            },
          ),
        ),

        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildThumbnail(Map<String, dynamic> photo) {
    final assetId = photo['asset_id'] as String;

    final deleteTime = photo['delete_time'] as int? ?? 0;

    final photoId = photo['id'] as int;

    // 获取会员状态
    final isPremium = context.watch<MembershipProvider>().isPremium;

    // 计算剩余天数
    final deleteDate = DateTime.fromMillisecondsSinceEpoch(deleteTime);
    final expireDate = deleteDate.add(const Duration(days: 30));
    final remainDays = expireDate.difference(DateTime.now()).inDays;

    // 会员显示永久保留，非会员显示剩余天数
    final remainText = isPremium 
        ? "永久保留" 
        : (remainDays < 0 ? "已过期" : "剩余$remainDays天");

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
          _showPreview(photo);
        }
      },

      child: SizedBox(
        width: 120,

        child: Column(
          children: [
            Stack(
              children: [
                Container(
                  width: 120,

                  height: 90,

                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),

                    color: Colors.grey.shade300,

                    border: isSelected
                        ? Border.all(color: Colors.blue, width: 3)
                        : null,
                  ),

                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),

                    child: _buildThumbnailImage(assetId),
                  ),
                ),

                // 红色倒计时标签

                Positioned(
                  right: 4,

                  bottom: 4,

                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,

                      vertical: 2,
                    ),

                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.85),

                      borderRadius: BorderRadius.circular(4),
                    ),

                    child: Text(
                      remainText,

                      style: const TextStyle(
                        color: Colors.white,

                        fontSize: 10,

                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                // 多选勾选标记

                if (_multiSelectMode && isSelected)
                  Positioned(
                    left: 4,

                    top: 4,

                    child: Container(
                      width: 24,

                      height: 24,

                      decoration: const BoxDecoration(
                        color: Colors.blue,

                        shape: BoxShape.circle,
                      ),

                      child: const Icon(
                        Icons.check,

                        color: Colors.white,

                        size: 16,
                      ),
                    ),
                  ),
              ],
            ),
          ],
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
            child: Icon(Icons.image, color: Colors.grey, size: 30),
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
        const ThumbnailSize(200, 200),
      );

      if (data != null) {
        _thumbnailCache[assetId] = data;
      }

      return data;
    } catch (e) {
      return null;
    }
  }

  void _showPreview(Map<String, dynamic> photo) {
    final assetId = photo['asset_id'] as String;

    final photoId = photo['id'] as int;

    final provider = context.read<PhotoProvider>();

    showDialog(
      context: context,

      builder: (dialogContext) {
        return Dialog(
          child: SizedBox(
            width: 340,

            child: Column(
              mainAxisSize: MainAxisSize.min,

              children: [
                SizedBox(
                  height: 300,

                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(28),
                    ),

                    child: FutureBuilder<Uint8List?>(
                      future: _loadThumbnail(assetId),

                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return Container(
                            color: Colors.grey.shade300,

                            child: const Center(
                              child: CircularProgressIndicator(),
                            ),
                          );
                        }

                        return Image.memory(
                          snapshot.data!,

                          fit: BoxFit.cover,

                          width: double.infinity,
                        );
                      },
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(16),

                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,

                    children: [
                      ElevatedButton.icon(
                        onPressed: () async {
                          await provider.restorePhoto(photoId);

                          if (!dialogContext.mounted) return;

                          Navigator.pop(dialogContext);
                        },

                        icon: const Icon(Icons.restore),

                        label: const Text("恢复"),

                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,

                          foregroundColor: Colors.white,
                        ),
                      ),

                      ElevatedButton.icon(
                        onPressed: () {
                          _confirmPermanentDelete(dialogContext, provider, photoId);
                        },

                        icon: const Icon(Icons.delete_forever),

                        label: const Text("永久删除"),

                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,

                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _confirmPermanentDelete(
    BuildContext dialogContext,

    PhotoProvider provider,

    int photoId,
  ) {
    showDialog(
      context: dialogContext,

      builder: (confirmContext) {
        return AlertDialog(
          title: const Text("永久删除"),

          content: const Text("确定永久删除此照片？此操作不可恢复。"),

          actions: [
            TextButton(
              onPressed: () => Navigator.pop(confirmContext),

              child: const Text("取消"),
            ),

            TextButton(
              onPressed: () async {
                await provider.permanentDeletePhoto(photoId);

                if (!confirmContext.mounted) return;

                Navigator.pop(confirmContext);

                Navigator.pop(dialogContext);
              },

              child: const Text("删除", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildBottomToolbar(PhotoProvider provider) {
    if (!_multiSelectMode) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),

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

          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,

            children: [
              TextButton.icon(
                onPressed: () async {
                  await provider.restoreAll();
                },

                icon: const Icon(Icons.restore, color: Colors.green),

                label: const Text(
                  "全部恢复",

                  style: TextStyle(color: Colors.green),
                ),
              ),

              TextButton.icon(
                onPressed: () => _confirmClearAll(provider),

                icon: const Icon(Icons.delete_forever, color: Colors.red),

                label: const Text(
                  "清空所有",

                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),

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

        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,

          children: [
            TextButton(
              onPressed: () {
                setState(() {
                  final allIds = provider.recyclePhotos
                      .map((p) => p['id'] as int)
                      .toSet();

                  if (_selectedIds.length == allIds.length) {
                    _selectedIds.clear();
                  } else {
                    _selectedIds.addAll(allIds);
                  }
                });
              },

              child: Text(
                _selectedIds.length == provider.recyclePhotos.length
                    ? "取消全选"
                    : "全选",
              ),
            ),

            TextButton.icon(
              onPressed: _selectedIds.isEmpty
                  ? null
                  : () async {
                      for (final id in _selectedIds) {
                        await provider.restorePhoto(id);
                      }

                      setState(() {
                        _selectedIds.clear();

                        _multiSelectMode = false;
                      });
                    },

              icon: const Icon(Icons.restore),

              label: const Text("恢复"),
            ),

            TextButton.icon(
              onPressed: _selectedIds.isEmpty
                  ? null
                  : () {
                      showDialog(
                        context: context,

                        builder: (confirmContext) {
                          return AlertDialog(
                            title: const Text("永久删除"),

                            content: Text(
                              "确定永久删除选中的 ${_selectedIds.length} 张照片？",
                            ),

                            actions: [
                              TextButton(
                                onPressed: () =>
                                    Navigator.pop(confirmContext),

                                child: const Text("取消"),
                              ),

                              TextButton(
                                onPressed: () async {
                                  for (final id in _selectedIds) {
                                    await provider.permanentDeletePhoto(id);
                                  }

                                  if (!confirmContext.mounted) return;

                                  Navigator.pop(confirmContext);

                                  setState(() {
                                    _selectedIds.clear();

                                    _multiSelectMode = false;
                                  });
                                },

                                child: const Text(
                                  "删除",

                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                            ],
                          );
                        },
                      );
                    },

              icon: const Icon(Icons.delete_forever, color: Colors.red),

              label: const Text(
                "删除",

                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmClearAll(PhotoProvider provider) {
    showDialog(
      context: context,

      builder: (dialogContext) {
        return AlertDialog(
          title: const Text("清空回收站"),

          content: const Text("确定清空回收站？此操作不可恢复。"),

          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),

              child: const Text("取消"),
            ),

            TextButton(
              onPressed: () async {
                await provider.clearRecycleBin();

                if (!dialogContext.mounted) return;

                Navigator.pop(dialogContext);
              },

              child: const Text("清空", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}
