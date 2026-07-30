import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/category_provider.dart';

class CreateCategoryPage extends StatefulWidget {
  const CreateCategoryPage({super.key});

  @override
  State<CreateCategoryPage> createState() => _CreateCategoryPageState();
}

class _CreateCategoryPageState extends State<CreateCategoryPage> {
  final TextEditingController nameController = TextEditingController();

  String selectedIcon = "📷";

  String selectedColor = "4A90D9";

  final List<String> icons = [
    "📷",
    "👶",
    "🐶",
    "🐱",
    "🚗",
    "🏠",
    "💼",
    "✈️",
    "🍔",
    "🎮",
    "📚",
    "🎵",
    "❤️",
    "⭐",
    "🌈",
    "📱",
  ];

  final List<String> colors = [
    "4A90D9",
    "2ECC71",
    "FF6B6B",
    "F39C12",
    "9B59B6",
    "E67E22",
    "1ABC9C",
    "34495E",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("创建分类")),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            const Text(
              "分类名称",

              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            TextField(
              controller: nameController,

              decoration: const InputDecoration(
                hintText: "例如：宝宝、宠物、汽车",

                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 25),

            const Text(
              "选择图标",

              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            Wrap(
              spacing: 15,

              runSpacing: 15,

              children: icons.map((icon) {
                final selected = selectedIcon == icon;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedIcon = icon;
                    });
                  },

                  child: Container(
                    width: 45,

                    height: 45,

                    alignment: Alignment.center,

                    decoration: BoxDecoration(
                      color: selected
                          ? Colors.blue.withOpacity(0.2)
                          : Colors.grey.withOpacity(0.1),

                      borderRadius: BorderRadius.circular(12),

                      border: selected
                          ? Border.all(color: Colors.blue, width: 2)
                          : null,
                    ),

                    child: Text(icon, style: const TextStyle(fontSize: 28)),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 25),

            const Text(
              "选择颜色",

              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            Wrap(
              spacing: 15,

              children: colors.map((color) {
                final selected = selectedColor == color;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedColor = color;
                    });
                  },

                  child: Container(
                    width: 40,

                    height: 40,

                    decoration: BoxDecoration(
                      color: Color(int.parse("FF$color", radix: 16)),

                      shape: BoxShape.circle,

                      border: selected
                          ? Border.all(color: Colors.black, width: 3)
                          : null,
                    ),
                  ),
                );
              }).toList(),
            ),

            const Spacer(),

            SizedBox(
              width: double.infinity,

              height: 50,

              child: ElevatedButton(
                onPressed: saveCategory,

                child: const Text("保存分类", style: TextStyle(fontSize: 18)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void saveCategory() {
    final name = nameController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("请输入分类名称")));

      return;
    }

    context.read<CategoryProvider>().addCategory(
      name: name,

      icon: selectedIcon,

      color: selectedColor,
    );

    Navigator.pop(context);
  }

  @override
  void dispose() {
    nameController.dispose();

    super.dispose();
  }
}
