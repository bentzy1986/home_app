import 'package:flutter/material.dart';

class CarMaintenanceDetails extends StatelessWidget {
  const CarMaintenanceDetails({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('טיפולים שוטפים'),
        backgroundColor: Colors.blue[100],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildMaintenanceItem(
            'טיפול 10,000',
            '12/01/2026',
            'הוחלף שמן ופילטרים',
            '₪850',
          ),
          _buildMaintenanceItem(
            'החלפת צמיגים',
            '05/11/2025',
            'זוג קדמי - Michelin',
            '₪1,200',
          ),
          _buildMaintenanceItem(
            'החלפת מצבר',
            '20/08/2025',
            'מצבר Varta 60Ah',
            '₪650',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        tooltip: 'הוסף טיפול חדש',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildMaintenanceItem(
    String title,
    String date,
    String desc,
    String price,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('$date\n$desc'),
        isThreeLine: true,
        trailing: Text(
          price,
          style: const TextStyle(
            color: Colors.green,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
