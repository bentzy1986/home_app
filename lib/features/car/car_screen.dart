import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'car_details_screen.dart';

class CarScreen extends StatefulWidget {
  const CarScreen({super.key});
  @override
  State<CarScreen> createState() => _CarScreenState();
}

class _CarScreenState extends State<CarScreen> {
  final List<Map<String, dynamic>> _cars = [
    {
      'plate': '12-345-67',
      'nickname': 'יונדאי משפחתית',
      'testDate': '2026-08-15',
      'licenseDate': '2026-08-15',
      'mandatoryInsurance': '2027-01-01',
      'comprehensiveInsurance': '2027-01-01',
      'history': <Map<String, String>>[],
    },
    {
      'plate': '99-888-77',
      'nickname': 'קיה פיקנטו',
      'testDate': '2026-11-20',
      'licenseDate': '2026-11-20',
      'mandatoryInsurance': '2026-05-10',
      'comprehensiveInsurance': '2026-05-10',
      'history': <Map<String, String>>[],
    },
  ];

  int _currentCarIndex = 0;

  int _daysLeft(String dateStr) {
    try {
      final expiry = DateTime.parse(dateStr);
      return expiry.difference(DateTime.now()).inDays;
    } catch (e) {
      return 0;
    }
  }

  Future<void> _selectDate(
    BuildContext context,
    TextEditingController controller,
  ) async {
    DateTime initialDate = DateTime.now();
    try {
      initialDate = DateTime.parse(controller.text);
    } catch (_) {}
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );
    if (picked != null) {
      setState(() {
        controller.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  void _editCar(int index) {
    final car = _cars[index];
    final nC = TextEditingController(text: car['nickname']);
    final pC = TextEditingController(text: car['plate']);
    final tC = TextEditingController(text: car['testDate']);
    final lC = TextEditingController(text: car['licenseDate']);
    final mC = TextEditingController(text: car['mandatoryInsurance']);
    final cC = TextEditingController(text: car['comprehensiveInsurance']);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
          left: 20,
          right: 20,
          top: 20,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'עריכת פרטי רכב',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: nC,
                textAlign: TextAlign.right,
                decoration: const InputDecoration(labelText: 'כינוי'),
              ),
              TextField(
                controller: pC,
                textAlign: TextAlign.right,
                decoration: const InputDecoration(labelText: 'מספר רישוי'),
              ),
              _buildDateField(tC, 'תאריך טסט'),
              _buildDateField(lC, 'רישיון רכב'),
              _buildDateField(mC, 'ביטוח חובה'),
              _buildDateField(cC, 'ביטוח מקיף'),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  minimumSize: const Size(double.infinity, 45),
                ),
                onPressed: () {
                  setState(() {
                    _cars[index].addAll({
                      'nickname': nC.text,
                      'plate': pC.text,
                      'testDate': tC.text,
                      'licenseDate': lC.text,
                      'mandatoryInsurance': mC.text,
                      'comprehensiveInsurance': cC.text,
                    });
                  });
                  Navigator.pop(ctx);
                },
                child: const Text(
                  'שמור שינויים',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateField(TextEditingController controller, String label) {
    return TextField(
      controller: controller,
      readOnly: true,
      textAlign: TextAlign.right,
      onTap: () => _selectDate(context, controller),
      decoration: InputDecoration(
        labelText: label,
        suffixIcon: const Icon(Icons.calendar_today, size: 18),
      ),
    );
  }

  Widget _buildStatusTile(
    String title,
    String date,
    IconData icon,
    Color color,
  ) {
    final days = _daysLeft(date);
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.1),
          child: Icon(icon, color: color),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(
          'חידוש ב: ${DateFormat('dd/MM/yyyy').format(DateTime.parse(date))}',
        ),
        trailing: Text(
          '$days ימים',
          style: TextStyle(
            color: days < 30 ? Colors.red : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final car = _cars[_currentCarIndex];
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: AppBar(
        title: const Text('ניהול רכבים'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => _editCar(_currentCarIndex),
          ),
          IconButton(
            icon: const Icon(Icons.swap_horiz),
            onPressed: () {
              setState(() {
                _currentCarIndex = (_currentCarIndex + 1) % _cars.length;
              });
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              car['nickname'],
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),
            GestureDetector(
              onTap: () => _editCar(_currentCarIndex),
              child: Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFD700),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(width: 2),
                ),
                child: Text(
                  car['plate'],
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
            _buildStatusTile(
              'טסט שנתי',
              car['testDate'],
              Icons.fact_check,
              Colors.orange,
            ),
            _buildStatusTile(
              'רישיון רכב',
              car['licenseDate'],
              Icons.assignment,
              Colors.blue,
            ),
            _buildStatusTile(
              'ביטוח חובה',
              car['mandatoryInsurance'],
              Icons.security,
              Colors.green,
            ),
            _buildStatusTile(
              'ביטוח מקיף',
              car['comprehensiveInsurance'],
              Icons.shield,
              Colors.teal,
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (c) => CarDetailsScreen(carData: car),
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text(
                'היסטוריית טיפולים ומסמכים',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
