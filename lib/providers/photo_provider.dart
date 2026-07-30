import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';

class PhotoProvider extends ChangeNotifier {
  List<AssetEntity> photos = [];

  bool loading = false;

  int total = 0;

  int get remaining => photos.length;

  // 加载照片

  Future<void> loadPhotos() async {
    loading = true;

    notifyListeners();

    final permission = await PhotoManager.requestPermissionExtend();

    if (permission.isAuth) {
      final albums = await PhotoManager.getAssetPathList(
        type: RequestType.image,
      );

      if (albums.isNotEmpty) {
        final list = await albums.first.getAssetListPaged(page: 0, size: 50);

        photos = list;

        total = list.length;
      }
    }

    loading = false;

    notifyListeners();
  }

  // 删除当前照片（给滑动页面调用）

  void removeCurrentPhoto() {
    if (photos.isNotEmpty) {
      photos.removeAt(0);
    }

    notifyListeners();
  }
}
