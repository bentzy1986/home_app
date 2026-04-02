import 'package:flutter/material.dart';
import 'car_maintenance_details.dart';

class CarScreen extends StatelessWidget {
  const CarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A1A), // אותו שחור מדף הבית
        title: const Text(
          'הרכב שלי',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context), // חוזר לדף הבית
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildCarCard(
            context,
            'טיפולים שוטפים',
            Icons.build_circle_rounded,
            Colors.blue,
            const CarMaintenanceDetails(),
          ),
          _buildCarCard(
            context,
            'ביטוח וטסט',
            Icons.verified_user_rounded,
            Colors.red,
            null,
          ),
        ],
      ),
    );
  }

  Widget _buildCarCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    Widget? targetPage,
  ) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 10,
        ),
        leading: Icon(icon, color: color, size: 35),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          if (targetPage != null) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => targetPage),
            );
          }
        },
      ),
    );
  }
}
