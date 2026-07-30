import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/category_provider.dart';
import 'create_category_page.dart';

class CategoryPage extends StatelessWidget {
  const CategoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CategoryProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text("我的分类")),

      body: provider.loading
          ? const Center(child: CircularProgressIndicator())
          : GridView.builder(
              padding: const EdgeInsets.all(16),

              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,

                crossAxisSpacing: 15,

                mainAxisSpacing: 15,
              ),

              itemCount: provider.categories.length + 1,

              itemBuilder: (context, index) {
                // 最后一个按钮 = 创建分类

                if (index == provider.categories.length) {
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,

                        MaterialPageRoute(
                          builder: (_) => const CreateCategoryPage(),
                        ),
                      );
                    },

                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),

                        border: Border.all(color: Colors.blue, width: 2),
                      ),

                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,

                        children: [
                          Icon(Icons.add, size: 40, color: Colors.blue),

                          Text("新建分类", style: TextStyle(color: Colors.blue)),
                        ],
                      ),
                    ),
                  );
                }

                final item = provider.categories[index];

                return GestureDetector(
                  onLongPress: () {
                    if (item['is_default'] == 0) {
                      showDeleteDialog(context, provider, item);
                    }
                  },

                  child: Container(
                    decoration: BoxDecoration(
                      color: Color(
                        int.parse("FF${item['color']}", radix: 16),
                      ).withValues(alpha: 0.15),

                      borderRadius: BorderRadius.circular(20),
                    ),

                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,

                      children: [
                        Text(
                          item['icon'],

                          style: const TextStyle(fontSize: 40),
                        ),

                        const SizedBox(height: 8),

                        Text(
                          item['name'],

                          style: const TextStyle(
                            fontSize: 16,

                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  void showDeleteDialog(
    BuildContext context,

    CategoryProvider provider,

    Map<String, dynamic> item,
  ) {
    showDialog(
      context: context,

      builder: (context) {
        return AlertDialog(
          title: const Text("删除分类"),

          content: Text("确定删除 ${item['name']} ?"),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },

              child: const Text("取消"),
            ),

            TextButton(
              onPressed: () {
                provider.deleteCategory(item['id']);

                Navigator.pop(context);
              },

              child: const Text("删除"),
            ),
          ],
        );
      },
    );
  }
}
