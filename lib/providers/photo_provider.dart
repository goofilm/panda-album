import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:photo_manager/photo_manager.dart';

import '../data/database_helper.dart';

/// 媒体类型筛选
enum MediaTypeFilter { all, image, video }

class PhotoProvider extends ChangeNotifier {
  final DatabaseHelper _db = DatabaseHelper.instance;

  List<AssetEntity> photos = [];

  List<AssetEntity> videos = [];

  // 回收站照片列表

  List<Map<String, dynamic>> recyclePhotos = [];

  bool loading = false;

  /// 相册中媒体总数

  int albumTotal = 0;

  /// 照片总数

  int imageCount = 0;

  /// 视频总数

  int videoCount = 0;

  /// 已整理照片数

  int organizedPhotoCount = 0;

  /// 已整理视频数

  int organizedVideoCount = 0;

  int recycleBinCount = 0;

  /// 当前已加载的页数

  int _currentPage = 0;

  static const int _pageSize = 50;

  bool hasMore = true;

  /// 当前筛选类型

  MediaTypeFilter mediaFilter = MediaTypeFilter.all;

  /// 是否已初始化过

  bool _photoInitialized = false;

  bool _videoInitialized = false;

  /// 已处理的 asset_id 集合（避免重复加载）

  Set<String> _processedIds = {};

  int get remaining => mediaFilter == MediaTypeFilter.video
      ? videos.length
      : photos.length;

  /// 按类型获取相册总数

  int getAlbumTotal(MediaTypeFilter filter) {
    switch (filter) {
      case MediaTypeFilter.image:
        return imageCount;
      case MediaTypeFilter.video:
        return videoCount;
      case MediaTypeFilter.all:
        return imageCount + videoCount;
    }
  }

  /// 按类型获取已整理数

  int getOrganizedCount(MediaTypeFilter filter) {
    switch (filter) {
      case MediaTypeFilter.image:
        return organizedPhotoCount;
      case MediaTypeFilter.video:
        return organizedVideoCount;
      case MediaTypeFilter.all:
        return organizedPhotoCount + organizedVideoCount;
    }
  }

  // 加载照片（带缓存，不会重复加载）

  Future<void> loadPhotos({MediaTypeFilter filter = MediaTypeFilter.all}) async {
    final needPhotoLoad = filter != MediaTypeFilter.video && !_photoInitialized;
    final needVideoLoad = filter != MediaTypeFilter.image && !_videoInitialized;

    if (!needPhotoLoad && !needVideoLoad && photos.isNotEmpty) {
      // 已经加载过，只刷新统计
      await refreshStats();
      return;
    }

    loading = true;
    mediaFilter = filter;
    notifyListeners();

    // 启动时自动清理超过30天的回收站记录
    await _db.deleteExpiredPhotos(30);

    // 获取已处理的 asset_id
    _processedIds = await _db.getProcessedAssetIds();

    final permission = await PhotoManager.requestPermissionExtend();

    if (permission.isAuth) {
      // 统计各类型数量（只算一次）
      if (imageCount == 0 || videoCount == 0) {
        await _countMediaTypes();
      }

      // 加载照片
      if (needPhotoLoad) {
        await _loadAssets(RequestType.image, isPhoto: true);
        _photoInitialized = true;
      }

      // 加载视频
      if (needVideoLoad) {
        await _loadAssets(RequestType.video, isPhoto: false);
        _videoInitialized = true;
      }

      // 设置当前筛选
      mediaFilter = filter;
    }

    await refreshStats();
    loading = false;
    notifyListeners();

    // 注册相册变化监听
    startListeningToChanges();
  }

  // 加载指定类型的资产

  Future<void> _loadAssets(RequestType type, {required bool isPhoto}) async {
    final albums = await PhotoManager.getAssetPathList(type: type);

    if (albums.isNotEmpty) {
      final album = albums.first;
      final list = await album.getAssetListPaged(page: 0, size: _pageSize);

      // 过滤掉已处理的
      final filtered = list.where((a) => !_processedIds.contains(a.id)).toList();

      if (isPhoto) {
        photos = filtered;
      } else {
        videos = filtered;
      }
    }
  }

  // 加载更多（分页）

  Future<void> loadMorePhotos() async {
    if (!hasMore || loading) return;

    final isVideo = mediaFilter == MediaTypeFilter.video;
    final requestType = isVideo ? RequestType.video : RequestType.image;

    final albums = await PhotoManager.getAssetPathList(type: requestType);
    if (albums.isEmpty) return;

    _currentPage++;
    final list = await albums.first.getAssetListPaged(
      page: _currentPage,
      size: _pageSize,
    );

    if (list.isEmpty || list.length < _pageSize) {
      hasMore = false;
    }

    final filtered = list.where((a) => !_processedIds.contains(a.id)).toList();

    if (isVideo) {
      videos.addAll(filtered);
    } else {
      photos.addAll(filtered);
    }

    notifyListeners();
  }

