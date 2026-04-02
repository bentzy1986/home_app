import 'package:flutter/material.dart';

class MaintenanceScreen extends StatefulWidget {
  const MaintenanceScreen({super.key});

  @override
  State<MaintenanceScreen> createState() => _MaintenanceScreenState();
}

class _MaintenanceScreenState extends State<MaintenanceScreen> {
  // רשימת המשימות עם שדה 'isDone' חדש כדי לשלוט במצב הלחיצה
  final List<Map<String, dynamic>> _maintenanceTasks = [
    {
      'title': 'ניקוי פילטר מזגנים',
      'period': 'כל 3 חודשים',
      'lastDone': '01/01/2026',
      'isUrgent': true,
      'isDone': false,
    },
    {
      'title': 'החלפת פילטר בתמי 4',
      'period': 'כל חצי שנה',
      'lastDone': '05/12/2025',
      'isUrgent': true,
      'isDone': false,
    },
    {
      'title': 'החלפת מסנן תמי 4',
      'period': 'פעם בשנה',
      'lastDone': '10/11/2025',
      'isUrgent': false,
      'isDone': false,
    },
    {
      'title': 'ניקוי פילטר מדיח',
      'period': 'כל חודשיים',
      'lastDone': '15/02/2026',
      'isUrgent': false,
      'isDone': false,
    },
    {
      'title': 'ניקוי פילטר מכונת כביסה',
      'period': 'כל חצי שנה',
      'lastDone': '20/01/2026',
      'isUrgent': false,
      'isDone': false,
    },
    {
      'title': 'ניקוי פילטר מייבש',
      'period': 'כל חודש',
      'lastDone': '10/03/2026',
      'isUrgent': false,
      'isDone': false,
    },
  ];

  void _showTaskDialog(int? index) {
    final bool isEditing = index != null;
    final titleController = TextEditingController(
      text: isEditing ? _maintenanceTasks[index]['title'] : '',
    );
    final periodController = TextEditingController(
      text: isEditing ? _maintenanceTasks[index]['period'] : '',
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) => Padding(
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
              isEditing ? 'עריכת משימת תחזוקה' : 'הוספת משימה חדשה',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: titleController,
              textAlign: TextAlign.right,
              decoration: const InputDecoration(
                labelText: 'שם המשימה',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: periodController,
              textAlign: TextAlign.right,
              decoration: const InputDecoration(
                labelText: 'תדירות (למשל: כל חודש)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1A1A1A),
                minimumSize: const Size(double.infinity, 55),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              onPressed: () {
                if (titleController.text.isNotEmpty) {
                  setState(() {
                    if (isEditing) {
                      _maintenanceTasks[index]['title'] = titleController.text;
                      _maintenanceTasks[index]['period'] =
                          periodController.text;
                    } else {
                      _maintenanceTasks.add({
                        'title': titleController.text,
                        'period': periodController.text,
                        'lastDone': 'טרם בוצע',
                        'isUrgent': false,
                        'isDone': false,
                      });
                    }
                  });
                  Navigator.pop(context);
                }
              },
              child: Text(
                isEditing ? 'שמור שינויים' : 'הוסף משימה',
                style: const TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text(
          'תחזוקה שוטפת',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: _maintenanceTasks.length,
        itemBuilder: (context, index) {
          final task = _maintenanceTasks[index];
          bool isDone = task['isDone'] ?? false;

          return Card(
            margin: const EdgeInsets.only(bottom: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: ListTile(
              onTap: () => _showTaskDialog(index),
              contentPadding: const EdgeInsets.all(15),
              leading: Icon(
                task['isUrgent'] && !isDone
                    ? Icons.warning_amber_rounded
                    : Icons.settings_suggest_outlined,
                color: task['isUrgent'] && !isDone ? Colors.red : Colors.blue,
                size: 30,
              ),
              title: Text(
                task['title'],
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  decoration: isDone ? TextDecoration.lineThrough : null,
                  color: isDone ? Colors.grey : Colors.black,
                ),
              ),
              subtitle: Text(
                'תדירות: ${task['period']}\nבוצע: ${task['lastDone']}',
              ),
              trailing: OutlinedButton(
                onPressed: () {
                  setState(() {
                    // היפוך מצב ה-Done
                    task['isDone'] = !isDone;
                    if (task['isDone']) {
                      task['lastDone'] =
                          "${DateTime.now().day.toString().padLeft(2, '0')}/${DateTime.now().month.toString().padLeft(2, '0')}/${DateTime.now().year}";
                    }
                  });
                },
                style: OutlinedButton.styleFrom(
                  backgroundColor: isDone
                      ? Colors.green.withValues(alpha: 0.1)
                      : Colors.transparent,
                  side: BorderSide(
                    color: isDone ? Colors.green : Colors.grey.shade400,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  isDone ? 'בוצע ✓' : 'לביצוע',
                  style: TextStyle(
                    color: isDone ? Colors.green : Colors.black54,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showTaskDialog(null),
        backgroundColor: const Color(0xFF1A1A1A),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
