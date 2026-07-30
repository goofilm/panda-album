import 'package:flutter/material.dart';

import 'features/home/home_page.dart';

class PhotoOrganizerApp extends StatelessWidget {
  const PhotoOrganizerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      title: "照片整理",

      theme: ThemeData(
        useMaterial3: true,

        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),

      home: const HomePage(),
    );
  }
}
