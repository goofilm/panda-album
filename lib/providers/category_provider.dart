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

  // 初始化加载分类

  Future<void> loadCategories() async {
    loading = true;

    notifyListeners();

    categories = await _db.getCategories();

    loading = false;

    notifyListeners();
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
