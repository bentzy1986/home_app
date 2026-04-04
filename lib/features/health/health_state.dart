import 'package:flutter/material.dart';
import 'models/health_models.dart';
import '../../services/storage_service.dart';

class HealthState extends ChangeNotifier {
  List<HealthMember> members = [];
  List<Appointment> appointments = [];
  List<Medication> medications = [];
  List<MedicalTest> tests = [];

  // ====== Persistence ======
  Future<void> loadFromStorage() async {
    final membersData = StorageService.loadJson('health_members');
    final appointmentsData = StorageService.loadJson('health_appointments');
    final medicationsData = StorageService.loadJson('health_medications');
    final testsData = StorageService.loadJson('health_tests');

    members = membersData != null
        ? (membersData as List).map((m) => _memberFromJson(m)).toList()
        : _defaultMembers();

    appointments = appointmentsData != null
        ? (appointmentsData as List)
              .map((a) => _appointmentFromJson(a))
              .toList()
        : _defaultAppointments();

    medications = medicationsData != null
        ? (medicationsData as List).map((m) => _medicationFromJson(m)).toList()
        : _defaultMedications();

    tests = testsData != null
        ? (testsData as List).map((t) => _testFromJson(t)).toList()
        : _defaultTests();

    notifyListeners();
  }

  Future<void> _save() async {
    await StorageService.saveJson(
      'health_members',
      members.map((m) => _memberToJson(m)).toList(),
    );
    await StorageService.saveJson(
      'health_appointments',
      appointments.map((a) => _appointmentToJson(a)).toList(),
    );
    await StorageService.saveJson(
      'health_medications',
      medications.map((m) => _medicationToJson(m)).toList(),
    );
    await StorageService.saveJson(
      'health_tests',
      tests.map((t) => _testToJson(t)).toList(),
    );
  }

  void notifyExternally() {
    _save();
    notifyListeners();
  }

  // ====== Serialization ======
  Map<String, dynamic> _memberToJson(HealthMember m) => {
    'id': m.id,
    'name': m.name,
    'color': m.color.toARGB32(),
    'birthDate': m.birthDate?.toIso8601String(),
  };

  HealthMember _memberFromJson(Map<String, dynamic> j) => HealthMember(
    id: j['id'],
    name: j['name'],
    color: Color(j['color']),
    birthDate: j['birthDate'] != null ? DateTime.parse(j['birthDate']) : null,
  );

  Map<String, dynamic> _appointmentToJson(Appointment a) => {
    'id': a.id,
    'title': a.title,
    'type': a.type.index,
    'dateTime': a.dateTime.toIso8601String(),
    'doctorName': a.doctorName,
    'location': a.location,
    'memberId': a.memberId,
    'isDone': a.isDone,
    'notes': a.notes,
  };

  Appointment _appointmentFromJson(Map<String, dynamic> j) => Appointment(
    id: j['id'],
    title: j['title'],
    type: DoctorType.values[j['type']],
    dateTime: DateTime.parse(j['dateTime']),
    doctorName: j['doctorName'],
    location: j['location'],
    memberId: j['memberId'],
    isDone: j['isDone'] ?? false,
    notes: j['notes'],
  );

  Map<String, dynamic> _medicationToJson(Medication m) => {
    'id': m.id,
    'name': m.name,
    'dosage': m.dosage,
    'frequency': m.frequency.index,
    'memberId': m.memberId,
    'isActive': m.isActive,
    'startDate': m.startDate.toIso8601String(),
    'endDate': m.endDate?.toIso8601String(),
    'notes': m.notes,
  };

  Medication _medicationFromJson(Map<String, dynamic> j) => Medication(
    id: j['id'],
    name: j['name'],
    dosage: j['dosage'],
    frequency: MedicationFrequency.values[j['frequency']],
    memberId: j['memberId'],
    isActive: j['isActive'] ?? true,
    startDate: DateTime.parse(j['startDate']),
    endDate: j['endDate'] != null ? DateTime.parse(j['endDate']) : null,
    notes: j['notes'],
  );

  Map<String, dynamic> _testToJson(MedicalTest t) => {
    'id': t.id,
    'title': t.title,
    'type': t.type.index,
    'date': t.date.toIso8601String(),
    'memberId': t.memberId,
    'result': t.result,
    'isDone': t.isDone,
    'notes': t.notes,
  };

  MedicalTest _testFromJson(Map<String, dynamic> j) => MedicalTest(
    id: j['id'],
    title: j['title'],
    type: TestType.values[j['type']],
    date: DateTime.parse(j['date']),
    memberId: j['memberId'],
    result: j['result'],
    isDone: j['isDone'] ?? false,
    notes: j['notes'],
  );

  // ====== ברירות מחדל ======
  List<HealthMember> _defaultMembers() => [
    HealthMember(
      id: 'm1',
      name: 'אבא',
      color: const Color(0xFF2193B0),
      birthDate: DateTime(1986, 5, 12),
    ),
    HealthMember(
      id: 'm2',
      name: 'אמא',
      color: const Color(0xFFEB3349),
      birthDate: DateTime(1988, 8, 3),
    ),
    HealthMember(
      id: 'm3',
      name: 'ילד 1',
      color: const Color(0xFF11998E),
      birthDate: DateTime(2016, 11, 20),
    ),
    HealthMember(
      id: 'm4',
      name: 'ילד 2',
      color: const Color(0xFFF7971E),
      birthDate: DateTime(2019, 3, 7),
    ),
  ];

