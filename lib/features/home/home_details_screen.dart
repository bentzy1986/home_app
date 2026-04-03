import 'package:flutter/material.dart';
// ייבוא של כל הדפים הפנימיים שבנינו
import 'bills_screen.dart';
import 'cleaning_screen.dart';
import 'maintenance_screen.dart';
import 'service_providers_screen.dart'; // התת-נושא החדש

class HomeDetailsScreen extends StatelessWidget {
  const HomeDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A1A),
        elevation: 0,
        title: const Text(
          'ניהול הבית',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        // כפתור חזור לבן ומינימליסטי
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // 1. תחזוקה שוטפת
          _buildDetailItem(
            context,
            'תחזוקה שוטפת',
            Icons.handyman_rounded,
            Colors.orange,
            const MaintenanceScreen(),
          ),

          // 2. חשבונות (חשמל, מים, ארנונה)
          _buildDetailItem(
            context,
            'חשבונות (חשמל, מים, ארנונה)',
            Icons.receipt_long_rounded,
            Colors.blue,
            const BillsScreen(),
          ),

          // 3. ניקיון שבועי
          _buildDetailItem(
            context,
            'ניקיון שבועי',
            Icons.auto_fix_high_rounded,
            Colors.cyan,
            const CleaningScreen(),
          ),

          // 4. בעלי מקצוע - התת-נושא החדש
          _buildDetailItem(
            context,
            'בעלי מקצוע',
            Icons.people_alt_rounded,
            Colors.indigo,
            const ServiceProvidersScreen(),
          ),

          // 5. רשימת תקלות
          _buildDetailItem(
            context,
            'רשימת תקלות',
            Icons.report_problem_rounded,
            Colors.red,
            null, // עדיין בבנייה
          ),
        ],
      ),
    );
  }

  // פונקציה לבניית שורה ברשימה בצורה אחידה ומעוצבת
  Widget _buildDetailItem(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    Widget? targetPage,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 15),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: Colors.grey.withValues(alpha: 0.1)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 10,
        ),
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.1),
          child: Icon(icon, color: color, size: 22),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Color(0xFF2D3436),
          ),
        ),
        // חץ חזור בצד שמאל (מותאם ל-RTL)
        trailing: const Icon(
          Icons.arrow_back_ios,
          size: 14,
          color: Colors.grey,
        ),
        onTap: () {
          if (targetPage != null) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => targetPage),
            );
          } else {
            // הודעה זמנית לדפים שטרם נבנו
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('הדף של $title נמצא כרגע בבנייה...'),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            );
          }
        },
      ),
    );
  }
}