  // 统计各媒体类型数量

  Future<void> _countMediaTypes() async {
    try {
      final imageAlbums = await PhotoManager.getAssetPathList(
        type: RequestType.image,
      );

      final videoAlbums = await PhotoManager.getAssetPathList(
        type: RequestType.video,
      );

      imageCount = imageAlbums.isNotEmpty
          ? await imageAlbums.first.assetCountAsync
          : 0;

      videoCount = videoAlbums.isNotEmpty
          ? await videoAlbums.first.assetCountAsync
          : 0;

      albumTotal = imageCount + videoCount;
    } catch (e) {
      imageCount = 0;
      videoCount = 0;
    }
  }

  // 切换媒体类型筛选（仅刷新UI，不重新加载）

  void switchFilter(MediaTypeFilter filter) {
    if (filter == mediaFilter) return;
    mediaFilter = filter;
    notifyListeners();
  }

  // 刷新统计数据

  Future<void> refreshStats() async {
    organizedPhotoCount = await _db.getOrganizedCountByType(0);
    organizedVideoCount = await _db.getOrganizedCountByType(1);
    recycleBinCount = await _db.getRecycleBinCount();
    notifyListeners();
  }

  // 加载回收站照片

  Future<void> loadRecyclePhotos() async {
    recyclePhotos = await _db.getRecyclePhotos();
    recycleBinCount = recyclePhotos.length;
    notifyListeners();
  }

  // 恢复单张照片

  Future<void> restorePhoto(int id) async {
    await _db.restorePhoto(id);
    await loadRecyclePhotos();
  }

  // 永久删除单张照片（同时从设备删除）

  Future<void> permanentDeletePhoto(int id) async {
    final assetId = await _db.permanentDeletePhoto(id);

    // 从设备相册真正删除文件

    if (assetId != null) {
      try {
        await PhotoManager.editor.deleteWithIds([assetId]);
      } catch (e) {
        // 忽略删除失败，DB记录已删
      }

      // 刷新设备媒体计数

      await _countMediaTypes();
    }

    await loadRecyclePhotos();
  }

  // 全部恢复

  Future<void> restoreAll() async {
    await _db.restoreAllPhotos();
    await loadRecyclePhotos();
  }

  // 清空回收站（同时从设备删除所有文件）

  Future<void> clearRecycleBin() async {
    final assetIds = await _db.clearRecycleBin();

    // 从设备相册真正删除所有文件

    if (assetIds.isNotEmpty) {
      try {
        await PhotoManager.editor.deleteWithIds(assetIds);
      } catch (e) {
        // 忽略删除失败，DB记录已删
      }

      // 刷新设备媒体计数

      await _countMediaTypes();
    }

    await loadRecyclePhotos();
  }

  // 移除当前照片（给滑动页面调用）

  Future<void> removeCurrentPhoto({bool isVideo = false}) async {
    final list = isVideo ? videos : photos;

    if (list.isNotEmpty) {
      final removed = list.removeAt(0);
      _processedIds.add(removed.id);
    }

    // 剩余少于5张时自动加载更多
    if (list.length < 5 && hasMore) {
      await loadMorePhotos();
    }

    notifyListeners();
  }

  // 将照片重新插入列表头部（用于撤销操作）

  void reinsertPhoto(AssetEntity photo, {bool isVideo = false}) {
    if (isVideo) {
      videos.insert(0, photo);
    } else {
      photos.insert(0, photo);
    }

    _processedIds.remove(photo.id);

    notifyListeners();
  }

  /// 是否已注册的相册变化监听

  bool _changeCallbackRegistered = false;

  /// 防抖定时器

  DateTime? _lastChangeTime;

  /// 保存回调引用以便移除

  ValueChanged<MethodCall>? _changeCallback;

  /// 强制重新加载（用户手动触发）

  Future<void> forceReload() async {
    _photoInitialized = false;
    _videoInitialized = false;
    photos.clear();
    videos.clear();
    _currentPage = 0;
    hasMore = true;
    await loadPhotos();
  }

  /// 注册相册变化监听（拍照/删除等操作后自动刷新）

  void startListeningToChanges() {
    if (_changeCallbackRegistered) return;

    _changeCallback = (MethodCall call) async {
      // 防抖：2秒内只响应一次
      final now = DateTime.now();
      if (_lastChangeTime != null &&
          now.difference(_lastChangeTime!) < const Duration(seconds: 2)) {
        return;
      }
      _lastChangeTime = now;

      debugPrint('检测到相册变化，自动刷新...');
      await forceReload();
    };

    PhotoManager.addChangeCallback(_changeCallback!);
    PhotoManager.startChangeNotify();
    _changeCallbackRegistered = true;
  }

  /// 停止监听

  void stopListeningToChanges() {
    if (_changeCallbackRegistered && _changeCallback != null) {
      PhotoManager.removeChangeCallback(_changeCallback!);
      _changeCallbackRegistered = false;
    }
  }
}
