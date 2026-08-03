import 'package:flutter/material.dart';

import '../data/database_helper.dart';

class CategoryProvider extends ChangeNotifier {
  final DatabaseHelper _db = DatabaseHelper.instance;

  /// 所有分类

  List<Map<String, dynamic>> categories = [];

  /// 照片分类

  List<Map<String, dynamic>> get photoCategories =>
      categories.where((c) => (c['media_type'] ?? 0) == 0).toList();

  /// 视频分类

  List<Map<String, dynamic>> get videoCategories =>
      categories.where((c) => (c['media_type'] ?? 0) == 1).toList();

  bool loading = false;

  /// 各分类下的媒体数量

  Map<int, int> categoryCounts = {};

  /// 已保留未分类的照片数量（按类型）

  int photoKeptCount = 0;

  int videoKeptCount = 0;

  /// 当前 tab 对应的已保留数量

  int get keptCount => _selectedTab == 1 ? videoKeptCount : photoKeptCount;

  int _selectedTab = 0;

  void setSelectedTab(int tab) {
    _selectedTab = tab;
  }

  // 初始化加载分类

  Future<void> loadCategories() async {
    loading = true;

    notifyListeners();

    categories = await _db.getCategories();

    await _loadAllCounts();

    await _loadKeptCounts();

    loading = false;

    notifyListeners();
  }

  // 加载所有分类的媒体数量

  Future<void> _loadAllCounts() async {
    final counts = <int, int>{};

    for (final cat in categories) {
      final id = cat['id'] as int;

      counts[id] = await _db.getCategoryPhotoCount(id);
    }

    categoryCounts = counts;
  }

  // 加载已保留未分类的数量

  Future<void> _loadKeptCounts() async {
    photoKeptCount = await _db.getKeptUncategorizedCount(mediaType: 0);

    videoKeptCount = await _db.getKeptUncategorizedCount(mediaType: 1);
  }

  // 按类型加载分类

  Future<List<Map<String, dynamic>>> loadCategoriesByType(int mediaType) async {
    return await _db.getCategories(mediaType: mediaType);
  }

  // 添加用户分类

  Future<void> addCategory({
    required String name,

    required String icon,

    required String color,

    int mediaType = 0,
  }) async {
    await _db.addCategory(
      name: name,

      icon: icon,

      color: color,

      mediaType: mediaType,
    );

    await loadCategories();
  }

  // 修改分类

  Future<void> updateCategory({
    required int id,

    required String name,

    required String icon,

    required String color,
  }) async {
    await _db.updateCategory(id: id, name: name, icon: icon, color: color);

    await loadCategories();
  }

  // 删除分类

  Future<void> deleteCategory(int id) async {
    await _db.deleteCategory(id);

    await loadCategories();
  }

  // 合并分类

  Future<void> mergeCategory(int fromId, int toId) async {
    await _db.mergeCategories(fromId, toId);

    await loadCategories();
  }

  // 更新分类排序

  Future<void> updateSortOrder(List<int> categoryIds) async {
    await _db.updateCategorySortOrder(categoryIds);
    await loadCategories();
  }

  // 根据ID查找分类

  Map<String, dynamic>? getCategoryById(int id) {
    try {
      return categories.firstWhere((item) => item['id'] == id);
    } catch (e) {
      return null;
    }
  }

  // 用户分类数量

  int get customCount {
    return categories.where((item) => item['is_default'] == 0).length;
  }
}
