import 'package:flutter/material.dart';
import 'models/car_models.dart';
import '../../services/storage_service.dart';

class CarState extends ChangeNotifier {
  List<CarModel> cars = [];
  int _currentIndex = 0;

  CarModel get currentCar => cars[_currentIndex];
  int get currentIndex => _currentIndex;

  // ====== Persistence ======
  Future<void> loadFromStorage() async {
    final carsData = StorageService.loadJson('car_cars');

    cars = carsData != null
        ? (carsData as List).map((c) => _carFromJson(c)).toList()
        : _defaultCars();

    if (_currentIndex >= cars.length) _currentIndex = 0;
    notifyListeners();
  }

  Future<void> _save() async {
    await StorageService.saveJson(
      'car_cars',
      cars.map((c) => _carToJson(c)).toList(),
    );
  }

  // ====== Serialization ======
  Map<String, dynamic> _carToJson(CarModel c) => {
    'id': c.id,
    'nickname': c.nickname,
    'plate': c.plate,
    'brand': c.brand,
    'model': c.model,
    'year': c.year,
    'fuelType': c.fuelType.index,
    'currentMileage': c.currentMileage,
    'documents': c.documents.map((d) => _docToJson(d)).toList(),
    'serviceHistory': c.serviceHistory.map((s) => _recordToJson(s)).toList(),
    'reminders': c.reminders.map((r) => _reminderToJson(r)).toList(),
    'attachments': c.attachments.map((a) => _attachmentToJson(a)).toList(),
  };

  CarModel _carFromJson(Map<String, dynamic> j) => CarModel(
    id: j['id'],
    nickname: j['nickname'],
    plate: j['plate'],
    brand: j['brand'],
    model: j['model'],
    year: j['year'],
    fuelType: FuelType.values[j['fuelType']],
    currentMileage: j['currentMileage'],
    documents: (j['documents'] as List).map((d) => _docFromJson(d)).toList(),
    serviceHistory: (j['serviceHistory'] as List)
        .map((s) => _recordFromJson(s))
        .toList(),
    reminders: (j['reminders'] as List)
        .map((r) => _reminderFromJson(r))
        .toList(),
    attachments: j['attachments'] != null
        ? (j['attachments'] as List).map((a) => _attachmentFromJson(a)).toList()
        : [],
  );

  Map<String, dynamic> _docToJson(CarDocument d) => {
    'id': d.id,
    'title': d.title,
    'expiryDate': d.expiryDate.toIso8601String(),
    'iconCode': d.icon.codePoint,
    'colorValue': d.color.toARGB32(),
  };

  CarDocument _docFromJson(Map<String, dynamic> j) => CarDocument(
    id: j['id'],
    title: j['title'],
    expiryDate: DateTime.parse(j['expiryDate']),
    icon: IconData(j['iconCode'], fontFamily: 'MaterialIcons'),
    color: Color(j['colorValue']),
  );

  Map<String, dynamic> _recordToJson(ServiceRecord s) => {
    'id': s.id,
    'title': s.title,
    'type': s.type.index,
    'date': s.date.toIso8601String(),
    'cost': s.cost,
    'mileage': s.mileage,
    'garage': s.garage,
    'notes': s.notes,
  };

  ServiceRecord _recordFromJson(Map<String, dynamic> j) => ServiceRecord(
    id: j['id'],
    title: j['title'],
    type: ServiceType.values[j['type']],
    date: DateTime.parse(j['date']),
    cost: (j['cost'] as num).toDouble(),
    mileage: j['mileage'],
    garage: j['garage'],
    notes: j['notes'],
  );

  Map<String, dynamic> _reminderToJson(ServiceReminder r) => {
    'id': r.id,
    'title': r.title,
    'type': r.type.index,
    'dueDate': r.dueDate.toIso8601String(),
    'dueMileage': r.dueMileage,
    'isDone': r.isDone,
  };

