import 'package:flutter/material.dart';
import 'features/home_management/home_management_screen.dart';

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
      // כאן אנחנו מגדירים את כיוון האפליקציה מימין לשמאל באופן גלובלי
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.rtl, // הופך את כל האפליקציה לעברית
          child: child!,
        );
      },
      home: const HomeManagementScreen(),
    );
  }
}
