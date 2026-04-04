import 'package:flutter/material.dart';
import 'models/health_models.dart';

class HealthState extends ChangeNotifier {
  final List<HealthMember> members = [
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

  final List<Appointment> appointments = [
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

  final List<Medication> medications = [
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

  final List<MedicalTest> tests = [
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

  HealthMember? getMember(String? id) {
    if (id == null) return null;
    try {
      return members.firstWhere((m) => m.id == id);
    } catch (_) {
      return null;
    }
  }

  // תורים קרובים
  List<Appointment> get upcomingAppointments {
    return appointments
        .where((a) => !a.isDone && a.dateTime.isAfter(DateTime.now()))
        .toList()
      ..sort((a, b) => a.dateTime.compareTo(b.dateTime));
  }

  // תורים לפי חבר משפחה
  List<Appointment> appointmentsForMember(String memberId) {
    return appointments.where((a) => a.memberId == memberId).toList()
      ..sort((a, b) => a.dateTime.compareTo(b.dateTime));
  }

  // תרופות פעילות
  List<Medication> get activeMedications =>
      medications.where((m) => m.isActive).toList();

  // בדיקות ממתינות
  List<MedicalTest> get pendingTests =>
      tests.where((t) => !t.isDone).toList()
        ..sort((a, b) => a.date.compareTo(b.date));

  // ====== פעולות תורים ======
  void addAppointment(Appointment a) {
    appointments.add(a);
    notifyListeners();
  }

  void toggleAppointment(String id) {
    final a = appointments.firstWhere((a) => a.id == id);
    a.isDone = !a.isDone;
    notifyListeners();
  }

  void deleteAppointment(String id) {
    appointments.removeWhere((a) => a.id == id);
    notifyListeners();
  }

  void updateAppointment(Appointment updated) {
    final i = appointments.indexWhere((a) => a.id == updated.id);
    if (i != -1) {
      appointments[i] = updated;
      notifyListeners();
    }
  }

  // ====== פעולות תרופות ======
  void addMedication(Medication m) {
    medications.add(m);
    notifyListeners();
  }

  void toggleMedication(String id) {
    final m = medications.firstWhere((m) => m.id == id);
    m.isActive = !m.isActive;
    notifyListeners();
  }

  void deleteMedication(String id) {
    medications.removeWhere((m) => m.id == id);
    notifyListeners();
  }

  // ====== פעולות בדיקות ======
  void addTest(MedicalTest t) {
    tests.add(t);
    notifyListeners();
  }

  void completeTest(String id, String result) {
    final t = tests.firstWhere((t) => t.id == id);
    t.isDone = true;
    t.result = result;
    notifyListeners();
  }

  void deleteTest(String id) {
    tests.removeWhere((t) => t.id == id);
    notifyListeners();
  }
}
