import 'package:flutter/material.dart';
import 'features/home/home_management_screen.dart';

class AppShell extends StatelessWidget {
  const AppShell({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomeManagementScreen(), // דף הבית הוא נקודת המוצא היחידה
    );
  }
}
