import 'package:flutter/material.dart';

class BillsScreen extends StatefulWidget {
  const BillsScreen({super.key});

  @override
  State<BillsScreen> createState() => _BillsScreenState();
}

class _BillsScreenState extends State<BillsScreen> {
  // רשימת הנתונים
  final List<Map<String, dynamic>> _bills = [
    {
      'title': 'חברת החשמל',
      'date': '15/03/2026',
      'amount': '450',
      'isPaid': true,
    },
    {
      'title': 'מי שקמה (מים)',
      'date': '10/03/2026',
      'amount': '180',
      'isPaid': true,
    },
    {'title': 'ארנונה', 'date': '01/03/2026', 'amount': '820', 'isPaid': false},
  ];

  // פונקציה לבחירת תאריך
  Future<void> _selectDate(
    BuildContext context,
    TextEditingController controller,
    StateSetter setStateInsideModal,
  ) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setStateInsideModal(() {
        controller.text =
            "${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}";
      });
    }
  }

  void _showBillDialog(int? index) {
    final bool isEditing = index != null;
    final titleController = TextEditingController(
      text: isEditing ? _bills[index]['title'] : '',
    );
    final amountController = TextEditingController(
      text: isEditing ? _bills[index]['amount'].toString() : '',
    );
    final dateController = TextEditingController(
      text: isEditing
          ? _bills[index]['date']
          : "${DateTime.now().day.toString().padLeft(2, '0')}/${DateTime.now().month.toString().padLeft(2, '0')}/${DateTime.now().year}",
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            top: 25,
            left: 25,
            right: 25,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                isEditing ? 'עריכת חשבון' : 'הוספת חשבון',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: titleController,
                textAlign: TextAlign.right,
                decoration: const InputDecoration(
                  labelText: 'סוג החשבון',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: amountController,
                textAlign: TextAlign.right,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'סכום (₪)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: dateController,
                readOnly: true,
                textAlign: TextAlign.right,
                onTap: () =>
                    _selectDate(context, dateController, setModalState),
                decoration: const InputDecoration(
                  labelText: 'תאריך',
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.calendar_today),
                ),
              ),
              const SizedBox(height: 25),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1A1A1A),
                  minimumSize: const Size(double.infinity, 55),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                onPressed: () {
                  if (titleController.text.isNotEmpty &&
                      amountController.text.isNotEmpty) {
                    setState(() {
                      final billData = {
                        'title': titleController.text,
                        'amount': amountController.text,
                        'date': dateController.text,
                        'isPaid': isEditing ? _bills[index]['isPaid'] : false,
                      };
                      if (isEditing) {
                        _bills[index] = billData;
                      } else {
                        _bills.add(billData);
                      }
                    });
                    Navigator.pop(context);
                  }
                },
                child: Text(
                  isEditing ? 'שמור שינויים' : 'הוסף חשבון',
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double total = _bills.fold(
      0,
      (sum, item) => sum + (double.tryParse(item['amount'].toString()) ?? 0),
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text(
          'ניהול חשבונות',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF2193B0), Color(0xFF6DD5ED)],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'סה"כ לתשלום החודש',
                      style: TextStyle(color: Colors.white70),
                    ),
                    Text(
                      '₪${total.toStringAsFixed(0)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const Icon(
                  Icons.account_balance_wallet,
                  color: Colors.white,
                  size: 45,
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: _bills.length,
              itemBuilder: (context, index) {
                final bill = _bills[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: ListTile(
                    onTap: () => _showBillDialog(index),
                    leading: IconButton(
                      icon: Icon(
                        bill['isPaid']
                            ? Icons.check_circle
                            : Icons.error_outline,
                        color: bill['isPaid'] ? Colors.green : Colors.red,
                      ),
                      onPressed: () {
                        setState(() {
                          bill['isPaid'] = !bill['isPaid'];
                        });
                      },
                    ),
                    title: Text(
                      bill['title'],
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(bill['date']),
                    trailing: Text(
                      '₪${bill['amount']}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showBillDialog(null),
        backgroundColor: const Color(0xFF1A1A1A),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
