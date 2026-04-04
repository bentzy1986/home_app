import 'package:flutter/material.dart';
import 'models/home_models.dart';
import '../../services/storage_service.dart';

class HomeState extends ChangeNotifier {
  List<Property> properties = [];
  int _currentIndex = 0;

  Property get currentProperty => properties[_currentIndex];
  int get currentIndex => _currentIndex;

  // ====== Persistence ======
  Future<void> loadFromStorage() async {
    final propertiesData = StorageService.loadJson('home_properties');

    properties = propertiesData != null
        ? (propertiesData as List).map((p) => _propertyFromJson(p)).toList()
        : _defaultProperties();

    if (_currentIndex >= properties.length) _currentIndex = 0;
    notifyListeners();
  }

  Future<void> _save() async {
    await StorageService.saveJson(
      'home_properties',
      properties.map((p) => _propertyToJson(p)).toList(),
    );
  }

  // ====== Serialization ======
  Map<String, dynamic> _propertyToJson(Property p) => {
    'id': p.id,
    'name': p.name,
    'address': p.address,
    'type': p.type.index,
    'tenantName': p.tenantName,
    'rentalIncome': p.rentalIncome,
    'leaseEnd': p.leaseEnd?.toIso8601String(),
    'tasks': p.tasks.map((t) => _taskToJson(t)).toList(),
    'bills': p.bills.map((b) => _billToJson(b)).toList(),
    'providers': p.providers.map((s) => _providerToJson(s)).toList(),
    'cleaningTasks': p.cleaningTasks.map((c) => _cleaningToJson(c)).toList(),
  };

  Property _propertyFromJson(Map<String, dynamic> j) => Property(
    id: j['id'],
    name: j['name'],
    address: j['address'],
    type: PropertyType.values[j['type']],
    tenantName: j['tenantName'],
    rentalIncome: j['rentalIncome']?.toDouble(),
    leaseEnd: j['leaseEnd'] != null ? DateTime.parse(j['leaseEnd']) : null,
    tasks: (j['tasks'] as List).map((t) => _taskFromJson(t)).toList(),
    bills: (j['bills'] as List).map((b) => _billFromJson(b)).toList(),
    providers: (j['providers'] as List)
        .map((s) => _providerFromJson(s))
        .toList(),
    cleaningTasks: (j['cleaningTasks'] as List)
        .map((c) => _cleaningFromJson(c))
        .toList(),
  );

  Map<String, dynamic> _taskToJson(MaintenanceTask t) => {
    'id': t.id,
    'title': t.title,
    'type': t.type.index,
    'priority': t.priority.index,
    'isDone': t.isDone,
    'createdAt': t.createdAt.toIso8601String(),
    'completedAt': t.completedAt?.toIso8601String(),
    'cost': t.cost,
    'notes': t.notes,
    'contractor': t.contractor,
  };

  MaintenanceTask _taskFromJson(Map<String, dynamic> j) => MaintenanceTask(
    id: j['id'],
    title: j['title'],
    type: MaintenanceType.values[j['type']],
    priority: TaskPriority.values[j['priority']],
    isDone: j['isDone'] ?? false,
    createdAt: DateTime.parse(j['createdAt']),
    completedAt: j['completedAt'] != null
        ? DateTime.parse(j['completedAt'])
        : null,
    cost: j['cost']?.toDouble(),
    notes: j['notes'],
    contractor: j['contractor'],
  );

  Map<String, dynamic> _billToJson(Bill b) => {
    'id': b.id,
    'title': b.title,
    'amount': b.amount,
    'dueDay': b.dueDay,
    'isPaid': b.isPaid,
    'date': b.date.toIso8601String(),
  };

  Bill _billFromJson(Map<String, dynamic> j) => Bill(
    id: j['id'],
    title: j['title'],
    amount: (j['amount'] as num).toDouble(),
    dueDay: j['dueDay'],
    isPaid: j['isPaid'] ?? false,
    date: DateTime.parse(j['date']),
  );

  Map<String, dynamic> _providerToJson(ServiceProvider s) => {
    'id': s.id,
    'name': s.name,
    'profession': s.profession,
    'phone': s.phone,
    'notes': s.notes,
    'rating': s.rating,
  };

  ServiceProvider _providerFromJson(Map<String, dynamic> j) => ServiceProvider(
    id: j['id'],
    name: j['name'],
    profession: j['profession'],
    phone: j['phone'],
    notes: j['notes'],
    rating: j['rating']?.toDouble(),
  );

  Map<String, dynamic> _cleaningToJson(CleaningTask c) => {
    'id': c.id,
    'title': c.title,
    'isDone': c.isDone,
    'iconCode': c.icon.codePoint,
  };

