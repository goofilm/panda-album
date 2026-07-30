import 'package:flutter/foundation.dart';
import 'package:photo_manager/photo_manager.dart';

class PhotoService {
  static Future<bool> requestPermission() async {
    final PermissionState state = await PhotoManager.requestPermissionExtend();

    debugPrint("权限状态:$state");

    return state.isAuth;
  }

  static Future<int> getPhotoCount() async {
    final List<AssetPathEntity> albums = await PhotoManager.getAssetPathList(
      type: RequestType.image,

      onlyAll: true,
    );

    if (albums.isEmpty) {
      debugPrint("没有找到相册");

      return 0;
    }

    final AssetPathEntity allPhotos = albums.first;

    final int count = await allPhotos.assetCountAsync;

    debugPrint("照片数量:$count");

    return count;
  }

  static Future<List<AssetEntity>> getPhotos() async {
    final List<AssetPathEntity> albums = await PhotoManager.getAssetPathList(
      type: RequestType.image,

      onlyAll: true,
    );

    if (albums.isEmpty) {
      return [];
    }

    final List<AssetEntity> photos = await albums.first.getAssetListPaged(
      page: 0,

      size: 50,
    );

    debugPrint("读取照片:${photos.length}");

    return photos;
  }
}
