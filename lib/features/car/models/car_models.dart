import 'package:flutter/material.dart';

// ====== סוג דלק ======
enum FuelType { petrol95, petrol98, diesel, electric, hybrid }

extension FuelTypeExtension on FuelType {
  String get label {
    switch (this) {
      case FuelType.petrol95:
        return 'בנזין 95';
      case FuelType.petrol98:
        return 'בנזין 98';
      case FuelType.diesel:
        return 'דיזל';
      case FuelType.electric:
        return 'חשמלי';
      case FuelType.hybrid:
        return 'היברידי';
    }
  }

  IconData get icon {
    switch (this) {
      case FuelType.petrol95:
      case FuelType.petrol98:
      case FuelType.diesel:
        return Icons.local_gas_station_rounded;
      case FuelType.electric:
        return Icons.electric_bolt_rounded;
      case FuelType.hybrid:
        return Icons.eco_rounded;
    }
  }

  Color get color {
    switch (this) {
      case FuelType.petrol95:
        return const Color(0xFF2196F3);
      case FuelType.petrol98:
        return const Color(0xFF9C27B0);
      case FuelType.diesel:
        return const Color(0xFF607D8B);
      case FuelType.electric:
        return const Color(0xFF4CAF50);
      case FuelType.hybrid:
        return const Color(0xFF11998E);
    }
  }
}

// ====== סוג טיפול ======
enum ServiceType {
  oilChange,
  tires,
  battery,
  brakes,
  filter,
  insurance,
  test,
  fuel,
  other,
}

extension ServiceTypeExtension on ServiceType {
  String get label {
    switch (this) {
      case ServiceType.oilChange:
        return 'החלפת שמן';
      case ServiceType.tires:
        return 'צמיגים';
      case ServiceType.battery:
        return 'מצבר';
      case ServiceType.brakes:
        return 'בלמים';
      case ServiceType.filter:
        return 'פילטר';
      case ServiceType.insurance:
        return 'ביטוח';
      case ServiceType.test:
        return 'טסט';
      case ServiceType.fuel:
        return 'תדלוק';
      case ServiceType.other:
        return 'אחר';
    }
  }

  IconData get icon {
    switch (this) {
      case ServiceType.oilChange:
        return Icons.opacity_rounded;
      case ServiceType.tires:
        return Icons.tire_repair_rounded;
      case ServiceType.battery:
        return Icons.battery_charging_full_rounded;
      case ServiceType.brakes:
        return Icons.disc_full_rounded;
      case ServiceType.filter:
        return Icons.filter_alt_rounded;
      case ServiceType.insurance:
        return Icons.shield_rounded;
      case ServiceType.test:
        return Icons.fact_check_rounded;
      case ServiceType.fuel:
        return Icons.local_gas_station_rounded;
      case ServiceType.other:
        return Icons.build_rounded;
    }
  }

  Color get color {
    switch (this) {
      case ServiceType.oilChange:
        return const Color(0xFFFF9800);
      case ServiceType.tires:
        return const Color(0xFF607D8B);
      case ServiceType.battery:
        return const Color(0xFFFFC107);
      case ServiceType.brakes:
        return const Color(0xFFEB3349);
      case ServiceType.filter:
        return const Color(0xFF2196F3);
      case ServiceType.insurance:
        return const Color(0xFF4CAF50);
      case ServiceType.test:
        return const Color(0xFF9C27B0);
      case ServiceType.fuel:
        return const Color(0xFF11998E);
      case ServiceType.other:
        return const Color(0xFF9E9E9E);
    }
  }
}

// ====== רישיון / תאריך חשוב ======
class CarDocument {
  final String id;
  final String title;
  final DateTime expiryDate;
  final IconData icon;
  final Color color;

  CarDocument({
    required this.id,
    required this.title,
    required this.expiryDate,
    required this.icon,
    required this.color,
  });

  int get daysLeft => expiryDate.difference(DateTime.now()).inDays;
  bool get isExpired => daysLeft < 0;
  bool get isUrgent => daysLeft >= 0 && daysLeft <= 30;
}

// ====== רשומת טיפול / הוצאה ======
class ServiceRecord {
  final String id;
  final String title;
  final ServiceType type;
  final DateTime date;
  final double cost;
  final int? mileage;
  final String? garage;
  final String? notes;

  ServiceRecord({
    required this.id,
    required this.title,
    required this.type,
    required this.date,
    required this.cost,
    this.mileage,
    this.garage,
    this.notes,
  });
}

// ====== תזכורת טיפול ======
class ServiceReminder {
  final String id;
  final String title;
  final ServiceType type;
  final DateTime dueDate;
  final int? dueMileage;
  bool isDone;

  ServiceReminder({
    required this.id,
    required this.title,
    required this.type,
    required this.dueDate,
    this.dueMileage,
    this.isDone = false,
  });

  int get daysLeft => dueDate.difference(DateTime.now()).inDays;
  bool get isUrgent => daysLeft >= 0 && daysLeft <= 30;
  bool get isOverdue => daysLeft < 0 && !isDone;
}

// ====== מסמך/תמונה מצורפת ======
class CarAttachment {
  final String id;
  final String title;
  final String filePath;
  final bool isImage;
  final DateTime createdAt;
  final String? relatedId;

  CarAttachment({
    required this.id,
    required this.title,
    required this.filePath,
    required this.isImage,
    required this.createdAt,
    this.relatedId,
  });
}

// ====== רכב ======
class CarModel {
  final String id;
  String nickname;
  String plate;
  String? brand;
  String? model;
  int? year;
  FuelType fuelType;
  int? currentMileage;
  final List<CarDocument> documents;
  final List<ServiceRecord> serviceHistory;
  final List<ServiceReminder> reminders;
  final List<CarAttachment> attachments;

  CarModel({
    required this.id,
    required this.nickname,
    required this.plate,
    this.brand,
    this.model,
    this.year,
    required this.fuelType,
    this.currentMileage,
    required this.documents,
    required this.serviceHistory,
    required this.reminders,
    List<CarAttachment>? attachments,
  }) : attachments = attachments ?? [];

  double get yearlyExpenses {
    final now = DateTime.now();
    return serviceHistory
        .where((s) => s.date.year == now.year)
        .fold(0, (sum, s) => sum + s.cost);
  }

  double get totalExpenses => serviceHistory.fold(0, (sum, s) => sum + s.cost);

  List<ServiceReminder> get activeReminders =>
      reminders.where((r) => !r.isDone).toList()
        ..sort((a, b) => a.dueDate.compareTo(b.dueDate));

  List<CarDocument> get urgentDocuments =>
      documents.where((d) => d.isUrgent || d.isExpired).toList()
        ..sort((a, b) => a.daysLeft.compareTo(b.daysLeft));
}
