import 'package:flutter/material.dart';

import 'package:photo_manager/photo_manager.dart';

import '../services/photo_service.dart';

class PhotoProvider extends ChangeNotifier {
  List<AssetEntity> photos = [];

  int total = 0;

  bool loading = false;

  Future<void> loadPhotos() async {
    loading = true;

    notifyListeners();

    photos = await PhotoService.getPhotos();

    total = photos.length;

    debugPrint("最终照片数量:$total");

    loading = false;

    notifyListeners();
  }
}
