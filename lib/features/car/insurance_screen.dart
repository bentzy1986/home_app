import 'package:flutter/material.dart';

class InsuranceScreen extends StatefulWidget {
  final Map<String, dynamic> carData;
  const InsuranceScreen({super.key, required this.carData});

  @override
  State<InsuranceScreen> createState() => _InsuranceScreenState();
}

class _InsuranceScreenState extends State<InsuranceScreen> {
  DateTime _mandatoryExpiry = DateTime(2026, 9, 1);
  DateTime _comprehensiveExpiry = DateTime(2026, 9, 1);

  final _companyController = TextEditingController(text: "הפניקס");
  final _policyController = TextEditingController(text: "123456789");

  String _getDaysRemaining(DateTime targetDate) {
    final now = DateTime.now();
    final difference = targetDate
        .difference(DateTime(now.year, now.month, now.day))
        .inDays;
    if (difference < 0) {
      return "פג תוקף! (${difference.abs()} ימים)";
    }
    if (difference <= 30) {
      return "נשארו $difference ימים - לחדש!";
    }
    return "נשארו עוד $difference ימים";
  }

  String _formatDate(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
  }

  Future<void> _selectDate(BuildContext context, bool isMandatory) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isMandatory ? _mandatoryExpiry : _comprehensiveExpiry,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        if (isMandatory) {
          _mandatoryExpiry = picked;
        } else {
          _comprehensiveExpiry = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text(
          'ביטוח רכב',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            _buildInfoCard(),
            const SizedBox(height: 20),
            _buildInsuranceTypeCard(
              title: 'ביטוח חובה',
              expiryDate: _mandatoryExpiry,
              icon: Icons.gavel_rounded,
              color: Colors.blue,
              onTap: () => _selectDate(context, true),
            ),
            const SizedBox(height: 15),
            _buildInsuranceTypeCard(
              title: 'ביטוח מקיף / צד ג\'',
              expiryDate: _comprehensiveExpiry,
              icon: Icons.shield_rounded,
              color: Colors.green,
              onTap: () => _selectDate(context, false),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: Colors.grey.withValues(alpha: 0.1)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _companyController,
              textAlign: TextAlign.right,
              decoration: const InputDecoration(
                labelText: 'חברת ביטוח / סוכן',
                prefixIcon: Icon(Icons.business),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _policyController,
              textAlign: TextAlign.right,
              decoration: const InputDecoration(
                labelText: 'מספר פוליסה',
                prefixIcon: Icon(Icons.tag),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInsuranceTypeCard({
    required String title,
    required DateTime expiryDate,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    final String daysLeftText = _getDaysRemaining(expiryDate);
    final bool isUrgent = expiryDate.difference(DateTime.now()).inDays <= 30;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: Colors.grey.withValues(alpha: 0.1)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(15),
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.1),
          child: Icon(icon, color: color),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 5),
            Text('בתוקף עד: ${_formatDate(expiryDate)}'),
            const SizedBox(height: 5),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: isUrgent
                    ? Colors.red.withValues(alpha: 0.1)
                    : Colors.green.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                daysLeftText,
                style: TextStyle(
                  color: isUrgent ? Colors.red : Colors.green[700],
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.calendar_month, color: Colors.grey),
          onPressed: onTap,
        ),
      ),
    );
  }
}
