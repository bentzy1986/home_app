import 'package:flutter/material.dart';
import 'models/home_models.dart';

class HomeState extends ChangeNotifier {
  final List<Property> properties = [
    Property(
      id: 'p1',
      name: 'הבית שלנו',
      address: 'רחוב הרצל 12, תל אביב',
      type: PropertyType.owned,
      tasks: [
        MaintenanceTask(
          id: 't1',
          title: 'תיקון נזילה בכיור',
          type: MaintenanceType.plumbing,
          priority: TaskPriority.urgent,
          createdAt: DateTime.now().subtract(const Duration(days: 2)),
        ),
        MaintenanceTask(
          id: 't2',
          title: 'החלפת פילטר במזגן',
          type: MaintenanceType.ac,
          priority: TaskPriority.medium,
          createdAt: DateTime.now().subtract(const Duration(days: 5)),
        ),
        MaintenanceTask(
          id: 't3',
          title: 'צביעת קיר בסלון',
          type: MaintenanceType.painting,
          priority: TaskPriority.low,
          createdAt: DateTime.now().subtract(const Duration(days: 10)),
        ),
      ],
      bills: [
        Bill(
          id: 'b1',
          title: 'חברת החשמל',
          amount: 450,
          dueDay: '15',
          isPaid: true,
          date: DateTime.now(),
        ),
        Bill(
          id: 'b2',
          title: 'מי שקמה',
          amount: 180,
          dueDay: '10',
          isPaid: true,
          date: DateTime.now(),
        ),
        Bill(
          id: 'b3',
          title: 'ארנונה',
          amount: 820,
          dueDay: '1',
          isPaid: false,
          date: DateTime.now(),
        ),
        Bill(
          id: 'b4',
          title: 'ועד בית',
          amount: 300,
          dueDay: '1',
          isPaid: false,
          date: DateTime.now(),
        ),
      ],
      providers: [
        ServiceProvider(
          id: 'sp1',
          name: 'יוסי כהן',
          profession: 'אינסטלטור',
          phone: '050-1234567',
          rating: 4.5,
        ),
        ServiceProvider(
          id: 'sp2',
          name: 'דוד לוי',
          profession: 'חשמלאי',
          phone: '052-9876543',
          rating: 5.0,
        ),
      ],
      cleaningTasks: [
        CleaningTask(
          id: 'c1',
          title: 'שטיפת ריצפה',
          icon: Icons.cleaning_services,
        ),
        CleaningTask(
          id: 'c2',
          title: 'ניקיון מקלחות',
          icon: Icons.bathtub_rounded,
        ),
        CleaningTask(
          id: 'c3',
          title: 'ניקיון שירותים',
          icon: Icons.bathtub_rounded,
        ),
        CleaningTask(id: 'c4', title: 'החלפת מצעים', icon: Icons.bed_rounded),
        CleaningTask(id: 'c5', title: 'ריקון פחים', icon: Icons.delete_outline),
        CleaningTask(
          id: 'c6',
          title: 'כביסות',
          icon: Icons.local_laundry_service_rounded,
        ),
        CleaningTask(
          id: 'c7',
          title: 'ניקוי חלונות',
          icon: Icons.window_rounded,
        ),
        CleaningTask(
          id: 'c8',
          title: 'הכנסת כלים למדיח',
          icon: Icons.flatware_rounded,
        ),
      ],
    ),
    Property(
      id: 'p2',
      name: 'נכס להשכרה',
      address: 'רחוב ביאליק 5, רמת גן',
      type: PropertyType.rental,
      tenantName: 'משפחת ישראלי',
      rentalIncome: 4500,
      leaseEnd: DateTime(2026, 8, 31),
      tasks: [
        MaintenanceTask(
          id: 't4',
          title: 'תיקון דלת כניסה',
          type: MaintenanceType.other,
          priority: TaskPriority.high,
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
        ),
      ],
      bills: [
        Bill(
          id: 'b5',
          title: 'ארנונה',
          amount: 650,
          dueDay: '1',
          isPaid: false,
          date: DateTime.now(),
        ),
        Bill(
          id: 'b6',
          title: 'ועד בית',
          amount: 200,
          dueDay: '1',
          isPaid: true,
          date: DateTime.now(),
        ),
      ],
      providers: [],
      cleaningTasks: [],
    ),
  ];

