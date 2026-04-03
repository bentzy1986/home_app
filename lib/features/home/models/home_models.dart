import 'package:flutter/material.dart';

// ====== סוג נכס ======
enum PropertyType { owned, rented, rental }

extension PropertyTypeExtension on PropertyType {
  String get label {
    switch (this) {
      case PropertyType.owned:
        return 'בבעלות (מגורים)';
      case PropertyType.rented:
        return 'שכור';
      case PropertyType.rental:
        return 'להשכרה (נכס מניב)';
    }
  }

  IconData get icon {
    switch (this) {
      case PropertyType.owned:
        return Icons.home_rounded;
      case PropertyType.rented:
        return Icons.apartment_rounded;
      case PropertyType.rental:
        return Icons.monetization_on_rounded;
    }
  }

  Color get color {
    switch (this) {
      case PropertyType.owned:
        return const Color(0xFF4A00E0);
      case PropertyType.rented:
        return const Color(0xFF2193B0);
      case PropertyType.rental:
        return const Color(0xFF11998E);
    }
  }
}

// ====== סוג משימת תחזוקה ======
enum MaintenanceType {
  plumbing,
  electric,
  ac,
  painting,
  cleaning,
  appliance,
  garden,
  other,
}

extension MaintenanceTypeExtension on MaintenanceType {
  String get label {
    switch (this) {
      case MaintenanceType.plumbing:
        return 'אינסטלציה';
      case MaintenanceType.electric:
        return 'חשמל';
      case MaintenanceType.ac:
        return 'מיזוג';
      case MaintenanceType.painting:
        return 'צביעה';
      case MaintenanceType.cleaning:
        return 'ניקיון';
      case MaintenanceType.appliance:
        return 'מכשירי חשמל';
      case MaintenanceType.garden:
        return 'גינה';
      case MaintenanceType.other:
        return 'אחר';
    }
  }

  IconData get icon {
    switch (this) {
      case MaintenanceType.plumbing:
        return Icons.water_drop_rounded;
      case MaintenanceType.electric:
        return Icons.electric_bolt_rounded;
      case MaintenanceType.ac:
        return Icons.ac_unit_rounded;
      case MaintenanceType.painting:
        return Icons.format_paint_rounded;
      case MaintenanceType.cleaning:
        return Icons.cleaning_services_rounded;
      case MaintenanceType.appliance:
        return Icons.kitchen_rounded;
      case MaintenanceType.garden:
        return Icons.yard_rounded;
      case MaintenanceType.other:
        return Icons.build_rounded;
    }
  }

  Color get color {
    switch (this) {
      case MaintenanceType.plumbing:
        return const Color(0xFF2196F3);
      case MaintenanceType.electric:
        return const Color(0xFFFFC107);
      case MaintenanceType.ac:
        return const Color(0xFF00BCD4);
      case MaintenanceType.painting:
        return const Color(0xFF9C27B0);
      case MaintenanceType.cleaning:
        return const Color(0xFF4CAF50);
      case MaintenanceType.appliance:
        return const Color(0xFFFF9800);
      case MaintenanceType.garden:
        return const Color(0xFF8BC34A);
      case MaintenanceType.other:
        return const Color(0xFF9E9E9E);
    }
  }
}

// ====== עדיפות משימה ======
enum TaskPriority { low, medium, high, urgent }

extension TaskPriorityExtension on TaskPriority {
  String get label {
    switch (this) {
      case TaskPriority.low:
        return 'נמוכה';
      case TaskPriority.medium:
        return 'בינונית';
      case TaskPriority.high:
        return 'גבוהה';
      case TaskPriority.urgent:
        return 'דחוף';
    }
  }

  Color get color {
    switch (this) {
      case TaskPriority.low:
        return Colors.grey;
      case TaskPriority.medium:
        return Colors.blue;
      case TaskPriority.high:
        return Colors.orange;
      case TaskPriority.urgent:
        return Colors.red;
    }
  }
}

// ====== משימת תחזוקה / תקלה ======
class MaintenanceTask {
  final String id;
  String title;
  final MaintenanceType type;
  final TaskPriority priority;
  bool isDone;
  final DateTime createdAt;
  DateTime? completedAt;
  final double? cost;
  final String? notes;
  final String? contractor;

  MaintenanceTask({
    required this.id,
    required this.title,
    required this.type,
    required this.priority,
    this.isDone = false,
    required this.createdAt,
    this.completedAt,
    this.cost,
    this.notes,
    this.contractor,
  });
}

// ====== חשבון חודשי ======
class Bill {
  final String id;
  String title;
  double amount;
  String? dueDay; // יום בחודש
  bool isPaid;
  final DateTime date;

  Bill({
    required this.id,
    required this.title,
    required this.amount,
    this.dueDay,
    this.isPaid = false,
    required this.date,
  });
}

// ====== בעל מקצוע ======
class ServiceProvider {
  final String id;
  String name;
  String profession;
  String phone;
  String? notes;
  double? rating;

  ServiceProvider({
    required this.id,
    required this.name,
    required this.profession,
    required this.phone,
    this.notes,
    this.rating,
  });
}

// ====== משימת ניקיון שבועית ======
class CleaningTask {
  final String id;
  String title;
  bool isDone;
  IconData icon;

  CleaningTask({
    required this.id,
    required this.title,
    this.isDone = false,
    required this.icon,
  });
}

// ====== נכס ======
class Property {
  final String id;
  String name;
  String address;
  PropertyType type;
  String? tenantName;
  double? rentalIncome;
  DateTime? leaseEnd;
  final List<MaintenanceTask> tasks;
  final List<Bill> bills;
  final List<ServiceProvider> providers;
  final List<CleaningTask> cleaningTasks;

  Property({
    required this.id,
    required this.name,
    required this.address,
    required this.type,
    this.tenantName,
    this.rentalIncome,
    this.leaseEnd,
    required this.tasks,
    required this.bills,
    required this.providers,
    required this.cleaningTasks,
  });

  // משימות פתוחות
  List<MaintenanceTask> get openTasks =>
      tasks.where((t) => !t.isDone).toList()
        ..sort((a, b) => b.priority.index.compareTo(a.priority.index));

  // חשבונות לא שולמו
  List<Bill> get unpaidBills => bills.where((b) => !b.isPaid).toList();

  // סך חשבונות החודש
  double get totalBills => bills.fold(0, (sum, b) => sum + b.amount);

  // התקדמות ניקיון
  int get cleaningDone => cleaningTasks.where((t) => t.isDone).length;
  double get cleaningProgress =>
      cleaningTasks.isEmpty ? 0 : cleaningDone / cleaningTasks.length;
}
