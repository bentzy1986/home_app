import 'package:flutter/material.dart';

class CleaningScreen extends StatefulWidget {
  const CleaningScreen({super.key});

  @override
  State<CleaningScreen> createState() => _CleaningScreenState();
}

class _CleaningScreenState extends State<CleaningScreen> {
  final List<Map<String, dynamic>> _tasks = [
    {'title': 'שטיפת ריצפה', 'done': false},
    {'title': 'ניקיון מקלחות', 'done': false},
    {'title': 'ניקיון שירותים', 'done': false},
    {'title': 'החלפת מצעים', 'done': false},
    {'title': 'ריקון פחים', 'done': false},
    {'title': 'ניקיון מרפסת', 'done': false},
    {'title': 'ניקוי חלונות', 'done': false},
    {'title': 'ניקוי מראות', 'done': false},
    {'title': 'ניקוי רהיטים', 'done': false},
    {'title': 'כביסות', 'done': false},
    {'title': 'הכנסת כלים למדיח', 'done': false},
  ];

  @override
  Widget build(BuildContext context) {
    int completed = _tasks.where((t) => t['done']).length;
    double progress = _tasks.isEmpty ? 0 : completed / _tasks.length;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text(
          'ניקיון שבועי',
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
              color: Colors.white,
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${(progress * 100).toInt()}% הושלם',
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 18,
                        color: Colors.cyan,
                      ),
                    ),
                    Text(
                      '$completed מתוך ${_tasks.length}',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.grey[100],
                    color: Colors.cyan,
                    minHeight: 12,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: _tasks.length,
              itemBuilder: (context, index) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.02),
                        blurRadius: 5,
                      ),
                    ],
                  ),
                  child: CheckboxListTile(
                    activeColor: Colors.cyan,
                    title: Text(
                      _tasks[index]['title'],
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        decoration: _tasks[index]['done']
                            ? TextDecoration.lineThrough
                            : null,
                        color: _tasks[index]['done']
                            ? Colors.grey
                            : Colors.black87,
                      ),
                    ),
                    value: _tasks[index]['done'],
                    onChanged: (val) {
                      setState(() {
                        _tasks[index]['done'] = val;
                      });
                    },
                    secondary: Icon(
                      _getIconForTask(_tasks[index]['title']),
                      color: _tasks[index]['done'] ? Colors.grey : Colors.cyan,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIconForTask(String title) {
    if (title.contains('ריצפה')) {
      return Icons.cleaning_services;
    }
    if (title.contains('מקלחת') || title.contains('שירותים')) {
      return Icons.bathtub;
    }
    if (title.contains('מצעים')) {
      return Icons.bed;
    }
    if (title.contains('פחים')) {
      return Icons.delete_outline;
    }
    if (title.contains('חלונות') || title.contains('מראות')) {
      return Icons.wb_sunny_outlined;
    }
    if (title.contains('מדיח') || title.contains('כלים')) {
      return Icons.flatware;
    }
    if (title.contains('כביסות')) {
      return Icons.local_laundry_service;
    }
    return Icons.check_circle_outline;
  }
}