  int _currentIndex = 0;

  Property get currentProperty => properties[_currentIndex];
  int get currentIndex => _currentIndex;

  void switchProperty(int index) {
    if (index >= 0 && index < properties.length) {
      _currentIndex = index;
      notifyListeners();
    }
  }

  // ====== נכסים ======
  void addProperty(Property property) {
    properties.add(property);
    notifyListeners();
  }

  void updateProperty(Property updated) {
    final i = properties.indexWhere((p) => p.id == updated.id);
    if (i != -1) {
      properties[i] = updated;
      notifyListeners();
    }
  }

  void deleteProperty(String id) {
    properties.removeWhere((p) => p.id == id);
    if (_currentIndex >= properties.length) {
      _currentIndex = properties.length - 1;
    }
    notifyListeners();
  }

  // ====== משימות ======
  void addTask(String propertyId, MaintenanceTask task) {
    final p = properties.firstWhere((p) => p.id == propertyId);
    p.tasks.add(task);
    notifyListeners();
  }

  void toggleTask(String propertyId, String taskId) {
    final p = properties.firstWhere((p) => p.id == propertyId);
    final t = p.tasks.firstWhere((t) => t.id == taskId);
    t.isDone = !t.isDone;
    t.completedAt = t.isDone ? DateTime.now() : null;
    notifyListeners();
  }

  void deleteTask(String propertyId, String taskId) {
    final p = properties.firstWhere((p) => p.id == propertyId);
    p.tasks.removeWhere((t) => t.id == taskId);
    notifyListeners();
  }

  // ====== חשבונות ======
  void addBill(String propertyId, Bill bill) {
    final p = properties.firstWhere((p) => p.id == propertyId);
    p.bills.add(bill);
    notifyListeners();
  }

  void toggleBill(String propertyId, String billId) {
    final p = properties.firstWhere((p) => p.id == propertyId);
    final b = p.bills.firstWhere((b) => b.id == billId);
    b.isPaid = !b.isPaid;
    notifyListeners();
  }

  void deleteBill(String propertyId, String billId) {
    final p = properties.firstWhere((p) => p.id == propertyId);
    p.bills.removeWhere((b) => b.id == billId);
    notifyListeners();
  }

  void updateBill(String propertyId, Bill updated) {
    final p = properties.firstWhere((p) => p.id == propertyId);
    final i = p.bills.indexWhere((b) => b.id == updated.id);
    if (i != -1) {
      p.bills[i] = updated;
      notifyListeners();
    }
  }

  // ====== בעלי מקצוע ======
  void addProvider(String propertyId, ServiceProvider provider) {
    final p = properties.firstWhere((p) => p.id == propertyId);
    p.providers.add(provider);
    notifyListeners();
  }

  void deleteProvider(String propertyId, String providerId) {
    final p = properties.firstWhere((p) => p.id == propertyId);
    p.providers.removeWhere((sp) => sp.id == providerId);
    notifyListeners();
  }

  void updateProvider(String propertyId, ServiceProvider updated) {
    final p = properties.firstWhere((p) => p.id == propertyId);
    final i = p.providers.indexWhere((sp) => sp.id == updated.id);
    if (i != -1) {
      p.providers[i] = updated;
      notifyListeners();
    }
  }

  // ====== ניקיון ======
  void toggleCleaning(String propertyId, String taskId) {
    final p = properties.firstWhere((p) => p.id == propertyId);
    final t = p.cleaningTasks.firstWhere((t) => t.id == taskId);
    t.isDone = !t.isDone;
    notifyListeners();
  }

  void resetCleaning(String propertyId) {
    final p = properties.firstWhere((p) => p.id == propertyId);
    for (final t in p.cleaningTasks) {
      t.isDone = false;
    }
    notifyListeners();
  }

  void addCleaningTask(String propertyId, CleaningTask task) {
    final p = properties.firstWhere((p) => p.id == propertyId);
    p.cleaningTasks.add(task);
    notifyListeners();
  }

  // סך משימות פתוחות מכל הנכסים
  int get totalOpenTasks =>
      properties.fold(0, (sum, p) => sum + p.openTasks.length);

  // סך חשבונות לא שולמו
  int get totalUnpaidBills =>
      properties.fold(0, (sum, p) => sum + p.unpaidBills.length);
}
