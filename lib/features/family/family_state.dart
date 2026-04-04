import 'package:flutter/material.dart';
import 'models/family_models.dart';
import '../../services/storage_service.dart';

class FamilyState extends ChangeNotifier {
  List<FamilyMember> members = [];
  List<FamilyEvent> events = [];
  List<WeeklyActivity> activities = [];

  // ====== Persistence ======
  Future<void> loadFromStorage() async {
    final membersData = StorageService.loadJson('family_members');
    final eventsData = StorageService.loadJson('family_events');
    final activitiesData = StorageService.loadJson('family_activities');

    members = membersData != null
        ? (membersData as List).map((m) => _memberFromJson(m)).toList()
        : _defaultMembers();

    events = eventsData != null
        ? (eventsData as List).map((e) => _eventFromJson(e)).toList()
        : _defaultEvents();

    activities = activitiesData != null
        ? (activitiesData as List).map((a) => _activityFromJson(a)).toList()
        : _defaultActivities();

    notifyListeners();
  }

  Future<void> _save() async {
    await StorageService.saveJson(
      'family_members',
      members.map((m) => _memberToJson(m)).toList(),
    );
    await StorageService.saveJson(
      'family_events',
      events.map((e) => _eventToJson(e)).toList(),
    );
    await StorageService.saveJson(
      'family_activities',
      activities.map((a) => _activityToJson(a)).toList(),
    );
  }

  // ====== Serialization ======
  Map<String, dynamic> _memberToJson(FamilyMember m) => {
    'id': m.id,
    'name': m.name,
    'color': m.color.toARGB32(),
    'birthday': m.birthday?.toIso8601String(),
  };

  FamilyMember _memberFromJson(Map<String, dynamic> j) => FamilyMember(
    id: j['id'],
    name: j['name'],
    color: Color(j['color']),
    birthday: j['birthday'] != null ? DateTime.parse(j['birthday']) : null,
  );

  Map<String, dynamic> _eventToJson(FamilyEvent e) => {
    'id': e.id,
    'title': e.title,
    'date': e.date.toIso8601String(),
    'type': e.type.index,
    'memberId': e.memberId,
    'notes': e.notes,
  };

  FamilyEvent _eventFromJson(Map<String, dynamic> j) => FamilyEvent(
    id: j['id'],
    title: j['title'],
    date: DateTime.parse(j['date']),
    type: EventType.values[j['type']],
    memberId: j['memberId'],
    notes: j['notes'],
  );

  Map<String, dynamic> _activityToJson(WeeklyActivity a) => {
    'id': a.id,
    'title': a.title,
    'recurrence': a.recurrence.index,
    'weekdays': a.weekdays.map((d) => d.index).toList(),
    'time': a.time,
    'specificDate': a.specificDate?.toIso8601String(),
    'memberId': a.memberId,
    'location': a.location,
    'cancelledDates': a.cancelledDates.map((d) => d.toIso8601String()).toList(),
  };

  WeeklyActivity _activityFromJson(Map<String, dynamic> j) => WeeklyActivity(
    id: j['id'],
    title: j['title'],
    recurrence: ActivityRecurrence.values[j['recurrence']],
    weekdays: (j['weekdays'] as List)
        .map((d) => Weekday.values[d as int])
        .toList(),
    time: j['time'],
    specificDate: j['specificDate'] != null
        ? DateTime.parse(j['specificDate'])
        : null,
    memberId: j['memberId'],
    location: j['location'],
    cancelledDates: (j['cancelledDates'] as List)
        .map((d) => DateTime.parse(d as String))
        .toList(),
  );

  // ====== ברירות מחדל ======
  List<FamilyMember> _defaultMembers() => [
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

  List<FamilyEvent> _defaultEvents() => [
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

  List<WeeklyActivity> _defaultActivities() => [
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

  // ====== Getters ======
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

  List<WeeklyActivity> activitiesForDate(DateTime date) {
    return activities.where((a) => a.occursOn(date)).toList();
  }

  List<WeeklyActivity> activitiesForWeekday(int flutterWeekday) {
    return activities
        .where(
          (a) =>
              a.recurrence == ActivityRecurrence.weekly &&
              a.weekdays.any((d) => d.flutterWeekday == flutterWeekday),
        )
        .toList();
  }

  // ====== פעולות ======
  void addEvent(FamilyEvent event) {
    events.add(event);
    _save();
    notifyListeners();
  }

  void updateEvent(FamilyEvent updated) {
    final i = events.indexWhere((e) => e.id == updated.id);
    if (i != -1) {
      events[i] = updated;
      _save();
      notifyListeners();
    }
  }

  void deleteEvent(String id) {
    events.removeWhere((e) => e.id == id);
    _save();
    notifyListeners();
  }

  void addActivity(WeeklyActivity activity) {
    activities.add(activity);
    _save();
    notifyListeners();
  }

  void updateActivity(WeeklyActivity updated) {
    final i = activities.indexWhere((a) => a.id == updated.id);
    if (i != -1) {
      activities[i] = updated;
      _save();
      notifyListeners();
    }
  }

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
    _save();
    notifyListeners();
  }

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
    _save();
    notifyListeners();
  }

  void deleteActivity(String id) {
    activities.removeWhere((a) => a.id == id);
    _save();
    notifyListeners();
  }

  void addMember(FamilyMember member) {
    members.add(member);
    _save();
    notifyListeners();
  }

  void updateMember(FamilyMember updated) {
    final i = members.indexWhere((m) => m.id == updated.id);
    if (i != -1) {
      members[i] = updated;
      _save();
      notifyListeners();
    }
  }
}
