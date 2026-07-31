import 'package:flutter/material.dart';

import '../data/database_helper.dart';

class PrivateAlbumProvider extends ChangeNotifier {
  final DatabaseHelper _db = DatabaseHelper.instance;

  /// 所有私密相册
  List<Map<String, dynamic>> privateAlbums = [];

  /// 照片私密相册
  List<Map<String, dynamic>> get photoAlbums =>
      privateAlbums.where((a) => (a['media_type'] ?? 0) == 0).toList();

  /// 视频私密相册
  List<Map<String, dynamic>> get videoAlbums =>
      privateAlbums.where((a) => (a['media_type'] ?? 0) == 1).toList();

  /// 各相册下的照片数量
  Map<int, int> albumCounts = {};

  /// 是否已解锁（通过 PIN 验证）
  bool _isUnlocked = false;

  bool get isUnlocked => _isUnlocked;

  bool loading = false;

  /// 解锁私密相册
  void unlock() {
    _isUnlocked = true;
    notifyListeners();
  }

  /// 锁定
  void lock() {
    _isUnlocked = false;
    notifyListeners();
  }

  /// 加载所有私密相册
  Future<void> loadAlbums() async {
    loading = true;
    notifyListeners();

    privateAlbums = await _db.getPrivateAlbums();
    await _loadAllCounts();

    loading = false;
    notifyListeners();
  }

  /// 加载所有相册的照片数量
  Future<void> _loadAllCounts() async {
    final counts = <int, int>{};
    for (final album in privateAlbums) {
      final id = album['id'] as int;
      counts[id] = await _db.getPrivatePhotoCount(id);
    }
    albumCounts = counts;
  }

  /// 创建私密相册
  Future<void> addAlbum({
    required String name,
    required String icon,
    required String color,
    int mediaType = 0,
  }) async {
    await _db.addPrivateAlbum(
      name: name,
      icon: icon,
      color: color,
      mediaType: mediaType,
    );
    await loadAlbums();
  }

  /// 删除私密相册
  Future<void> deleteAlbum(int id) async {
    await _db.deletePrivateAlbum(id);
    await loadAlbums();
  }

  /// 修改私密相册
  Future<void> updateAlbum({
    required int id,
    required String name,
    required String icon,
    required String color,
  }) async {
    await _db.updatePrivateAlbum(
      id: id,
      name: name,
      icon: icon,
      color: color,
    );
    await loadAlbums();
  }

  /// 添加照片到私密相册
  Future<void> addPhotoToAlbum({
    required String assetId,
    required int albumId,
    int mediaType = 0,
  }) async {
    await _db.addPhotoToPrivateAlbum(
      assetId: assetId,
      albumId: albumId,
      mediaType: mediaType,
    );
    await _loadAllCounts();
    notifyListeners();
  }

  /// 从私密相册移除照片
  Future<void> removePhotoFromAlbum(String assetId) async {
    await _db.removePhotoFromPrivateAlbum(assetId);
    await _loadAllCounts();
    notifyListeners();
  }

  /// 获取私密相册中的照片
  Future<List<Map<String, dynamic>>> getPrivatePhotos(int albumId) async {
    return await _db.getPrivatePhotos(albumId);
  }

  /// 是否已设置 PIN
  Future<bool> hasPinSet() async {
    return await _db.hasPinSet();
  }

  /// 保存 PIN
  Future<void> savePin(String pin) async {
    await _db.savePin(pin);
  }

  /// 验证 PIN
  Future<bool> verifyPin(String pin) async {
    return await _db.verifyPin(pin);
  }

  /// 删除 PIN
  Future<void> deletePin() async {
    await _db.deletePin();
    _isUnlocked = false;
    notifyListeners();
  }

  /// 私密照片总数
  int get totalPrivateCount {
    return albumCounts.values.fold(0, (a, b) => a + b);
  }
}
