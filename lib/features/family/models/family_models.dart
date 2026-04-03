import 'package:flutter/material.dart';

enum EventType { birthday, activity, familyEvent, other }

extension EventTypeExtension on EventType {
  String get label {
    switch (this) {
      case EventType.birthday:
        return 'יום הולדת';
      case EventType.activity:
        return 'חוג';
      case EventType.familyEvent:
        return 'אירוע משפחתי';
      case EventType.other:
        return 'אחר';
    }
  }

  IconData get icon {
    switch (this) {
      case EventType.birthday:
        return Icons.cake_rounded;
      case EventType.activity:
        return Icons.sports_soccer_rounded;
      case EventType.familyEvent:
        return Icons.family_restroom_rounded;
      case EventType.other:
        return Icons.more_horiz_rounded;
    }
  }

  Color get color {
    switch (this) {
      case EventType.birthday:
        return const Color(0xFFE91E63);
      case EventType.activity:
        return const Color(0xFFFF9800);
      case EventType.familyEvent:
        return const Color(0xFF4A00E0);
      case EventType.other:
        return const Color(0xFF607D8B);
    }
  }
}

enum Weekday { sunday, monday, tuesday, wednesday, thursday, friday }

extension WeekdayExtension on Weekday {
  String get label {
    switch (this) {
      case Weekday.sunday:
        return 'ראשון';
      case Weekday.monday:
        return 'שני';
      case Weekday.tuesday:
        return 'שלישי';
      case Weekday.wednesday:
        return 'רביעי';
      case Weekday.thursday:
        return 'חמישי';
      case Weekday.friday:
        return 'שישי';
    }
  }

  int get flutterWeekday {
    switch (this) {
      case Weekday.sunday:
        return 7;
      case Weekday.monday:
        return 1;
      case Weekday.tuesday:
        return 2;
      case Weekday.wednesday:
        return 3;
      case Weekday.thursday:
        return 4;
      case Weekday.friday:
        return 5;
    }
  }
}

// סוג החזרתיות של החוג
enum ActivityRecurrence {
  oneTime, // חד פעמי — תאריך ספציפי
  weekly, // שבועי — ימים קבועים
}

extension ActivityRecurrenceExtension on ActivityRecurrence {
  String get label {
    switch (this) {
      case ActivityRecurrence.oneTime:
        return 'חד פעמי';
      case ActivityRecurrence.weekly:
        return 'שבועי קבוע';
    }
  }

  IconData get icon {
    switch (this) {
      case ActivityRecurrence.oneTime:
        return Icons.looks_one_rounded;
      case ActivityRecurrence.weekly:
        return Icons.repeat_rounded;
    }
  }
}

class FamilyMember {
  final String id;
  final String name;
  final Color color;
  final DateTime? birthday;

  FamilyMember({
    required this.id,
    required this.name,
    required this.color,
    this.birthday,
  });

  FamilyMember copyWith({String? name, Color? color, DateTime? birthday}) {
    return FamilyMember(
      id: id,
      name: name ?? this.name,
      color: color ?? this.color,
      birthday: birthday ?? this.birthday,
    );
  }
}

class FamilyEvent {
  final String id;
  final String title;
  final DateTime date;
  final EventType type;
  final String? memberId;
  final String? notes;

  FamilyEvent({
    required this.id,
    required this.title,
    required this.date,
    required this.type,
    this.memberId,
    this.notes,
  });
}

class WeeklyActivity {
  final String id;
  final String title;
  final ActivityRecurrence recurrence;
  // לחוג שבועי — ימים קבועים
  final List<Weekday> weekdays;
  // לחוג חד פעמי — תאריך ספציפי
  final DateTime? specificDate;
  final String time;
  final String? memberId;
  final String? location;
  // תאריכים מבוטלים (חריגים)
  final List<DateTime> cancelledDates;

  WeeklyActivity({
    required this.id,
    required this.title,
    required this.recurrence,
    required this.weekdays,
    required this.time,
    this.specificDate,
    this.memberId,
    this.location,
    this.cancelledDates = const [],
  });

  String get weekdaysLabel => weekdays.map((d) => d.label).join(', ');

  bool isCancelledOn(DateTime date) {
    return cancelledDates.any(
      (d) => d.year == date.year && d.month == date.month && d.day == date.day,
    );
  }

  // האם החוג מתקיים בתאריך נתון
  bool occursOn(DateTime date) {
    if (isCancelledOn(date)) return false;
    if (recurrence == ActivityRecurrence.oneTime) {
      return specificDate != null &&
          specificDate!.year == date.year &&
          specificDate!.month == date.month &&
          specificDate!.day == date.day;
    }
    return weekdays.any((d) => d.flutterWeekday == date.weekday);
  }
}