  ServiceReminder _reminderFromJson(Map<String, dynamic> j) => ServiceReminder(
    id: j['id'],
    title: j['title'],
    type: ServiceType.values[j['type']],
    dueDate: DateTime.parse(j['dueDate']),
    dueMileage: j['dueMileage'],
    isDone: j['isDone'] ?? false,
  );

  Map<String, dynamic> _attachmentToJson(CarAttachment a) => {
    'id': a.id,
    'title': a.title,
    'filePath': a.filePath,
    'isImage': a.isImage,
    'createdAt': a.createdAt.toIso8601String(),
    'relatedId': a.relatedId,
  };

  CarAttachment _attachmentFromJson(Map<String, dynamic> j) => CarAttachment(
    id: j['id'],
    title: j['title'],
    filePath: j['filePath'],
    isImage: j['isImage'] ?? true,
    createdAt: DateTime.parse(j['createdAt']),
    relatedId: j['relatedId'],
  );

  // ====== ברירות מחדל ======
  List<CarModel> _defaultCars() => [
    CarModel(
      id: 'c1',
      nickname: 'יונדאי משפחתית',
      plate: '12-345-67',
      brand: 'Hyundai',
      model: 'Tucson',
      year: 2020,
      fuelType: FuelType.petrol95,
      currentMileage: 45000,
      documents: [
        CarDocument(
          id: 'd1',
          title: 'טסט שנתי',
          expiryDate: DateTime(2026, 8, 15),
          icon: Icons.fact_check_rounded,
          color: Colors.orange,
        ),
        CarDocument(
          id: 'd2',
          title: 'רישיון רכב',
          expiryDate: DateTime(2026, 8, 15),
          icon: Icons.assignment_rounded,
          color: Colors.blue,
        ),
        CarDocument(
          id: 'd3',
          title: 'ביטוח חובה',
          expiryDate: DateTime(2027, 1, 1),
          icon: Icons.security_rounded,
          color: Colors.green,
        ),
        CarDocument(
          id: 'd4',
          title: 'ביטוח מקיף',
          expiryDate: DateTime(2027, 1, 1),
          icon: Icons.shield_rounded,
          color: Colors.teal,
        ),
      ],
      serviceHistory: [
        ServiceRecord(
          id: 's1',
          title: 'טיפול 45,000',
          type: ServiceType.oilChange,
          date: DateTime(2026, 2, 10),
          cost: 850,
          mileage: 45000,
          garage: 'מוסך המרכז',
        ),
        ServiceRecord(
          id: 's2',
          title: 'החלפת צמיגים קדמיים',
          type: ServiceType.tires,
          date: DateTime(2025, 11, 5),
          cost: 1200,
          mileage: 42000,
          garage: 'צמיגי העיר',
        ),
      ],
      reminders: [
        ServiceReminder(
          id: 'r1',
          title: 'טיפול 50,000',
          type: ServiceType.oilChange,
          dueDate: DateTime(2026, 8, 1),
          dueMileage: 50000,
        ),
      ],
      attachments: [],
    ),
    CarModel(
      id: 'c2',
      nickname: 'קיה פיקנטו',
      plate: '99-888-77',
      brand: 'Kia',
      model: 'Picanto',
      year: 2019,
      fuelType: FuelType.petrol95,
      currentMileage: 62000,
      documents: [
        CarDocument(
          id: 'd5',
          title: 'טסט שנתי',
          expiryDate: DateTime(2026, 11, 20),
          icon: Icons.fact_check_rounded,
          color: Colors.orange,
        ),
        CarDocument(
          id: 'd6',
          title: 'ביטוח חובה',
          expiryDate: DateTime(2026, 5, 10),
          icon: Icons.security_rounded,
          color: Colors.green,
        ),
        CarDocument(
          id: 'd7',
          title: 'ביטוח מקיף',
          expiryDate: DateTime(2026, 5, 10),
          icon: Icons.shield_rounded,
          color: Colors.teal,
        ),
      ],
      serviceHistory: [
        ServiceRecord(
          id: 's3',
          title: 'החלפת מצבר',
          type: ServiceType.battery,
          date: DateTime(2025, 8, 20),
          cost: 650,
          mileage: 60000,
          garage: 'חשמלאי רכב',
        ),
      ],
      reminders: [
        ServiceReminder(
          id: 'r2',
          title: 'טיפול 65,000',
          type: ServiceType.oilChange,
          dueDate: DateTime(2026, 6, 1),
          dueMileage: 65000,
        ),
      ],
      attachments: [],
    ),
  ];

