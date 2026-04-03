import 'package:flutter/material.dart';

class CarDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> carData;
  const CarDetailsScreen({super.key, required this.carData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('פירוט: ${carData['nickname']}')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'היסטוריית טיפולים',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 15),
          _buildServiceItem('טיפול שנתי', '10/02/2026', '₪1,200', 'מוסך המרכז'),
          _buildServiceItem(
            'החלפת צמיגים',
            '05/11/2025',
            '₪1,800',
            'צמיגי העיר',
          ),
          const SizedBox(height: 30),
          const Text(
            'מסמכים סרוקים',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 15),
          Card(
            child: ListTile(
              leading: const Icon(Icons.picture_as_pdf, color: Colors.red),
              title: const Text('פוליסת ביטוח מקיף 2026'),
              trailing: const Icon(Icons.open_in_new),
              onTap: () {},
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.black,
        onPressed: () {},
        child: const Icon(Icons.add_a_photo, color: Colors.white),
      ),
    );
  }

  Widget _buildServiceItem(
    String title,
    String date,
    String price,
    String garage,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('$date | $garage'),
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
