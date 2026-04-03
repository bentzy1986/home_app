import 'package:flutter/material.dart';

class FinanceDashboardScreen extends StatefulWidget {
  const FinanceDashboardScreen({super.key});
  @override
  State<FinanceDashboardScreen> createState() => _FinanceDashboardScreenState();
}

class _FinanceDashboardScreenState extends State<FinanceDashboardScreen> {
  double balance = 12550.0,
      income = 15000.0,
      expenses = 8400.0,
      budget = 10000.0;
  final List<Map<String, dynamic>> _trans = [
    {
      't': 'סופרמרקט',
      'a': -450.0,
      'c': 'מזון',
      'd': 'היום',
      'i': Icons.shopping_cart,
    },
    {
      't': 'משכורת',
      'a': 15000.0,
      'c': 'הכנסה',
      'd': '01/04',
      'i': Icons.payments,
    },
  ];

  void _addT() {
    final tC = TextEditingController(), aC = TextEditingController();
    bool isInc = false;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
            left: 20,
            right: 20,
            top: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'הוספת תנועה',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('הוצאה'),
                  Switch(
                    value: isInc,
                    activeThumbColor: Colors.green,
                    onChanged: (v) => setS(() => isInc = v),
                  ),
                  const Text('הכנסה'),
                ],
              ),
              TextField(
                controller: tC,
                textAlign: TextAlign.right,
                decoration: const InputDecoration(labelText: 'תיאור'),
              ),
              TextField(
                controller: aC,
                textAlign: TextAlign.right,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'סכום'),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                  ),
                  onPressed: () {
                    if (tC.text.isEmpty || aC.text.isEmpty) return;
                    double val = double.parse(aC.text) * (isInc ? 1 : -1);
                    setState(() {
                      _trans.insert(0, {
                        't': tC.text,
                        'a': val,
                        'c': isInc ? 'הכנסה' : 'הוצאה',
                        'd': 'היום',
                        'i': isInc ? Icons.payments : Icons.shopping_cart,
                      });
                      balance += val;
                      if (isInc) {
                        income += val;
                      } else {
                        expenses += val.abs();
                      }
                    });
                    Navigator.pop(ctx);
                  },
                  child: const Text(
                    'שמור',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _summaryCard(String label, String amount, Color color) {
    return Container(
      width: 150,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        // תיקון כאן: שימוש ב-withValues במקום withOpacity
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          Text(
            amount,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double prog = expenses / budget;
    return Scaffold(
      appBar: AppBar(title: const Text('פיננסים'), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1A1A1A), Color(0xFF3A3A3A)],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  const Text(
                    'יתרה בחשבון',
                    style: TextStyle(color: Colors.white70),
                  ),
                  Text(
                    '₪${balance.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _summaryCard('הוצאות', '₪${expenses.toInt()}', Colors.red),
                _summaryCard('הכנסות', '₪${income.toInt()}', Colors.green),
              ],
            ),
            const SizedBox(height: 20),
            LinearProgressIndicator(
              value: prog > 1 ? 1 : prog,
              minHeight: 8,
              backgroundColor: Colors.grey[300],
              color: prog > 0.9 ? Colors.red : Colors.blue,
            ),
            const SizedBox(height: 20),
            ..._trans.map(
              (t) => ListTile(
                leading: CircleAvatar(
                  // תיקון כאן: שימוש ב-withValues
                  backgroundColor: t['a'] > 0
                      ? Colors.green.withValues(alpha: 0.1)
                      : Colors.red.withValues(alpha: 0.1),
                  child: Icon(
                    t['i'] as IconData,
                    color: t['a'] > 0 ? Colors.green : Colors.red,
                  ),
                ),
                title: Text(t['t']),
                trailing: Text(
                  '${t['a']} ₪',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: t['a'] > 0 ? Colors.green : Colors.black,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.black,
        onPressed: _addT,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
