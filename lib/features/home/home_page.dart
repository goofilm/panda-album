import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/photo_provider.dart';
import '../swipe/swipe_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PhotoProvider>().loadPhotos();
    });
  }

  @override
  Widget build(BuildContext context) {
    final photoProvider = context.watch<PhotoProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text("照片整理"),

        actions: [
          IconButton(icon: const Icon(Icons.language), onPressed: () {}),

          IconButton(
            icon: const Icon(Icons.workspace_premium),

            onPressed: () {},
          ),
        ],
      ),

      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 40),

            const Icon(Icons.inventory_2, size: 100, color: Colors.blue),

            const SizedBox(height: 30),

            const Text(
              "整理照片",

              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: 150,

              height: 150,

              child: CircularProgressIndicator(
                strokeWidth: 12,

                value: photoProvider.total == 0 ? 0 : 0.35,
              ),
            ),

            const SizedBox(height: 20),

            Text(
              photoProvider.loading
                  ? "正在扫描照片..."
                  : "还剩 ${photoProvider.total} 张待整理",

              style: const TextStyle(fontSize: 20),
            ),

            const Spacer(),

            Container(
              padding: const EdgeInsets.all(20),

              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,

                children: [
                  _bottomButton(Icons.category, "我的分类"),

                  FloatingActionButton(
                    onPressed: () {
                      Navigator.push(
                        context,

                        MaterialPageRoute(builder: (_) => const SwipePage()),
                      );
                    },

                    child: const Icon(Icons.play_arrow),
                  ),

                  _bottomButton(Icons.delete, "回收站"),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _bottomButton(IconData icon, String text) {
    return Column(
      mainAxisSize: MainAxisSize.min,

      children: [Icon(icon), Text(text)],
    );
  }
}
