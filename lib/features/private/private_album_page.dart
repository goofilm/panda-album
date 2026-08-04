import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/private_album_provider.dart';
import 'create_private_album_page.dart';
import 'private_album_detail_page.dart';
import 'private_settings_page.dart';

class PrivateAlbumPage extends StatefulWidget {
  const PrivateAlbumPage({super.key});

  @override
  State<PrivateAlbumPage> createState() => _PrivateAlbumPageState();
}

class _PrivateAlbumPageState extends State<PrivateAlbumPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: 2, vsync: this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PrivateAlbumProvider>().loadAlbums();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PrivateAlbumProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('私密相册'),

        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: '设置',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PrivateSettingsPage()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.lock_open),
            tooltip: '锁定',
            onPressed: () {
              provider.lock();

              Navigator.pop(context);
            },
          ),
        ],

        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: '照片'),
            Tab(text: '视频'),
          ],
        ),
      ),

      body: TabBarView(
        controller: _tabController,
        children: [
          _buildAlbumList(provider.photoAlbums, provider, 0),
          _buildAlbumList(provider.videoAlbums, provider, 1),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final mediaType = _tabController.index;

          // 所有功能已对全部用户开放，无需会员检查
          Navigator.push(
            context,

            MaterialPageRoute(
              builder: (_) => CreatePrivateAlbumPage(mediaType: mediaType),
            ),
          );
        },

        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildAlbumList(
    List<Map<String, dynamic>> albums,
    PrivateAlbumProvider provider,
    int mediaType,
  ) {
    if (provider.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (albums.isEmpty) {
      return Center(
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
              mediaType == 0 ? '暂无私密照片相册' : '暂无私密视频相册',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '点击右下角 + 创建',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade400,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => provider.loadAlbums(),
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
        ),
        itemCount: albums.length,
        itemBuilder: (context, index) {
          final album = albums[index];
          final id = album['id'] as int;
          final name = album['name'] as String;
          final icon = album['icon'] as String;
          final count = provider.albumCounts[id] ?? 0;
          final colorStr = album['color'] as String? ?? '4A90D9';
          final color = Color(int.parse('0xFF$colorStr'));

          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PrivateAlbumDetailPage(
                    albumId: id,
                    albumName: name,
                    albumIcon: icon,
                    albumColor: color,
                    mediaType: mediaType,
                  ),
                ),
              );
            },
            onLongPress: () => _showAlbumOptions(album),
            child: Container(
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: color.withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(icon, style: const TextStyle(fontSize: 40)),
                  const SizedBox(height: 8),
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$count 个',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showAlbumOptions(Map<String, dynamic> album) {
    final id = album['id'] as int;
    final name = album['name'] as String;

    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 16),
              Text(
                name,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.delete_outline, color: Colors.red),
                title: const Text('删除相册'),
                subtitle: const Text('照片不会被删除，仅删除相册'),
                onTap: () async {
                  Navigator.pop(context);

                  final confirm = await showDialog<bool>(
                    context: this.context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('确认删除'),
                      content: Text('确定要删除「$name」相册吗？\n相册内的照片不会被删除。'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, false),
                          child: const Text('取消'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, true),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.red,
                          ),
                          child: const Text('删除'),
                        ),
                      ],
                    ),
                  );

                  if (confirm == true && mounted) {
                    await this.context
                        .read<PrivateAlbumProvider>()
                        .deleteAlbum(id);
                  }
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }
}
