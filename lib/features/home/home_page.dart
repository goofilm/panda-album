import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
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

              child: CircularProgressIndicator(strokeWidth: 12, value: 0.35),
            ),

            const SizedBox(height: 20),

            const Text("还剩 350 张待整理", style: TextStyle(fontSize: 20)),

            const Spacer(),

            Container(
              padding: const EdgeInsets.all(20),

              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,

                children: [
                  _bottomButton(Icons.category, "我的分类"),

                  FloatingActionButton(
                    onPressed: () {},

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
