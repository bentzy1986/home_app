import 'package:flutter/material.dart';

class MaintenanceScreen extends StatelessWidget {
  const MaintenanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: AppBar(
        title: const Text(
          'תחזוקת הבית',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'משימות פתוחות',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 15),
          _buildTaskTile(
            'תיקון נזילה בכיור',
            'דחוף',
            Icons.water_drop,
            Colors.red,
          ),
          _buildTaskTile(
            'החלפת פילטר במזגן',
            'תחזוקה',
            Icons.ac_unit,
            Colors.orange,
          ),
          _buildTaskTile(
            'צביעת קיר בסלון',
            'פרויקט',
            Icons.format_paint,
            Colors.purple,
          ),
          const SizedBox(height: 30),
          const Text(
            'אנשי מקצוע',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 15),
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: const ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.blueGrey,
                child: Icon(Icons.person, color: Colors.white),
              ),
              title: Text(
                'יוסי אינסטלטור',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text('050-1234567'),
              trailing: Icon(Icons.phone, color: Colors.green),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskTile(String title, String tag, IconData icon, Color color) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(
          tag,
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        trailing: const Icon(Icons.check_circle_outline, color: Colors.grey),
      ),
    );
  }
}
