import 'package:flutter/material.dart';
import 'models/family_models.dart';

class FamilyState extends ChangeNotifier {
  final List<FamilyMember> members = [
    FamilyMember(
      id: '1',
      name: 'אבא',
      color: const Color(0xFF2193B0),
      birthday: DateTime(1986, 5, 12),
    ),
    FamilyMember(
      id: '2',
      name: 'אמא',
      color: const Color(0xFFEB3349),
      birthday: DateTime(1988, 8, 3),
    ),
    FamilyMember(
      id: '3',
      name: 'ילד 1',
      color: const Color(0xFF11998E),
      birthday: DateTime(2016, 11, 20),
    ),
    FamilyMember(
      id: '4',
      name: 'ילד 2',
      color: const Color(0xFFF7971E),
      birthday: DateTime(2019, 3, 7),
    ),
  ];

  final List<FamilyEvent> events = [
    FamilyEvent(
      id: 'e1',
      title: 'יום הולדת ילד 1',
      date: DateTime(DateTime.now().year, 11, 20),
      type: EventType.birthday,
      memberId: '3',
    ),
    FamilyEvent(
      id: 'e2',
      title: 'טיול משפחתי',
      date: DateTime.now().add(const Duration(days: 10)),
      type: EventType.familyEvent,
    ),
  ];

  final List<WeeklyActivity> activities = [
    WeeklyActivity(
      id: 'a1',
      title: 'כדורגל',
      recurrence: ActivityRecurrence.weekly,
      weekdays: [Weekday.monday, Weekday.wednesday],
      time: '16:00',
      memberId: '3',
      location: 'מגרש השכונה',
    ),
    WeeklyActivity(
      id: 'a2',
      title: 'בלט',
      recurrence: ActivityRecurrence.weekly,
      weekdays: [Weekday.tuesday],
      time: '17:00',
      memberId: '4',
      location: 'אולפן המחול',
    ),
  ];

  FamilyMember? getMember(String? id) {
    if (id == null) return null;
    try {
      return members.firstWhere((m) => m.id == id);
    } catch (_) {
      return null;
    }
  }

  List<FamilyEvent> get upcomingEvents {
    final now = DateTime.now();
    final soon = now.add(const Duration(days: 30));
    return events
        .where((e) => e.date.isAfter(now) && e.date.isBefore(soon))
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }

  List<Map<String, dynamic>> get upcomingBirthdays {
    final now = DateTime.now();
    final result = <Map<String, dynamic>>[];
    for (final m in members) {
      if (m.birthday == null) continue;
      final next = DateTime(now.year, m.birthday!.month, m.birthday!.day);
      final adjusted = next.isBefore(now)
          ? DateTime(now.year + 1, m.birthday!.month, m.birthday!.day)
          : next;
      final days = adjusted
          .difference(DateTime(now.year, now.month, now.day))
          .inDays;
      result.add({'member': m, 'days': days, 'date': adjusted});
    }
    result.sort((a, b) => (a['days'] as int).compareTo(b['days'] as int));
    return result;
  }

  List<FamilyEvent> eventsForDate(DateTime date) {
    return events
        .where(
          (e) =>
              e.date.year == date.year &&
              e.date.month == date.month &&
              e.date.day == date.day,
        )
        .toList();
  }

  // חוגים לפי תאריך ספציפי (כולל ביטולים)
  List<WeeklyActivity> activitiesForDate(DateTime date) {
    return activities.where((a) => a.occursOn(date)).toList();
  }

  // לצורך הלוח — כל החוגים ביום בשבוע (ללא סינון ביטולים)
  List<WeeklyActivity> activitiesForWeekday(int flutterWeekday) {
    return activities
        .where(
          (a) =>
              a.recurrence == ActivityRecurrence.weekly &&
              a.weekdays.any((d) => d.flutterWeekday == flutterWeekday),
        )
        .toList();
  }

  void addEvent(FamilyEvent event) {
    events.add(event);
    notifyListeners();
  }

  void updateEvent(FamilyEvent updated) {
    final i = events.indexWhere((e) => e.id == updated.id);
    if (i != -1) {
      events[i] = updated;
      notifyListeners();
    }
  }

  void deleteEvent(String id) {
    events.removeWhere((e) => e.id == id);
    notifyListeners();
  }

  void addActivity(WeeklyActivity activity) {
    activities.add(activity);
    notifyListeners();
  }

  void updateActivity(WeeklyActivity updated) {
    final i = activities.indexWhere((a) => a.id == updated.id);
    if (i != -1) {
      activities[i] = updated;
      notifyListeners();
    }
  }

  // ביטול חד פעמי בתאריך ספציפי
  void cancelActivityOnDate(String id, DateTime date) {
    final i = activities.indexWhere((a) => a.id == id);
    if (i == -1) return;
    final a = activities[i];
    final newDates = List<DateTime>.from(a.cancelledDates)
      ..add(DateTime(date.year, date.month, date.day));
    activities[i] = WeeklyActivity(
      id: a.id,
      title: a.title,
      recurrence: a.recurrence,
      weekdays: a.weekdays,
      time: a.time,
      specificDate: a.specificDate,
      memberId: a.memberId,
      location: a.location,
      cancelledDates: newDates,
    );
    notifyListeners();
  }

  // מחיקת יום ספציפי מחוג שבועי
  void deleteActivityDay(String id, Weekday day) {
    final i = activities.indexWhere((a) => a.id == id);
    if (i == -1) return;
    final a = activities[i];
    if (a.weekdays.length <= 1) {
      activities.removeAt(i);
    } else {
      activities[i] = WeeklyActivity(
        id: a.id,
        title: a.title,
        recurrence: a.recurrence,
        weekdays: a.weekdays.where((d) => d != day).toList(),
        time: a.time,
        specificDate: a.specificDate,
        memberId: a.memberId,
        location: a.location,
        cancelledDates: a.cancelledDates,
      );
    }
    notifyListeners();
  }

  // מחיקת החוג לגמרי
  void deleteActivity(String id) {
    activities.removeWhere((a) => a.id == id);
    notifyListeners();
  }

  void addMember(FamilyMember member) {
    members.add(member);
    notifyListeners();
  }

  void updateMember(FamilyMember updated) {
    final i = members.indexWhere((m) => m.id == updated.id);
    if (i != -1) {
      members[i] = updated;
      notifyListeners();
    }
  }
}
