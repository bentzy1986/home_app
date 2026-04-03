import 'package:flutter/material.dart';
import '../../widgets/detail_list_item.dart';

class HealthScreen extends StatelessWidget {
  const HealthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A1A),
        elevation: 0,
        title: const Text(
          'בריאות',
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
            title: 'תורים לרופאים',
            icon: Icons.calendar_today,
            color: Colors.blue,
            onTap: () {},
          ),
          DetailListItem(
            title: 'ניהול תרופות',
            icon: Icons.medication,
            color: Colors.red,
            onTap: () {},
          ),
          DetailListItem(
            title: 'מעקב בדיקות',
            icon: Icons.biotech,
            color: Colors.orange,
            onTap: () {},
          ),
          DetailListItem(
            title: 'כושר ותזונה',
            icon: Icons.fitness_center,
            color: Colors.green,
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