  List<Appointment> _defaultAppointments() => [
    Appointment(
      id: 'a1',
      title: 'רופא משפחה',
      type: DoctorType.gp,
      dateTime: DateTime.now().add(const Duration(days: 1)),
      doctorName: 'ד"ר כהן',
      location: 'קופת חולים מרכז',
      memberId: 'm1',
    ),
    Appointment(
      id: 'a2',
      title: 'רופא שיניים',
      type: DoctorType.dentist,
      dateTime: DateTime.now().add(const Duration(days: 7)),
      doctorName: 'ד"ר לוי',
      memberId: 'm3',
    ),
    Appointment(
      id: 'a3',
      title: 'בדיקת עיניים',
      type: DoctorType.eye,
      dateTime: DateTime.now().add(const Duration(days: 14)),
      memberId: 'm2',
    ),
  ];

  List<Medication> _defaultMedications() => [
    Medication(
      id: 'med1',
      name: 'ויטמין D',
      dosage: '1000 יחב"ל',
      frequency: MedicationFrequency.daily,
      memberId: 'm1',
      startDate: DateTime(2026, 1, 1),
    ),
    Medication(
      id: 'med2',
      name: 'אומגה 3',
      dosage: '1 כמוסה',
      frequency: MedicationFrequency.daily,
      memberId: 'm2',
      startDate: DateTime(2026, 2, 1),
    ),
  ];

  List<MedicalTest> _defaultTests() => [
    MedicalTest(
      id: 'tst1',
      title: 'בדיקת דם שנתית',
      type: TestType.blood,
      date: DateTime.now().add(const Duration(days: 10)),
      memberId: 'm1',
    ),
    MedicalTest(
      id: 'tst2',
      title: 'צילום חזה',
      type: TestType.imaging,
      date: DateTime.now().subtract(const Duration(days: 30)),
      memberId: 'm1',
      result: 'תקין',
      isDone: true,
    ),
  ];

  // ====== Getters ======
  HealthMember? getMember(String? id) {
    if (id == null) return null;
    try {
      return members.firstWhere((m) => m.id == id);
    } catch (_) {
      return null;
    }
  }

  List<Appointment> get upcomingAppointments {
    return appointments
        .where((a) => !a.isDone && a.dateTime.isAfter(DateTime.now()))
        .toList()
      ..sort((a, b) => a.dateTime.compareTo(b.dateTime));
  }

  List<Appointment> appointmentsForMember(String memberId) {
    return appointments.where((a) => a.memberId == memberId).toList()
      ..sort((a, b) => a.dateTime.compareTo(b.dateTime));
  }

  List<Medication> get activeMedications =>
      medications.where((m) => m.isActive).toList();

  List<MedicalTest> get pendingTests =>
      tests.where((t) => !t.isDone).toList()
        ..sort((a, b) => a.date.compareTo(b.date));

  // ====== פעולות בני משפחה ======
  void addMember(HealthMember member) {
    members.add(member);
    _save();
    notifyListeners();
  }

  void updateMember(HealthMember updated) {
    final i = members.indexWhere((m) => m.id == updated.id);
    if (i != -1) {
      members[i] = updated;
      _save();
      notifyListeners();
    }
  }

  void deleteMember(String id) {
    members.removeWhere((m) => m.id == id);
    _save();
    notifyListeners();
  }

  // ====== פעולות תורים ======
  void addAppointment(Appointment a) {
    appointments.add(a);
    _save();
    notifyListeners();
  }

  void toggleAppointment(String id) {
    final a = appointments.firstWhere((a) => a.id == id);
    a.isDone = !a.isDone;
    _save();
    notifyListeners();
  }

  void deleteAppointment(String id) {
    appointments.removeWhere((a) => a.id == id);
    _save();
    notifyListeners();
  }

  void updateAppointment(Appointment updated) {
    final i = appointments.indexWhere((a) => a.id == updated.id);
    if (i != -1) {
      appointments[i] = updated;
      _save();
      notifyListeners();
    }
  }

  // ====== פעולות תרופות ======
  void addMedication(Medication m) {
    medications.add(m);
    _save();
    notifyListeners();
  }

  void toggleMedication(String id) {
    final m = medications.firstWhere((m) => m.id == id);
    m.isActive = !m.isActive;
    _save();
    notifyListeners();
  }

  void deleteMedication(String id) {
    medications.removeWhere((m) => m.id == id);
    _save();
    notifyListeners();
  }

  // ====== פעולות בדיקות ======
  void addTest(MedicalTest t) {
    tests.add(t);
    _save();
    notifyListeners();
  }

  void completeTest(String id, String result) {
    final t = tests.firstWhere((t) => t.id == id);
    t.isDone = true;
    t.result = result;
    _save();
    notifyListeners();
  }

  void deleteTest(String id) {
    tests.removeWhere((t) => t.id == id);
    _save();
    notifyListeners();
  }
}
