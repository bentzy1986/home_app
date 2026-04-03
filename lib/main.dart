import 'package:flutter/material.dart';
import 'features/family/family_state.dart';
import 'features/home_management/home_management_screen.dart';

final FamilyState globalFamilyState = FamilyState();

void main() {
  runApp(const HomeManagerApp());
}

class HomeManagerApp extends StatelessWidget {
  const HomeManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ניהול הבית',
      theme: ThemeData(useMaterial3: true),
      builder: (context, child) {
        return Directionality(textDirection: TextDirection.rtl, child: child!);
      },
      home: const HomeManagementScreen(),
    );
  }
}