  // ====== פעולות ======
  void switchCar(int index) {
    if (index >= 0 && index < cars.length) {
      _currentIndex = index;
      notifyListeners();
    }
  }

  void addCar(CarModel car) {
    cars.add(car);
    _save();
    notifyListeners();
  }

  void updateCar(CarModel updated) {
    final i = cars.indexWhere((c) => c.id == updated.id);
    if (i != -1) {
      cars[i] = updated;
      _save();
      notifyListeners();
    }
  }

  void deleteCar(String id) {
    cars.removeWhere((c) => c.id == id);
    if (_currentIndex >= cars.length) _currentIndex = cars.length - 1;
    _save();
    notifyListeners();
  }

  void addServiceRecord(String carId, ServiceRecord record) {
    final car = cars.firstWhere((c) => c.id == carId);
    car.serviceHistory.insert(0, record);
    _save();
    notifyListeners();
  }

  void deleteServiceRecord(String carId, String recordId) {
    final car = cars.firstWhere((c) => c.id == carId);
    car.serviceHistory.removeWhere((s) => s.id == recordId);
    _save();
    notifyListeners();
  }

  void addReminder(String carId, ServiceReminder reminder) {
    final car = cars.firstWhere((c) => c.id == carId);
    car.reminders.add(reminder);
    _save();
    notifyListeners();
  }

  void toggleReminder(String carId, String reminderId) {
    final car = cars.firstWhere((c) => c.id == carId);
    final reminder = car.reminders.firstWhere((r) => r.id == reminderId);
    reminder.isDone = !reminder.isDone;
    _save();
    notifyListeners();
  }

  void deleteReminder(String carId, String reminderId) {
    final car = cars.firstWhere((c) => c.id == carId);
    car.reminders.removeWhere((r) => r.id == reminderId);
    _save();
    notifyListeners();
  }

  void updateDocument(String carId, CarDocument updated) {
    final car = cars.firstWhere((c) => c.id == carId);
    final i = car.documents.indexWhere((d) => d.id == updated.id);
    if (i != -1) {
      car.documents[i] = updated;
      _save();
      notifyListeners();
    }
  }

  void updateMileage(String carId, int mileage) {
    final car = cars.firstWhere((c) => c.id == carId);
    car.currentMileage = mileage;
    _save();
    notifyListeners();
  }

  // ====== פעולות מסמכים/תמונות ======
  void addAttachment(String carId, CarAttachment attachment) {
    final car = cars.firstWhere((c) => c.id == carId);
    car.attachments.add(attachment);
    _save();
    notifyListeners();
  }

  void deleteAttachment(String carId, String attachmentId) {
    final car = cars.firstWhere((c) => c.id == carId);
    car.attachments.removeWhere((a) => a.id == attachmentId);
    _save();
    notifyListeners();
  }

  List<Map<String, dynamic>> get allUrgentReminders {
    final result = <Map<String, dynamic>>[];
    for (final car in cars) {
      for (final r in car.activeReminders) {
        if (r.isUrgent || r.isOverdue) {
          result.add({'car': car, 'reminder': r});
        }
      }
    }
    return result;
  }

  List<Map<String, dynamic>> get allUrgentDocuments {
    final result = <Map<String, dynamic>>[];
    for (final car in cars) {
      for (final d in car.urgentDocuments) {
        result.add({'car': car, 'document': d});
      }
    }
    return result;
  }
}
