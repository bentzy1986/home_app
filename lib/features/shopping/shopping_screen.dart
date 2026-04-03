import 'package:flutter/material.dart';
import '../../widgets/detail_list_item.dart';

class ShoppingScreen extends StatelessWidget {
  const ShoppingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A1A),
        elevation: 0,
        title: const Text(
          'קניות',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          DetailListItem(
            title: 'רשימת מכולת',
            icon: Icons.shopping_basket,
            color: Colors.orange,
            onTap: () {},
          ),
          DetailListItem(
            title: 'מלאי מזווה',
            icon: Icons.inventory_2,
            color: Colors.brown,
            onTap: () {},
          ),
          DetailListItem(
            title: 'קניות לבית',
            icon: Icons.chair,
            color: Colors.blueGrey,
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
