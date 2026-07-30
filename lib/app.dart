import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'features/home/home_page.dart';

import 'providers/photo_provider.dart';
import 'providers/category_provider.dart';

class PhotoOrganizerApp extends StatelessWidget {
  const PhotoOrganizerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // 照片数据
        ChangeNotifierProvider(create: (_) => PhotoProvider()),

        // 分类数据
        ChangeNotifierProvider(
          create: (_) => CategoryProvider()..loadCategories(),
        ),
      ],

      child: MaterialApp(
        debugShowCheckedModeBanner: false,

        title: "照片整理",

        theme: ThemeData(
          useMaterial3: true,

          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        ),

        home: const HomePage(),
      ),
    );
  }
}
