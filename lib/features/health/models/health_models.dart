import 'package:flutter/material.dart';

// ====== סוג רופא ======
enum DoctorType {
  gp,
  pediatrician,
  dentist,
  eye,
  gynecologist,
  orthopedic,
  dermatologist,
  cardiologist,
  other,
}

extension DoctorTypeExtension on DoctorType {
  String get label {
    switch (this) {
      case DoctorType.gp:
        return 'רופא משפחה';
      case DoctorType.pediatrician:
        return 'רופא ילדים';
      case DoctorType.dentist:
        return 'שיניים';
      case DoctorType.eye:
        return 'עיניים';
      case DoctorType.gynecologist:
        return 'גינקולוג';
      case DoctorType.orthopedic:
        return 'אורתופד';
      case DoctorType.dermatologist:
        return 'עור';
      case DoctorType.cardiologist:
        return 'לב';
      case DoctorType.other:
        return 'אחר';
    }
  }

  IconData get icon {
    switch (this) {
      case DoctorType.gp:
        return Icons.medical_services_rounded;
      case DoctorType.pediatrician:
        return Icons.child_care_rounded;
      case DoctorType.dentist:
        return Icons.medical_services_rounded;
      case DoctorType.eye:
        return Icons.visibility_rounded;
      case DoctorType.gynecologist:
        return Icons.pregnant_woman_rounded;
      case DoctorType.orthopedic:
        return Icons.accessibility_new_rounded;
      case DoctorType.dermatologist:
        return Icons.face_rounded;
      case DoctorType.cardiologist:
        return Icons.monitor_heart_rounded;
      case DoctorType.other:
        return Icons.local_hospital_rounded;
    }
  }

  Color get color {
    switch (this) {
      case DoctorType.gp:
        return const Color(0xFF2196F3);
      case DoctorType.pediatrician:
        return const Color(0xFF4CAF50);
      case DoctorType.dentist:
        return const Color(0xFF00BCD4);
      case DoctorType.eye:
        return const Color(0xFF9C27B0);
      case DoctorType.gynecologist:
        return const Color(0xFFE91E63);
      case DoctorType.orthopedic:
        return const Color(0xFFFF9800);
      case DoctorType.dermatologist:
        return const Color(0xFFFF5722);
      case DoctorType.cardiologist:
        return const Color(0xFFEB3349);
      case DoctorType.other:
        return const Color(0xFF607D8B);
    }
  }
}

// ====== תדירות תרופה ======
enum MedicationFrequency { daily, twice, thrice, weekly, asNeeded }

extension MedicationFrequencyExtension on MedicationFrequency {
  String get label {
    switch (this) {
      case MedicationFrequency.daily:
        return 'פעם ביום';
      case MedicationFrequency.twice:
        return 'פעמיים ביום';
      case MedicationFrequency.thrice:
        return '3 פעמים ביום';
      case MedicationFrequency.weekly:
        return 'פעם בשבוע';
      case MedicationFrequency.asNeeded:
        return 'לפי הצורך';
    }
  }
}

// ====== סוג בדיקה ======
enum TestType { blood, urine, imaging, ecg, other }

extension TestTypeExtension on TestType {
  String get label {
    switch (this) {
      case TestType.blood:
        return 'דם';
      case TestType.urine:
        return 'שתן';
      case TestType.imaging:
        return 'הדמיה';
      case TestType.ecg:
        return 'אק"ג';
      case TestType.other:
        return 'אחר';
    }
  }

  IconData get icon {
    switch (this) {
      case TestType.blood:
        return Icons.bloodtype_rounded;
      case TestType.urine:
        return Icons.science_rounded;
      case TestType.imaging:
        return Icons.document_scanner_rounded;
      case TestType.ecg:
        return Icons.monitor_heart_rounded;
      case TestType.other:
        return Icons.biotech_rounded;
    }
  }
}

// ====== תור ======
class Appointment {
  final String id;
  String title;
  final DoctorType type;
  final DateTime dateTime;
  final String? doctorName;
  final String? location;
  final String? memberId;
  bool isDone;
  final String? notes;

  Appointment({
    required this.id,
    required this.title,
    required this.type,
    required this.dateTime,
    this.doctorName,
    this.location,
    this.memberId,
    this.isDone = false,
    this.notes,
  });

  int get daysLeft => dateTime.difference(DateTime.now()).inDays;
  bool get isToday => DateUtils.isSameDay(dateTime, DateTime.now());
  bool get isPast => dateTime.isBefore(DateTime.now()) && !isDone;
}

// ====== תרופה ======
class Medication {
  final String id;
  String name;
  String dosage;
  final MedicationFrequency frequency;
  final String? memberId;
  bool isActive;
  final DateTime startDate;
  final DateTime? endDate;
  final String? notes;

  Medication({
    required this.id,
    required this.name,
    required this.dosage,
    required this.frequency,
    this.memberId,
    this.isActive = true,
    required this.startDate,
    this.endDate,
    this.notes,
  });
}

// ====== בדיקה ======
class MedicalTest {
  final String id;
  String title;
  final TestType type;
  final DateTime date;
  final String? memberId;
  String? result;
  bool isDone;
  final String? notes;

  MedicalTest({
    required this.id,
    required this.title,
    required this.type,
    required this.date,
    this.memberId,
    this.result,
    this.isDone = false,
    this.notes,
  });
}

// ====== בן משפחה בריאות ======
class HealthMember {
  final String id;
  final String name;
  final Color color;
  final DateTime? birthDate;

  HealthMember({
    required this.id,
    required this.name,
    required this.color,
    this.birthDate,
  });

  int? get age {
    if (birthDate == null) return null;
    final now = DateTime.now();
    int age = now.year - birthDate!.year;
    if (now.month < birthDate!.month ||
        (now.month == birthDate!.month && now.day < birthDate!.day)) {
      age--;
    }
    return age;
  }
}
