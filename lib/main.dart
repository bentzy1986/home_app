import 'package:flutter/material.dart';
import 'features/family/family_state.dart';
import 'features/finance/finance_state.dart';
import 'features/car/car_state.dart';
import 'features/home/home_state.dart';
import 'features/health/health_state.dart';
import 'features/shopping/shopping_state.dart';
import 'features/home/home_management_screen.dart';

final FamilyState globalFamilyState = FamilyState();
final FinanceState globalFinanceState = FinanceState();
final CarState globalCarState = CarState();
final HomeState globalHomeState = HomeState();
final HealthState globalHealthState = HealthState();
final ShoppingState globalShoppingState = ShoppingState();

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
