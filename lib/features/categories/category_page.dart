import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/database_helper.dart';
import '../../providers/category_provider.dart';
import '../../providers/private_album_provider.dart';
import '../../providers/membership_provider.dart';
import '../../services/membership_service.dart';
import '../../widgets/morandi_color.dart';
import '../private/private_lock_page.dart';
import '../membership/membership_page.dart';
import 'create_category_page.dart';
import 'category_detail_page.dart';
import 'kept_photos_page.dart';

class CategoryPage extends StatefulWidget {
  const CategoryPage({super.key});

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage>
    with SingleTickerProviderStateMixin {
  final DatabaseHelper _db = DatabaseHelper.instance;

  int _organizedCount = 0;

  int _selectedTab = 0;

  late final TabController _tabController = TabController(
    length: 2,

    vsync: this,
  );

  @override
  void initState() {
    super.initState();

    _loadStats();

    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {
          _selectedTab = _tabController.index;
        });

        context.read<CategoryProvider>().setSelectedTab(_selectedTab);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();

    super.dispose();
  }

  Future<void> _loadStats() async {
    final count = await _db.getOrganizedCount();

    if (!mounted) return;

    setState(() {
      _organizedCount = count;
    });

    // 刷新分类统计和已保留数量
    if (mounted) {
      context.read<CategoryProvider>().loadCategories();
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CategoryProvider>();

    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text("我的分类"),

        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),

            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,

                  MaterialPageRoute(
                    builder: (_) => CreateCategoryPage(
                      mediaType: _selectedTab,
                    ),
                  ),
                ).then((_) => _loadStats());
              },

              child: Container(
                width: 36,

                height: 36,

                decoration: const BoxDecoration(
                  color: Colors.blue,

                  shape: BoxShape.circle,
                ),

                child: const Icon(Icons.add, color: Colors.white, size: 22),
              ),
            ),
          ),
        ],
      ),

      body: provider.loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // 顶部 TabBar

                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),

                  color: Colors.white,

                  child: TabBar(
                    controller: _tabController,

                    labelColor: Colors.blue,

                    unselectedLabelColor: Colors.grey,

                    indicatorColor: Colors.blue,

                    tabs: [
                      Tab(text: "照片分类 (${provider.photoCategories.length})"),

                      Tab(text: "视频分类 (${provider.videoCategories.length})"),
                    ],
                  ),
                ),

                // 顶部统计条

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,

                    vertical: 10,
                  ),

                  color: Colors.blue.withValues(alpha: 0.05),

                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,

                    children: [
                      Text(
                        _selectedTab == 0
                            ? "照片分类 ${provider.photoCategories.length} 个 · 已收纳 $_organizedCount 张"
                            : "视频分类 ${provider.videoCategories.length} 个",

                        style: TextStyle(
                          fontSize: screenWidth * 0.035,

                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),

                // 分类网格

                Expanded(
                  child: _buildCategoryGrid(provider),
                ),

                // 底部私密相册入口
                _buildPrivateEntry(),
              ],
            ),
    );
  }

  Widget _buildCategoryGrid(CategoryProvider provider) {
    final currentCategories = _selectedTab == 0
        ? provider.photoCategories
        : provider.videoCategories;

    return GridView.builder(
      padding: const EdgeInsets.all(16),

      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,

        crossAxisSpacing: 15,

        mainAxisSpacing: 15,
      ),

      itemCount: currentCategories.length + 2,

      itemBuilder: (context, index) {
        if (index == 0) {
          return _buildKeptCard(provider);
        }

        if (index == currentCategories.length + 1) {
          return _buildAddCard();
        }

        final item = currentCategories[index - 1];

        return _buildCategoryCard(item, provider);
      },
    );
  }

  Widget _buildKeptCard(CategoryProvider provider) {
    final screenWidth = MediaQuery.of(context).size.width;

    final keptCount = provider.keptCount;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => KeptPhotosPage(mediaType: _selectedTab),
          ),
        ).then((_) {
          _loadStats();
          provider.loadCategories();
        });
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.green.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.25),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Icon(
                  Icons.check_circle,
                  size: screenWidth * 0.07,
                  color: Colors.green.shade700,
                ),
              ),
            ),
            SizedBox(height: screenWidth * 0.02),
            Text(
              '已保留',
              style: TextStyle(
                fontSize: screenWidth * 0.035,
                fontWeight: FontWeight.bold,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                '$keptCount 个',
                style: TextStyle(
                  fontSize: screenWidth * 0.028,
                  color: Colors.grey.shade500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrivateEntry() {
    final privateProvider = context.watch<PrivateAlbumProvider>();

    final count = privateProvider.totalPrivateCount;

    final isVideo = _selectedTab == 1;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        border: Border(
          top: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const PrivateLockPage()),
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.blue.shade200,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.blue.shade100,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.lock_outline,
                  color: Colors.blue.shade700,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isVideo ? '私密视频相册' : '私密照片相册',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade900,
                      ),
                    ),
                    Text(
                      count > 0
                          ? '$count 个${isVideo ? "视频" : "照片"}已保护'
                          : '点击进入私密空间',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: Colors.blue.shade400,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAddCard() {
    return GestureDetector(
      onTap: () async {
        // 检查会员限制
        final membership = context.read<MembershipProvider>();
        final categoryProvider = context.read<CategoryProvider>();
        final currentCount = categoryProvider.categories.length;
        
        final canCreate = await membership.canUseFeature('category', currentCount: currentCount);
        
        if (!canCreate && mounted) {
          // 显示升级提示
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('免费版限制'),
              content: Text('免费版最多创建 ${MembershipBenefits.freeCategoryLimit} 个分类\n\n开通会员可创建无限分类'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('取消'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const MembershipPage()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber.shade700,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('开通会员'),
                ),
              ],
            ),
          );
          return;
        }
        
        Navigator.push(
          context,

          MaterialPageRoute(
            builder: (_) => CreateCategoryPage(mediaType: _selectedTab),
          ),
        ).then((_) => _loadStats());
      },

      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),

          border: Border.all(color: Colors.blue, width: 2),
        ),

        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [
            Icon(Icons.add, size: 40, color: Colors.blue),

            Text("新建分类", style: TextStyle(color: Colors.blue)),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryCard(
    Map<String, dynamic> item,

    CategoryProvider provider,
  ) {
    final color = morandiFromHex(item['color']);

    final screenWidth = MediaQuery.of(context).size.width;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,

          MaterialPageRoute(
            builder: (_) => CategoryDetailPage(category: item),
          ),
        ).then((_) => _loadStats());
      },

      child: Container(
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),

          borderRadius: BorderRadius.circular(20),
        ),

        child: Stack(
          children: [
            // 主体内容

            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,

                children: [
                  // 圆形彩色背景 + Emoji

                  Container(
                    width: 52,

                    height: 52,

                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.3),

                      shape: BoxShape.circle,
                    ),

                    child: Center(
                      child: Text(
                        item['icon'],

                        style: TextStyle(fontSize: screenWidth * 0.07),
                      ),
                    ),
                  ),

                  SizedBox(height: screenWidth * 0.02),

                  Text(
                    item['name'],

                    style: TextStyle(
                      fontSize: screenWidth * 0.035,

                      fontWeight: FontWeight.bold,
                    ),

                    overflow: TextOverflow.ellipsis,
                  ),

                  // 已收纳数量

                  Builder(
                    builder: (context) {
                      final count = provider.categoryCounts[item['id']] ?? 0;

                      return Padding(
                        padding: const EdgeInsets.only(top: 2),

                        child: Text(
                          '$count 个',

                          style: TextStyle(
                            fontSize: screenWidth * 0.028,

                            color: Colors.grey.shade500,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            // 右上角溢出菜单（非默认分类）

            if (item['is_default'] == 0)
              Positioned(
                right: 0,

                top: 0,

                child: PopupMenuButton<String>(
                  icon: Icon(
                    Icons.more_vert,

                    size: screenWidth * 0.045,

                    color: Colors.grey,
                  ),

                  padding: EdgeInsets.zero,

                  onSelected: (value) {
                    switch (value) {
                      case 'rename':
                        _showEditDialog(item);

                        break;

                      case 'delete':
                        _showDeleteDialog(provider, item);

                        break;

                      case 'merge':
                        _showMergeDialog(provider, item);

                        break;
                    }
                  },

                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'rename',

                      child: Row(
                        children: [
                          Icon(Icons.edit, size: 18),

                          SizedBox(width: 8),

                          Text("重命名"),
                        ],
                      ),
                    ),

                    const PopupMenuItem(
                      value: 'merge',

                      child: Row(
                        children: [
                          Icon(Icons.merge, size: 18),

                          SizedBox(width: 8),

                          Text("合并到..."),
                        ],
                      ),
                    ),

                    const PopupMenuItem(
                      value: 'delete',

                      child: Row(
                        children: [
                          Icon(Icons.delete, size: 18, color: Colors.red),

                          SizedBox(width: 8),

                          Text("删除", style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showEditDialog(Map<String, dynamic> item) {
    final nameController = TextEditingController(text: item['name']);

    String selectedIcon = item['icon'];

    String selectedColor = item['color'];

    final icons = [
      "📷", "👶", "🐶", "🐱", "🚗", "🏠",
      "💼", "✈️", "🍔", "🎮", "📚", "🎵",
    ];

    final colors = [
      "4A90D9", "2ECC71", "FF6B6B", "F39C12",
      "9B59B6", "E67E22", "1ABC9C", "34495E",
    ];

    final provider = context.read<CategoryProvider>();

    showDialog(
      context: context,

      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text("编辑分类"),

              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,

                  children: [
                    TextField(
                      controller: nameController,

                      decoration: const InputDecoration(
                        hintText: "分类名称",

                        border: OutlineInputBorder(),
                      ),
                    ),

                    const SizedBox(height: 16),

                    const Align(
                      alignment: Alignment.centerLeft,

                      child: Text(
                        "图标",

                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),

                    const SizedBox(height: 8),

                    Wrap(
                      spacing: 10,

                      runSpacing: 10,

                      children: icons.map((icon) {
                        final sel = selectedIcon == icon;

                        return GestureDetector(
                          onTap: () {
                            setDialogState(() {
                              selectedIcon = icon;
                            });
                          },

                          child: Container(
                            width: 40,

                            height: 40,

                            alignment: Alignment.center,

                            decoration: BoxDecoration(
                              color: sel
                                  ? Colors.blue.withValues(alpha: 0.2)
                                  : Colors.grey.withValues(alpha: 0.1),

                              borderRadius: BorderRadius.circular(10),

                              border: sel
                                  ? Border.all(color: Colors.blue, width: 2)
                                  : null,
                            ),

                            child: Text(
                              icon,

                              style: const TextStyle(fontSize: 24),
                            ),
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 16),

                    const Align(
                      alignment: Alignment.centerLeft,

                      child: Text(
                        "颜色",

                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),

                    const SizedBox(height: 8),

                    Wrap(
                      spacing: 10,

                      children: colors.map((c) {
                        final sel = selectedColor == c;

                        return GestureDetector(
                          onTap: () {
                            setDialogState(() {
                              selectedColor = c;
                            });
                          },

                          child: Container(
                            width: 36,

                            height: 36,

                            decoration: BoxDecoration(
                              color: Color(int.parse("FF$c", radix: 16)),

                              shape: BoxShape.circle,

                              border: sel
                                  ? Border.all(
                                      color: Colors.black,

                                      width: 3,
                                    )
                                  : null,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),

              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),

                  child: const Text("取消"),
                ),

                ElevatedButton(
                  onPressed: () async {
                    final name = nameController.text.trim();

                    if (name.isEmpty) return;

                    await provider.updateCategory(
                      id: item['id'],

                      name: name,

                      icon: selectedIcon,

                      color: selectedColor,
                    );

                    if (!dialogContext.mounted) return;

                    Navigator.pop(dialogContext);

                    await _loadStats();
                  },

                  child: const Text("保存"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showDeleteDialog(
    CategoryProvider provider,

    Map<String, dynamic> item,
  ) async {
    // 先查询该分类下有多少照片

    final count = await _db.getCategoryPhotoCount(item['id']);

    if (!mounted) return;

    showDialog(
      context: context,

      builder: (dialogContext) {
        return AlertDialog(
          title: const Text("删除分类"),

          content: Text(
            count > 0
                ? "确定删除「${item['name']}」？\n该分类下 $count 张照片将回到待整理状态，需要重新分类。"
                : "确定删除「${item['name']}」？",
          ),

          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),

              child: const Text("取消"),
            ),

            TextButton(
              onPressed: () async {
                await provider.deleteCategory(item['id']);

                if (!dialogContext.mounted) return;

                Navigator.pop(dialogContext);

                await _loadStats();
              },

              child: const Text("删除", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  void _showMergeDialog(
    CategoryProvider provider,

    Map<String, dynamic> item,
  ) {
    final currentCategories = _selectedTab == 0
        ? provider.photoCategories
        : provider.videoCategories;

    final otherCategories = currentCategories
        .where((c) => c['id'] != item['id'])
        .toList();

    showDialog(
      context: context,

      builder: (dialogContext) {
        return AlertDialog(
          title: Text("将「${item['name']}」合并到..."),

          content: SizedBox(
            width: double.maxFinite,

            child: ListView.builder(
              shrinkWrap: true,

              itemCount: otherCategories.length,

              itemBuilder: (context, index) {
                final target = otherCategories[index];

                return ListTile(
                  leading: Text(
                    target['icon'],

                    style: const TextStyle(fontSize: 24),
                  ),

                  title: Text(target['name']),

                  onTap: () async {
                    final targetName = target['name'];

                    await provider.mergeCategory(
                      item['id'],

                      target['id'],
                    );

                    if (!dialogContext.mounted) return;

                    Navigator.pop(dialogContext);

                    await _loadStats();

                    if (!context.mounted) return;

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("已合并到「$targetName」"),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),

              child: const Text("取消"),
            ),
          ],
        );
      },
    );
  }
}