  CleaningTask _cleaningFromJson(Map<String, dynamic> j) => CleaningTask(
    id: j['id'],
    title: j['title'],
    isDone: j['isDone'] ?? false,
    icon: IconData(j['iconCode'], fontFamily: 'MaterialIcons'),
  );

  // ====== ברירות מחדל ======
  List<Property> _defaultProperties() => [
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

  // ====== פעולות ======
  void switchProperty(int index) {
    if (index >= 0 && index < properties.length) {
      _currentIndex = index;
      notifyListeners();
    }
  }

  void addProperty(Property property) {
    properties.add(property);
    _save();
    notifyListeners();
  }

  void updateProperty(Property updated) {
    final i = properties.indexWhere((p) => p.id == updated.id);
    if (i != -1) {
      properties[i] = updated;
      _save();
      notifyListeners();
    }
  }

  void deleteProperty(String id) {
    properties.removeWhere((p) => p.id == id);
    if (_currentIndex >= properties.length) {
      _currentIndex = properties.length - 1;
    }
    _save();
    notifyListeners();
  }

  void addTask(String propertyId, MaintenanceTask task) {
    final p = properties.firstWhere((p) => p.id == propertyId);
    p.tasks.add(task);
    _save();
    notifyListeners();
  }

  void toggleTask(String propertyId, String taskId) {
    final p = properties.firstWhere((p) => p.id == propertyId);
    final t = p.tasks.firstWhere((t) => t.id == taskId);
    t.isDone = !t.isDone;
    t.completedAt = t.isDone ? DateTime.now() : null;
    _save();
    notifyListeners();
  }

  void deleteTask(String propertyId, String taskId) {
    final p = properties.firstWhere((p) => p.id == propertyId);
    p.tasks.removeWhere((t) => t.id == taskId);
    _save();
    notifyListeners();
  }

  void addBill(String propertyId, Bill bill) {
    final p = properties.firstWhere((p) => p.id == propertyId);
    p.bills.add(bill);
    _save();
    notifyListeners();
  }

  void toggleBill(String propertyId, String billId) {
    final p = properties.firstWhere((p) => p.id == propertyId);
    final b = p.bills.firstWhere((b) => b.id == billId);
    b.isPaid = !b.isPaid;
    _save();
    notifyListeners();
  }

  void deleteBill(String propertyId, String billId) {
    final p = properties.firstWhere((p) => p.id == propertyId);
    p.bills.removeWhere((b) => b.id == billId);
    _save();
    notifyListeners();
  }

  void updateBill(String propertyId, Bill updated) {
    final p = properties.firstWhere((p) => p.id == propertyId);
    final i = p.bills.indexWhere((b) => b.id == updated.id);
    if (i != -1) {
      p.bills[i] = updated;
      _save();
      notifyListeners();
    }
  }

  void addProvider(String propertyId, ServiceProvider provider) {
    final p = properties.firstWhere((p) => p.id == propertyId);
    p.providers.add(provider);
    _save();
    notifyListeners();
  }

  void deleteProvider(String propertyId, String providerId) {
    final p = properties.firstWhere((p) => p.id == propertyId);
    p.providers.removeWhere((sp) => sp.id == providerId);
    _save();
    notifyListeners();
  }

  void updateProvider(String propertyId, ServiceProvider updated) {
    final p = properties.firstWhere((p) => p.id == propertyId);
    final i = p.providers.indexWhere((sp) => sp.id == updated.id);
    if (i != -1) {
      p.providers[i] = updated;
      _save();
      notifyListeners();
    }
  }

  void toggleCleaning(String propertyId, String taskId) {
    final p = properties.firstWhere((p) => p.id == propertyId);
    final t = p.cleaningTasks.firstWhere((t) => t.id == taskId);
    t.isDone = !t.isDone;
    _save();
    notifyListeners();
  }

  void resetCleaning(String propertyId) {
    final p = properties.firstWhere((p) => p.id == propertyId);
    for (final t in p.cleaningTasks) {
      t.isDone = false;
    }
    _save();
    notifyListeners();
  }

  void addCleaningTask(String propertyId, CleaningTask task) {
    final p = properties.firstWhere((p) => p.id == propertyId);
    p.cleaningTasks.add(task);
    _save();
    notifyListeners();
  }

  int get totalOpenTasks =>
      properties.fold(0, (sum, p) => sum + p.openTasks.length);

  int get totalUnpaidBills =>
      properties.fold(0, (sum, p) => sum + p.unpaidBills.length);
}
