import 'package:flutter/material.dart';

class RegistrationTestScreen extends StatefulWidget {
  final Map<String, dynamic> carData;
  const RegistrationTestScreen({super.key, required this.carData});

  @override
  State<RegistrationTestScreen> createState() => _RegistrationTestScreenState();
}

class _RegistrationTestScreenState extends State<RegistrationTestScreen> {
  // משתני תאריך מסוג DateTime כדי להקל על החישובים
  DateTime _feeDate = DateTime(2026, 5, 1);
  bool _isFeePaid = false;

  DateTime _testDate = DateTime(2026, 6, 15);
  bool _isTestDone = false;

  // פונקציה שמחשבת כמה ימים נשארו ומחזירה טקסט מעוצב
  String _getDaysRemaining(DateTime targetDate) {
    final now = DateTime.now();
    final difference = targetDate
        .difference(DateTime(now.year, now.month, now.day))
        .inDays;

    if (difference < 0) return "עבר הזמן! (${difference.abs()} ימים באיחור)";
    if (difference == 0) return "היום האחרון!";
    if (difference <= 14) return "נשארו $difference ימים - דחוף!";
    return "נשארו עוד $difference ימים";
  }

  // פונקציה עזר להפיכת DateTime לטקסט תצוגה (DD/MM/YYYY)
  String _formatDate(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
  }

  Future<void> _selectDate(BuildContext context, bool isFee) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isFee ? _feeDate : _testDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        if (isFee) {
          _feeDate = picked;
        } else {
          _testDate = picked;
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
          'טסט ורישוי שנתי',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            _buildStatusCard(
              title: 'תשלום אגרת רישיון',
              date: _feeDate,
              isDone: _isFeePaid,
              icon: Icons.receipt_long_rounded,
              color: Colors.blue,
              onDateTap: () => _selectDate(context, true),
              onToggle: (val) => setState(() => _isFeePaid = val!),
            ),
            const SizedBox(height: 20),
            _buildStatusCard(
              title: 'ביצוע טסט במכון',
              date: _testDate,
              isDone: _isTestDone,
              icon: Icons.fact_check_rounded,
              color: Colors.green,
              onDateTap: () => _selectDate(context, false),
              onToggle: (val) => setState(() => _isTestDone = val!),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard({
    required String title,
    required DateTime date,
    required bool isDone,
    required IconData icon,
    required Color color,
    required VoidCallback onDateTap,
    required Function(bool?) onToggle,
  }) {
    String daysLeftText = _getDaysRemaining(date);
    bool isOverdue = date.difference(DateTime.now()).inDays < 0 && !isDone;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: Colors.grey.withValues(alpha: 0.1)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: color.withValues(alpha: 0.1),
                  child: Icon(icon, color: color),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                    ),
                  ),
                ),
                Checkbox(
                  value: isDone,
                  onChanged: onToggle,
                  activeColor: color,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
              ],
            ),
            const Divider(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'תאריך יעד:',
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    TextButton(
                      onPressed: onDateTap,
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                      ),
                      child: Text(
                        _formatDate(date),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
                // כאן הוספנו את חישוב הימים
                if (!isDone)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: isOverdue
                          ? Colors.red.withValues(alpha: 0.1)
                          : Colors.orange.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      daysLeftText,
                      style: TextStyle(
                        color: isOverdue ? Colors.red : Colors.orange[800],
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  )
                else
                  const Icon(Icons.check_circle, color: Colors.green),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
